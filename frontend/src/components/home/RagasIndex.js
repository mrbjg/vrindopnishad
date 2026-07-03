import React from 'react';
import { Link } from 'react-router-dom';
import { Music, Volume2 } from 'lucide-react';

const RagasIndex = ({ isHi, ragas, navigate }) => {
  if (!ragas || ragas.length === 0) return null;

  return (
    <div className="glass-card p-4 sm:p-5 rounded-2xl border border-white/5 space-y-4 max-w-4xl mx-auto shadow-md text-left">
      <div className="flex justify-between items-center pb-2 border-b border-white/5 select-none">
        <h3 className="text-xs font-bold text-minimal-gold uppercase tracking-wider flex items-center gap-1.5 font-headings">
          <Music size={12} className="text-primary" />
          {isHi ? "राग रागिनियाँ" : "Classical Ragas"}
        </h3>
        <Link
          to={isHi ? "/hi/ragas" : "/ragas"}
          className="text-[10px] text-primary hover:underline font-bold min-h-[24px] flex items-center"
        >
          {isHi ? "सभी राग" : "View All"}
        </Link>
      </div>
      <div className="flex flex-wrap gap-2">
        {ragas.slice(0, 10).map((raga, index) => (
          <button
            key={`${raga.slug || raga.name || 'raga'}-${index}`}
            onClick={() => navigate(isHi ? `/hi/ragas/${raga.slug}` : `/ragas/${raga.slug}`)}
            className="flex items-center gap-1.5 px-3 py-2 rounded-xl bg-white/5 hover:bg-white/10 border border-white/5 hover:border-white/10 text-xs text-left transition-all group touch-manipulation hover:scale-[1.02]"
          >
            <span className="font-semibold text-white/90 group-hover:text-primary transition-colors text-[11px]">
              {raga.name}
            </span>
            <span className="text-[9px] text-white/35 font-light bg-white/5 px-1.5 py-0.5 rounded-md flex items-center gap-0.5 shrink-0 select-none">
              <Volume2 size={8} />
              {raga.verses ? raga.verses.length : (raga.verseIds ? raga.verseIds.length : 0)}
            </span>
          </button>
        ))}
      </div>
    </div>
  );
};

export default React.memo(RagasIndex);
