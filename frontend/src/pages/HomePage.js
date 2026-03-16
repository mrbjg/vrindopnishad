import React from 'react';
import { Link } from 'react-router-dom';
import { Compass, Scroll, Music, FileText, ArrowRight } from 'lucide-react';

const HomePage = () => {
  return (
    <div className="animate-fade-in">
      {/* Hero Section */}
      <div className="text-center py-12 md:py-24 max-w-4xl mx-auto">
        <div className="om-symbol text-[#fbbf24] text-4xl mb-6 opacity-80 animate-pulse">ॐ</div>
        <h1 className="text-5xl md:text-7xl font-bold mb-6 tracking-tight text-white drop-shadow-2xl">
          वृंदोपनिषद्
        </h1>
        <p className="text-lg md:text-xl text-white/70 font-light max-w-2xl mx-auto leading-relaxed mb-12">
          Discover the spiritual essence of Hindu culture. 
          A sacred digital sanctuary for devotional poetry, verses, and hymns.
        </p>

        <div className="flex flex-wrap justify-center gap-4">
          <Link to="/content" className="btn-premium">
            <Compass size={20} />
            Explore Content
          </Link>
          <Link to="/category/shloka" className="px-8 py-3 rounded-full border border-white/20 hover:bg-white/5 transition-all flex items-center gap-2 font-medium">
            <Scroll size={20} className="text-primary" />
            Browse Shlokas
          </Link>
        </div>
      </div>

      {/* Categories Grid */}
      <div className="py-12">
        <div className="flex items-center gap-4 mb-12">
          <div className="h-[1px] flex-1 bg-white/10"></div>
          <h2 className="text-2xl font-semibold opacity-60 uppercase tracking-widest">Categories</h2>
          <div className="h-[1px] flex-1 bg-white/10"></div>
        </div>

        <div className="content-grid">
          <Link to="/category/shloka" className="glass-card flex flex-col items-center text-center">
             <div className="w-16 h-16 rounded-full bg-primary/20 flex items-center justify-center text-primary mb-6 shadow-inner">
               <Scroll size={32} />
             </div>
             <div className="badge border-primary/30 text-primary/80">Vedas & Upanishads</div>
             <h3 className="text-xl font-bold mb-4">Sacred Verses</h3>
             <p className="text-white/60 text-sm leading-relaxed">
               Dive into the timeless wisdom of Sanskrit shlokas from ancient scriptures.
             </p>
          </Link>

          <Link to="/category/strotra" className="glass-card flex flex-col items-center text-center">
             <div className="w-16 h-16 rounded-full bg-blue-500/20 flex items-center justify-center text-blue-400 mb-6 shadow-inner">
               <Music size={32} />
             </div>
             <div className="badge border-blue-400/30 text-blue-400/80">Devotional Hymns</div>
             <h3 className="text-xl font-bold mb-4">Strotras</h3>
             <p className="text-white/60 text-sm leading-relaxed">
               Experience the power of traditional hymns and prayers dedicated to the divine.
             </p>
          </Link>

          <Link to="/category/poem" className="glass-card flex flex-col items-center text-center">
             <div className="w-16 h-16 rounded-full bg-purple-500/20 flex items-center justify-center text-purple-400 mb-6 shadow-inner">
               <FileText size={32} />
             </div>
             <div className="badge border-purple-400/30 text-purple-400/80">Spiritual Poetry</div>
             <h3 className="text-xl font-bold mb-4">Poems</h3>
             <p className="text-white/60 text-sm leading-relaxed">
               Contemporary and classic spiritual poetry expressing the depths of devotion.
             </p>
          </Link>
        </div>
      </div>

      {/* Call to action */}
      <div className="mt-24 p-8 md:p-16 glass-card text-center relative overflow-hidden group">
        <div className="absolute inset-0 bg-gradient-to-br from-primary/10 to-transparent opacity-50"></div>
        <div className="relative z-10">
          <h2 className="text-3xl font-bold mb-6">Start Your Spiritual Journey</h2>
          <p className="text-white/70 max-w-xl mx-auto mb-10 leading-relaxed">
             Immerse yourself in sacred texts with audio narrations, beautiful imagery, and deep spiritual insights.
          </p>
          <Link to="/content" className="btn-premium px-12 py-4">
             Enter Presence
             <ArrowRight size={20} />
          </Link>
        </div>
      </div>
    </div>
  );
};

export default HomePage;
