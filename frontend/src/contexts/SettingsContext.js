import React, { createContext, useState, useEffect, useContext } from 'react';

const SettingsContext = createContext();

// All available themes with metadata for the picker UI
export const THEMES = [
  { id: 'dark',      label: 'Dark',        icon: 'Moon',      group: 'base' },
  { id: 'light',     label: 'Light',       icon: 'Sun',       group: 'base' },
  { id: 'night',     label: 'Moon Night',  icon: 'Sparkles',  group: 'mood' },
  { id: 'space',     label: 'Space',       icon: 'Orbit',     group: 'mood' },
  { id: 'void',      label: 'Deep Void',   icon: 'Compass',   group: 'mood' },
  { id: 'winter',    label: 'Winter',      icon: 'Snowflake', group: 'mood' },
  { id: 'snow',      label: 'Snowfall',    icon: 'CloudSnow', group: 'mood' },
  { id: 'rainy',     label: 'Rainy',       icon: 'CloudRain', group: 'mood' },
  { id: 'mountains', label: 'Mountains',   icon: 'Mountain',  group: 'mood' },
  { id: 'mountain_morning', label: 'Mountain Morning', icon: 'Sunrise', group: 'mood' },
  { id: 'sunset',    label: 'Sunset',      icon: 'Sunset',    group: 'mood' },
  { id: 'forest',    label: 'Forest',      icon: 'Leaf',      group: 'mood' },
  { id: 'ocean',     label: 'Ocean',       icon: 'Waves',     group: 'mood' },
  { id: 'waterfall', label: 'Waterfall',   icon: 'Droplets',  group: 'mood' },
];

// Themes that use light text (dark backgrounds)
const DARK_THEMES = ['dark', 'night', 'space', 'void', 'waterfall'];

export const isLightTheme = (themeId) => !DARK_THEMES.includes(themeId);

export const SettingsProvider = ({ children }) => {
  const [settings, setSettings] = useState(() => {
    const saved = localStorage.getItem('user_settings');
    let initial = saved ? JSON.parse(saved) : {
      fontSize: 2,
      fontStyle: 'Serif',
      lineByLine: true,
      smoothScroll: false,
      theme: 'light'
    };
    
    // Migration from old string-based font sizes
    if (typeof initial.fontSize === 'string') {
      const mapping = { 'normal': 2, 'large': 3, 'xlarge': 4 };
      initial.fontSize = mapping[initial.fontSize] || 2;
    }

    // Migration: add theme if missing
    if (!initial.theme) initial.theme = 'light';
    
    return initial;
  });

  useEffect(() => {
    localStorage.setItem('user_settings', JSON.stringify(settings));
    
    document.documentElement.setAttribute('data-font-size', settings.fontSize);
    document.documentElement.setAttribute('data-font-style', settings.fontStyle);

    // Apply theme
    const theme = settings.theme || 'light';
    document.documentElement.setAttribute('data-theme', theme);

    // Toggle light/dark class for Tailwind dark: variants
    if (isLightTheme(theme)) {
      document.documentElement.classList.remove('dark');
      document.documentElement.classList.add('light-mode');
    } else {
      document.documentElement.classList.add('dark');
      document.documentElement.classList.remove('light-mode');
    }
  }, [settings]);

  const updateSetting = (key, value) => {
    setSettings(prev => ({ ...prev, [key]: value }));
  };

  return (
    <SettingsContext.Provider value={{ settings, updateSetting }}>
      {children}
    </SettingsContext.Provider>
  );
};

export const useSettings = () => {
  const context = useContext(SettingsContext);
  if (!context) {
    throw new Error('useSettings must be used within a SettingsProvider');
  }
  return context;
};
