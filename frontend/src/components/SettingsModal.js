import React, { useState, useContext } from 'react';
import { X, Type, Layout, AlignLeft, User, Check, AlertCircle, Palette } from 'lucide-react';
import { useSettings, THEMES } from '../contexts/SettingsContext';
import { AuthContext } from '../App';
import { updateProfile } from 'firebase/auth';
import ThemeIcon from './ThemeIcon';

const themeGradients = {
  dark: '#09090b',
  light: 'linear-gradient(135deg, #fdfbf7 0%, #eae5d9 100%)',
  night: '#030712',
  space: '#08070d',
  void: '#000000',
  winter: 'linear-gradient(135deg, #e0f2fe 0%, #f0f9ff 100%)',
  snow: 'linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%)',
  rainy: 'linear-gradient(135deg, #f1f5f9 0%, #cbd5e1 100%)',
  mountains: 'linear-gradient(135deg, #fafaf9 0%, #e7e5e4 100%)',
  mountain_morning: 'linear-gradient(135deg, #ffedd5 0%, #fee2e2 100%)',
  sunset: 'linear-gradient(135deg, #fff7ed 0%, #ffedd5 100%)',
  forest: 'linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%)',
  ocean: 'linear-gradient(135deg, #ecfeff 0%, #cffafe 100%)',
  waterfall: '#061217',
  cherryblossom: '#140a15',
  cherryblossom_light: 'linear-gradient(135deg, #fff0f3 0%, #ffe4e6 100%)',
  aurora: '#040d1a',
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
      updateSetting('devoteeName', displayName);
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
      <div 
        className="settings-modal-card-v2 w-full max-w-md relative z-10 animate-scale-in flex flex-col max-h-[90vh] shadow-2xl p-0 overflow-hidden"
      >
        {/* Fixed Header */}
        <div className="settings-modal-header flex justify-between items-center p-6 sm:p-8 pb-3 sm:pb-4">
          <div className="flex items-center gap-3">
            <div className="settings-modal-header-badge">
              <Palette size={20} />
            </div>
            <h2 className="settings-modal-title text-2xl font-bold font-headings">Sanctuary Settings</h2>
          </div>
          <button 
            onClick={onClose}
            className="settings-modal-close p-2 rounded-full transition-colors"
          >
            <X size={24} />
          </button>
        </div>

        {/* Scrollable Content */}
        <div 
          data-lenis-prevent 
          className="flex-1 overflow-y-auto p-6 sm:p-8 pt-4 sm:pt-6 space-y-8 sm:space-y-10 custom-scrollbar"
        >
          {/* Personal Profile Section */}
          {user ? (
            <div className="space-y-4">
              <h3 className="settings-modal-section-label text-xs uppercase tracking-[0.2em] font-bold flex items-center gap-2">
                <User size={14} /> Personal Profile
              </h3>
              <form onSubmit={handleUpdateProfile} className="space-y-3">
                <div className="premium-input-container flex items-center px-4 gap-3 group relative">
                  <User className="premium-input-icon flex-shrink-0" size={18} />
                  <input
                    type="text"
                    value={displayName}
                    onChange={(e) => setDisplayName(e.target.value)}
                    className="premium-input-field pr-12 text-sm"
                    placeholder="Your Full Name"
                  />
                  <button
                    type="submit"
                    disabled={isUpdating || displayName === user?.displayName}
                    className={`absolute right-2 top-1/2 -translate-y-1/2 p-1.5 rounded-lg transition-all ${
                      displayName !== user?.displayName && !isUpdating
                        ? 'bg-primary text-white shadow-lg hover:scale-105 active:scale-95'
                        : 'settings-modal-btn-disabled'
                    }`}
                  >
                    {isUpdating ? (
                      <div className="w-4 h-4 border-2 border-current/30 border-t-current rounded-full animate-spin"></div>
                    ) : (
                      <Check size={16} />
                    )}
                  </button>
                </div>
                {updateStatus.message && (
                  <div className={`flex items-center gap-2 text-[10px] font-bold uppercase tracking-wider animate-in fade-in slide-in-from-top-1 ${
                    updateStatus.type === 'success' ? 'text-green-500' : 'text-red-500'
                  }`}>
                    {updateStatus.type === 'success' ? <Check size={12} /> : <AlertCircle size={12} />}
                    {updateStatus.message}
                  </div>
                )}
              </form>
            </div>
          ) : (
            <div className="space-y-4">
              <h3 className="settings-modal-section-label text-xs uppercase tracking-[0.2em] font-bold flex items-center gap-2">
                <User size={14} /> Devotee Identity
              </h3>
              <div className="premium-input-container flex items-center px-4 gap-3 group relative">
                <User className="premium-input-icon flex-shrink-0" size={18} />
                <input
                  type="text"
                  value={settings.devoteeName || ''}
                  onChange={(e) => updateSetting('devoteeName', e.target.value)}
                  className="premium-input-field text-sm"
                  placeholder="Enter Spiritual/Devotee Name"
                />
              </div>
            </div>
          )}

          {/* Sanctuary Themes & Celestial Moods */}
          <div className="space-y-4">
            <h3 className="settings-modal-section-label text-xs uppercase tracking-[0.2em] font-bold flex items-center gap-2">
              <Palette size={14} /> Sanctuary Theme
            </h3>
            
            <div className="space-y-5">
              {/* Base Themes */}
              <div>
                <span className="settings-modal-subsection text-[10px] uppercase tracking-widest block mb-2 font-bold">Core Modes</span>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  {THEMES.filter(t => t.group === 'base').map((t) => (
                    <button
                      key={t.id}
                      onClick={() => updateSetting('theme', t.id)}
                      className={`theme-picker-card-v2 ${settings.theme === t.id ? 'active' : ''}`}
                    >
                      <div className="theme-picker-inner">
                        <div className="flex items-center gap-2.5">
                          <div className="theme-icon-wrap-v2 p-1.5 rounded-lg">
                            <ThemeIcon name={t.icon} size={14} />
                          </div>
                          <span className="font-bold text-sm tracking-wide">{t.label}</span>
                        </div>
                        <div 
                          className="theme-swatch-v2 flex-shrink-0"
                          style={{ background: themeGradients[t.id] }}
                        ></div>
                      </div>
                    </button>
                  ))}
                </div>
              </div>

              {/* Moods */}
              <div>
                <span className="settings-modal-subsection text-[10px] uppercase tracking-widest block mb-2 font-bold">Celestial Moods</span>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  {THEMES.filter(t => t.group === 'mood').map((t) => (
                    <button
                      key={t.id}
                      onClick={() => updateSetting('theme', t.id)}
                      className={`theme-picker-card-v2 ${settings.theme === t.id ? 'active' : ''}`}
                    >
                      <div className="theme-picker-inner">
                        <div className="flex items-center gap-2.5">
                          <div className="theme-icon-wrap-v2 p-1.5 rounded-lg">
                            <ThemeIcon name={t.icon} size={14} />
                          </div>
                          <span className="font-bold text-sm tracking-wide">{t.label}</span>
                        </div>
                        <div 
                          className="theme-swatch-v2 flex-shrink-0"
                          style={{ background: themeGradients[t.id] }}
                        ></div>
                      </div>
                    </button>
                  ))}
                </div>
              </div>
            </div>
          </div>

          {/* Font Size */}
          <div className="space-y-4">
            <h3 className="settings-modal-section-label text-xs uppercase tracking-[0.2em] font-bold flex items-center gap-2">
              <Type size={14} /> Font Size
            </h3>
            <div className="premium-segmented-control grid-cols-5">
              {[1, 2, 3, 4, 5].map((size) => (
                <button
                  key={size}
                  onClick={() => updateSetting('fontSize', size)}
                  className={`segmented-control-btn ${settings.fontSize === size ? 'active' : ''}`}
                >
                  {size === 1 ? 'XS' : size === 2 ? 'SM' : size === 3 ? 'MD' : size === 4 ? 'LG' : 'XL'}
                </button>
              ))}
            </div>
          </div>

          {/* Font Style */}
          <div className="space-y-4">
            <h3 className="settings-modal-section-label text-xs uppercase tracking-[0.2em] font-bold flex items-center gap-2">
              <AlignLeft size={14} /> Typography
            </h3>
            <div className="premium-segmented-control grid-cols-3">
              {['Serif', 'Sans', 'Inter'].map((style) => (
                <button
                  key={style}
                  onClick={() => updateSetting('fontStyle', style)}
                  className={`segmented-control-btn ${settings.fontStyle === style ? 'active' : ''}`}
                  style={{
                    fontFamily: style === 'Serif' ? 'Georgia, serif' : style === 'Sans' ? 'system-ui, sans-serif' : '"Inter", sans-serif',
                    textTransform: 'none'
                  }}
                >
                  {style}
                </button>
              ))}
            </div>
          </div>

          {/* Sadhana Daily Goal */}
          <div className="space-y-4">
            <h3 className="settings-modal-section-label text-xs uppercase tracking-[0.2em] font-bold flex items-center gap-2">
              <Check size={14} /> Sadhana Daily Goal
            </h3>
            <div className="premium-segmented-control grid-cols-4">
              {[108, 432, 864, 1728].map((goal) => (
                <button
                  key={goal}
                  onClick={() => updateSetting('dailyGoal', goal)}
                  className={`segmented-control-btn ${settings.dailyGoal === goal ? 'active' : ''}`}
                >
                  {goal === 108 ? '1 Mala' : goal === 432 ? '4 Malas' : goal === 864 ? '8 Malas' : '16 Malas'}
                </button>
              ))}
            </div>
          </div>

          {/* Layout Mode */}
          <div className="space-y-4">
            <h3 className="settings-modal-section-label text-xs uppercase tracking-[0.2em] font-bold flex items-center gap-2">
              <Layout size={14} /> Interface Layout
            </h3>
            <div className="premium-segmented-control grid-cols-2">
              <button
                type="button"
                onClick={() => updateSetting('layoutMode', 'sanctuary')}
                className={`segmented-control-btn ${settings.layoutMode !== 'pookiz' ? 'active' : ''}`}
              >
                Sanctuary (Default)
              </button>
              <button
                type="button"
                onClick={() => updateSetting('layoutMode', 'pookiz')}
                className={`segmented-control-btn ${settings.layoutMode === 'pookiz' ? 'active' : ''}`}
              >
                Pookiz (Sleek Dark)
              </button>
            </div>
          </div>

          {/* Reading Mode */}
          <div className="space-y-4">
            <h3 className="settings-modal-section-label text-xs uppercase tracking-[0.2em] font-bold flex items-center gap-2">
              <Layout size={14} /> Reading Experience
            </h3>
            
            <div className="space-y-3">
              <div className="premium-toggle-row flex items-center justify-between transition-all group">
                <div className="flex flex-col">
                  <span className="settings-modal-toggle-title font-bold text-sm transition-all duration-300">Line-by-Line Reading</span>
                  <span className="settings-modal-toggle-desc text-xs">Auto-split Hindi/Sanskrit verses</span>
                </div>
                <button
                  onClick={() => updateSetting('lineByLine', !settings.lineByLine)}
                  className={`premium-toggle-switch ${settings.lineByLine ? 'active' : ''}`}
                  aria-label="Toggle line-by-line reading"
                >
                  <div className="premium-toggle-knob"></div>
                </button>
              </div>

              <div className="premium-toggle-row flex items-center justify-between transition-all group">
                <div className="flex flex-col">
                  <span className="settings-modal-toggle-title font-bold text-sm transition-all duration-300">Fluid Motion</span>
                  <span className="settings-modal-toggle-desc text-xs">Premium smooth scrolling experience</span>
                </div>
                <button
                  onClick={() => updateSetting('smoothScroll', !settings.smoothScroll)}
                  className={`premium-toggle-switch ${settings.smoothScroll ? 'active' : ''}`}
                  aria-label="Toggle fluid motion"
                >
                  <div className="premium-toggle-knob"></div>
                </button>
              </div>

              <div className="premium-toggle-row flex items-center justify-between transition-all group">
                <div className="flex flex-col">
                  <span className="settings-modal-toggle-title font-bold text-sm transition-all duration-300">Celestial Particles</span>
                  <span className="settings-modal-toggle-desc text-xs">Background effects (turn off to boost performance)</span>
                </div>
                <button
                  onClick={() => updateSetting('enableAnimations', settings.enableAnimations !== false ? false : true)}
                  className={`premium-toggle-switch ${settings.enableAnimations !== false ? 'active' : ''}`}
                  aria-label="Toggle celestial particles"
                >
                  <div className="premium-toggle-knob"></div>
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Fixed Footer */}
        <div className="settings-modal-footer p-6 sm:p-8 pt-3 sm:pt-4">
          <button 
            onClick={onClose}
            className="w-full h-14 shimmer-btn font-bold text-sm tracking-widest uppercase shadow-2xl transition-all cursor-pointer"
          >
            Save Preferences
          </button>
        </div>
      </div>
    </div>
  );
};

export default SettingsModal;
