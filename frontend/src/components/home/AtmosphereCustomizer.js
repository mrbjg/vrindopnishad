import React from 'react';

export const THEME_SWATCHES = {
  space: 'linear-gradient(135deg, #0f071a 0%, #a855f7 100%)',
  night: '#030712',
  void: '#000000',
  aurora: 'linear-gradient(135deg, #040d1a 0%, #10b981 100%)',
  sunset: 'linear-gradient(135deg, #fff7ed 0%, #ffedd5 100%)',
  cherryblossom: '#140a15',
  waterfall: '#061217',
  dark: '#09090b',
  light: 'linear-gradient(135deg, #fdfbf7 0%, #eae5d9 100%)',
};

const ATMOSPHERE_COLORS = {
  space: { border: 'rgba(168, 85, 247, 0.5)', bg: 'rgba(168, 85, 247, 0.12)', text: '#c084fc', glow: 'rgba(168, 85, 247, 0.25)' },
  night: { border: 'rgba(96, 165, 250, 0.5)', bg: 'rgba(96, 165, 250, 0.12)', text: '#60a5fa', glow: 'rgba(96, 165, 250, 0.25)' },
  void: { border: 'rgba(129, 140, 248, 0.5)', bg: 'rgba(129, 140, 248, 0.12)', text: '#818cf8', glow: 'rgba(129, 140, 248, 0.25)' },
  aurora: { border: 'rgba(52, 211, 153, 0.5)', bg: 'rgba(52, 211, 153, 0.12)', text: '#34d399', glow: 'rgba(52, 211, 153, 0.25)' },
  sunset: { border: 'rgba(251, 113, 133, 0.5)', bg: 'rgba(251, 113, 133, 0.12)', text: '#fb7185', glow: 'rgba(251, 113, 133, 0.25)' },
  cherryblossom: { border: 'rgba(244, 114, 182, 0.5)', bg: 'rgba(244, 114, 182, 0.12)', text: '#f472b6', glow: 'rgba(244, 114, 182, 0.25)' },
  waterfall: { border: 'rgba(45, 212, 191, 0.5)', bg: 'rgba(45, 212, 191, 0.12)', text: '#2dd4bf', glow: 'rgba(45, 212, 191, 0.25)' },
  dark: { border: 'rgba(226, 204, 122, 0.5)', bg: 'rgba(226, 204, 122, 0.12)', text: '#e2cc7a', glow: 'rgba(226, 204, 122, 0.25)' },
  light: { border: 'rgba(217, 119, 6, 0.5)', bg: 'rgba(217, 119, 6, 0.12)', text: '#b3922e', glow: 'rgba(217, 119, 6, 0.25)' },
};

const AtmosphereCustomizer = ({ isHi, theme, updateSetting }) => {
  const themesList = [
    { id: 'space', label: isHi ? 'दिव्य ब्रह्मांड' : 'Cosmic Space', desc: 'Purple nebulae & celestial orbit' },
    { id: 'night', label: isHi ? 'चन्द्र रात्रि' : 'Moon Night', desc: 'Twinkling sapphire stars & moon' },
    { id: 'void', label: isHi ? 'परम शून्य' : 'Deep Void', desc: 'Event horizon halo' },
    { id: 'aurora', label: isHi ? 'उत्तरी प्रभा' : 'Aurora Glow', desc: 'Celestial green & violet glow' },
    { id: 'sunset', label: isHi ? 'स्वर्ण संध्या' : 'Sunset Glow', desc: 'Warm peach sky' },
    { id: 'cherryblossom', label: isHi ? 'कुसुम रात्रि' : 'Sakura Night', desc: 'Midnight blossom velvet' },
    { id: 'waterfall', label: isHi ? 'प्रपात संगीत' : 'Waterfall', desc: 'Cliff & rushing stream' },
    { id: 'dark', label: isHi ? 'मूल डार्क' : 'Base Dark', desc: 'Serene charcoal' }
  ];

  return (
    <div className="space-y-3">
      <div className="flex justify-between items-center">
        <span className="text-[9px] uppercase tracking-[0.25em] text-primary font-bold block">Atmosphere Customizer</span>
        <span className="text-[9px] text-white/40 block font-light">Customize your sanctuary environment</span>
      </div>
      <div className="flex gap-3 overflow-x-auto pb-2 scrollbar-hide book-shelf-row select-none">
        {themesList.map((t) => {
          const isActive = theme === t.id;
          const colors = ATMOSPHERE_COLORS[t.id] || ATMOSPHERE_COLORS.dark;

          return (
            <button
              key={t.id}
              onClick={() => updateSetting('theme', t.id)}
              className="flex-none px-4 py-3 rounded-2xl border-2 text-left transition-all duration-300 w-44 relative group overflow-hidden"
              style={{
                borderColor: isActive ? colors.border : 'var(--glass-border)',
                backgroundColor: isActive ? colors.bg : 'var(--glass-bg)',
                color: isActive ? colors.text : 'var(--text-color)',
                opacity: isActive ? 1 : 0.7,
                boxShadow: 'none'
              }}
              aria-label={isHi ? `${t.label} वातावरण सक्रिय करें` : `Activate ${t.label} atmosphere`}
              title={t.desc}
            >
              <div className="flex justify-between items-center">
                <span className="text-xs font-bold truncate block">{t.label}</span>
                <div
                  className="w-3 h-3 rounded-full border border-white/10 shrink-0"
                  style={{ background: THEME_SWATCHES[t.id] }}
                />
              </div>
              <span className="text-[9px] text-white/35 mt-1 block font-light leading-none truncate">{t.desc}</span>
              <div
                className="absolute inset-0 backdrop-blur-[2px] flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity duration-300 pointer-events-none"
                style={{ backgroundColor: colors.bg }}
              >
                <span className="text-[9px] font-bold uppercase tracking-[0.2em]" style={{ color: colors.text }}>
                  {isActive ? (isHi ? 'सक्रिय' : 'Active') : (isHi ? 'चुनें' : 'Select')}
                </span>
              </div>
            </button>
          );
        })}
      </div>
    </div>
  );
};

export default React.memo(AtmosphereCustomizer);
