import React from 'react';
import { Link } from 'react-router-dom';
import { ChevronRight, Clock, ArrowRight } from 'lucide-react';
import AudioPlayButton from '../ui/AudioPlayButton';

const LatestVersesFeed = ({ isHi, latestVerses, navigate }) => {
  if (!latestVerses || latestVerses.length === 0) return null;

  return (
    <div className="space-y-5 text-left">
      <div className="flex justify-between items-end">
        <div>
          <span className="text-[9px] uppercase tracking-[0.25em] text-primary font-bold block mb-0.5">
            Freshly Curated Spiritual Wisdom
          </span>
          <h2 className="text-xl md:text-2xl font-bold font-headings text-minimal-gold">
            {isHi ? "नवीनतम वाणी एवं श्लोक" : "Latest Verse Feed"}
          </h2>
        </div>
        <Link
          to={isHi ? "/hi/content" : "/content"}
          className="text-xs text-primary hover:underline flex items-center gap-0.5 font-bold min-h-[30px] flex items-center"
        >
          {isHi ? "सम्पूर्ण वाणियाँ" : "View Library"}
          <ChevronRight size={14} />
        </Link>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-5 sm:gap-6">
        {latestVerses.map((verse, index) => {
          const excerpt =
            verse.hindi_text ||
            verse.sanskrit_text ||
            verse.english_translation ||
            verse.description ||
            "";
          const readingTime = Math.max(1, Math.ceil(excerpt.length / 120)) + " min read";

          return (
            <div
              key={`${verse.slug || verse.id || 'verse'}-${index}`}
              onClick={() => navigate(isHi ? `/hi/content/${verse.slug || verse.id}` : `/content/${verse.slug || verse.id}`)}
              className="premium-content-card p-5 cursor-pointer flex flex-col justify-between space-y-4 group hover:scale-[1.01] transition-all duration-300 touch-manipulation"
            >
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <span className="text-[9px] uppercase tracking-wider text-amber-500/80 bg-amber-500/5 px-2.5 py-0.5 rounded border border-amber-500/10 font-bold select-none">
                    {verse.category}
                  </span>
                  <span className="text-[9px] text-white/30 flex items-center gap-1 font-light select-none">
                    <Clock size={10} />
                    {readingTime}
                  </span>
                </div>
                <div className="space-y-1">
                  <h3 className="font-bold text-sm text-white/95 group-hover:text-primary transition-colors leading-snug line-clamp-2">
                    {verse.cleanTitle || verse.title}
                  </h3>
                  {verse.author && (
                    <span className="text-[10px] text-white/40 block font-light">
                      By {verse.author.replace(/जी/g, '')}
                    </span>
                  )}
                </div>
                <p className="text-[11px] text-white/45 font-light leading-relaxed line-clamp-3 select-none">
                  {excerpt}
                </p>
              </div>

              <div className="flex items-center justify-between border-t border-white/5 pt-3 shrink-0">
                <span className="text-[9px] uppercase tracking-wider text-white/35 flex items-center gap-1 font-bold group-hover:text-primary transition-colors select-none">
                  Read Verse <ArrowRight size={10} />
                </span>
                {verse.audio_url && (
                  <div onClick={(e) => e.stopPropagation()} className="relative z-20">
                    <AudioPlayButton
                      track={verse}
                      className="bg-sky-500/10 text-sky-400 border border-sky-500/20 p-2 rounded-full hover:scale-105 transition-transform"
                      size={14}
                    />
                  </div>
                )}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

export default React.memo(LatestVersesFeed);
