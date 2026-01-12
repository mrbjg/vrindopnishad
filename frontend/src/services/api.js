import { supabase } from '../lib/supabase';
import { mockApiService } from './mockData';

const USE_MOCK = process.env.REACT_APP_DEMO_MODE === 'true';

export const apiService = {
  // Content APIs
  getAllContent: async (category = null, limit = 50) => {
    if (USE_MOCK) {
      return mockApiService.getAllContent(category);
    }
    try {
      let query = supabase
        .from('content')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(limit);

      if (category) {
        query = query.eq('category', category);
      }

      const { data, error } = await query;
      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error fetching content:', error);
      throw error;
    }
  },

  getContentById: async (id) => {
    if (USE_MOCK) {
      return mockApiService.getContentById(id);
    }
    try {
      const { data, error } = await supabase
        .from('content')
        .select('*')
        .eq('id', id)
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error fetching content:', error);
      throw error;
    }
  },

  // Categories API
  getCategories: async () => {
    if (USE_MOCK) {
      return mockApiService.getCategories();
    }
    try {
      // Get unique categories from content table
      const { data, error } = await supabase
        .from('content')
        .select('category');

      if (error) throw error;

      const uniqueCategories = [...new Set(data.map(item => item.category))];
      return uniqueCategories;
    } catch (error) {
      console.error('Error fetching categories:', error);
      throw error;
    }
  },

  // Admin APIs (In case frontend needs them)
  createContent: async (contentData) => {
    try {
      const { data, error } = await supabase
        .from('content')
        .insert([contentData])
        .select()
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error creating content:', error);
      throw error;
    }
  },

  updateContent: async (id, contentData) => {
    try {
      const { data, error } = await supabase
        .from('content')
        .update(contentData)
        .eq('id', id)
        .select()
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error updating content:', error);
      throw error;
    }
  },

  deleteContent: async (id) => {
    try {
      const { error } = await supabase
        .from('content')
        .delete()
        .eq('id', id);

      if (error) throw error;
      return { success: true };
    } catch (error) {
      console.error('Error deleting content:', error);
      throw error;
    }
  },

  // Auth APIs
  login: async (email, password) => {
    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password
      });
      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Login error:', error);
      throw error;
    }
  },

  signUp: async (email, password) => {
    try {
      const { data, error } = await supabase.auth.signUp({
        email,
        password
      });
      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Sign up error:', error);
      throw error;
    }
  },

  signInWithGoogle: async () => {
    try {
      const { data, error } = await supabase.auth.signInWithOAuth({
        provider: 'google',
        options: {
          redirectTo: window.location.origin
        }
      });
      if (error) throw error;
      return data;
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
      const { data: { session }, error } = await supabase.auth.getSession();
      if (error) throw error;
      return session;
    } catch (error) {
      console.error('Token verification error:', error);
      throw error;
    }
  }
};

export const isDemoMode = USE_MOCK;
