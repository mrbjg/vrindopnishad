import { useState, useCallback } from 'react';

/**
 * Custom hook for managing local loading states
 * Use this when you need component-specific loading (not global)
 * 
 * @returns {object} - Loading state and control functions
 * 
 * @example
 * const { loading, startLoading, stopLoading, withLoading } = useLocalLoading();
 * 
 * // Manual control
 * startLoading();
 * await fetchData();
 * stopLoading();
 * 
 * // Or automatic with async function
 * await withLoading(async () => {
 *   await fetchData();
 * });
 */
export const useLocalLoading = (initialState = false) => {
    const [loading, setLoading] = useState(initialState);

    const startLoading = useCallback(() => {
        setLoading(true);
    }, []);

    const stopLoading = useCallback(() => {
        setLoading(false);
    }, []);

    /**
     * Wraps an async function with loading state
     * Automatically sets loading to true, runs the function, then sets to false
     */
    const withLoading = useCallback(async (asyncFn) => {
        setLoading(true);
        try {
            return await asyncFn();
        } finally {
            setLoading(false);
        }
    }, []);

    return {
        loading,
        startLoading,
        stopLoading,
        withLoading,
        setLoading, // For manual control if needed
    };
};

export default useLocalLoading;
