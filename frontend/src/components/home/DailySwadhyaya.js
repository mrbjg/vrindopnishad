import React, { useState, useEffect } from 'react';
import { ChevronRight, Share2, Copy, MessageCircle } from 'lucide-react';
import { shareVerseCard } from '../../utils/shareCard';

const DailySwadhyaya = ({
  isHi,
  dailyShloka,
  streak,
  isCompleted,
  handleComplete,
  particles,
}) => {
  const [activeTab, setActiveTab] = useState('verse'); 
  const [isPlaying, setIsPlaying] = useState(false);
  const [copiedText, setCopiedText] = useState(null);

  const handleCopy = (text, type) => {
    navigator.clipboard.writeText(text).then(() => {
      setCopiedText(type);
      setTimeout(() => setCopiedText(null), 2000);
    });
  };

  
  const handleChantAudio = () => {
    if (isPlaying) {
      window.speechSynthesis.cancel();
      setIsPlaying(false);
    } else {
      window.speechSynthesis.cancel();
      const utterance = new SpeechSynthesisUtterance(dailyShloka.sanskrit);

      const voices = window.speechSynthesis.getVoices();
      
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
      utterance.rate = 0.75; 
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
          
          <div
            className="absolute top-1 bottom-1 bg-white/[0.04] border border-white/10 rounded-lg transition-all duration-300 ease-out z-0"
            style={{
              width: 'calc(33.33% - 4px)',
              left: activeTab === 'verse' ? '2px' : activeTab === 'translation' ? '33.33%' : '66.66%'
            }}
          />
        </div>
      </div>

      
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
                className={`flex items-center justify-center gap-2 px-3.5 py-2.5 rounded-full border transition-all text-xs font-bold touch-manipulation min-h-[40px] relative group ${
                  isPlaying
                    ? 'border-primary bg-primary/10 text-primary'
                    : 'border-white/10 hover:border-primary/30 text-white/70'
                }`}
                title={isPlaying ? (isHi ? "ऑडियो रोकें" : "Pause Audio") : (isHi ? "ऑडियो सुनें" : "Listen to Audio")}
                aria-label={isPlaying ? "Pause Audio" : "Listen to Audio"}
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
                <span className="absolute -top-8 left-1/2 -translate-x-1/2 scale-0 group-hover:scale-100 bg-black text-[10px] text-white/90 px-2 py-1 rounded border border-white/10 transition-all duration-200 pointer-events-none whitespace-nowrap z-50">
                  {isPlaying ? (isHi ? "ऑडियो रोकें" : "Pause Audio") : (isHi ? "ऑडियो सुनें" : "Listen to Audio")}
                </span>
              </button>

              <button
                onClick={handleComplete}
                className={`flex items-center justify-center gap-2 px-3.5 py-2.5 rounded-full border transition-all text-xs font-bold relative touch-manipulation min-h-[40px] group ${
                  isCompleted
                    ? 'border-green-500 bg-green-500/10 text-green-500 cursor-default'
                    : 'border-white/10 hover:border-green-500/30 text-white/70'
                }`}
                title={isCompleted ? (isHi ? "पढ़ना पूर्ण किया" : "Already Completed") : (isHi ? "पढ़ा हुआ चिह्नित करें" : "Mark as Completed")}
                aria-label={isCompleted ? "Completed" : "Mark as Completed"}
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
                <span className="absolute -top-8 left-1/2 -translate-x-1/2 scale-0 group-hover:scale-100 bg-black text-[10px] text-white/90 px-2 py-1 rounded border border-white/10 transition-all duration-200 pointer-events-none whitespace-nowrap z-50">
                  {isCompleted ? (isHi ? "पूर्ण हुआ" : "Completed") : (isHi ? "पढ़ा हुआ चिह्नित करें" : "Mark as Read")}
                </span>
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
                <div className="flex items-center justify-between">
                  <span className="text-[8px] uppercase tracking-wider text-primary font-bold">भावार्थ (Hindi)</span>
                  <button 
                    onClick={() => handleCopy(dailyShloka.hindi, 'hindi')}
                    className="text-[9px] text-white/40 hover:text-white transition-colors flex items-center gap-0.5 relative group"
                    title={isHi ? "हिंदी भावार्थ कॉपी करें" : "Copy Hindi Translation"}
                    aria-label="Copy Hindi Translation"
                  >
                    <Copy size={9} aria-hidden="true" />
                    <span>{copiedText === 'hindi' ? (isHi ? "कॉपी हुआ" : "Copied") : (isHi ? "कॉपी" : "Copy")}</span>
                    <span className="absolute -top-6 left-1/2 -translate-x-1/2 scale-0 group-hover:scale-100 bg-black text-[9px] text-white/90 px-1.5 py-0.5 rounded border border-white/10 transition-all duration-200 pointer-events-none whitespace-nowrap z-50">
                      {copiedText === 'hindi' ? (isHi ? "कॉपी हुआ!" : "Copied!") : (isHi ? "कॉपी करें" : "Copy Translation")}
                    </span>
                  </button>
                </div>
                <p className="text-white/80 font-medium leading-relaxed whitespace-pre-line">{dailyShloka.hindi}</p>
              </div>
              <div className="border-t md:border-t-0 md:border-l lg:border-l-0 lg:border-t xl:border-t-0 xl:border-l border-white/5 pt-3.5 md:pt-0 md:pl-3.5 lg:pl-0 lg:pt-3.5 xl:pt-0 xl:pl-3.5 space-y-1">
                <div className="flex items-center justify-between">
                  <span className="text-[8px] uppercase tracking-wider text-sky-400/80 font-bold">English</span>
                  <button 
                    onClick={() => handleCopy(dailyShloka.english, 'english')}
                    className="text-[9px] text-white/40 hover:text-white transition-colors flex items-center gap-0.5 relative group"
                    title={isHi ? "अंग्रेजी अनुवाद कॉपी करें" : "Copy English Translation"}
                    aria-label="Copy English Translation"
                  >
                    <Copy size={9} aria-hidden="true" />
                    <span>{copiedText === 'english' ? (isHi ? "कॉपी हुआ" : "Copied") : (isHi ? "कॉपी" : "Copy")}</span>
                    <span className="absolute -top-6 left-1/2 -translate-x-1/2 scale-0 group-hover:scale-100 bg-black text-[9px] text-white/90 px-1.5 py-0.5 rounded border border-white/10 transition-all duration-200 pointer-events-none whitespace-nowrap z-50">
                      {copiedText === 'english' ? (isHi ? "कॉपी हुआ!" : "Copied!") : (isHi ? "कॉपी करें" : "Copy Translation")}
                    </span>
                  </button>
                </div>
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

        {/* Share & Copy Actions (Problem #4 & #15) */}
        <div className="flex flex-wrap items-center justify-center gap-2 pt-3.5 border-t border-white/5 mt-5 font-sans">
          <button
            onClick={() => handleCopy(dailyShloka.sanskrit, 'sanskrit')}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-white/5 hover:bg-white/10 text-white/60 hover:text-white transition-all text-[10px] font-semibold border border-white/5 relative group"
            title={isHi ? "संस्कृत श्लोक कॉपी करें" : "Copy Sanskrit Verse"}
            aria-label="Copy Sanskrit Verse"
          >
            <Copy size={11} aria-hidden="true" />
            <span>{copiedText === 'sanskrit' ? (isHi ? "कॉपी हुआ!" : "Copied!") : (isHi ? "श्लोक कॉपी" : "Copy Verse")}</span>
            <span className="absolute -top-8 left-1/2 -translate-x-1/2 scale-0 group-hover:scale-100 bg-black text-[10px] text-white/90 px-2 py-1 rounded border border-white/10 transition-all duration-200 pointer-events-none whitespace-nowrap z-50">
              {copiedText === 'sanskrit' ? (isHi ? "कॉपी हुआ!" : "Copied!") : (isHi ? "श्लोक कॉपी करें" : "Copy Sanskrit")}
            </span>
          </button>

          <button
            onClick={() => {
              const text = `${dailyShloka.sanskrit}\n\n${isHi ? 'भावार्थ' : 'Translation'}: ${isHi ? dailyShloka.hindi : dailyShloka.english}\n\n— ${dailyShloka.source}\n\nvia path.vrindopnishad.in`;
              const url = `https://api.whatsapp.com/send?text=${encodeURIComponent(text)}`;
              window.open(url, '_blank');
            }}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-[#25D366]/10 hover:bg-[#25D366]/20 text-[#25D366] hover:text-[#25D366]/90 transition-all text-[10px] font-semibold border border-[#25D366]/10 relative group"
            title={isHi ? "व्हाट्सएप पर साझा करें" : "Share on WhatsApp"}
            aria-label="Share on WhatsApp"
          >
            <MessageCircle size={11} aria-hidden="true" />
            <span>WhatsApp</span>
            <span className="absolute -top-8 left-1/2 -translate-x-1/2 scale-0 group-hover:scale-100 bg-black text-[10px] text-white/90 px-2 py-1 rounded border border-white/10 transition-all duration-200 pointer-events-none whitespace-nowrap z-50">
              {isHi ? "व्हाट्सएप पर शेयर" : "Share on WhatsApp"}
            </span>
          </button>

          <button
            onClick={() => {
              const text = `"${dailyShloka.sanskrit.substring(0, 100)}..." — ${dailyShloka.source} via path.vrindopnishad.in`;
              const url = `https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}`;
              window.open(url, '_blank');
            }}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-white/5 hover:bg-white/10 text-white/60 hover:text-white transition-all text-[10px] font-semibold border border-white/5 relative group"
            title={isHi ? "X पर साझा करें" : "Share on X"}
            aria-label="Share on X"
          >
            <span className="font-bold" aria-hidden="true">𝕏</span>
            <span>Share</span>
            <span className="absolute -top-8 left-1/2 -translate-x-1/2 scale-0 group-hover:scale-100 bg-black text-[10px] text-white/90 px-2 py-1 rounded border border-white/10 transition-all duration-200 pointer-events-none whitespace-nowrap z-50">
              {isHi ? "X पर साझा करें" : "Share on X"}
            </span>
          </button>

          <button
            onClick={() => shareVerseCard({
              sanskrit_text: dailyShloka.sanskrit,
              hindi_text: dailyShloka.hindi,
              english_translation: dailyShloka.english,
              author: isHi ? "श्रीमद्भगवद्गीता" : "Bhagavad Gita",
              title: dailyShloka.source,
              category: "shloka"
            }, isHi)}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-primary/10 hover:bg-primary/20 text-primary hover:text-primary transition-all text-[10px] font-bold border border-primary/20 relative group"
            title={isHi ? "कार्ड चित्र सहेजें" : "Save Image Card"}
            aria-label="Save Image Card"
          >
            <Share2 size={11} aria-hidden="true" />
            <span>{isHi ? "कार्ड चित्र" : "Share Card"}</span>
            <span className="absolute -top-8 left-1/2 -translate-x-1/2 scale-0 group-hover:scale-100 bg-black text-[10px] text-white/90 px-2 py-1 rounded border border-white/10 transition-all duration-200 pointer-events-none whitespace-nowrap z-50">
              {isHi ? "कार्ड चित्र बनाएं" : "Create Image Card"}
            </span>
          </button>
        </div>
      </div>
    </div>
  );
};

export default React.memo(DailySwadhyaya);
