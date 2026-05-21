import React, { useState, useEffect } from 'react';
import { Moon, Sun, Compass } from 'lucide-react';
import { useSettings } from '../contexts/SettingsContext';

const ThemeOnboardingModal = () => {
  const { settings, updateSetting } = useSettings();
  const [isOpen, setIsOpen] = useState(false);

  useEffect(() => {
    // Check if user has already onboarded the theme selection
    const onboarded = localStorage.getItem('theme_onboarded');
    if (onboarded !== 'true') {
      setIsOpen(true);
    }
  }, []);

  const handleConfirm = () => {
    localStorage.setItem('theme_onboarded', 'true');
    setIsOpen(false);
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-[3000] flex items-center justify-center p-4">
      {/* Backdrop with heavy blur */}
      <div className="absolute inset-0 bg-black/75 backdrop-blur-md animate-fade-in"></div>

      {/* Modal Container */}
      <div className="settings-modal-card-v2 w-full max-w-md relative z-10 animate-scale-in flex flex-col shadow-2xl p-8 overflow-hidden rounded-[32px]">
        {/* Decorative background glow */}
        <div className="absolute -top-24 -left-24 w-48 h-48 rounded-full bg-[#e2a850]/10 blur-[80px] pointer-events-none"></div>
        <div className="absolute -bottom-24 -right-24 w-48 h-48 rounded-full bg-[#e2a850]/5 blur-[80px] pointer-events-none"></div>

        {/* Sacred ॐ Symbol Header */}
        <div className="sacred-symbol-minimal mb-2 scale-90">
          <div className="sacred-symbol-ring" />
          <div className="sacred-symbol-text">ॐ</div>
        </div>

        <div className="text-center space-y-2">
          <h2 className="text-2xl font-bold font-headings text-minimal-gold">
            वृंदोपनिषद्
          </h2>
          <p className="text-xs uppercase tracking-[0.25em] text-[#e2a850]/80 font-semibold">
            Choose Sanctuary Atmosphere
          </p>
          <p className="text-xs text-white/50 font-light max-w-xs mx-auto leading-relaxed mt-2">
            Select a theme to start. You can change this and explore all seasonal and celestial moods at any time in settings.
          </p>
        </div>

        {/* Dynamic Theme Selection Grid */}
        <div className="grid grid-cols-2 gap-4 my-8 relative z-20">
          {/* Dark Mode */}
          <div
            onClick={() => updateSetting('theme', 'dark')}
            className={`p-6 rounded-[24px] border-2 cursor-pointer transition-all duration-300 flex flex-col items-center justify-between min-h-[160px] select-none ${
              settings.theme === 'dark'
                ? 'border-[#e2a850] bg-[#e2a850]/5 shadow-[0_0_20px_rgba(226,168,80,0.12)]'
                : 'border-white/5 bg-white/2 hover:border-white/10'
            }`}
          >
            <div className={`w-12 h-12 rounded-full border flex items-center justify-center transition-colors ${
              settings.theme === 'dark' 
                ? 'border-[#e2a850]/40 bg-[#e2a850]/10 text-[#e2a850]' 
                : 'border-white/10 bg-white/3 text-white/40'
            }`}>
              <Moon size={20} />
            </div>
            
            {/* Custom styled Radio Dot matching user screenshot */}
            <div className="w-5 h-5 rounded-full border border-white/25 flex items-center justify-center bg-[#111115]">
              <div className={`w-3 h-3 rounded-full transition-transform duration-300 ${
                settings.theme === 'dark' ? 'scale-100 bg-[#09090b]' : 'scale-0'
              }`} />
            </div>

            <span className={`text-xs font-bold tracking-wider uppercase transition-colors ${
              settings.theme === 'dark' ? 'text-white' : 'text-white/40'
            }`}>
              Dark
            </span>
          </div>

          {/* Light Mode */}
          <div
            onClick={() => updateSetting('theme', 'light')}
            className={`p-6 rounded-[24px] border-2 cursor-pointer transition-all duration-300 flex flex-col items-center justify-between min-h-[160px] select-none ${
              settings.theme === 'light'
                ? 'border-[#e2a850] bg-[#e2a850]/5 shadow-[0_0_20px_rgba(226,168,80,0.12)]'
                : 'border-white/5 bg-white/2 hover:border-white/10'
            }`}
          >
            <div className={`w-12 h-12 rounded-full border flex items-center justify-center transition-colors ${
              settings.theme === 'light' 
                ? 'border-[#e2a850]/40 bg-[#e2a850]/10 text-[#e2a850]' 
                : 'border-white/10 bg-white/3 text-white/40'
            }`}>
              <Sun size={20} />
            </div>
            
            {/* Custom styled Radio Dot matching user screenshot */}
            <div className="w-5 h-5 rounded-full border border-white/25 flex items-center justify-center bg-[#eae5d9]">
              <div className={`w-3 h-3 rounded-full transition-transform duration-300 ${
                settings.theme === 'light' ? 'scale-100 bg-[#fdfbf7]' : 'scale-0'
              }`} />
            </div>

            <span className={`text-xs font-bold tracking-wider uppercase transition-colors ${
              settings.theme === 'light' ? 'text-white' : 'text-white/40'
            }`}>
              Light
            </span>
          </div>
        </div>

        {/* Dismiss Button */}
        <button
          onClick={handleConfirm}
          className="w-full btn-premium py-3.5 text-xs uppercase tracking-widest font-bold shadow-lg hover:shadow-[#e2a850]/10 transition-all duration-300"
        >
          <Compass size={14} className="animate-spin-slow" />
          Enter Sanctuary
        </button>
      </div>
    </div>
  );
};

export default ThemeOnboardingModal;
