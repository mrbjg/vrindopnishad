import { mockApiService } from './mockData';
import { auth, db, contentDb } from '../firebase';
import { 
  signInWithEmailAndPassword, 
  createUserWithEmailAndPassword, 
  signInWithPopup, 
  GoogleAuthProvider,
  onAuthStateChanged,
  signOut,
  sendPasswordResetEmail
} from 'firebase/auth';
import { 
  collection, 
  doc, 
  getDocs, 
  getDoc, 
  setDoc, 
  updateDoc, 
  deleteDoc, 
  query, 
  where, 
  limit 
} from 'firebase/firestore';
import { ref, get, child, set as dbSet, update as dbUpdate, remove as dbRemove } from 'firebase/database';
import { supabase } from '../lib/supabase';
import { transliterate } from '../utils/transliterate';

const DB_PROVIDER = process.env.REACT_APP_DATABASE_PROVIDER || 'firebase';


const USE_MOCK = process.env.REACT_APP_DEMO_MODE === 'true';
const CACHE_PREFIX = 'sv_cache_';
const CACHE_EXPIRY = 30 * 60 * 1000;


let memoryCachedItems = null;
let memoryLastUpdated = '1970-01-01T00:00:00.000Z';
let memoryCategoryCache = {};
let lastSyncTime = 0;

const contentMapById = new Map();
const contentMapBySlug = new Map();

const updateMemoryCache = (items) => {
  memoryCachedItems = items;
  contentMapById.clear();
  contentMapBySlug.clear();
  if (!items) return;
  items.forEach(item => {
    if (!item) return;
    item.category = classifyItemCategory(item);
    
    const titleSlug = generateSlug(item.title);
    if (!item.slug && titleSlug) {
      item.slug = titleSlug;
    }
    
    if (item.id) {
      contentMapById.set(item.id.toString(), item);
    }
    if (item.slug) {
      contentMapBySlug.set(item.slug, item);
      contentMapBySlug.set(decodeURIComponent(item.slug), item);
    }
  });
};

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
        const parsed = e.newValue ? ensureSorted(JSON.parse(e.newValue)) : null;
        if (parsed) {
          updateMemoryCache(parsed);
        } else {
          updateMemoryCache(null);
        }
        memoryCategoryCache = {}; 
        const time = localStorage.getItem('vrindopnishad_all_content_last_updated');
        if (time) memoryLastUpdated = time;
      } catch (err) {
        updateMemoryCache(null);
      }
    }
  });
}


const generateSlug = (text) => {
  if (!text) return '';
  const transliterated = transliterate(text);
  return transliterated
    .toString()
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9\s-]/g, '') 
    .replace(/\s+/g, '-')         
    .replace(/--+/g, '-')         
    .replace(/^-+/, '')            
    .replace(/-+$/, '');           
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


function classifyItemCategory(item) {
  if (!item) return 'poem';
  const rawCat = (item.category || '').toLowerCase().trim();
  
  if (rawCat === 'saint' || rawCat === 'dham') {
    return rawCat;
  }
  
  if (rawCat === 'strotra' || rawCat === 'strotras' || rawCat === 'stotra' || rawCat === 'stotras') {
    return 'strotra';
  }
  if (rawCat === 'poem' || rawCat === 'poems' || rawCat === 'poetry') {
    return 'poem';
  }

  const title = (item.title || '').toLowerCase();
  const sanskrit = (item.sanskrit_text || '').toLowerCase();
  
  
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
  
  
  const hasSanskritText = sanskrit.trim().length > 10 && 
    (sanskrit.includes('॥') || sanskrit.includes('।') || sanskrit.includes('ॐ') || !/[a-z]{5,}/.test(sanskrit));
  
  const isScriptureBook = title.includes('gita') || title.includes('गीता') || 
    title.includes('upnishad') || title.includes('उपनिषद') || 
    title.includes('samhita') || title.includes('संहिता') || 
    title.includes('purana') || title.includes('पुराण') ||
    title.includes('shloka') || title.includes('श्लोक');

  if (isScriptureBook || hasSanskritText || rawCat === 'shloka' || rawCat === 'shlokas') {
    return 'shloka';
  }
  
  return 'poem';
}

const mapToAppModel = (item) => {
  if (!item) return null;
  return {
    id: item.id,
    title: item.title,
    sanskrit_text: item.sanskrit_text || item.sanskritText || '',
    hindi_text: item.hindi_text || item.hindiText || '',
    english_text: item.english_text || item.englishText || '',
    english_translation: item.english_translation || item.englishTranslation || '',
    category: item.category,
    description: item.description || '',
    content_text: item.content_text || item.contentText || '',
    tags: item.tags || [],
    status: (item.status || '').toLowerCase(),
    author: item.author || '',
    media_links: item.media_links || item.mediaLinks || [],
    audio_url: item.audio_url || item.audioUrl || '',
    image_urls: item.image_urls || item.imageUrls || [],
    video_urls: item.video_urls || item.videoUrls || [],
    slug: item.slug,
    created_at: item.created_at || item.createdAt,
    updated_at: item.updated_at || item.updatedAt
  };
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

  
  getAllContent: async (category = null, limit = 50) => {
    
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
          updateMemoryCache(cachedItems);
        }
        if (cachedTime) {
          lastUpdated = cachedTime;
          memoryLastUpdated = cachedTime;
        }
      } catch (e) {
        console.warn('Failed to parse global cache:', e);
      }
    }

    
    if (!cachedItems || cachedItems.length === 0) {
      console.log('[Cache-Miss] Loading initial dataset from local static backup (0 egress)...');
      cachedItems = ensureSorted(await fetchStaticBackup());
      
      
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
      updateMemoryCache(cachedItems);
      memoryLastUpdated = lastUpdated;
      memoryCategoryCache = {}; 
    }

    
    if (!USE_MOCK && typeof window !== 'undefined') {
      const now = Date.now();
      
      if (now - lastSyncTime > 5 * 60 * 1000) {
        lastSyncTime = now;
        
        setTimeout(async () => {
          try {
            let updates = [];
            if (DB_PROVIDER === 'supabase') {
              console.log(`[Supabase-Sync] Fetching updates since: ${lastUpdated}...`);
              const { data: rawUpdates, error } = await supabase
                .from('content')
                .select('*')
                .gt('updated_at', lastUpdated);
              
              if (error) throw error;
              updates = (rawUpdates || []).map(mapToAppModel).filter(Boolean);
            } else {
              console.log(`[Delta-Sync/RTDB] Fetching content from Realtime Database...`);
              const dbRef = ref(contentDb);
              const snapshot = await get(child(dbRef, 'content'));
              let rawUpdates = [];
              if (snapshot.exists()) {
                const val = snapshot.val();
                if (Array.isArray(val)) {
                  rawUpdates = val.filter(Boolean);
                } else if (typeof val === 'object') {
                  rawUpdates = Object.entries(val).map(([key, item]) => {
                    if (item && typeof item === 'object') {
                      return { id: item.id || key, ...item };
                    }
                    return null;
                  }).filter(Boolean);
                }
              }
              
              if (lastUpdated && lastUpdated !== '1970-01-01T00:00:00.000Z') {
                const lastTime = new Date(lastUpdated).getTime();
                rawUpdates = rawUpdates.filter(item => {
                  const itemTime = item.updated_at ? new Date(item.updated_at).getTime() : 0;
                  return itemTime > lastTime;
                });
              }
              
              updates = rawUpdates.map(mapToAppModel).filter(Boolean);
            }
            
            if (updates.length > 0) {
              console.log(`[Delta-Sync] Found ${updates.length} new or updated items!`);
              
              
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
              
              
              let maxTime = new Date(lastUpdated);
              updates.forEach(upd => {
                if (upd.updated_at) {
                  const t = new Date(upd.updated_at);
                  if (t > maxTime) maxTime = t;
                }
              });
              
              updateMemoryCache(newCachedItems);
              memoryLastUpdated = maxTime.toISOString();
              memoryCategoryCache = {}; 
              
              localStorage.setItem('vrindopnishad_all_content_cache', JSON.stringify(newCachedItems));
              localStorage.setItem('vrindopnishad_all_content_last_updated', maxTime.toISOString());
              
              
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
    
    
    if (limit && limit < filtered.length) {
      filtered = filtered.slice(0, limit);
    }
    
    return filtered;
  },

  getContentById: async (id) => {
    const cacheKey = `id_${id}`;
    let cached = getCache(cacheKey);
    if (cached) return cached;

    
    try {
      const decodedId = decodeURIComponent(id);
      
      let matched = contentMapById.get(id.toString()) || 
                    contentMapById.get(decodedId.toString()) ||
                    contentMapBySlug.get(id) ||
                    contentMapBySlug.get(decodedId);
      
      if (!matched && !memoryCachedItems) {
        const localCached = localStorage.getItem('vrindopnishad_all_content_cache');
        if (localCached) {
          const items = ensureSorted(JSON.parse(localCached));
          updateMemoryCache(items);
          
          matched = contentMapById.get(id.toString()) || 
                    contentMapById.get(decodedId.toString()) ||
                    contentMapBySlug.get(id) ||
                    contentMapBySlug.get(decodedId);
        }
      }
      
      if (matched) {
        console.log(`[Cache-Hit] getContentById matched item ${id} in global O(1) map.`);
        const cleanCategory = classifyItemCategory(matched);
        const data = { 
          ...matched, 
          category: cleanCategory,
          slug: matched.slug || generateSlug(matched.title) 
        };
        setCache(cacheKey, data);
        return data;
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
      const decodedId = decodeURIComponent(id);
      const isUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(decodedId);
      
      let rawData = null;
      if (DB_PROVIDER === 'supabase') {
        console.log('[Supabase] Fetching content by ID/Slug:', decodedId);
        let query = supabase.from('content').select('*');
        if (isUuid) {
          query = query.eq('id', decodedId);
        } else {
          query = query.eq('slug', decodedId);
        }
        const { data, error } = await query.maybeSingle();
        if (error) throw error;
        rawData = data;
        
        if (rawData) {
          const data = mapToAppModel(rawData);
          const cleanCategory = classifyItemCategory(data);
          const contentData = { 
            ...data, 
            category: cleanCategory,
            slug: data.slug || generateSlug(data.title) 
          };
          setCache(cacheKey, contentData);
          return contentData;
        }
        throw new Error("Content not found in Supabase database");
      } else {
        console.log('[RTDB] Resolving content from local cache or full sync:', decodedId);
        
        // Try to get from local memory maps first
        const decodedSlug = decodedId.toLowerCase();
        let found = contentMapById.get(decodedId) || contentMapBySlug.get(decodedId) || contentMapBySlug.get(decodedSlug);
        
        if (!found) {
          // Cache miss: sync the entire content node from Realtime Database
          console.log(`[Cache-Miss] getContentById for ${decodedId}, fetching RTDB...`);
          const allItems = await apiService.getAllContent();
          found = contentMapById.get(decodedId) || contentMapBySlug.get(decodedId) || contentMapBySlug.get(decodedSlug);
          
          if (!found) {
            // Slower fallback if maps are not fully indexed yet
            found = allItems.find(item => 
              item.id?.toString() === decodedId || 
              item.slug?.toLowerCase() === decodedSlug
            );
          }
        }

        if (found) {
          setCache(cacheKey, found);
          return found;
        }
        throw new Error("Content not found in Realtime Database");
      }
    } catch (error) {
      console.error('Error fetching content:', error);
      throw error;
    }
  },

  
  getCategories: async () => {
    
    return ['shloka', 'strotra', 'poem'];
  },

  
  createContent: async (contentData) => {
    try {
      const id = contentData.id || crypto.randomUUID();
      const slug = contentData.slug || generateSlug(contentData.title);
      
      if (DB_PROVIDER === 'supabase') {
        const payload = {
          id: id,
          title: contentData.title,
          sanskrit_text: contentData.sanskrit_text || '',
          hindi_text: contentData.hindi_text || '',
          english_text: contentData.english_text || '',
          english_translation: contentData.english_translation || '',
          category: contentData.category,
          description: contentData.description || '',
          content_text: contentData.content_text || '',
          tags: contentData.tags || [],
          status: (contentData.status || 'PUBLISHED').toLowerCase(),
          author: contentData.author || '',
          media_links: contentData.media_links || [],
          audio_url: contentData.audio_url || '',
          image_urls: contentData.image_urls || [],
          video_urls: contentData.video_urls || [],
          slug: slug
        };
        const { data, error } = await supabase.from('content').insert([payload]).select().single();
        if (error) throw error;
        return mapToAppModel(data);
      } else {
        const payload = {
          id: id,
          title: contentData.title || '',
          sanskrit_text: contentData.sanskrit_text || '',
          hindi_text: contentData.hindi_text || '',
          english_text: contentData.english_text || '',
          english_translation: contentData.english_translation || '',
          category: contentData.category || '',
          description: contentData.description || '',
          content_text: contentData.content_text || '',
          tags: contentData.tags || [],
          status: (contentData.status || 'published').toLowerCase(),
          author: contentData.author || '',
          media_links: contentData.media_links || [],
          audio_url: contentData.audio_url || '',
          image_urls: contentData.image_urls || [],
          video_urls: contentData.video_urls || [],
          slug: slug,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        };
        // Clean up undefined properties to avoid RTDB errors
        Object.keys(payload).forEach(key => {
          if (payload[key] === undefined) {
            delete payload[key];
          }
        });
        await dbSet(ref(contentDb, `content/${id}`), payload);
        return payload;
      }
    } catch (error) {
      console.error('Error creating content:', error);
      throw error;
    }
  },

  updateContent: async (id, contentData) => {
    try {
      const slug = contentData.slug || generateSlug(contentData.title);
      
      if (DB_PROVIDER === 'supabase') {
        const payload = {
          title: contentData.title,
          sanskrit_text: contentData.sanskrit_text || '',
          hindi_text: contentData.hindi_text || '',
          english_text: contentData.english_text || '',
          english_translation: contentData.english_translation || '',
          category: contentData.category,
          description: contentData.description || '',
          content_text: contentData.content_text || '',
          tags: contentData.tags || [],
          status: (contentData.status || 'PUBLISHED').toLowerCase(),
          author: contentData.author || '',
          media_links: contentData.media_links || [],
          audio_url: contentData.audio_url || '',
          image_urls: contentData.image_urls || [],
          video_urls: contentData.video_urls || [],
          slug: slug
        };
        const { data, error } = await supabase.from('content').update(payload).eq('id', id).select().single();
        if (error) throw error;
        return mapToAppModel(data);
      } else {
        const payload = {
          title: contentData.title,
          sanskrit_text: contentData.sanskrit_text || '',
          hindi_text: contentData.hindi_text || '',
          english_text: contentData.english_text || '',
          english_translation: contentData.english_translation || '',
          category: contentData.category,
          description: contentData.description || '',
          content_text: contentData.content_text || '',
          tags: contentData.tags || [],
          status: (contentData.status || 'published').toLowerCase(),
          author: contentData.author || '',
          media_links: contentData.media_links || [],
          audio_url: contentData.audio_url || '',
          image_urls: contentData.image_urls || [],
          video_urls: contentData.video_urls || [],
          slug: slug,
          updated_at: new Date().toISOString()
        };
        // Clean up undefined properties to avoid RTDB errors
        Object.keys(payload).forEach(key => {
          if (payload[key] === undefined) {
            delete payload[key];
          }
        });
        await dbUpdate(ref(contentDb, `content/${id}`), payload);
        return { ...contentData, id, slug };
      }
    } catch (error) {
      console.error('Error updating content:', error);
      throw error;
    }
  },

  deleteContent: async (id) => {
    try {
      if (DB_PROVIDER === 'supabase') {
        const { error } = await supabase.from('content').delete().eq('id', id);
        if (error) throw error;
        return true;
      } else {
        await dbRemove(ref(contentDb, `content/${id}`));
        return true;
      }
    } catch (error) {
      console.error('Error deleting content:', error);
      throw error;
    }
  },

  
  login: async (email, password) => {
    try {
      if (DB_PROVIDER === 'supabase') {
        const { data, error } = await supabase.auth.signInWithPassword({ email, password });
        if (error) throw error;
        return data.user;
      } else {
        const userCredential = await signInWithEmailAndPassword(auth, email, password);
        return userCredential.user;
      }
    } catch (error) {
      console.error('Login error:', error);
      throw error;
    }
  },

  signUp: async (email, password, fullName = '') => {
    try {
      if (DB_PROVIDER === 'supabase') {
        const { data, error } = await supabase.auth.signUp({
          email,
          password,
          options: {
            data: {
              display_name: fullName
            }
          }
        });
        if (error) throw error;
        return data.user;
      } else {
        const userCredential = await createUserWithEmailAndPassword(auth, email, password);
        return userCredential.user;
      }
    } catch (error) {
      console.error('Sign up error:', error);
      throw error;
    }
  },

  signInWithGoogle: async () => {
    try {
      if (DB_PROVIDER === 'supabase') {
        const { data, error } = await supabase.auth.signInWithOAuth({
          provider: 'google',
        });
        if (error) throw error;
        return data.user;
      } else {
        const provider = new GoogleAuthProvider();
        const userCredential = await signInWithPopup(auth, provider);
        return userCredential.user;
      }
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
      if (DB_PROVIDER === 'supabase') {
        const { data: { session }, error } = await supabase.auth.getSession();
        if (error || !session) throw new Error("No session found");
        return session;
      } else {
        if (!auth.currentUser) throw new Error("No user signed in");
        return await auth.currentUser.getIdTokenResult();
      }
    } catch (error) {
      console.error('Token verification error:', error);
      throw error;
    }
  },

  onAuthChanged: (callback) => {
    if (DB_PROVIDER === 'supabase') {
      const { data: { subscription } } = supabase.auth.onAuthStateChange((event, session) => {
        callback(session?.user || null, session?.access_token || null);
      });
      return () => subscription.unsubscribe();
    } else {
      return onAuthStateChanged(auth, async (firebaseUser) => {
        if (firebaseUser) {
          try {
            const token = await firebaseUser.getIdToken();
            callback(firebaseUser, token);
          } catch (e) {
            callback(firebaseUser, null);
          }
        } else {
          callback(null, null);
        }
      });
    }
  },

  logout: async () => {
    if (DB_PROVIDER === 'supabase') {
      const { error } = await supabase.auth.signOut();
      if (error) throw error;
    } else {
      await signOut(auth);
    }
  },

  
  generateAudio: async (contentId, text, language, token) => {
    const backendUrl = process.env.REACT_APP_API_URL || 'http://localhost:8000/api';
    const headers = token ? { Authorization: `Bearer ${token}` } : {};
    const axios = require('axios');
    await axios.post(
      `${backendUrl}/content/${contentId}/generate-audio`,
      { text, language },
      { headers }
    );
  },

  generateImage: async (contentId, prompt, token) => {
    const backendUrl = process.env.REACT_APP_API_URL || 'http://localhost:8000/api';
    const headers = token ? { Authorization: `Bearer ${token}` } : {};
    const axios = require('axios');
    await axios.post(
      `${backendUrl}/content/${contentId}/generate-image`,
      { prompt },
      { headers }
    );
  },

  uploadFile: async (contentId, file, type, token) => {
    const backendUrl = process.env.REACT_APP_API_URL || 'http://localhost:8000/api';
    const headers = token ? { Authorization: `Bearer ${token}` } : {};
    const formData = new FormData();
    formData.append('file', file);
    const axios = require('axios');
    await axios.post(
      `${backendUrl}/upload/${type}/${contentId}`,
      formData,
      { headers }
    );
  },

  resetPassword: async (email) => {
    if (DB_PROVIDER === 'supabase') {
      const { error } = await supabase.auth.resetPasswordForEmail(email);
      if (error) throw error;
    } else {
      await sendPasswordResetEmail(auth, email);
    }
  }
};

export const isDemoMode = USE_MOCK;
