import React, { useState, useEffect } from 'react';
import { ChevronRight } from 'lucide-react';

const DailySwadhyaya = ({
  isHi,
  dailyShloka,
  streak,
  isCompleted,
  handleComplete,
  particles,
}) => {
  const [activeTab, setActiveTab] = useState('verse'); // 'verse' | 'translation' | 'breakdown'
  const [isPlaying, setIsPlaying] = useState(false);

  // Speak / Speech synthesis handler optimized for mobile browsers
  const handleChantAudio = () => {
    if (isPlaying) {
      window.speechSynthesis.cancel();
      setIsPlaying(false);
    } else {
      window.speechSynthesis.cancel();
      const utterance = new SpeechSynthesisUtterance(dailyShloka.sanskrit);

      const voices = window.speechSynthesis.getVoices();
      // Search for Hindi or Sanskrit voice matching mobile browsers (iOS/Android)
      const hiVoice = voices.find(
        (v) =>
          v.lang.startsWith('hi') ||
          v.lang.startsWith('sa') ||
          v.name.includes('Hindi') ||
          v.name.includes('Sanskrit')
      );
      if (hiVoice) {
        utterance.voice = hiVoice;
      }
      utterance.rate = 0.75; // Slower rate for clear pronunciation
      utterance.pitch = 0.9;

      utterance.onend = () => setIsPlaying(false);
      utterance.onerror = () => setIsPlaying(false);

      window.speechSynthesis.speak(utterance);
      setIsPlaying(true);
    }
  };

  useEffect(() => {
    return () => {
      window.speechSynthesis.cancel();
    };
  }, []);

  return (
    <div className="glass-card p-4 sm:p-6 md:p-8 rounded-3xl border border-primary/10 shadow-2xl relative overflow-hidden h-full flex flex-col justify-between group">
      <div className="absolute top-0 right-0 p-6 opacity-[0.02] pointer-events-none hidden sm:block">
        <ChevronRight size={180} className="text-primary" />
      </div>

      <div>
        <div className="flex items-center justify-between mb-4 border-b border-white/5 pb-3">
          <div className="flex items-center gap-2">
            <span className="w-2.5 h-2.5 rounded-full bg-primary animate-ping" />
            <span className="text-[10px] uppercase tracking-[0.2em] text-white/60 font-bold">
              {isHi ? "दैनिक स्वाध्याय" : "Daily Swadhyaya"}
            </span>
          </div>
          <span className="text-[9px] font-bold text-primary bg-primary/5 border border-primary/10 px-2 py-0.5 rounded-md uppercase tracking-wider font-mono">
            {dailyShloka.source}
          </span>
        </div>

        {/* Sliding Tabs - Large Touch Targets for Mobile */}
        <div className="flex bg-white/5 p-1 rounded-xl gap-1 mb-5 relative select-none">
          {['verse', 'translation', 'breakdown'].map((tab) => (
            <button
              key={tab}
              onClick={() => {
                setActiveTab(tab);
                if (isPlaying) {
                  window.speechSynthesis.cancel();
                  setIsPlaying(false);
                }
              }}
              className={`flex-1 py-2 text-[10px] sm:text-xs font-bold uppercase tracking-wider rounded-lg transition-all z-10 touch-manipulation min-h-[36px] ${
                activeTab === tab ? 'text-primary' : 'text-white/45 hover:text-white/70'
              }`}
            >
              {tab === 'verse'
                ? isHi ? "श्लोक" : "Verse"
                : tab === 'translation'
                ? isHi ? "भावार्थ" : "Translation"
                : isHi ? "शब्दार्थ" : "Breakdown"}
            </button>
          ))}
          {/* Sliding indicator */}
          <div
            className="absolute top-1 bottom-1 bg-white/[0.04] border border-white/10 rounded-lg transition-all duration-300 ease-out z-0"
            style={{
              width: 'calc(33.33% - 4px)',
              left: activeTab === 'verse' ? '2px' : activeTab === 'translation' ? '33.33%' : '66.66%'
            }}
          />
        </div>
      </div>

      {/* Tab Content - Responsive Padding & Font Sizes */}
      <div className="min-h-[10rem] flex flex-col justify-center transition-all duration-300 flex-1">
        {activeTab === 'verse' && (
          <div className="space-y-5 animate-in fade-in zoom-in-95 duration-200 text-center">
            <blockquote className="text-center">
              <p className="text-sm sm:text-base md:text-lg font-bold text-minimal-gold leading-relaxed sm:leading-loose font-headings whitespace-pre-line select-all px-1">
                {dailyShloka.sanskrit}
              </p>
            </blockquote>

            <div className="flex justify-center gap-2.5 sm:gap-3">
              <button
                onClick={handleChantAudio}
                className={`flex items-center justify-center gap-2 px-3.5 py-2.5 rounded-full border transition-all text-xs font-bold touch-manipulation min-h-[40px] ${
                  isPlaying
                    ? 'border-primary bg-primary/10 text-primary'
                    : 'border-white/10 hover:border-primary/30 text-white/70'
                }`}
              >
                <span>{isPlaying ? '⏸' : '▶'}</span>
                <span>{isHi ? "सुनिए" : "Listen"}</span>
                {isPlaying && (
                  <div className="flex items-center gap-0.5 h-3 ml-1 shrink-0">
                    <span className="w-0.5 bg-primary rounded-full animate-bar-pulse-1" style={{ height: '4px' }} />
                    <span className="w-0.5 bg-primary rounded-full animate-bar-pulse-2" style={{ height: '8px' }} />
                    <span className="w-0.5 bg-primary rounded-full animate-bar-pulse-3" style={{ height: '12px' }} />
                    <span className="w-0.5 bg-primary rounded-full animate-bar-pulse-4" style={{ height: '6px' }} />
                  </div>
                )}
              </button>

              <button
                onClick={handleComplete}
                className={`flex items-center justify-center gap-2 px-3.5 py-2.5 rounded-full border transition-all text-xs font-bold relative touch-manipulation min-h-[40px] ${
                  isCompleted
                    ? 'border-green-500 bg-green-500/10 text-green-500 cursor-default'
                    : 'border-white/10 hover:border-green-500/30 text-white/70'
                }`}
              >
                <span>{isCompleted ? '✓' : '📿'}</span>
                <span>{isCompleted ? (isHi ? "पूर्ण" : "Completed") : (isHi ? "Mark Read" : "Mark Read")}</span>

                {particles.map((p) => (
                  <span
                    key={p.id}
                    className="absolute w-1.5 h-1.5 rounded-full pointer-events-none animate-particle"
                    style={{
                      background: p.color,
                      '--particle-x': `${p.x}px`,
                      '--particle-y': `${p.y}px`,
                      transform: `scale(${p.scale})`
                    }}
                  />
                ))}
              </button>
            </div>

            {streak > 0 && (
              <div className="text-[9px] text-primary/70 font-bold uppercase tracking-widest text-center animate-in fade-in slide-in-from-bottom-2">
                🔥 {streak} {isHi ? "दिवसीय सिलसिला" : "Day Streak"}
              </div>
            )}
          </div>
        )}

        {activeTab === 'translation' && (
          <div className="space-y-3.5 text-left animate-in fade-in zoom-in-95 duration-200">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-1 xl:grid-cols-2 gap-3 text-xs font-light leading-relaxed">
              <div className="space-y-1">
                <span className="text-[8px] uppercase tracking-wider text-primary font-bold block">भावार्थ (Hindi)</span>
                <p className="text-white/80 font-medium leading-relaxed whitespace-pre-line">{dailyShloka.hindi}</p>
              </div>
              <div className="border-t md:border-t-0 md:border-l lg:border-l-0 lg:border-t xl:border-t-0 xl:border-l border-white/5 pt-3.5 md:pt-0 md:pl-3.5 lg:pl-0 lg:pt-3.5 xl:pt-0 xl:pl-3.5 space-y-1">
                <span className="text-[8px] uppercase tracking-wider text-sky-400/80 font-bold block">English</span>
                <p className="text-white/70 italic leading-relaxed whitespace-pre-line">{dailyShloka.english}</p>
              </div>
            </div>

            <div className="mt-2.5 border-t border-white/5 pt-2.5">
              <span className="text-[8px] uppercase tracking-wider text-primary font-bold block mb-1">
                💡 {isHi ? "व्यावहारिक सूत्र" : "Practical Takeaway"}
              </span>
              <p className="text-white/75 text-xs italic font-medium leading-relaxed">{dailyShloka.takeaway}</p>
            </div>
          </div>
        )}

        {activeTab === 'breakdown' && (
          <div className="grid grid-cols-2 gap-1.5 text-left animate-in fade-in zoom-in-95 duration-200">
            {dailyShloka.breakdown.map((item, idx) => (
              <div
                key={idx}
                className="bg-white/[0.015] border border-white/5 rounded-xl p-2 flex flex-col gap-0.5 hover:border-primary/20 transition-all"
              >
                <span className="text-[11px] font-bold text-minimal-gold truncate">{item.sanskrit}</span>
                <span className="text-[9px] text-white/50 truncate">{item.meaning}</span>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default React.memo(DailySwadhyaya);
