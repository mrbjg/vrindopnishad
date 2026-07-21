import React from 'react';
import Link from 'next/link';

export default function NotFound() {
  return (
    <div className="py-16 md:py-24 flex items-center justify-center relative overflow-hidden min-h-[70vh]">
      {/* Background ambient glow matching theme */}
      <div className="absolute inset-0 z-0 pointer-events-none overflow-hidden">
        <div className="absolute top-[20%] left-[30%] w-[40vw] h-[40vw] rounded-full bg-primary/5 blur-[120px] animate-pulse"></div>
        <div className="absolute bottom-[20%] right-[30%] w-[35vw] h-[35vw] rounded-full bg-amber-500/5 blur-[120px] animate-pulse"></div>
      </div>

      <div className="relative z-10 w-full max-w-lg mx-auto px-6 text-center select-none space-y-6">
        {/* Sacred Om badge */}
        <div className="inline-flex items-center justify-center w-20 h-20 rounded-full bg-primary/10 border border-primary/20 shadow-lg shadow-primary/5 transition-transform hover:scale-105 duration-300">
          <span className="text-4xl text-primary font-serif">ॐ</span>
        </div>

        <div className="space-y-2">
          <h1 className="text-3xl sm:text-4xl font-bold font-headings text-amber-500 dark:text-amber-400">
            404 - पृष्ठ नहीं मिला
          </h1>
          
          <p className="text-sm sm:text-base text-foreground/60 max-w-md mx-auto leading-relaxed font-light">
            The page you are looking for has departed to another realm, or the slug has changed. Please verify the URL or return to home.
          </p>
        </div>

        <div className="flex flex-col sm:flex-row items-center justify-center gap-3 pt-2">
          <Link
            href="/"
            className="btn-premium px-6 py-3 text-xs w-full sm:w-auto justify-center"
          >
            Go to Home
          </Link>
          <Link
            href="/lyrics"
            className="px-6 py-3 rounded-full border border-white/10 hover:border-white/20 bg-white/5 hover:bg-white/10 text-xs font-semibold text-foreground/80 transition-all w-full sm:w-auto text-center"
          >
            Explore Library
          </Link>
        </div>
      </div>
    </div>
  );
}
