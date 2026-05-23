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
    try {
      const snapshot = await get(ref(contentDb, 'public/content'));
      if (snapshot.exists()) {
        const rawData = snapshot.val();
        let data = Array.isArray(rawData) ? rawData.filter(Boolean) : 
                   Object.keys(rawData).map(key => ({ id: key, ...rawData[key] }));
        
        data = data.reverse();
        if (category) data = data.filter(item => item.category === category);
        
        // Enhance data with slugs for SEO
        data = data.map(item => ({
          ...item,
          slug: item.slug || generateSlug(item.title)
        }));

        if (limit) data = data.slice(0, limit);
        
        setCache(cacheKey, data);
        return data;
      }
      return [];
    } catch (error) {
      console.warn('Firebase connection failed, falling back to Supabase...', error.message);
      try {
        let query = supabase.from('content').select('*').order('created_at', { ascending: false });
        if (category) query = query.eq('category', category);
        if (limit) query = query.limit(limit);
        const { data, error: supaError } = await query;
        if (supaError) throw supaError;
        setCache(cacheKey, data || []);
        return data || [];
      } catch (error) {
        console.error('All database sources failed:', error);
        throw error;
      }
    }
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
          const data = { 
            ...contentItem, 
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

          // 1. Try lookup by slug column first (most common case from card links)
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

          const contentData = { ...data, slug: data.slug || generateSlug(data.title) };
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
    const cacheKey = 'categories';
    const cached = getCache(cacheKey);
    if (cached) return cached;

    if (USE_MOCK) {
      const data = await mockApiService.getCategories();
      setCache(cacheKey, data);
      return data;
    }
    try {
      const snapshot = await get(ref(contentDb, 'public/content'));
      if (snapshot.exists()) {
        const rawData = snapshot.val();
        let data = Array.isArray(rawData) ? rawData.filter(Boolean) : 
                   Object.keys(rawData).map(key => rawData[key]);
        const uniqueCategories = [...new Set(data.map(item => item.category).filter(Boolean))];
        setCache(cacheKey, uniqueCategories);
        return uniqueCategories;
      }
      return [];
    } catch (error) {
      console.warn('Firebase fetch failed, falling back to Supabase...', error.message);
      try {
          const { data, error: supaError } = await supabase.from('content').select('category').not('category', 'is', null);
          if (supaError) throw supaError;
          const uniqueCategories = [...new Set(data.map(item => item.category))];
          setCache(cacheKey, uniqueCategories);
          return uniqueCategories;
      } catch (supaErr) {
          console.error('Error fetching categories:', supaErr);
          throw supaErr;
      }
    }
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
