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
        sessionStorage.setItem(CACHE_PREFIX + key, JSON.stringify({
            timestamp: Date.now(),
            data: data
        }));
    } catch (e) {}
};

const getCache = (key) => {
    try {
        const cached = sessionStorage.getItem(CACHE_PREFIX + key);
        if (!cached) return null;
        const { timestamp, data } = JSON.parse(cached);
        if (Date.now() - timestamp > CACHE_EXPIRY) {
            sessionStorage.removeItem(CACHE_PREFIX + key);
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

export const apiService = {
  getCachedData: (key) => getCache(key),

  // Content APIs
  getAllContent: async (category = null, limit = 50) => {
    const cacheKey = `all_${category || 'none'}_${limit}`;
    const cached = getCache(cacheKey);
    if (cached) return cached;

    if (USE_MOCK) {
      const data = await mockApiService.getAllContent(category);
      setCache(cacheKey, data);
      return data;
    }

    let rawItems = [];

    // 1. Try Firebase RTDB
    try {
      const snapshot = await get(ref(contentDb, 'public/content'));
      if (snapshot.exists()) {
        const rawData = snapshot.val();
        rawItems = Array.isArray(rawData) ? rawData.filter(Boolean) : 
                   Object.keys(rawData).map(key => ({ id: key, ...rawData[key] }));
        rawItems = rawItems.reverse();
      }
    } catch (error) {
      console.warn('Firebase connection failed, falling back to Supabase...', error.message);
      // 2. Fallback to Supabase
      try {
        const { data, error: supaError } = await supabase
          .from('content')
          .select('*')
          .order('created_at', { ascending: false });
        if (supaError) throw supaError;
        rawItems = data || [];
      } catch (err) {
        console.error('All database sources failed:', err);
        throw err;
      }
    }

    // 3. Dynamic client-side categorization & enhancement
    let processedItems = rawItems.map(item => {
      const cleanCategory = classifyItemCategory(item);
      return {
        ...item,
        category: cleanCategory,
        slug: item.slug || generateSlug(item.title)
      };
    });

    // 4. Client-side category filtering
    if (category) {
      const targetCat = category.toLowerCase().trim();
      processedItems = processedItems.filter(item => item.category?.toLowerCase() === targetCat);
    }

    // 5. Apply limit
    if (limit) {
      processedItems = processedItems.slice(0, limit);
    }

    setCache(cacheKey, processedItems);
    return processedItems;
  },

  getContentById: async (id) => {
    const cacheKey = `id_${id}`;
    const cached = getCache(cacheKey);
    if (cached) return cached;

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
