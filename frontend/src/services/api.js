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

const USE_MOCK = process.env.REACT_APP_DEMO_MODE === 'true';
const CACHE_PREFIX = 'sv_cache_';
const CACHE_EXPIRY = 30 * 60 * 1000;

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
      } catch (supaErr) {
        console.error('All database sources failed:', supaErr);
        throw supaErr;
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
      const snapshot = await get(ref(contentDb, `public/content/${id}`));
      if (snapshot.exists()) {
        const data = { id, ...snapshot.val() };
        setCache(cacheKey, data);
        return data;
      }
      throw new Error("Content not found");
    } catch (error) {
      console.warn('Firebase fetch failed, falling back to Supabase...', error.message);
      try {
          const { data, error: supaError } = await supabase.from('content').select('*').eq('id', id).single();
          if (supaError) throw supaError;
          const contentData = { id, ...data };
          setCache(cacheKey, contentData);
          return contentData;
      } catch (supaErr) {
          console.error('Error fetching content by ID:', supaErr);
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
