/**
 * Loader utilities - Centralized exports for easy loading management
 * 
 * Import everything you need from one place:
 * import { Loader, useLoading, useLocalLoading } from './utils/loaderUtils';
 */

// Main loader component
export { default as Loader } from '../components/Loader';

// Global loading context
export { useLoading, LoadingProvider } from '../contexts/LoadingContext';

// Local loading hook
export { default as useLocalLoading } from '../hooks/useLocalLoading';

/**
 * Quick usage examples:
 * 
 * // Page-specific loading
 * const { loading, withLoading } = useLocalLoading();
 * 
 * // Global loading
 * const { showLoading, hideLoading } = useLoading();
 * 
 * // Direct component
 * <Loader text="Loading..." />
 * <Loader fullScreen text="Loading page..." />
 * <Loader size="small" text="Loading section..." />
 */
