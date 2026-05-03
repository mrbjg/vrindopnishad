/**
 * Client-side utility for AI Semantic Search
 * Calls the Vercel serverless function for HF-powered semantic matching
 */

const API_ENDPOINT = '/api/semantic-search';

// In-memory client cache
const queryCache = new Map();
const CACHE_MAX = 50;

/**
 * Call the AI semantic search endpoint
 * @param {string} query - User's search query (Hinglish, Hindi, English, Sanskrit)
 * @returns {Promise<Array>} Top matching content items with similarity scores
 */
export async function semanticSearch(query) {
  if (!query || query.trim().length < 2) return [];
  
  const normalizedQuery = query.trim().toLowerCase();
  
  // Check client cache
  if (queryCache.has(normalizedQuery)) {
    return queryCache.get(normalizedQuery);
  }
  
  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 8000); // 8s timeout
    
    const res = await fetch(
      `${API_ENDPOINT}?q=${encodeURIComponent(normalizedQuery)}`,
      { signal: controller.signal }
    );
    clearTimeout(timeout);
    
    if (!res.ok) {
      console.warn('Semantic search API error:', res.status);
      return [];
    }
    
    const data = await res.json();
    const results = data.results || [];
    
    // Cache result
    if (queryCache.size >= CACHE_MAX) {
      const firstKey = queryCache.keys().next().value;
      queryCache.delete(firstKey);
    }
    queryCache.set(normalizedQuery, results);
    
    return results;
  } catch (error) {
    if (error.name === 'AbortError') {
      console.warn('Semantic search timed out');
    } else {
      console.warn('Semantic search unavailable:', error.message);
    }
    return [];
  }
}

/**
 * Check if the AI search API is available
 */
export async function isSemanticSearchAvailable() {
  try {
    const res = await fetch(`${API_ENDPOINT}?q=test`, { method: 'GET' });
    return res.ok;
  } catch {
    return false;
  }
}
