import { useState, useEffect, useRef } from 'react';

// Memory cache for super-fast synchronization across components
const memoryCache = new Map();

// Active background requests map for deduplication
const activeRequests = new Map();

/**
 * Custom hook for Stale-While-Revalidate (SWR) background data fetching.
 *
 * @param {string} cacheKey Unique cache identifier
 * @param {Function} fetchFn Asynchronous data fetcher (returns a Promise)
 * @param {Object} options Configuration options
 */
export const useSWR = (cacheKey, fetchFn, options = {}) => {
  const {
    initialData = null,
    revalidateOnFocus = false,
    dedupingInterval = 2000, // 2 seconds
    localStorageExpiry = 30 * 60 * 1000 // 30 minutes
  } = options;

  const [data, setData] = useState(() => {
    if (initialData) return initialData;
    if (!cacheKey || typeof window === 'undefined') return null;

    // 1. Try memory cache first
    if (memoryCache.has(cacheKey)) {
      return memoryCache.get(cacheKey);
    }

    // 2. Try localStorage cache
    try {
      const cached = localStorage.getItem(`vrindopnishad_swr_${cacheKey}`);
      if (cached) {
        const { timestamp, value } = JSON.parse(cached);
        if (Date.now() - timestamp < localStorageExpiry) {
          memoryCache.set(cacheKey, value);
          return value;
        } else {
          localStorage.removeItem(`vrindopnishad_swr_${cacheKey}`);
        }
      }
    } catch (e) {
      console.warn('[useSWR] localStorage read error:', e);
    }
    return null;
  });

  const [isValidating, setIsValidating] = useState(false);
  const [error, setError] = useState(null);

  const fetchFnRef = useRef(fetchFn);
  fetchFnRef.current = fetchFn;

  useEffect(() => {
    if (!cacheKey) return;

    let isMounted = true;
    const abortController = new AbortController();

    const fetchData = async (forceRevalidate = false) => {
      const now = Date.now();
      const dedupKey = `${cacheKey}`;
      const lastRequest = activeRequests.get(dedupKey);

      // Check deduplication
      if (!forceRevalidate && lastRequest && (now - lastRequest.timestamp < dedupingInterval)) {
        try {
          const result = await lastRequest.promise;
          if (isMounted) {
            setData(result);
            setError(null);
          }
        } catch (e) {
          if (isMounted) setError(e);
        }
        return;
      }

      setIsValidating(true);

      const promise = fetchFnRef.current({ signal: abortController.signal });
      activeRequests.set(dedupKey, { timestamp: now, promise });

      try {
        const result = await promise;
        if (isMounted) {
          setData(result);
          setError(null);
          
          // Write to memory cache
          memoryCache.set(cacheKey, result);

          // Write to localStorage cache (for small data only)
          try {
            const str = JSON.stringify({ timestamp: Date.now(), value: result });
            if (str.length < 200000) { // < 200KB limit for localStorage
              localStorage.setItem(`vrindopnishad_swr_${cacheKey}`, str);
            }
          } catch (e) {}
        }
      } catch (err) {
        if (err.name === 'AbortError') return;
        if (isMounted) {
          setError(err);
        }
      } finally {
        if (isMounted) {
          setIsValidating(false);
        }
        activeRequests.delete(dedupKey);
      }
    };

    fetchData();

    // Setup window focus revalidation
    const handleFocus = () => {
      fetchData(true);
    };

    if (revalidateOnFocus && typeof window !== 'undefined') {
      window.addEventListener('focus', handleFocus);
    }

    return () => {
      isMounted = false;
      abortController.abort();
      if (revalidateOnFocus && typeof window !== 'undefined') {
        window.removeEventListener('focus', handleFocus);
      }
    };
  }, [cacheKey, revalidateOnFocus, dedupingInterval, localStorageExpiry]);

  return { 
    data, 
    error, 
    isValidating, 
    mutate: (newValue) => {
      setData(newValue);
      if (cacheKey) {
        memoryCache.set(cacheKey, newValue);
        try {
          localStorage.setItem(
            `vrindopnishad_swr_${cacheKey}`,
            JSON.stringify({ timestamp: Date.now(), value: newValue })
          );
        } catch (e) {}
      }
    } 
  };
};
export default useSWR;
