import React, { useState, useRef, useEffect } from 'react';
import Head from 'next/head';
import Link from 'next/link';
import { 
  Play, Pause, Volume2, Share2, Copy, Check, Download, 
  MapPin, Utensils, HelpCircle, ChevronDown, ChevronUp,
  Type, RefreshCw, ArrowLeft, Sparkles
} from 'lucide-react';

export default function StotraDetailPage({ stotra, slug }) {
  const [fontSize, setFontSize] = useState(22); // Default 22px Devanagari font
  const [copiedVerseIndex, setCopiedVerseIndex] = useState(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [playbackSpeed, setPlaybackSpeed] = useState(1.0);
  const [expandedFaqs, setExpandedFaqs] = useState({});
  const audioRef = useRef(null);

  useEffect(() => {
    if (audioRef.current) {
      audioRef.current.playbackRate = playbackSpeed;
    }
  }, [playbackSpeed]);

  const toggleAudio = () => {
    if (!audioRef.current) return;
    if (isPlaying) {
      audioRef.current.pause();
      setIsPlaying(false);
    } else {
      audioRef.current.play();
      setIsPlaying(true);
    }
  };

  const handleSpeedChange = (speed) => {
    setPlaybackSpeed(speed);
    if (audioRef.current) {
      audioRef.current.playbackRate = speed;
    }
  };

  const copyToClipboard = (text, index) => {
    navigator.clipboard.writeText(text);
    setCopiedVerseIndex(index);
    setTimeout(() => setCopiedVerseIndex(null), 2000);
  };

  const shareOnWhatsApp = (text) => {
    const message = encodeURIComponent(`${text}\n\nपढ़ें VrindaVaani पर: ${window.location.href}`);
    window.open(`https://api.whatsapp.com/send?text=${message}`, '_blank');
  };

  const toggleFaq = (idx) => {
    setExpandedFaqs(prev => ({ ...prev, [idx]: !prev[idx] }));
  };

  if (!stotra) return null;

  // Generate JSON-LD Schema for Google Position 0 (FAQPage & MusicRecording)
  const faqSchema = stotra.faqs && stotra.faqs.length > 0 ? {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    "mainEntity": stotra.faqs.map(faq => ({
      "@type": "Question",
      "name": faq.question,
      "acceptedAnswer": {
        "@type": "Answer",
        "text": faq.answer
      }
    }))
  } : null;

  const musicSchema = stotra.audio_url ? {
    "@context": "https://schema.org",
    "@type": "MusicRecording",
    "name": stotra.title,
    "byArtist": {
      "@type": "MusicGroup",
      "name": stotra.author || "VrindaVaani"
    },
    "audio": stotra.audio_url
  } : null;

  return (
    <>
      <Head>
        <title>{`${stotra.title_hindi || stotra.title} - मूल श्लोक एवं हिंदी अर्थ | VrindaVaani`}</title>
        <meta name="description" content={stotra.meta_description || stotra.description_hindi} />
        <meta property="og:title" content={`${stotra.title_hindi} - हिंदी अर्थ सहित`} />
        <meta property="og:description" content={stotra.description_hindi} />
        {faqSchema && (
          <script
            type="application/ld+json"
            dangerouslySetInnerHTML={{ __html: JSON.stringify(faqSchema) }}
          />
        )}
        {musicSchema && (
          <script
            type="application/ld+json"
            dangerouslySetInnerHTML={{ __html: JSON.stringify(musicSchema) }}
          />
        )}
      </Head>

      <div className="min-h-screen bg-slate-950 text-slate-100 font-sans pb-24">
        {/* Top Header Banner */}
        <div className="relative overflow-hidden bg-gradient-to-b from-amber-950/40 via-slate-900 to-slate-950 border-b border-amber-500/20 pt-8 pb-12 px-4 sm:px-6 lg:px-8">
          <div className="absolute top-0 left-1/2 -translate-x-1/2 w-full max-w-7xl h-96 bg-amber-500/10 blur-3xl pointer-events-none rounded-full" />
          
          <div className="max-w-4xl mx-auto relative z-10">
            <Link 
              href="/lyrics" 
              className="inline-flex items-center gap-2 text-amber-400 hover:text-amber-300 text-sm font-medium mb-6 transition-colors"
            >
              <ArrowLeft className="w-4 h-4" />
              सभी स्तोत्र एवं पद (All Stotras)
            </Link>

            <div className="flex flex-wrap items-center gap-3 mb-4">
              <span className="px-3 py-1 bg-amber-500/20 text-amber-300 text-xs font-semibold rounded-full border border-amber-500/30 backdrop-blur-sm">
                सिद्ध स्तोत्रम् (Flagship)
              </span>
              {stotra.author && (
                <span className="px-3 py-1 bg-slate-800/80 text-slate-300 text-xs rounded-full border border-slate-700">
                  {stotra.author}
                </span>
              )}
            </div>

            <h1 className="text-3xl sm:text-4xl md:text-5xl font-extrabold text-amber-100 leading-tight mb-4 tracking-tight">
              {stotra.title_hindi || stotra.title}
            </h1>

            <p className="text-slate-300 text-base sm:text-lg leading-relaxed max-w-3xl">
              {stotra.description_hindi}
            </p>

            {/* Font Control Bar */}
            <div className="mt-8 flex flex-wrap items-center justify-between gap-4 p-4 bg-slate-900/80 backdrop-blur-md rounded-2xl border border-slate-800">
              <div className="flex items-center gap-3">
                <Type className="w-5 h-5 text-amber-400" />
                <span className="text-sm font-medium text-slate-300">अक्षर आकार (Font Size):</span>
                <div className="flex items-center gap-1 bg-slate-950 p-1 rounded-xl border border-slate-800">
                  <button 
                    onClick={() => setFontSize(Math.max(16, fontSize - 2))}
                    className="px-3 py-1 text-sm font-semibold text-slate-300 hover:text-amber-400 hover:bg-slate-800 rounded-lg transition-colors"
                  >
                    A-
                  </button>
                  <span className="px-2 text-xs font-mono text-amber-400">{fontSize}px</span>
                  <button 
                    onClick={() => setFontSize(Math.min(32, fontSize + 2))}
                    className="px-3 py-1 text-sm font-semibold text-slate-300 hover:text-amber-400 hover:bg-slate-800 rounded-lg transition-colors"
                  >
                    A+
                  </button>
                </div>
              </div>

              {/* Audio Controls */}
              {stotra.audio_url && (
                <div className="flex items-center gap-3">
                  <audio ref={audioRef} src={stotra.audio_url} onEnded={() => setIsPlaying(false)} />
                  <button
                    onClick={toggleAudio}
                    className="inline-flex items-center gap-2 px-5 py-2.5 bg-amber-500 hover:bg-amber-400 text-slate-950 font-bold rounded-xl shadow-lg shadow-amber-500/20 transition-all transform active:scale-95"
                  >
                    {isPlaying ? <Pause className="w-4 h-4" /> : <Play className="w-4 h-4 fill-current" />}
                    <span>{isPlaying ? 'रोकें (Pause)' : 'सुणें (Listen Audio)'}</span>
                  </button>

                  <div className="hidden sm:flex items-center gap-1 bg-slate-950 p-1 rounded-xl border border-slate-800">
                    {[0.75, 1.0, 1.25, 1.5].map(speed => (
                      <button
                        key={speed}
                        onClick={() => handleSpeedChange(speed)}
                        className={`px-2.5 py-1 text-xs font-semibold rounded-lg transition-colors ${
                          playbackSpeed === speed ? 'bg-amber-500 text-slate-950' : 'text-slate-400 hover:text-slate-200'
                        }`}
                      >
                        {speed}x
                      </button>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Verses Container */}
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 mt-10 space-y-8">
          {stotra.verses && stotra.verses.map((verse, idx) => (
            <div 
              key={idx}
              className="group relative bg-slate-900/60 backdrop-blur-xl border border-slate-800/80 hover:border-amber-500/40 rounded-3xl p-6 sm:p-8 transition-all duration-300 shadow-xl"
            >
              {/* Verse Badge & Toolbar */}
              <div className="flex items-center justify-between mb-6 pb-4 border-b border-slate-800/60">
                <span className="px-3.5 py-1 bg-amber-500/10 text-amber-400 font-bold text-xs rounded-full border border-amber-500/20">
                  श्लोक {verse.verse_number || idx + 1}
                </span>

                <div className="flex items-center gap-2">
                  <button
                    onClick={() => copyToClipboard(`${verse.sanskrit}\n\nभावार्थ:\n${verse.meaning_hindi}`, idx)}
                    className="p-2 text-slate-400 hover:text-amber-300 bg-slate-950/60 hover:bg-slate-800 rounded-xl transition-colors"
                    title="श्लोक एवं अर्थ कॉपी करें"
                  >
                    {copiedVerseIndex === idx ? <Check className="w-4 h-4 text-emerald-400" /> : <Copy className="w-4 h-4" />}
                  </button>
                  <button
                    onClick={() => shareOnWhatsApp(`${verse.sanskrit}\n\nभावार्थ:\n${verse.meaning_hindi}`)}
                    className="p-2 text-slate-400 hover:text-emerald-400 bg-slate-950/60 hover:bg-slate-800 rounded-xl transition-colors"
                    title="व्हाट्सएप पर शेयर करें"
                  >
                    <Share2 className="w-4 h-4" />
                  </button>
                </div>
              </div>

              {/* Original Devanagari Sanskrit Shloka */}
              <div 
                className="font-serif text-amber-100 font-bold leading-relaxed whitespace-pre-line tracking-wide mb-6"
                style={{ fontSize: `${fontSize}px` }}
              >
                {verse.sanskrit}
              </div>

              {/* Transliteration */}
              {verse.transliteration && (
                <div className="text-slate-400 text-sm italic font-mono mb-6 pb-4 border-b border-slate-800/40 leading-relaxed">
                  {verse.transliteration}
                </div>
              )}

              {/* Word Breakdown (पदच्छेद्य) */}
              {verse.padachhed && (
                <div className="mb-6 p-4 bg-slate-950/70 rounded-2xl border border-slate-800/80">
                  <span className="text-xs font-semibold text-amber-400/80 uppercase tracking-wider block mb-2">
                    पदच्छेद्य (Word Breakdown):
                  </span>
                  <p className="text-slate-300 text-sm font-sans leading-relaxed">
                    {verse.padachhed}
                  </p>
                </div>
              )}

              {/* Hindi Meaning (भावार्थ) */}
              <div className="p-5 bg-gradient-to-r from-amber-950/20 via-slate-900/60 to-slate-900/60 rounded-2xl border border-amber-500/20">
                <span className="text-xs font-bold text-amber-400 uppercase tracking-wider block mb-2 flex items-center gap-1.5">
                  <Sparkles className="w-3.5 h-3.5 text-amber-400" />
                  भावार्थ (Hindi Meaning):
                </span>
                <p className="text-slate-200 text-base sm:text-lg leading-relaxed font-sans">
                  {verse.meaning_hindi}
                </p>
              </div>
            </div>
          ))}

          {/* Cross-Ecosystem Integration Cards */}
          {stotra.ecosystem_links && (
            <div className="mt-14 pt-10 border-t border-slate-800 space-y-6">
              <h3 className="text-xl font-bold text-amber-200 flex items-center gap-2">
                <Sparkles className="w-5 h-5 text-amber-400" />
                धाम दर्शन एवं सात्विक प्रसाद (Vrinda Ecosystem Connections)
              </h3>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {/* Vrinda Tours Card */}
                {stotra.ecosystem_links.temple && (
                  <div className="bg-slate-900/80 border border-slate-800 rounded-3xl p-6 hover:border-amber-500/40 transition-colors">
                    <div className="flex items-center gap-3 mb-3">
                      <div className="p-2.5 bg-amber-500/20 text-amber-400 rounded-2xl">
                        <MapPin className="w-5 h-5" />
                      </div>
                      <div>
                        <span className="text-xs text-amber-400 font-semibold uppercase tracking-wider">Vrinda Tours</span>
                        <h4 className="text-lg font-bold text-slate-100">{stotra.ecosystem_links.temple.name}</h4>
                      </div>
                    </div>
                    <p className="text-slate-300 text-sm mb-4">{stotra.ecosystem_links.temple.description}</p>
                    <span className="inline-flex items-center gap-1 text-xs text-amber-400 font-medium">
                      स्थान: {stotra.ecosystem_links.temple.location}
                    </span>
                  </div>
                )}

                {/* Foody Vrinda Card */}
                {stotra.ecosystem_links.prashadam && (
                  <div className="bg-slate-900/80 border border-slate-800 rounded-3xl p-6 hover:border-emerald-500/40 transition-colors">
                    <div className="flex items-center gap-3 mb-3">
                      <div className="p-2.5 bg-emerald-500/20 text-emerald-400 rounded-2xl">
                        <Utensils className="w-5 h-5" />
                      </div>
                      <div>
                        <span className="text-xs text-emerald-400 font-semibold uppercase tracking-wider">Foody Vrinda</span>
                        <h4 className="text-lg font-bold text-slate-100">{stotra.ecosystem_links.prashadam.name}</h4>
                      </div>
                    </div>
                    <p className="text-slate-300 text-sm mb-4">{stotra.ecosystem_links.prashadam.description}</p>
                    <span className="inline-flex items-center gap-1 text-xs text-emerald-400 font-medium">
                      स्थान: {stotra.ecosystem_links.prashadam.location}
                    </span>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* FAQ Accordion Section (Google SERP Feature) */}
          {stotra.faqs && stotra.faqs.length > 0 && (
            <div className="mt-14 pt-10 border-t border-slate-800">
              <h3 className="text-2xl font-bold text-amber-100 mb-6 flex items-center gap-2">
                <HelpCircle className="w-6 h-6 text-amber-400" />
                अक्सर पूछे जाने वाले प्रश्न (FAQs)
              </h3>

              <div className="space-y-4">
                {stotra.faqs.map((faq, idx) => (
                  <div 
                    key={idx}
                    className="bg-slate-900/60 border border-slate-800 rounded-2xl overflow-hidden transition-colors"
                  >
                    <button
                      onClick={() => toggleFaq(idx)}
                      className="w-full p-5 text-left font-semibold text-slate-200 flex items-center justify-between gap-4 hover:text-amber-300 transition-colors"
                    >
                      <span>{faq.question}</span>
                      {expandedFaqs[idx] ? <ChevronUp className="w-5 h-5 text-amber-400" /> : <ChevronDown className="w-5 h-5 text-slate-400" />}
                    </button>
                    {expandedFaqs[idx] && (
                      <div className="p-5 pt-0 text-slate-300 text-sm leading-relaxed border-t border-slate-800/60 bg-slate-950/40">
                        {faq.answer}
                      </div>
                    )}
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </>
  );
}
