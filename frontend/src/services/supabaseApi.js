/**
 * Supabase API Service for VrindaVaani
 * Handles all database operations using Supabase client
 */
import { supabase } from '../lib/supabase';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000/api';

class SupabaseAPI {
    /**
     * Get all content from Supabase
     */
    async getAllContent(category = null) {
        try {
            let query = supabase
                .from('content')
                .select('*')
                .order('created_at', { ascending: false });

            if (category) {
                query = query.eq('category', category);
            }

            const { data, error } = await query;

            if (error) throw error;

            return {
                success: true,
                content: data || [],
                total: data?.length || 0
            };
        } catch (error) {
            console.error('Error fetching content:', error);
            return {
                success: false,
                content: [],
                total: 0,
                error: error.message
            };
        }
    }

    /**
     * Get single content by ID
     */
    async getContentById(id) {
        try {
            const { data, error } = await supabase
                .from('content')
                .select('*')
                .eq('id', id)
                .single();

            if (error) throw error;

            return {
                success: true,
                content: data
            };
        } catch (error) {
            console.error('Error fetching content by ID:', error);
            return {
                success: false,
                content: null,
                error: error.message
            };
        }
    }

    /**
     * Create new content (requires authentication)
     */
    async createContent(contentData, token) {
        try {
            const response = await fetch(`${API_BASE_URL}/content`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify(contentData)
            });

            const data = await response.json();
            return data;
        } catch (error) {
            console.error('Error creating content:', error);
            return { success: false, error: error.message };
        }
    }

    /**
     * Update content (requires authentication)
     */
    async updateContent(id, contentData, token) {
        try {
            const response = await fetch(`${API_BASE_URL}/content/${id}`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify(contentData)
            });

            const data = await response.json();
            return data;
        } catch (error) {
            console.error('Error updating content:', error);
            return { success: false, error: error.message };
        }
    }

    /**
     * Delete content (requires authentication)
     */
    async deleteContent(id, token) {
        try {
            const response = await fetch(`${API_BASE_URL}/content/${id}`, {
                method: 'DELETE',
                headers: {
                    'Authorization': `Bearer ${token}`
                }
            });

            const data = await response.json();
            return data;
        } catch (error) {
            console.error('Error deleting content:', error);
            return { success: false, error: error.message };
        }
    }

    /**
     * Get all categories
     */
    async getCategories() {
        try {
            const { data, error } = await supabase
                .from('content')
                .select('category')
                .not('category', 'is', null);

            if (error) throw error;

            // Get unique categories
            const uniqueCategories = [...new Set(data.map(item => item.category))];
            const categories = uniqueCategories.map(cat => ({
                id: cat.toLowerCase().replace(/\s+/g, '-'),
                name: cat
            }));

            return {
                success: true,
                categories
            };
        } catch (error) {
            console.error('Error fetching categories:', error);
            return {
                success: true,
                categories: []
            };
        }
    }

    /**
     * Admin login
     */
    async login(email, password) {
        try {
            const response = await fetch(`${API_BASE_URL}/auth/login`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ email, password })
            });

            const data = await response.json();
            return data;
        } catch (error) {
            console.error('Login error:', error);
            return { success: false, error: error.message };
        }
    }

    /**
     * Verify token
     */
    async verifyToken(token) {
        try {
            const response = await fetch(`${API_BASE_URL}/auth/verify`, {
                headers: {
                    'Authorization': `Bearer ${token}`
                }
            });

            const data = await response.json();
            return data;
        } catch (error) {
            console.error('Token verification error:', error);
            return { valid: false };
        }
    }

    /**
     * Upload file
     */
    async uploadFile(type, contentId, file, token) {
        try {
            const formData = new FormData();
            formData.append('file', file);

            const response = await fetch(`${API_BASE_URL}/upload/${type}/${contentId}`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${token}`
                },
                body: formData
            });

            const data = await response.json();
            return data;
        } catch (error) {
            console.error('Upload error:', error);
            return { success: false, error: error.message };
        }
    }

    /**
     * Search content
     */
    async searchContent(searchTerm) {
        try {
            const { data, error } = await supabase
                .from('content')
                .select('*')
                .or(`title.ilike.%${searchTerm}%,hindi_text.ilike.%${searchTerm}%,english_translation.ilike.%${searchTerm}%`);

            if (error) throw error;

            return {
                success: true,
                content: data || [],
                total: data?.length || 0
            };
        } catch (error) {
            console.error('Search error:', error);
            return {
                success: false,
                content: [],
                total: 0
            };
        }
    }
}

export default new SupabaseAPI();
