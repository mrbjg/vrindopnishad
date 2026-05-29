import { supabase } from '../lib/supabase';
import { mockApiService } from './mockData';
import { auth, contentDb } from '../firebase';
import { ref, get } from 'firebase/database';
import { 
  signInWithEmailAndPassword, 
  createUserWithEmailAndPassword, 
  signInWithPopup, 
  GoogleAuthProvider 
} from 'firebase/auth';
import { transliterate } from '../utils/transliterate';

const USE_MOCK = process.env.REACT_APP_DEMO_MODE === 'true';
const CACHE_PREFIX = 'sv_cache_';
const CACHE_EXPIRY = 30 * 60 * 1000;

// Module-scoped in-memory cache for all items and metadata
let memoryCachedItems = null;
let memoryLastUpdated = '1970-01-01T00:00:00.000Z';
let memoryCategoryCache = {};
let lastSyncTime = 0;

// Fast numeric date sorter to sort database once in O(N log N) and avoid redundant sorting
const ensureSorted = (items) => {
  if (!items || !Array.isArray(items)) return [];
  items.forEach(item => {
    if (item && !item._created_time) {
      item._created_time = item.created_at ? new Date(item.created_at).getTime() : 0;
    }
  });
  return items.sort((a, b) => b._created_time - a._created_time);
};

if (typeof window !== 'undefined') {
  window.addEventListener('storage', (e) => {
    if (e.key === 'vrindopnishad_all_content_cache') {
      try {
        memoryCachedItems = e.newValue ? ensureSorted(JSON.parse(e.newValue)) : null;
        memoryCategoryCache = {}; // invalidate categorized caches
        const time = localStorage.getItem('vrindopnishad_all_content_last_updated');
        if (time) memoryLastUpdated = time;
      } catch (err) {
        memoryCachedItems = null;
      }
    }
  });
}

// Helper to generate a URL-friendly Hinglish slug from a title (matches brajrasik.org SEO)
const generateSlug = (text) => {
  if (!text) return '';
  const transliterated = transliterate(text);
  return transliterated
    .toString()
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9\s-]/g, '') // Keep letters, numbers, spaces, hyphens only
    .replace(/\s+/g, '-')         // Spaces to hyphens
    .replace(/--+/g, '-')         // Collapse multiple hyphens
    .replace(/^-+/, '')            // Trim leading
    .replace(/-+$/, '');           // Trim trailing
};

const setCache = (key, data) => {
    try {
        localStorage.setItem(CACHE_PREFIX + key, JSON.stringify({
            timestamp: Date.now(),
            data: data
        }));
    } catch (e) {}
};

const getCache = (key) => {
    try {
        const cached = localStorage.getItem(CACHE_PREFIX + key);
        if (!cached) return null;
        const { timestamp, data } = JSON.parse(cached);
        if (Date.now() - timestamp > CACHE_EXPIRY) {
            localStorage.removeItem(CACHE_PREFIX + key);
            return null;
        }
        return data;
    } catch (e) { return null; }
};

// Smart client-side categorizer to map generic DB categories into Shlokas, Strotras, and Poems
const classifyItemCategory = (item) => {
  if (!item) return 'poem';
  const rawCat = (item.category || '').toLowerCase().trim();
  
  if (rawCat === 'saint' || rawCat === 'dham') {
    return rawCat;
  }
  
  if (rawCat === 'shloka' || rawCat === 'shlokas') {
    return 'shloka';
  }
  if (rawCat === 'strotra' || rawCat === 'strotras' || rawCat === 'stotra' || rawCat === 'stotras') {
    return 'strotra';
  }
  if (rawCat === 'poem' || rawCat === 'poems' || rawCat === 'poetry') {
    return 'poem';
  }

  const title = (item.title || '').toLowerCase();
  const sanskrit = (item.sanskrit_text || '').toLowerCase();
  
  // 1. Check if it's a Strotra (e.g. Strotram, Ashtakam, Shatakam, Mahimamritam)
  if (
    title.includes('स्तोत्र') || title.includes('strotra') || title.includes('stotra') ||
    title.includes('शतक') || title.includes('shatak') ||
    title.includes('अष्टक') || title.includes('ashtak') ||
    title.includes('महिमामृत') || title.includes('mahimamrit') ||
    title.includes('सुधानिधि') || title.includes('sudhanidhi') ||
    title.includes('सहस्रनाम') || title.includes('sahasranam') ||
    sanskrit.includes('स्तोत्र') || sanskrit.includes('strotra') || sanskrit.includes('stotra')
  ) {
    return 'strotra';
  }
  
  // 2. Check if it's a Shloka (Sanskrit verses from scriptures like Gita, Upanishad, Samhitas)
  const hasSanskritText = sanskrit.trim().length > 10 && 
    (sanskrit.includes('॥') || sanskrit.includes('।') || sanskrit.includes('ॐ') || !/[a-z]{5,}/.test(sanskrit));
  
  const isScriptureBook = title.includes('gita') || title.includes('गीता') || 
    title.includes('upnishad') || title.includes('उपनिषद') || 
    title.includes('samhita') || title.includes('संहिता') || 
    title.includes('purana') || title.includes('पुराण') ||
    title.includes('shloka') || title.includes('श्लोक');

  if (isScriptureBook || hasSanskritText) {
    return 'shloka';
  }
  
  // 3. Fallback to Poem (vaani pads, dohas, sakhis, savaiyas, etc.)
  return 'poem';
};

const fetchStaticBackup = async () => {
  try {
    const res = await fetch('/data/content_backup.json');
    if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
    return await res.json();
  } catch (e) {
    console.warn("Failed to fetch static backup content, using empty array:", e);
    return [];
  }
};

export const apiService = {
  getCachedData: (key) => getCache(key),
  getMemoryCachedItems: () => memoryCachedItems,
  getMemoryCachedCategoryItems: (category) => {
    if (!category || !memoryCachedItems) return [];
    const targetCat = category.toLowerCase().trim();
    if (!memoryCategoryCache[targetCat]) {
      memoryCategoryCache[targetCat] = memoryCachedItems.filter(
        item => item.category?.toLowerCase() === targetCat
      );
    }
    return memoryCategoryCache[targetCat];
  },

  // Content APIs
  getAllContent: async (category = null, limit = 50) => {
    // 1. Check if we have the global cache in memory first
    let cachedItems = [];
    let lastUpdated = '1970-01-01T00:00:00.000Z';
    
    if (memoryCachedItems && memoryCachedItems.length > 0) {
      cachedItems = memoryCachedItems;
      lastUpdated = memoryLastUpdated;
    } else {
      try {
        const localCached = localStorage.getItem('vrindopnishad_all_content_cache');
        const cachedTime = localStorage.getItem('vrindopnishad_all_content_last_updated');
        if (localCached) {
          cachedItems = ensureSorted(JSON.parse(localCached));
          memoryCachedItems = cachedItems;
        }
        if (cachedTime) {
          lastUpdated = cachedTime;
          memoryLastUpdated = cachedTime;
        }
      } catch (e) {
        console.warn('Failed to parse global cache:', e);
      }
    }

    // 2. If no cache exists, load static backup JSON first (serves from CDN, 0 egress)
    if (!cachedItems || cachedItems.length === 0) {
      console.log('[Cache-Miss] Loading initial dataset from local static backup (0 egress)...');
      cachedItems = ensureSorted(await fetchStaticBackup());
      
      // Calculate initial lastUpdated from static items
      if (cachedItems && cachedItems.length > 0) {
        let maxTime = new Date('1970-01-01T00:00:00Z');
        cachedItems.forEach(item => {
          if (item.updated_at) {
            const t = new Date(item.updated_at);
            if (t > maxTime) maxTime = t;
          }
        });
        lastUpdated = maxTime.toISOString();
        
        try {
          localStorage.setItem('vrindopnishad_all_content_cache', JSON.stringify(cachedItems));
          localStorage.setItem('vrindopnishad_all_content_last_updated', lastUpdated);
        } catch (e) {}
      }
      memoryCachedItems = cachedItems;
      memoryLastUpdated = lastUpdated;
      memoryCategoryCache = {}; // Reset category cache since base items changed
    }

    // 3. Trigger a background delta-sync with Supabase (only fetches rows updated since lastUpdated, minimizing egress!)
    if (!USE_MOCK && typeof window !== 'undefined') {
      const now = Date.now();
      // Throttle delta sync to once every 5 minutes
      if (now - lastSyncTime > 5 * 60 * 1000) {
        lastSyncTime = now;
        // Run delta-sync asynchronously without blocking the UI
        setTimeout(async () => {
          try {
            console.log(`[Delta-Sync] Fetching updates since: ${lastUpdated}...`);
            let updates = [];
            
            const { data, error } = await supabase
              .from('content')
              .select('*')
              .gt('updated_at', lastUpdated)
              .order('updated_at', { ascending: true });
              
            if (error) throw error;
            updates = data || [];
            
            if (updates.length > 0) {
              console.log(`[Delta-Sync] Found ${updates.length} new or updated items from Supabase!`);
              
              // Merge updates into cachedItems
              const itemMap = new Map(cachedItems.map(item => [item.id, item]));
              
              updates.forEach(upd => {
                const cleanCategory = classifyItemCategory(upd);
                const processed = {
                  ...upd,
                  category: cleanCategory,
                  slug: upd.slug || generateSlug(upd.title)
                };
                itemMap.set(upd.id, processed);
              });
              
              const newCachedItems = ensureSorted(Array.from(itemMap.values()));
              
              // Find new max updated_at
              let maxTime = new Date(lastUpdated);
              updates.forEach(upd => {
                if (upd.updated_at) {
                  const t = new Date(upd.updated_at);
                  if (t > maxTime) maxTime = t;
                }
              });
              
              memoryCachedItems = newCachedItems;
              memoryLastUpdated = maxTime.toISOString();
              memoryCategoryCache = {}; // Invalidate categorized cache
              
              localStorage.setItem('vrindopnishad_all_content_cache', JSON.stringify(newCachedItems));
              localStorage.setItem('vrindopnishad_all_content_last_updated', maxTime.toISOString());
              
              // Dispatch storage event to update other components or tabs
              window.dispatchEvent(new Event('storage'));
            } else {
              console.log('[Delta-Sync] Database is up to date. 0 new items fetched.');
            }
          } catch (err) {
            console.warn('[Delta-Sync] Background delta sync failed:', err.message);
          }
        }, 2000);
      }
    }

    // 4. Return requested subset from cached items
    let filtered = cachedItems;
    if (category) {
      const targetCat = category.toLowerCase().trim();
      if (memoryCategoryCache[targetCat]) {
        filtered = memoryCategoryCache[targetCat];
      } else {
        filtered = filtered.filter(item => item.category?.toLowerCase() === targetCat);
        memoryCategoryCache[targetCat] = filtered;
      }
    }
    
    // Skip dynamic O(N log N) sorting since global cachedItems is pre-sorted!
    if (limit && limit < filtered.length) {
      filtered = filtered.slice(0, limit);
    }
    
    return filtered;
  },

  getContentById: async (id) => {
    const cacheKey = `id_${id}`;
    let cached = getCache(cacheKey);
    if (cached) return cached;

    // Fallback: Check global pre-fetched in-memory/localStorage cache first
    try {
      let items = memoryCachedItems;
      if (!items) {
        const localCached = localStorage.getItem('vrindopnishad_all_content_cache');
        if (localCached) {
          items = JSON.parse(localCached);
          memoryCachedItems = items;
        }
      }
      if (items) {
        const decodedId = decodeURIComponent(id);
        const matched = items.find(item => 
          item.id?.toString() === id.toString() ||
          item.id?.toString() === decodedId.toString() ||
          item.slug === id ||
          item.slug === decodedId ||
          generateSlug(item.title) === id || 
          generateSlug(item.title) === decodedId
        );
        if (matched) {
          console.log(`[Cache-Hit] getContentById matched item ${id} in global in-memory cache.`);
          const cleanCategory = classifyItemCategory(matched);
          const data = { 
            ...matched, 
            category: cleanCategory,
            slug: matched.slug || generateSlug(matched.title) 
          };
          setCache(cacheKey, data);
          return data;
        }
      }
    } catch (e) {
      console.warn('Failed to check global cache for getContentById:', e);
    }

    if (USE_MOCK) {
      const data = await mockApiService.getContentById(id);
      setCache(cacheKey, data);
      return data;
    }
    try {
      const snapshot = await get(ref(contentDb, 'public/content'));
      if (snapshot.exists()) {
        const rawData = snapshot.val();
        let contentItem = null;
        
        // Normalize to array for consistent searching
        const items = Array.isArray(rawData) 
          ? rawData.map((item, index) => ({ id: item.id || index.toString(), ...item })).filter(i => i.title)
          : Object.keys(rawData).map(key => ({ id: key, ...rawData[key] }));

        console.log(`Searching for content with ID/Slug: "${id}" in ${items.length} items`);

        // Search by exact ID, stored Slug, or derived Title-Slug
        contentItem = items.find(item => {
          const s1 = item.id?.toString() === id.toString();
          const s2 = item.slug === id;
          const s3 = generateSlug(item.title) === id;
          const s4 = generateSlug(item.title) === decodeURIComponent(id);
          return s1 || s2 || s3 || s4;
        });

        if (contentItem) {
          console.log(`Found content: ${contentItem.title}`);
          const cleanCategory = classifyItemCategory(contentItem);
          const data = { 
            ...contentItem, 
            category: cleanCategory,
            slug: contentItem.slug || generateSlug(contentItem.title) 
          };
          setCache(cacheKey, data);
          return data;
        } else {
          console.warn(`Content not found for ID/Slug: "${id}"`);
        }
      }
      throw new Error("Content not found");
    } catch (error) {
      console.warn('Firebase fetch failed, falling back to Supabase...', error.message);
      try {
          const decodedId = decodeURIComponent(id);
          let data = null;

          // 1. Try lookup by slug column first
          const { data: slugData } = await supabase.from('content').select('*').eq('slug', id).maybeSingle();
          if (slugData) {
            data = slugData;
          }

          // 2. Try decoded slug
          if (!data && decodedId !== id) {
            const { data: decodedSlugData } = await supabase.from('content').select('*').eq('slug', decodedId).maybeSingle();
            if (decodedSlugData) data = decodedSlugData;
          }

          // 3. Try lookup by UUID id
          if (!data) {
            const { data: idData } = await supabase.from('content').select('*').eq('id', id).maybeSingle();
            if (idData) data = idData;
          }

          // 4. Last resort: fetch all and match by generated slug from title
          if (!data) {
             console.log('Not found by slug/id in Supabase, searching by generated slug...');
             const { data: allData, error: allErr } = await supabase.from('content').select('*');
             if (allErr) throw allErr;
             
             data = allData.find(item => 
                item.slug === id ||
                item.slug === decodedId ||
                generateSlug(item.title) === id || 
                generateSlug(item.title) === decodedId
             );
          }

          if (!data) throw new Error("Content not found in Supabase");

          const cleanCategory = classifyItemCategory(data);
          const contentData = { 
            ...data, 
            category: cleanCategory,
            slug: data.slug || generateSlug(data.title) 
          };
          setCache(cacheKey, contentData);
          return contentData;
      } catch (supaErr) {
          console.error('Error fetching content from Supabase:', supaErr);
          throw supaErr;
      }
    }
  },

  // Categories API
  getCategories: async () => {
    // Return standard client-side categories corresponding to filter pills and paths
    return ['shloka', 'strotra', 'poem'];
  },

  // Admin APIs (In case frontend needs them)
  createContent: async (contentData) => {
    try {
      throw new Error("createContent not implemented yet for Firebase");
    } catch (error) {
      console.error('Error creating content:', error);
      throw error;
    }
  },

  updateContent: async (id, contentData) => {
    try {
      throw new Error("updateContent not implemented yet for Firebase");
    } catch (error) {
      console.error('Error updating content:', error);
      throw error;
    }
  },

  deleteContent: async (id) => {
    try {
      throw new Error("deleteContent not implemented yet for Firebase");
    } catch (error) {
      console.error('Error deleting content:', error);
      throw error;
    }
  },

  // Auth APIs
  login: async (email, password) => {
    try {
      const userCredential = await signInWithEmailAndPassword(auth, email, password);
      return userCredential.user;
    } catch (error) {
      console.error('Login error:', error);
      throw error;
    }
  },

  signUp: async (email, password) => {
    try {
      const userCredential = await createUserWithEmailAndPassword(auth, email, password);
      return userCredential.user;
    } catch (error) {
      console.error('Sign up error:', error);
      throw error;
    }
  },

  signInWithGoogle: async () => {
    try {
      const provider = new GoogleAuthProvider();
      const userCredential = await signInWithPopup(auth, provider);
      return userCredential.user;
    } catch (error) {
      console.error('Google sign in error:', error);
      throw error;
    }
  },

  verifyToken: async () => {
    if (USE_MOCK) {
      return mockApiService.verifyToken();
    }
    try {
      if (!auth.currentUser) throw new Error("No user signed in");
      return await auth.currentUser.getIdTokenResult();
    } catch (error) {
      console.error('Token verification error:', error);
      throw error;
    }
  }
};

export const isDemoMode = USE_MOCK;
