import React from 'react';
import { Link } from 'react-router-dom';
import { ChevronRight } from 'lucide-react';

const getInitials = (name) => {
  if (!name) return 'V';
  let clean = name.replace(/^(Shri|Swami|Sri|Shree|श्री|स्वामी|श्रीमद्)\s+/i, '').trim();
  if (!clean.length) clean = name;
  const first = clean.charAt(0);
  return first.match(/[a-zA-Z]/) ? first.toUpperCase() : first;
};

const SAINT_COLORS = [
  {
    borderHover: 'rgba(244, 114, 182, 0.25)',
    avatarBg: 'rgba(244, 114, 182, 0.05)',
    avatarBorder: 'rgba(244, 114, 182, 0.15)',
    avatarBorderHover: 'rgba(244, 114, 182, 0.45)',
    text: '#f472b6',
    badgeBg: 'rgba(244, 114, 182, 0.1)',
    badgeBorder: 'rgba(244, 114, 182, 0.2)'
  },
  {
    borderHover: 'rgba(226, 204, 122, 0.25)',
    avatarBg: 'rgba(226, 204, 122, 0.05)',
    avatarBorder: 'rgba(226, 204, 122, 0.15)',
    avatarBorderHover: 'rgba(226, 204, 122, 0.45)',
    text: '#e2cc7a',
    badgeBg: 'rgba(226, 204, 122, 0.1)',
    badgeBorder: 'rgba(226, 204, 122, 0.2)'
  },
  {
    borderHover: 'rgba(96, 165, 250, 0.25)',
    avatarBg: 'rgba(96, 165, 250, 0.05)',
    avatarBorder: 'rgba(96, 165, 250, 0.15)',
    avatarBorderHover: 'rgba(96, 165, 250, 0.45)',
    text: '#60a5fa',
    badgeBg: 'rgba(96, 165, 250, 0.1)',
    badgeBorder: 'rgba(96, 165, 250, 0.2)'
  },
  {
    borderHover: 'rgba(52, 211, 153, 0.25)',
    avatarBg: 'rgba(52, 211, 153, 0.05)',
    avatarBorder: 'rgba(52, 211, 153, 0.15)',
    avatarBorderHover: 'rgba(52, 211, 153, 0.45)',
    text: '#34d399',
    badgeBg: 'rgba(52, 211, 153, 0.1)',
    badgeBorder: 'rgba(52, 211, 153, 0.2)'
  },
  {
    borderHover: 'rgba(251, 146, 60, 0.25)',
    avatarBg: 'rgba(251, 146, 60, 0.05)',
    avatarBorder: 'rgba(251, 146, 60, 0.15)',
    avatarBorderHover: 'rgba(251, 146, 60, 0.45)',
    text: '#fb923c',
    badgeBg: 'rgba(251, 146, 60, 0.1)',
    badgeBorder: 'rgba(251, 146, 60, 0.2)'
  },
  {
    borderHover: 'rgba(167, 139, 250, 0.25)',
    avatarBg: 'rgba(167, 139, 250, 0.05)',
    avatarBorder: 'rgba(167, 139, 250, 0.15)',
    avatarBorderHover: 'rgba(167, 139, 250, 0.45)',
    text: '#a78bfa',
    badgeBg: 'rgba(167, 139, 250, 0.1)',
    badgeBorder: 'rgba(167, 139, 250, 0.2)'
  }
];

const SaintsSpotlight = ({ isHi, saints, navigate }) => {
  if (!saints || saints.length === 0) return null;

  return (
    <div className="space-y-5 text-left">
      <div className="flex justify-between items-end">
        <div>
          <span className="text-[9px] uppercase tracking-[0.25em] text-primary font-bold block mb-0.5">
            Divine Creators & Spiritual Guides
          </span>
          <h2 className="text-xl md:text-2xl font-bold font-headings text-minimal-gold">
            {isHi ? "परम पावन रसिक सन्त" : "VrindaVaani Devotee Saints"}
          </h2>
        </div>
        <Link
          to={isHi ? "/hi/saints" : "/saints"}
          className="text-xs text-primary hover:underline flex items-center gap-0.5 font-bold min-h-[30px] flex items-center relative group"
          aria-label={isHi ? "सभी रसिक संतों की जीवनियाँ देखें" : "View all Rasik saint biographies"}
          title={isHi ? "सभी सन्त देखें" : "View All Saints"}
        >
          {isHi ? "सभी सन्त" : "View All Saints"}
          <ChevronRight size={14} />
          <span className="absolute -top-7 right-0 scale-0 group-hover:scale-100 bg-black text-[9px] text-white/90 px-1.5 py-0.5 rounded border border-white/10 transition-all duration-200 pointer-events-none whitespace-nowrap z-30">
            {isHi ? "सभी संत जीवनी" : "Explore all saints"}
          </span>
        </Link>
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-6 gap-3 sm:gap-4">
        {saints.slice(0, 6).map((sant, index) => {
          const c = SAINT_COLORS[index % SAINT_COLORS.length];
          return (
            <div
              key={`${sant.slug || sant.cleanName || 'sant'}-${index}`}
              onClick={() => navigate(isHi ? `/hi/saints/${sant.slug}` : `/saints/${sant.slug}`)}
              className="glass-card !p-3 rounded-2xl border border-white/5 text-center cursor-pointer group transition-all flex flex-col items-center justify-between space-y-2.5 touch-manipulation hover:scale-[1.02] relative overflow-hidden"
              style={{
                '--hover-border': c.borderHover
              }}
              role="button"
              tabIndex={0}
              aria-label={isHi ? `संत: ${sant.name}` : `Saint: ${sant.hinglishName}`}
              onKeyDown={(e) => {
                if (e.key === 'Enter' || e.key === ' ') {
                  navigate(isHi ? `/hi/saints/${sant.slug}` : `/saints/${sant.slug}`);
                }
              }}
            >
              <div className="absolute top-1 right-1.5 scale-0 group-hover:scale-100 bg-black/85 text-[7px] text-white/90 px-1 py-0.5 rounded border border-white/10 transition-all duration-200 pointer-events-none whitespace-nowrap z-10">
                {isHi ? "जीवनी देखें" : "View Bio"}
              </div>

              <div
                className="w-12 h-12 sm:w-14 sm:h-14 rounded-full flex items-center justify-center font-bold text-base sm:text-lg shadow-inner group-hover:scale-105 transition-all duration-300 select-none border"
                style={{
                  backgroundColor: c.avatarBg,
                  borderColor: c.avatarBorder,
                  color: c.text,
                  '--avatar-border-hover': c.avatarBorderHover
                }}
              >
                {getInitials(isHi ? sant.name : sant.hinglishName)}
              </div>
              <div className="min-w-0 w-full px-1">
                <h3
                  className="font-bold text-[10px] sm:text-[11px] text-white/90 transition-colors line-clamp-2 w-full leading-tight py-0.5 saint-card-title"
                  style={{ '--text-hover-color': c.text }}
                >
                  {isHi ? sant.name : sant.hinglishName}
                </h3>
                <span className="text-[9px] text-white/35 font-light block mt-0.5">
                  {sant.verses ? sant.verses.length : (sant.verseIds ? sant.verseIds.length : 0)} verses
                </span>
              </div>
              <span
                className="text-[8px] px-2 py-0.5 rounded-full uppercase tracking-wider font-bold select-none border"
                style={{
                  backgroundColor: c.badgeBg,
                  borderColor: c.badgeBorder,
                  color: c.text
                }}
                aria-label={isHi ? `${sant.name} का अन्वेषण करें` : `Explore ${sant.hinglishName}`}
              >
                Explore
              </span>
            </div>
          );
        })}
      </div>
    </div>
  );
};

export default React.memo(SaintsSpotlight);
