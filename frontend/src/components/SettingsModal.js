import React, { useState, useContext } from 'react';
import { X, Type, Layout, AlignLeft, User, Check, AlertCircle, Palette } from 'lucide-react';
import { useSettings, THEMES } from '../contexts/SettingsContext';
import { AuthContext } from '../App';
import { updateProfile } from 'firebase/auth';
import ThemeIcon from './ThemeIcon';

const themeGradients = {
  dark: 'radial-gradient(circle, #0F0025 0%, #050010 100%)',
  light: 'linear-gradient(135deg, #fdfbf7 0%, #eae5d9 100%)',
  night: 'linear-gradient(180deg, #020617 0%, #0f172a 100%)',
  space: 'radial-gradient(circle, #1e1b4b 0%, #090514 100%)',
  void: '#010101',
  winter: 'linear-gradient(135deg, #e0f2fe 0%, #f0f9ff 100%)',
  snow: 'linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%)',
  rainy: 'linear-gradient(135deg, #f1f5f9 0%, #cbd5e1 100%)',
  mountains: 'linear-gradient(135deg, #fafaf9 0%, #e7e5e4 100%)',
  sunset: 'linear-gradient(135deg, #fff7ed 0%, #ffedd5 100%)',
  forest: 'linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%)',
  ocean: 'linear-gradient(135deg, #ecfeff 0%, #cffafe 100%)',
};

const SettingsModal = ({ isOpen, onClose }) => {
  const { settings, updateSetting } = useSettings();
  const { user, refreshUser } = useContext(AuthContext);
  const [displayName, setDisplayName] = useState(user?.displayName || '');
  const [updateStatus, setUpdateStatus] = useState({ type: '', message: '' });
  const [isUpdating, setIsUpdating] = useState(false);

  const handleUpdateProfile = async (e) => {
    e.preventDefault();
    if (!user) return;
    setIsUpdating(true);
    setUpdateStatus({ type: '', message: '' });

    try {
      await updateProfile(user, { displayName });
      if (refreshUser) refreshUser();
      setUpdateStatus({ type: 'success', message: 'Profile updated successfully!' });
      setTimeout(() => setUpdateStatus({ type: '', message: '' }), 3000);
    } catch (error) {
      console.error('Update profile error:', error);
      setUpdateStatus({ type: 'error', message: 'Failed to update profile.' });
    } finally {
      setIsUpdating(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-[2000] flex items-center justify-center p-4">
      {/* Backdrop */}
      <div 
        className="absolute inset-0 bg-black/60 backdrop-blur-sm animate-fade-in"
        onClick={onClose}
      ></div>

      {/* Modal Card */}
      <div className="glass-card w-full max-w-md relative z-10 animate-scale-in flex flex-col max-h-[90vh] border border-white/20 shadow-2xl p-0 overflow-hidden">
        {/* Fixed Header */}
        <div className="flex justify-between items-center p-8 pb-4 border-b border-white/5">
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

        {/* Scrollable Content */}
        <div className="flex-1 overflow-y-auto p-8 pt-6 space-y-10 custom-scrollbar">
          {/* Personal Profile Section */}
          {user && (
            <div className="space-y-4">
              <h3 className="text-xs uppercase tracking-[0.2em] text-white/30 font-bold flex items-center gap-2">
                <User size={14} /> Personal Profile
              </h3>
              <form onSubmit={handleUpdateProfile} className="space-y-3">
                <div className="relative group">
                  <input
                    type="text"
                    value={displayName}
                    onChange={(e) => setDisplayName(e.target.value)}
                    className="w-full h-12 bg-white/5 border border-white/10 rounded-xl px-4 outline-none focus:border-primary/60 focus:bg-white/10 transition-all text-sm"
                    placeholder="Your Full Name"
                  />
                  <button
                    type="submit"
                    disabled={isUpdating || displayName === user?.displayName}
                    className={`absolute right-2 top-1/2 -translate-y-1/2 p-2 rounded-lg transition-all ${
                      displayName !== user?.displayName && !isUpdating
                        ? 'bg-primary text-white shadow-lg'
                        : 'bg-white/5 text-white/20'
                    }`}
                  >
                    {isUpdating ? (
                      <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                    ) : (
                      <Check size={16} />
                    )}
                  </button>
                </div>
                {updateStatus.message && (
                  <div className={`flex items-center gap-2 text-[10px] font-bold uppercase tracking-wider animate-in fade-in slide-in-from-top-1 ${
                    updateStatus.type === 'success' ? 'text-green-400' : 'text-red-400'
                  }`}>
                    {updateStatus.type === 'success' ? <Check size={12} /> : <AlertCircle size={12} />}
                    {updateStatus.message}
                  </div>
                )}
              </form>
            </div>
          )}

          {/* Sanctuary Themes & Celestial Moods */}
          <div className="space-y-4">
            <h3 className="text-xs uppercase tracking-[0.2em] text-white/30 font-bold flex items-center gap-2">
              <Palette size={14} /> Sanctuary Theme
            </h3>
            
            <div className="space-y-4">
              {/* Base Themes */}
              <div>
                <span className="text-[10px] uppercase tracking-widest text-white/40 block mb-2 font-semibold">Core Modes</span>
                <div className="grid grid-cols-2 gap-2">
                  {THEMES.filter(t => t.group === 'base').map((t) => (
                    <button
                      key={t.id}
                      onClick={() => updateSetting('theme', t.id)}
                      className={`flex items-center gap-3 p-3 rounded-xl text-sm font-semibold transition-all border ${
                        settings.theme === t.id 
                          ? 'bg-primary border-primary text-white shadow-lg shadow-primary/20' 
                          : 'bg-white/5 border-white/10 text-white/60 hover:bg-white/10'
                      }`}
                    >
                      <div 
                        className="w-5 h-5 rounded-full flex-shrink-0 border border-white/20 shadow-sm"
                        style={{ background: themeGradients[t.id] }}
                      ></div>
                      <span className="flex items-center gap-2">
                        <ThemeIcon name={t.icon} size={14} className="opacity-85" />
                        {t.label}
                      </span>
                    </button>
                  ))}
                </div>
              </div>

              {/* Moods */}
              <div>
                <span className="text-[10px] uppercase tracking-widest text-white/40 block mb-2 font-semibold">Celestial Moods</span>
                <div className="grid grid-cols-2 gap-2">
                  {THEMES.filter(t => t.group === 'mood').map((t) => (
                    <button
                      key={t.id}
                      onClick={() => updateSetting('theme', t.id)}
                      className={`flex items-center gap-3 p-3 rounded-xl text-xs font-semibold transition-all border ${
                        settings.theme === t.id 
                          ? 'bg-primary border-primary text-white shadow-lg shadow-primary/20' 
                          : 'bg-white/5 border-white/10 text-white/60 hover:bg-white/10'
                      }`}
                    >
                      <div 
                        className="w-5 h-5 rounded-full flex-shrink-0 border border-white/20 shadow-sm"
                        style={{ background: themeGradients[t.id] }}
                      ></div>
                      <span className="flex items-center gap-2">
                        <ThemeIcon name={t.icon} size={14} className="opacity-85" />
                        {t.label}
                      </span>
                    </button>
                  ))}
                </div>
              </div>
            </div>
          </div>

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
            
            <div className="space-y-3">
              <div className="flex items-center justify-between p-4 bg-white/5 border border-white/10 rounded-2xl transition-all hover:bg-white/10 group">
                <div className="flex flex-col">
                  <span className="font-bold text-sm transition-all duration-300">Line-by-Line Reading</span>
                  <span className="text-xs text-white/30">Auto-split Hindi/Sanskrit verses</span>
                </div>
                <button
                  onClick={() => updateSetting('lineByLine', !settings.lineByLine)}
                  className={`w-14 h-8 rounded-full transition-all relative ${
                    settings.lineByLine ? 'sacred-toggle-active' : 'bg-white/10'
                  }`}
                >
                  <div className={`absolute top-1 w-6 h-6 rounded-full bg-white transition-all shadow-md ${
                    settings.lineByLine ? 'left-7' : 'left-1'
                  }`}></div>
                </button>
              </div>

              <div className="flex items-center justify-between p-4 bg-white/5 border border-white/10 rounded-2xl transition-all hover:bg-white/10 group">
                <div className="flex flex-col">
                  <span className="font-bold text-sm transition-all duration-300">Fluid Motion</span>
                  <span className="text-xs text-white/30">Premium smooth scrolling experience</span>
                </div>
                <button
                  onClick={() => updateSetting('smoothScroll', !settings.smoothScroll)}
                  className={`w-14 h-8 rounded-full transition-all relative ${
                    settings.smoothScroll ? 'sacred-toggle-active' : 'bg-white/10'
                  }`}
                >
                  <div className={`absolute top-1 w-6 h-6 rounded-full bg-white transition-all shadow-md ${
                    settings.smoothScroll ? 'left-7' : 'left-1'
                  }`}></div>
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Fixed Footer */}
        <div className="p-8 pt-4 border-t border-white/5 bg-white/[0.02]">
          <button 
            onClick={onClose}
            className="w-full btn-sacred-gold py-4 font-bold text-sm tracking-widest uppercase shadow-2xl hover:scale-[1.02] active:scale-[0.98] transition-all"
          >
            Save Preferences
          </button>
        </div>
      </div>
    </div>
  );
};

export default SettingsModal;
