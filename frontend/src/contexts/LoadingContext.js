import React, { createContext, useContext, useState, useCallback } from 'react';
import Loader from '../components/Loader';

/**
 * Loading Context - Provides global loading state management
 * Use this to show/hide loading indicator from any component
 */
const LoadingContext = createContext();

export const useLoading = () => {
    const context = useContext(LoadingContext);
    if (!context) {
        throw new Error('useLoading must be used within a LoadingProvider');
    }
    return context;
};

export const LoadingProvider = ({ children }) => {
    const [isLoading, setIsLoading] = useState(false);
    const [loadingText, setLoadingText] = useState('');

    const showLoading = useCallback((text = 'Loading...') => {
        setLoadingText(text);
        setIsLoading(true);
    }, []);

    const hideLoading = useCallback(() => {
        setIsLoading(false);
        setLoadingText('');
    }, []);

    const value = {
        isLoading,
        showLoading,
        hideLoading,
    };

    return (
        <LoadingContext.Provider value={value}>
            {children}
            <Loader fullScreen show={isLoading} text={loadingText} />
        </LoadingContext.Provider>
    );
};

export default LoadingContext;
