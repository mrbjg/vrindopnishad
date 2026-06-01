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
            {isHi ? "परम पावन रसिक सन्त" : "Braj Rasik Saints"}
          </h2>
        </div>
        <Link
          to={isHi ? "/hi/saints" : "/saints"}
          className="text-xs text-primary hover:underline flex items-center gap-0.5 font-bold min-h-[30px] flex items-center"
        >
          {isHi ? "सभी सन्त" : "View All Saints"}
          <ChevronRight size={14} />
        </Link>
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-6 gap-3 sm:gap-4">
        {saints.slice(0, 6).map((sant, index) => (
          <div
            key={`${sant.slug || sant.cleanName || 'sant'}-${index}`}
            onClick={() => navigate(isHi ? `/hi/saints/${sant.slug}` : `/saints/${sant.slug}`)}
            className="glass-card !p-3 rounded-2xl border border-white/5 hover:border-amber-500/20 text-center cursor-pointer group transition-all flex flex-col items-center justify-between space-y-2.5 touch-manipulation hover:scale-[1.02]"
          >
            <div className="w-12 h-12 sm:w-14 sm:h-14 rounded-full bg-amber-500/5 border border-amber-500/10 group-hover:border-amber-500/40 flex items-center justify-center text-amber-500 font-bold text-base sm:text-lg shadow-inner group-hover:scale-105 transition-all duration-300 select-none">
              {getInitials(isHi ? sant.name : sant.hinglishName)}
            </div>
            <div className="min-w-0 w-full px-1">
              <h3 className="font-bold text-[10px] sm:text-[11px] text-white/90 group-hover:text-primary transition-colors line-clamp-2 w-full leading-tight py-0.5 saint-card-title">
                {isHi ? sant.name : sant.hinglishName}
              </h3>
              <span className="text-[9px] text-white/35 font-light block mt-0.5">
                {sant.verses.length} verses
              </span>
            </div>
            <span className="text-[8px] bg-amber-500/10 text-primary border border-amber-500/20 px-2 py-0.5 rounded-full uppercase tracking-wider font-bold select-none">
              Explore
            </span>
          </div>
        ))}
      </div>
    </div>
  );
};

export default React.memo(SaintsSpotlight);
