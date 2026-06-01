import React from 'react';
import { Link } from 'react-router-dom';
import { ChevronRight, FileText } from 'lucide-react';

const getBookGradient = (name) => {
  let h = 0;
  for (let i = 0; i < name.length; i++) h = name.charCodeAt(i) + ((h << 5) - h);
  const h1 = Math.abs(h % 360);
  const h2 = (h1 + 60) % 360;
  return `linear-gradient(135deg, hsl(${h1}, 75%, 26%) 0%, hsl(${h2}, 60%, 8%) 100%)`;
};

const LibraryShowcase = ({ isHi, books, navigate }) => {
  if (!books || books.length === 0) return null;

  return (
    <div className="space-y-5 text-left">
      <div className="flex justify-between items-end">
        <div>
          <span className="text-[9px] uppercase tracking-[0.25em] text-primary font-bold block mb-0.5">
            Sacred Library Catalog
          </span>
          <h2 className="text-xl md:text-2xl font-bold font-headings text-minimal-gold">
            {isHi ? "दिव्य ग्रन्थ एवं वाणी" : "Granthas & Scriptures"}
          </h2>
        </div>
        <Link
          to={isHi ? "/hi/granthas" : "/granthas"}
          className="text-xs text-primary hover:underline flex items-center gap-0.5 font-bold min-h-[30px] flex items-center"
        >
          {isHi ? "सभी ग्रन्थ" : "View All Granthas"}
          <ChevronRight size={14} />
        </Link>
      </div>

      
      <div className="flex gap-4 overflow-x-auto pb-4 pt-1 snap-x book-shelf-row scrollbar-hide select-none -mx-4 px-4 sm:mx-0 sm:px-0">
        {books.slice(0, 8).map((book, index) => (
          <div
            key={`${book.slug || book.name || 'book'}-${index}`}
            onClick={() => navigate(isHi ? `/hi/granthas/${book.slug}` : `/granthas/${book.slug}`)}
            className="w-[280px] sm:w-80 flex-none glass-card p-4 rounded-2xl hover:border-amber-500/25 transition-all snap-start flex gap-4 border border-white/5 cursor-pointer group shadow-lg touch-manipulation"
          >
            
            <div
              className="book-cover-premium shrink-0 text-white select-none shadow-xl w-[90px] h-[130px] rounded-lg overflow-hidden relative"
              style={{ background: getBookGradient(book.name) }}
            >
              <div className="book-cover-inner-gold">
                <div className="text-[8px] opacity-40 font-semibold tracking-widest">ॐ</div>
                <span className="text-[9px] font-bold line-clamp-3 text-center leading-tight tracking-wide uppercase px-0.5 text-white/90 font-headings">
                  {book.name.replace(/जी की वाणी/g, '').replace(/वाणी/g, '').replace(/ग्रन्थ/g, '')}
                </span>
                <span className="text-[7px] text-white/60 uppercase tracking-widest font-headings font-bold opacity-60">
                  SCRIPTURE
                </span>
              </div>
            </div>

            
            <div className="flex flex-col justify-between py-1 min-w-0 flex-1">
              <div className="space-y-1">
                <h3 className="font-bold text-xs text-white/95 group-hover:text-primary transition-colors leading-snug line-clamp-2">
                  {book.name}
                </h3>
                <span className="text-[10px] text-white/40 block truncate">
                  By {book.author ? book.author.replace(/जी/g, '') : 'Braj Rasik'}
                </span>
              </div>
              <div className="space-y-2">
                <span className="text-[9px] text-white/30 flex items-center gap-1">
                  <FileText size={10} />
                  {book.verses.length} verses
                </span>
                <button className="w-full bg-white/5 hover:bg-primary/20 text-white/70 hover:text-primary font-bold text-[9px] py-1.5 px-2 rounded-lg transition-colors border border-white/10 hover:border-primary/20 tracking-wider uppercase min-h-[28px] flex items-center justify-center">
                  {isHi ? "वाणी पढ़ें" : "Read Now"}
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default React.memo(LibraryShowcase);
