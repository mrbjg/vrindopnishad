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

export const apiService = {
  // Content APIs
  getAllContent: async (category = null, limit = 50) => {
    if (USE_MOCK) {
      return mockApiService.getAllContent(category);
    }
    try {
      const snapshot = await get(ref(contentDb, 'public/content'));
      if (snapshot.exists()) {
        const rawData = snapshot.val();
        
        let data;
        // Handle array vs object format just like original bridge
        if (Array.isArray(rawData)) {
            data = rawData.filter(Boolean); // Filter out nulls
        } else {
            data = Object.keys(rawData).map(key => ({
                id: key,
                ...rawData[key]
            }));
        }
        
        data = data.reverse();
        
        if (category) {
            data = data.filter(item => item.category === category);
        }
        
        if (limit) {
            data = data.slice(0, limit);
        }
        
        return data;
      }
      return [];
    } catch (error) {
      console.warn('Firebase connection failed, falling back to Supabase...', error.message);
      try {
        let query = supabase.from('content').select('*').order('created_at', { ascending: false });
        if (category) {
            query = query.eq('category', category);
        }
        if (limit) {
            query = query.limit(limit);
        }
        const { data, error: supaError } = await query;
        if (supaError) throw supaError;
        return data || [];
      } catch (supaErr) {
        console.error('All database sources failed:', supaErr);
        throw supaErr;
      }
    }
  },

  getContentById: async (id) => {
    if (USE_MOCK) {
      return mockApiService.getContentById(id);
    }
    try {
      const snapshot = await get(ref(contentDb, `public/content/${id}`));
      if (snapshot.exists()) {
        return {
          id,
          ...snapshot.val()
        };
      }
      throw new Error("Content not found");
    } catch (error) {
      console.warn('Firebase fetch failed, falling back to Supabase...', error.message);
      try {
          const { data, error: supaError } = await supabase.from('content').select('*').eq('id', id).single();
          if (supaError) throw supaError;
          return { id, ...data };
      } catch (supaErr) {
          console.error('Error fetching content by ID:', supaErr);
          throw supaErr;
      }
    }
  },

  // Categories API
  getCategories: async () => {
    if (USE_MOCK) {
      return mockApiService.getCategories();
    }
    try {
      const snapshot = await get(ref(contentDb, 'public/content'));
      if (snapshot.exists()) {
        const rawData = snapshot.val();
        let data;
        if (Array.isArray(rawData)) {
            data = rawData.filter(Boolean);
        } else {
            data = Object.keys(rawData).map(key => rawData[key]);
        }
        const uniqueCategories = [...new Set(data.map(item => item.category).filter(Boolean))];
        return uniqueCategories;
      }
      return [];
    } catch (error) {
      console.warn('Firebase fetch failed, falling back to Supabase...', error.message);
      try {
          const { data, error: supaError } = await supabase.from('content').select('category').not('category', 'is', null);
          if (supaError) throw supaError;
          const uniqueCategories = [...new Set(data.map(item => item.category))];
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
