import React from 'react';
import Link from 'next/link';

export default function NotFound() {
  return (
    <div className="min-h-screen flex items-center justify-center relative overflow-hidden bg-slate-950 font-sans">
      {/* Background design system matching layout.js / App.js theme */}
      <div className="absolute inset-0 z-0 pointer-events-none overflow-hidden">
        <div className="absolute top-[20%] left-[30%] w-[40vw] h-[40vw] rounded-full bg-amber-500/10 blur-[120px] animate-pulse duration-5000"></div>
        <div className="absolute bottom-[20%] right-[30%] w-[35vw] h-[35vw] rounded-full bg-violet-600/10 blur-[120px] animate-pulse duration-7000"></div>
        {/* Subtle grid pattern overlay */}
        <div className="absolute inset-0 bg-[radial-gradient(ellipse_80%_80%_at_50%_-20%,rgba(120,119,198,0.15),rgba(255,255,255,0))]"></div>
      </div>

      <div className="relative z-10 w-full max-w-lg mx-auto px-6 text-center select-none">
        {/* Divine symbol with glowing effect */}
        <div className="inline-flex items-center justify-center w-24 h-24 rounded-full bg-amber-500/10 border border-amber-500/20 shadow-[0_0_50px_rgba(245,158,11,0.05)] mb-8 transition-transform hover:scale-105 duration-300">
          <span className="text-5xl text-amber-400 font-serif drop-shadow-[0_0_8px_rgba(245,158,11,0.3)]">ॐ</span>
        </div>

        <h1 className="text-4xl sm:text-5xl font-semibold tracking-tight text-white mb-4">
          404 - पृष्ठ नहीं मिला
        </h1>
        
        <p className="text-base sm:text-lg text-slate-400 max-w-md mx-auto mb-10 leading-relaxed">
          The page you are looking for has departed to another realm, or the slug has changed. Please verify the URL or return to home.
        </p>

        <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
          <Link
            href="/"
            className="w-full sm:w-auto px-8 py-3.5 bg-gradient-to-r from-amber-500 to-amber-600 hover:from-amber-400 hover:to-amber-500 text-slate-950 font-semibold rounded-xl shadow-lg shadow-amber-500/10 transition-all hover:-translate-y-0.5 active:translate-y-0 select-none text-center"
          >
            Go to Home
          </Link>
          <Link
            href="/content"
            className="w-full sm:w-auto px-8 py-3.5 bg-white/5 hover:bg-white/10 text-white font-medium rounded-xl border border-white/10 transition-all hover:-translate-y-0.5 active:translate-y-0 select-none text-center"
          >
            Explore Library
          </Link>
        </div>
      </div>
    </div>
  );
}
