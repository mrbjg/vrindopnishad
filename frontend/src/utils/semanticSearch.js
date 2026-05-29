

const API_ENDPOINT = '/api/semantic-search';


const queryCache = new Map();
const CACHE_MAX = 50;


export async function semanticSearch(query) {
  if (!query || query.trim().length < 2) return [];
  
  const normalizedQuery = query.trim().toLowerCase();
  
  
  if (queryCache.has(normalizedQuery)) {
    return queryCache.get(normalizedQuery);
  }
  
  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 8000); 
    
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


export async function isSemanticSearchAvailable() {
  try {
    const res = await fetch(`${API_ENDPOINT}?q=test`, { method: 'GET' });
    return res.ok;
  } catch {
    return false;
  }
}
