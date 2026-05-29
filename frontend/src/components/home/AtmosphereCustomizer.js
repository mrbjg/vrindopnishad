import React from 'react';

export const THEME_SWATCHES = {
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

const AtmosphereCustomizer = ({ isHi, theme, updateSetting }) => {
  const themesList = [
    { id: 'dark', label: isHi ? 'मूल डार्क' : 'Base Dark', desc: 'Serene charcoal' },
    { id: 'light', label: isHi ? 'मूल लाइट' : 'Base Light', desc: 'Minimalist cream' },
    { id: 'night', label: isHi ? 'चन्द्र रात्रि' : 'Moon Night', desc: 'Twinkling stars & moon' },
    { id: 'space', label: isHi ? 'दिव्य ब्रह्मांड' : 'Cosmic Space', desc: 'Saturn overlay' },
    { id: 'void', label: isHi ? 'परम शून्य' : 'Deep Void', desc: 'Event horizon halo' },
    { id: 'sunset', label: isHi ? 'स्वर्ण संध्या' : 'Sunset Glow', desc: 'Warm peach sky' },
    { id: 'waterfall', label: isHi ? 'प्रपात संगीत' : 'Waterfall', desc: 'Cliff & rushing stream' },
    { id: 'mountains', label: isHi ? 'मौन पर्वत' : 'Mountains', desc: 'Sage-stone peaks' }
  ];

  return (
    <div className="space-y-3">
      <div className="flex justify-between items-center">
        <span className="text-[9px] uppercase tracking-[0.25em] text-primary font-bold block">Atmosphere Customizer</span>
        <span className="text-[9px] text-white/40 block font-light">Customize your sanctuary environment</span>
      </div>
      <div className="flex gap-3 overflow-x-auto pb-2 scrollbar-hide book-shelf-row select-none">
        {themesList.map((t) => (
          <button
            key={t.id}
            onClick={() => updateSetting('theme', t.id)}
            className={`flex-none px-4 py-3 rounded-2xl border text-left transition-all duration-300 w-44 hover:scale-[1.02] ${
              theme === t.id
                ? 'border-primary bg-primary/10 text-primary shadow-lg shadow-primary/5'
                : 'border-white/5 bg-white/2 text-white/60 hover:border-white/10'
            }`}
          >
            <div className="flex justify-between items-center">
              <span className="text-xs font-bold truncate block">{t.label}</span>
              <div
                className="w-3 h-3 rounded-full border border-white/10 shrink-0"
                style={{ background: THEME_SWATCHES[t.id] }}
              />
            </div>
            <span className="text-[9px] text-white/35 mt-1 block font-light leading-none truncate">{t.desc}</span>
          </button>
        ))}
      </div>
    </div>
  );
};

export default React.memo(AtmosphereCustomizer);
