import React, { createContext, useContext, useEffect } from 'react';
import { useSettings, isLightTheme } from './SettingsContext';

const ThemeContext = createContext();

export const useTheme = () => {
    const context = useContext(ThemeContext);
    if (!context) {
        throw new Error('useTheme must be used within a ThemeProvider');
    }
    return context;
};

export const ThemeProvider = ({ children }) => {
    const { settings } = useSettings();
    const currentTheme = settings.theme || 'light';
    const isDark = !isLightTheme(currentTheme);

    useEffect(() => {
        // Update meta theme-color for mobile browsers
        const metaThemeColor = document.querySelector('meta[name="theme-color"]');
        if (metaThemeColor) {
            metaThemeColor.setAttribute(
                'content',
                isDark ? '#0D0D12' : '#F8F7F4'
            );
        }
    }, [isDark]);

    const value = {
        theme: currentTheme,
        resolvedTheme: isDark ? 'dark' : 'light',
        isDark,
    };

    return (
        <ThemeContext.Provider value={value}>
            {children}
        </ThemeContext.Provider>
    );
};

export default ThemeContext;
