import React from 'react';
import { X, Type, Layout, AlignLeft } from 'lucide-react';
import { useSettings } from '../contexts/SettingsContext';

const SettingsModal = ({ isOpen, onClose }) => {
  const { settings, updateSetting } = useSettings();

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-[2000] flex items-center justify-center p-4">
      {/* Backdrop */}
      <div 
        className="absolute inset-0 bg-black/60 backdrop-blur-sm animate-fade-in"
        onClick={onClose}
      ></div>

      {/* Modal Card */}
      <div className="glass-card w-full max-w-md relative z-10 animate-scale-in p-8 border border-white/20 shadow-2xl">
        <div className="flex justify-between items-center mb-10">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-primary/20 rounded-lg text-primary">
              <Type size={20} />
            </div>
            <h2 className="text-2xl font-bold font-headings">Sanctuary Settings</h2>
          </div>
          <button 
            onClick={onClose}
            className="p-2 hover:bg-white/10 rounded-full transition-colors text-white/40 hover:text-white"
          >
            <X size={24} />
          </button>
        </div>

        <div className="space-y-10">
          {/* Font Size */}
          <div className="space-y-4">
            <h3 className="text-xs uppercase tracking-[0.2em] text-white/30 font-bold flex items-center gap-2">
              <Type size={14} /> Font Size
            </h3>
            <div className="grid grid-cols-5 gap-2">
              {[1, 2, 3, 4, 5].map((size) => (
                <button
                  key={size}
                  onClick={() => updateSetting('fontSize', size)}
                  className={`py-3 rounded-xl text-xs font-bold transition-all border ${
                    settings.fontSize === size 
                      ? 'bg-primary border-primary text-white shadow-lg shadow-primary/20' 
                      : 'bg-white/5 border-white/10 text-white/40 hover:bg-white/10'
                  }`}
                >
                  {size === 1 ? 'XS' : size === 2 ? 'SM' : size === 3 ? 'MD' : size === 4 ? 'LG' : 'XL'}
                </button>
              ))}
            </div>
          </div>

          {/* Font Style */}
          <div className="space-y-4">
            <h3 className="text-xs uppercase tracking-[0.2em] text-white/30 font-bold flex items-center gap-2">
              <AlignLeft size={14} /> Typography
            </h3>
            <div className="grid grid-cols-3 gap-3">
              {['Serif', 'Sans', 'Inter'].map((style) => (
                <button
                  key={style}
                  onClick={() => updateSetting('fontStyle', style)}
                  className={`py-3 rounded-xl text-sm font-semibold transition-all border ${
                    settings.fontStyle === style 
                      ? 'bg-primary border-primary text-white shadow-lg shadow-primary/20' 
                      : 'bg-white/5 border-white/10 text-white/60 hover:bg-white/10'
                  }`}
                >
                  {style}
                </button>
              ))}
            </div>
          </div>

          {/* Reading Mode */}
          <div className="space-y-4">
            <h3 className="text-xs uppercase tracking-[0.2em] text-white/30 font-bold flex items-center gap-2">
              <Layout size={14} /> Reading Experience
            </h3>
            <div className="flex items-center justify-between p-4 bg-white/5 border border-white/10 rounded-2xl">
              <div className="flex flex-col">
                <span className="font-bold text-sm">Line-by-Line Reading</span>
                <span className="text-xs text-white/30">Auto-split Hindi/Sanskrit verses</span>
              </div>
              <button
                onClick={() => updateSetting('lineByLine', !settings.lineByLine)}
                className={`w-14 h-8 rounded-full transition-all relative ${
                  settings.lineByLine ? 'bg-primary' : 'bg-white/10'
                }`}
              >
                <div className={`absolute top-1 w-6 h-6 rounded-full bg-white transition-all shadow-md ${
                  settings.lineByLine ? 'left-7' : 'left-1'
                }`}></div>
              </button>
            </div>
          </div>
        </div>

        <div className="mt-12">
          <button 
            onClick={onClose}
            className="w-full btn-premium py-4 font-bold text-sm tracking-widest uppercase"
          >
            Save Preferences
          </button>
        </div>
      </div>
    </div>
  );
};

export default SettingsModal;
