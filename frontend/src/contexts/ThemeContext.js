import React, { createContext, useContext, useEffect, useState } from 'react';

const ThemeContext = createContext();

export const useTheme = () => {
    const context = useContext(ThemeContext);
    if (!context) {
        throw new Error('useTheme must be used within a ThemeProvider');
    }
    return context;
};

export const ThemeProvider = ({ children }) => {
    // Always track the resolved theme (what the system says)
    const [resolvedTheme, setResolvedTheme] = useState('light');

    useEffect(() => {
        const root = window.document.documentElement;

        const updateTheme = () => {
            // Always check system preference
            const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
            const effectiveTheme = systemPrefersDark ? 'dark' : 'light';

            setResolvedTheme(effectiveTheme);

            // Update the HTML class
            if (effectiveTheme === 'dark') {
                root.classList.add('dark');
                root.classList.remove('light');
            } else {
                root.classList.remove('dark');
                root.classList.add('light');
            }

            // Update meta theme-color for mobile browsers
            const metaThemeColor = document.querySelector('meta[name="theme-color"]');
            if (metaThemeColor) {
                metaThemeColor.setAttribute(
                    'content',
                    effectiveTheme === 'dark' ? '#0D0D12' : '#F8F7F4'
                );
            }
        };

        // Set initial theme
        updateTheme();

        // Listen for system theme changes
        const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
        const handleChange = () => {
            updateTheme();
        };

        // Modern browsers
        mediaQuery.addEventListener('change', handleChange);

        return () => {
            mediaQuery.removeEventListener('change', handleChange);
        };
    }, []);

    const value = {
        theme: 'system',      // Always system mode
        resolvedTheme,        // 'light' or 'dark' (current actual theme)
        isDark: resolvedTheme === 'dark',
    };

    return (
        <ThemeContext.Provider value={value}>
            {children}
        </ThemeContext.Provider>
    );
};

export default ThemeContext;
