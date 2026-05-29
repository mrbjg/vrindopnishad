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

export const isLightTheme = (themeId) => !DARK_THEMES.includes(themeId);

export const SettingsProvider = ({ children }) => {
  const [settings, setSettings] = useState(() => {
    const saved = localStorage.getItem('user_settings');
    let initial = saved ? JSON.parse(saved) : {
      fontSize: 2,
      fontStyle: 'Serif',
      lineByLine: true,
      smoothScroll: false,
      theme: 'light',
      devoteeName: '',
      dailyGoal: 432,
      layoutMode: 'sanctuary',
      enableAnimations: true
    };
    
    
    if (typeof initial.fontSize === 'string') {
      const mapping = { 'normal': 2, 'large': 3, 'xlarge': 4 };
      initial.fontSize = mapping[initial.fontSize] || 2;
    }

    
    if (!initial.theme) initial.theme = 'light';
    
    
    if (initial.devoteeName === undefined) initial.devoteeName = '';
    if (initial.dailyGoal === undefined) initial.dailyGoal = 432;
    if (initial.layoutMode === undefined) initial.layoutMode = 'sanctuary';
    if (initial.enableAnimations === undefined) initial.enableAnimations = true;
    
    return initial;
  });

  useEffect(() => {
    localStorage.setItem('user_settings', JSON.stringify(settings));
    
    document.documentElement.setAttribute('data-font-size', settings.fontSize);
    document.documentElement.setAttribute('data-font-style', settings.fontStyle);
    document.documentElement.setAttribute('data-layout-mode', settings.layoutMode || 'sanctuary');

    
    const theme = settings.theme || 'light';
    document.documentElement.setAttribute('data-theme', theme);

    
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
