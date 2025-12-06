import axios from 'axios';
import { mockApiService, mockContent, mockCategories } from './mockData';

const BACKEND_URL = process.env.REACT_APP_BACKEND_URL || 'http://localhost:8000';
const API_URL = `${BACKEND_URL}/api`;
const USE_MOCK = process.env.REACT_APP_DEMO_MODE === 'true' || !BACKEND_URL || BACKEND_URL === '';

// Create axios instance with default config
const apiClient = axios.create({
  baseURL: API_URL,
  timeout: 10000
});

// Add token to requests
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('admin_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

export const apiService = {
  // Content APIs
  getAllContent: async (category = null, limit = 50) => {
    if (USE_MOCK) {
      return mockApiService.getAllContent(category);
    }
    try {
      const params = { limit };
      if (category) params.category = category;
      const response = await apiClient.get('/content', { params });
      return response.data;
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
      const response = await apiClient.get(`/content/${id}`);
      return response.data;
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
      const response = await apiClient.get('/categories');
      return response.data;
    } catch (error) {
      console.error('Error fetching categories:', error);
      throw error;
    }
  },

  // Admin APIs
  createContent: async (contentData) => {
    if (USE_MOCK) {
      return { success: true, id: 'mock-id', message: 'Content created in demo mode' };
    }
    try {
      const response = await apiClient.post('/content', contentData);
      return response.data;
    } catch (error) {
      console.error('Error creating content:', error);
      throw error;
    }
  },

  updateContent: async (id, contentData) => {
    if (USE_MOCK) {
      return { success: true, message: 'Content updated in demo mode' };
    }
    try {
      const response = await apiClient.put(`/content/${id}`, contentData);
      return response.data;
    } catch (error) {
      console.error('Error updating content:', error);
      throw error;
    }
  },

  deleteContent: async (id) => {
    if (USE_MOCK) {
      return { success: true, message: 'Content deleted in demo mode' };
    }
    try {
      const response = await apiClient.delete(`/content/${id}`);
      return response.data;
    } catch (error) {
      console.error('Error deleting content:', error);
      throw error;
    }
  },

  uploadAudio: async (contentId, file) => {
    if (USE_MOCK) {
      return { success: true, audio_url: 'mock-audio-url' };
    }
    try {
      const formData = new FormData();
      formData.append('file', file);
      const response = await apiClient.post(`/upload/audio/${contentId}`, formData);
      return response.data;
    } catch (error) {
      console.error('Error uploading audio:', error);
      throw error;
    }
  },

  uploadImage: async (contentId, file) => {
    if (USE_MOCK) {
      return { success: true, image_url: 'mock-image-url' };
    }
    try {
      const formData = new FormData();
      formData.append('file', file);
      const response = await apiClient.post(`/upload/image/${contentId}`, formData);
      return response.data;
    } catch (error) {
      console.error('Error uploading image:', error);
      throw error;
    }
  },

  uploadVideo: async (contentId, file) => {
    if (USE_MOCK) {
      return { success: true, video_url: 'mock-video-url' };
    }
    try {
      const formData = new FormData();
      formData.append('file', file);
      const response = await apiClient.post(`/upload/video/${contentId}`, formData);
      return response.data;
    } catch (error) {
      console.error('Error uploading video:', error);
      throw error;
    }
  },

  generateAudio: async (contentId, text, language = 'hi-IN') => {
    if (USE_MOCK) {
      return { success: true, audio_url: 'mock-generated-audio' };
    }
    try {
      const response = await apiClient.post(`/content/${contentId}/generate-audio`, {
        text,
        language
      });
      return response.data;
    } catch (error) {
      console.error('Error generating audio:', error);
      throw error;
    }
  },

  generateImage: async (contentId, prompt) => {
    if (USE_MOCK) {
      return { success: true, image_urls: ['mock-generated-image'] };
    }
    try {
      const response = await apiClient.post(`/content/${contentId}/generate-image`, {
        prompt
      });
      return response.data;
    } catch (error) {
      console.error('Error generating image:', error);
      throw error;
    }
  },

  // Auth APIs
  login: async (email, password) => {
    if (USE_MOCK) {
      return mockApiService.login(email, password);
    }
    try {
      const response = await apiClient.post('/auth/login', { email, password });
      return response.data;
    } catch (error) {
      console.error('Login error:', error);
      throw error;
    }
  },

  verifyToken: async () => {
    if (USE_MOCK) {
      return mockApiService.verifyToken();
    }
    try {
      const response = await apiClient.get('/auth/verify');
      return response.data;
    } catch (error) {
      console.error('Token verification error:', error);
      throw error;
    }
  }
};

export const isDemoMode = USE_MOCK;
