import React from 'react';
import { MapPin, BookOpen, ArrowRight } from 'lucide-react';

const PilgrimageHub = ({ isHi, navigate }) => {
  return (
    <div className="space-y-5">
      <div className="text-left">
        <span className="text-[9px] uppercase tracking-[0.25em] text-primary font-bold block mb-0.5">
          Spiritual Discovery & Geography
        </span>
        <h2 className="text-xl md:text-2xl font-bold font-headings text-minimal-gold">
          {isHi ? "ब्रज धाम एवं आध्यात्मिक ज्ञान" : "Divine Knowledge & Pilgrimage Hub"}
        </h2>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 sm:gap-6 text-left">
        
        <div
          onClick={() => navigate(isHi ? "/hi/places" : "/places")}
          className="glass-card p-5 sm:p-6 rounded-3xl border border-white/5 hover:border-orange-500/25 cursor-pointer group transition-all flex flex-col justify-between space-y-4 hover:scale-[1.01] touch-manipulation relative overflow-hidden"
          role="button"
          tabIndex={0}
          aria-label={isHi ? "ब्रज धाम दर्शन मार्गदर्शिका" : "Braj Dham Sacred Places"}
          onKeyDown={(e) => {
            if (e.key === 'Enter' || e.key === ' ') {
              navigate(isHi ? "/hi/places" : "/places");
            }
          }}
        >
          <div className="absolute top-2 right-2 scale-0 group-hover:scale-100 bg-black/80 text-[8px] text-white/90 px-1.5 py-0.5 rounded border border-white/10 transition-all duration-200 pointer-events-none whitespace-nowrap z-10">
            {isHi ? "दर्शन प्रारम्भ करें" : "Start journey"}
          </div>
          <div className="space-y-3">
            <div className="flex justify-between items-start">
              <div className="w-10 h-10 rounded-2xl bg-orange-500/5 border border-orange-500/10 flex items-center justify-center text-orange-400 group-hover:border-orange-500/30 transition-all duration-300 select-none">
                <MapPin size={18} />
              </div>
              <span className="text-[8px] bg-orange-500/10 text-orange-300 border border-orange-500/20 px-2.5 py-0.5 rounded-full uppercase tracking-wider font-bold select-none">
                {isHi ? "तीर्थ दर्शन" : "Pilgrimage"}
              </span>
            </div>
            <div className="space-y-1">
              <h3 className="font-bold text-sm md:text-base text-white/95 group-hover:text-orange-300 transition-colors leading-snug">
                {isHi ? "ब्रज धाम दर्शन मार्गदर्शिका" : "Braj Dham Sacred Places"}
              </h3>
              <p className="text-[11px] text-white/45 font-light leading-relaxed">
                {isHi
                  ? "वृंदावन के पावन वनों, कुंडों और संतों की साधना-स्थली का अलौकिक परिचय। आध्यात्मिक इतिहास और भौगोलिक महत्व के साथ।"
                  : "A spiritual guide to the holy groves, sacred lakes, and mystical temples of Vrindavan, complete with historical and saintly connections."
                }
              </p>
            </div>
          </div>
          <div className="flex items-center justify-between border-t border-white/5 pt-3">
            <span className="text-[9px] uppercase tracking-wider text-white/35 flex items-center gap-1 font-bold group-hover:text-orange-300 transition-colors select-none">
              {isHi ? "यात्रा प्रारंभ करें" : "Start Pilgrimage"} <ArrowRight size={10} />
            </span>
            <span className="text-[9px] text-white/30 font-light select-none">10+ Sacred Sites</span>
          </div>
        </div>

        
        <div
          onClick={() => navigate(isHi ? "/hi/glossary" : "/glossary")}
          className="glass-card p-5 sm:p-6 rounded-3xl border border-white/5 hover:border-cyan-500/25 cursor-pointer group transition-all flex flex-col justify-between space-y-4 hover:scale-[1.01] touch-manipulation relative overflow-hidden"
          role="button"
          tabIndex={0}
          aria-label={isHi ? "वृन्दावाणि शब्दावली" : "VrindaVaani Devotee Glossary"}
          onKeyDown={(e) => {
            if (e.key === 'Enter' || e.key === ' ') {
              navigate(isHi ? "/hi/glossary" : "/glossary");
            }
          }}
        >
          <div className="absolute top-2 right-2 scale-0 group-hover:scale-100 bg-black/80 text-[8px] text-white/90 px-1.5 py-0.5 rounded border border-white/10 transition-all duration-200 pointer-events-none whitespace-nowrap z-10">
            {isHi ? "शब्दावली खोजें" : "Explore glossary"}
          </div>
          <div className="space-y-3">
            <div className="flex justify-between items-start">
              <div className="w-10 h-10 rounded-2xl bg-cyan-500/5 border border-cyan-500/10 flex items-center justify-center text-cyan-400 group-hover:border-cyan-500/30 transition-all duration-300 select-none">
                <BookOpen size={18} />
              </div>
              <span className="text-[8px] bg-cyan-500/10 text-cyan-300 border border-cyan-500/20 px-2.5 py-0.5 rounded-full uppercase tracking-wider font-bold select-none">
                {isHi ? "शब्दावली" : "Encyclopedia"}
              </span>
            </div>
            <div className="space-y-1">
              <h3 className="font-bold text-sm md:text-base text-white/95 group-hover:text-cyan-300 transition-colors leading-snug">
                {isHi ? "वृन्दावाणि शब्दावली" : "VrindaVaani Devotee Glossary"}
              </h3>
              <p className="text-[11px] text-white/45 font-light leading-relaxed">
                {isHi
                  ? "वाणी साहित्य और रस उपासना में प्रयुक्त होने वाले गहन आध्यात्मिक शब्दों, दर्शनों और भावों का प्रामाणिक शब्दकोश।"
                  : "Explore the meanings, etymologies, and philosophical contexts of core theological terms used in the spiritual poetry of Vrindavan."
                }
              </p>
            </div>
          </div>
          <div className="flex items-center justify-between border-t border-white/5 pt-3">
            <span className="text-[9px] uppercase tracking-wider text-white/35 flex items-center gap-1 font-bold group-hover:text-cyan-300 transition-colors select-none">
              {isHi ? "शब्दकोश देखें" : "Explore Glossary"} <ArrowRight size={10} />
            </span>
            <span className="text-[9px] text-white/30 font-light select-none">15+ Core Terms</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default React.memo(PilgrimageHub);
