import { useState, useCallback } from 'react';


export const useLocalLoading = (initialState = false) => {
    const [loading, setLoading] = useState(initialState);

    const startLoading = useCallback(() => {
        setLoading(true);
    }, []);

    const stopLoading = useCallback(() => {
        setLoading(false);
    }, []);

    
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
        setLoading, 
    };
};

export default useLocalLoading;
