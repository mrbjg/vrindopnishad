'use client';

import React, { createContext, useState, useEffect, useContext } from 'react';

const SettingsContext = createContext();


export const THEMES = [
  { id: 'dark',      label: 'Dark',        icon: 'Moon',      group: 'base' },
  { id: 'light',     label: 'Light',       icon: 'Sun',       group: 'base' },
  { id: 'night',     label: 'Moon Night',  icon: 'Sparkles',  group: 'mood' },
  { id: 'space',     label: 'Space',       icon: 'Orbit',     group: 'mood' },
  { id: 'void',      label: 'Deep Void',   icon: 'Sparkle',   group: 'mood' },
  { id: 'winter',    label: 'Winter',      icon: 'Snowflake', group: 'mood' },
  { id: 'snow',      label: 'Snowfall',    icon: 'CloudSnow', group: 'mood' },
  { id: 'rainy',     label: 'Rainy',       icon: 'CloudRain', group: 'mood' },
  { id: 'mountains', label: 'Mountains',   icon: 'Mountain',  group: 'mood' },
  { id: 'mountain_morning', label: 'Mountain Morning', icon: 'Sunrise', group: 'mood' },
  { id: 'sunset',    label: 'Sunset',      icon: 'Sunset',    group: 'mood' },
  { id: 'forest',    label: 'Forest',      icon: 'Leaf',      group: 'mood' },
  { id: 'ocean',     label: 'Ocean',       icon: 'Waves',     group: 'mood' },
  { id: 'waterfall', label: 'Waterfall',   icon: 'Droplets',  group: 'mood' },
  { id: 'cherryblossom', label: 'Cherry Blossom (Dark)', icon: 'Flower2', group: 'mood' },
  { id: 'cherryblossom_light', label: 'Cherry Blossom (Light)', icon: 'Flower2', group: 'mood' },
  { id: 'aurora',    label: 'Aurora Glow',   icon: 'Sparkles', group: 'mood' },
];


const DARK_THEMES = ['dark', 'night', 'space', 'void', 'waterfall', 'cherryblossom', 'aurora'];

const RANDOM_ATMOSPHERES = ['space', 'night', 'void', 'aurora', 'sunset', 'cherryblossom'];

export const isLightTheme = (themeId) => !DARK_THEMES.includes(themeId);

export const SettingsProvider = ({ children }) => {
  const [settings, setSettings] = useState({
    fontSize: 2,
    fontStyle: 'Serif',
    lineByLine: true,
    smoothScroll: false,
    theme: 'space',
    hasUserChosenTheme: false,
    devoteeName: '',
    dailyGoal: 432,
    layoutMode: 'sanctuary',
    enableAnimations: true
  });

  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
    const saved = typeof window !== 'undefined' ? localStorage.getItem('user_settings') : null;
    if (saved) {
      try {
        let parsed = JSON.parse(saved);
        if (typeof parsed.fontSize === 'string') {
          const mapping = { 'normal': 2, 'large': 3, 'xlarge': 4 };
          parsed.fontSize = mapping[parsed.fontSize] || 2;
        }
        if (!parsed.hasUserChosenTheme) {
          // If user hasn't explicitly chosen a theme, pick a random high-end theme!
          const randomTheme = RANDOM_ATMOSPHERES[Math.floor(Math.random() * RANDOM_ATMOSPHERES.length)];
          parsed.theme = randomTheme;
        }
        if (parsed.devoteeName === undefined) parsed.devoteeName = '';
        if (parsed.dailyGoal === undefined) parsed.dailyGoal = 432;
        if (parsed.layoutMode === undefined) parsed.layoutMode = 'sanctuary';
        if (parsed.enableAnimations === undefined) parsed.enableAnimations = true;
        setSettings(parsed);
      } catch (e) {
        console.warn('Failed to parse settings', e);
      }
    } else {
      // First visit! Randomly pick a breathtaking sanctuary theme
      const randomTheme = RANDOM_ATMOSPHERES[Math.floor(Math.random() * RANDOM_ATMOSPHERES.length)];
      setSettings(prev => ({
        ...prev,
        theme: randomTheme,
        hasUserChosenTheme: false
      }));
    }
  }, []);

  useEffect(() => {
    if (!mounted) return;
    localStorage.setItem('user_settings', JSON.stringify(settings));
    
    document.documentElement.setAttribute('data-font-size', settings.fontSize);
    document.documentElement.setAttribute('data-font-style', settings.fontStyle);
    document.documentElement.setAttribute('data-layout-mode', settings.layoutMode || 'sanctuary');

    const theme = settings.theme || 'space';
    document.documentElement.setAttribute('data-theme', theme);

    if (isLightTheme(theme)) {
      document.documentElement.classList.remove('dark');
      document.documentElement.classList.add('light-mode');
    } else {
      document.documentElement.classList.add('dark');
      document.documentElement.classList.remove('light-mode');
    }
  }, [settings, mounted]);

  const updateSetting = (key, value) => {
    setSettings(prev => {
      const next = { ...prev, [key]: value };
      if (key === 'theme') {
        next.hasUserChosenTheme = true;
      }
      return next;
    });
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
