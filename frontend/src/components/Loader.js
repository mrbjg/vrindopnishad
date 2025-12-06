import React from 'react';
import './Loader.css';

/**
 * Loader Component - Displays animated loading spinner
 * Uses the beautiful bubble animation (Load 9 style)
 * 
 * @param {boolean} fullScreen - If true, shows as fullscreen overlay
 * @param {boolean} show - Controls visibility of loader
 * @param {string} text - Optional loading text to display
 * @param {string} size - Size variant: 'default', 'small', 'large' (default: 'default')
 * @param {string} className - Additional CSS classes to apply
 */
const Loader = ({
    fullScreen = false,
    show = true,
    text = '',
    size = 'default',
    className = ''
}) => {
    if (!show) return null;

    // Determine size class
    const sizeClass = size === 'small' ? 'loader-small' : '';
    const combinedClassName = `load-wrapp ${sizeClass} ${className}`.trim();

    const loaderContent = (
        <div className={combinedClassName}>
            <div className="load-9">
                {text && <p className="loader-text">{text}</p>}
                <div className="spinner">
                    <div className="bubble-1"></div>
                    <div className="bubble-2"></div>
                </div>
            </div>
        </div>
    );

    if (fullScreen) {
        return (
            <div className="loader-fullscreen">
                {loaderContent}
            </div>
        );
    }

    return loaderContent;
};

export default Loader;
