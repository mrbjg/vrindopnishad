import React, { createContext, useState, useEffect, useContext } from 'react';

const SettingsContext = createContext();

export const SettingsProvider = ({ children }) => {
  const [settings, setSettings] = useState(() => {
    const saved = localStorage.getItem('user_settings');
    return saved ? JSON.parse(saved) : {
      fontSize: 'normal', // normal, large, xlarge
      fontStyle: 'Serif', // Serif (Laila), Sans (Poppins), Inter
      lineByLine: true
    };
  });

  useEffect(() => {
    localStorage.setItem('user_settings', JSON.stringify(settings));
    
    // Apply global font styles if needed, or specific settings
    document.documentElement.setAttribute('data-font-size', settings.fontSize);
    document.documentElement.setAttribute('data-font-style', settings.fontStyle);
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
