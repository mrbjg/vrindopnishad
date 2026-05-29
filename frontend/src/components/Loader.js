import React from 'react';
import './Loader.css';


const Loader = ({
    fullScreen = false,
    show = true,
    text = '',
    size = 'default',
    className = ''
}) => {
    if (!show) return null;

    
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
