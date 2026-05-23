import React, { useState, useEffect, useContext } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Music, FileText, ArrowRight, Heart, Users, MapPin, Book, ChevronRight, X, Search } from 'lucide-react';
import { Helmet } from 'react-helmet-async';
import { ApiContext } from '../App';
import { extractRelations } from '../utils/relations';
import AudioPlayButton from '../components/ui/AudioPlayButton';

const DAILY_SHLOKAS = [
  {
    source: "श्रीमद्भगवद्गीता २.४७ (Bhagavad Gita 2.47)",
    sanskrit: "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन ।\nमा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि ॥",
    hindi: "तुम्हारा अधिकार केवल कर्म करने पर है, उसके फलों पर कभी नहीं। इसलिए कर्म के फलों की चिंता मत करो और कर्म न करने के प्रति आसक्त मत हो।",
    english: "You have a right to perform your prescribed duties, but you are not entitled to the fruits of your actions. Never consider yourself to be the cause of your activities' results, nor be attached to inaction."
  },
  {
    source: "श्रीमद्भगवद्गीता १८.६६ (Bhagavad Gita 18.66)",
    sanskrit: "सर्वधर्मान्परित्यज्य मामेकं शरणं व्रज ।\nअहं तं सर्वपापेभ्यो मोक्षयिष्यामि मा शुचः ॥",
    hindi: "सभी धर्मों का त्याग करके केवल मेरी शरण में आओ। मैं तुम्हें सभी पापों से मुक्त कर दूंगा, शोक मत करो।",
    english: "Abandon all varieties of religion and just surrender unto Me. I shall deliver you from all sinful reactions. Do not fear."
  },
  {
    source: "श्रीमद्भगवद्गीता ४.७ (Bhagavad Gita 4.7)",
    sanskrit: "यदा यदा हि धर्मस्य ग्लानिर्भवति भारत ।\nअभ्युत्थानमधर्मस्य तदात्मानं सृजाम्यहम् ॥",
    hindi: "हे भारत! जब-जब धर्म की हानि होती है और अधर्म का उत्थान होता है, तब-तब मैं अपने रूप को सृजित करता हूँ (अवतार लेता हूँ)।",
    english: "Whenever there is a decline in righteousness and an increase in unrighteousness, O Bharat, then I manifest Myself on earth."
  }
];

const VerseListItem = ({ verse, isHindiRoute }) => {
  const [isExpanded, setIsExpanded] = useState(false);

  return (
    <div className="border border-white/5 rounded-xl bg-white/5 overflow-hidden transition-all duration-300">
      <div 
        onClick={() => setIsExpanded(!isExpanded)}
        className="p-4 flex items-center justify-between cursor-pointer hover:bg-white/5 transition-colors"
      >
        <div className="min-w-0 pr-3">
          <h4 className="font-bold text-sm text-white/90 line-clamp-1">{verse.cleanTitle || verse.title}</h4>
          <span className="text-[9px] uppercase tracking-wider text-amber-500/80 mt-1 block">{verse.category}</span>
        </div>
        <div className="flex items-center gap-2 shrink-0">
          {verse.audio_url && (
            <AudioPlayButton 
              track={verse}
              className="text-sky-400 bg-sky-500/10 border border-sky-500/20 p-2 rounded-full hover:scale-105 transition-transform" 
              size={14}
            />
          )}
          <ChevronRight size={16} className={`text-white/30 transition-transform duration-300 ${isExpanded ? 'rotate-90' : ''}`} />
        </div>
      </div>

      <div className={`verse-expansion-panel ${isExpanded ? 'open border-t border-white/5 p-4 bg-black/20' : ''}`}>
        {isExpanded && (
          <div className="space-y-4 text-xs md:text-sm text-left">
            {verse.sanskrit_text && (
              <div>
                <h5 className="text-[10px] uppercase tracking-wider text-amber-500/60 font-bold mb-1.5">मूल पाठ (Original Text)</h5>
                <p className="font-semibold text-minimal-gold leading-loose whitespace-pre-line text-center py-2 font-headings select-all text-sm">
                  {verse.sanskrit_text}
                </p>
              </div>
            )}

            {verse.hindi_text && (
              <div>
                <h5 className="text-[10px] uppercase tracking-wider text-white/40 font-bold mb-1">भावार्थ (Hindi Translation)</h5>
                <p className="text-white/70 leading-relaxed font-light">
                  {verse.hindi_text}
                </p>
              </div>
            )}

            {verse.english_translation && (
              <div>
                <h5 className="text-[10px] uppercase tracking-wider text-white/40 font-bold mb-1">English Translation</h5>
                <p className="text-white/60 leading-relaxed font-light italic">
                  {verse.english_translation}
                </p>
              </div>
            )}

            {verse.description && !verse.hindi_text && !verse.english_translation && (
              <div>
                <h5 className="text-[10px] uppercase tracking-wider text-white/40 font-bold mb-1">Description</h5>
                <p className="text-white/60 leading-relaxed font-light">
                  {verse.description}
                </p>
              </div>
            )}

            <div className="pt-2 text-right">
              <Link 
                to={isHindiRoute ? `/hi/content/${verse.slug || verse.id}` : `/content/${verse.slug || verse.id}`}
                className="inline-flex items-center gap-1 text-[10px] uppercase tracking-wider text-primary hover:underline font-bold"
              >
                Go to Dedicated Page
                <ArrowRight size={10} />
              </Link>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

const HomePage = () => {
  const location = useLocation();
  const isHindiRoute = location.pathname.startsWith('/hi');
  const { apiService } = useContext(ApiContext);

  const [allItems, setAllItems] = useState([]);
  const [saints, setSaints] = useState([]);
  const [books, setBooks] = useState([]);
  const [ragas, setRagas] = useState([]);
  const [loading, setLoading] = useState(true);

  const [searchQuery, setSearchQuery] = useState('');
  const [selectedItem, setSelectedItem] = useState(null);
  const [previewType, setPreviewType] = useState(null);
  const [drawerTab, setDrawerTab] = useState('bio');

  const openPreview = (item, type) => {
    setSelectedItem(item);
    setPreviewType(type);
    setDrawerTab('bio');
  };

  const closePreview = () => {
    setSelectedItem(null);
    setPreviewType(null);
  };

  useEffect(() => {
    let active = true;
    const load = async () => {
      try {
        const fetchedItems = await apiService.getAllContent(null, 10000);
        const relations = extractRelations(fetchedItems);
        if (active) {
          setAllItems(fetchedItems);
          setSaints(relations.sants);
          setBooks(relations.books);
          setRagas(relations.ragas);
        }
      } catch (error) {
        console.error('Error loading homepage relations:', error);
      } finally {
        if (active) setLoading(false);
      }
    };
    load();
    return () => { active = false; };
  }, [apiService]);

  const getBookCoverGradient = (bookName) => {
    let hash = 0;
    for (let i = 0; i < bookName.length; i++) {
      hash = bookName.charCodeAt(i) + ((hash << 5) - hash);
    }
    const h1 = Math.abs(hash % 360);
    const h2 = (h1 + 60) % 360;
    return `linear-gradient(135deg, hsl(${h1}, 65%, 32%) 0%, hsl(${h2}, 55%, 12%) 100%)`;
  };

  const filteredResults = React.useMemo(() => {
    if (!searchQuery.trim() || searchQuery.trim().length < 2) {
      return { sants: [], books: [], ragas: [], verses: [] };
    }
    const q = searchQuery.toLowerCase().trim();

    const matchedSants = saints.filter(s => 
      s.name?.toLowerCase().includes(q) || 
      s.hinglishName?.toLowerCase().includes(q)
    );

    const matchedBooks = books.filter(b => 
      b.name?.toLowerCase().includes(q) || 
      (b.author && b.author.toLowerCase().includes(q))
    );

    const matchedRagas = ragas.filter(r => 
      r.name?.toLowerCase().includes(q) || 
      r.hinglishName?.toLowerCase().includes(q)
    );

    const matchedVerses = allItems.filter(v => 
      v.category?.toLowerCase() !== 'saint' && (
        v.title?.toLowerCase().includes(q) ||
        v.sanskrit_text?.toLowerCase().includes(q) ||
        v.hindi_text?.toLowerCase().includes(q) ||
        v.english_translation?.toLowerCase().includes(q) ||
        v.description?.toLowerCase().includes(q)
      )
    ).slice(0, 10);

    return { sants: matchedSants, books: matchedBooks, ragas: matchedRagas, verses: matchedVerses };
  }, [searchQuery, saints, books, ragas, allItems]);

  const latestVerses = React.useMemo(() => {
    return allItems
      .filter(item => item.category?.toLowerCase() !== 'saint')
      .slice(0, 5);
  }, [allItems]);

  const shlokaIndex = new Date().getDate() % DAILY_SHLOKAS.length;
  const dailyShloka = DAILY_SHLOKAS[shlokaIndex];

  if (loading) {
    return (
      <div className="relative max-w-6xl mx-auto px-4 py-8 animate-pulse text-left min-h-screen">
        <div className="text-center pt-8 pb-12 max-w-2xl mx-auto space-y-4">
          <div className="h-12 bg-white/5 rounded-2xl w-48 mx-auto" />
          <div className="h-4 bg-white/5 rounded w-36 mx-auto" />
          <div className="h-14 bg-white/5 rounded-2xl w-full" />
        </div>
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <div className="lg:col-span-2 space-y-10">
            <div className="h-64 bg-white/5 rounded-2xl" />
            <div className="space-y-4">
              <div className="h-6 bg-white/5 rounded w-48" />
              <div className="h-20 bg-white/5 rounded-2xl" />
              <div className="h-20 bg-white/5 rounded-2xl" />
            </div>
          </div>
          <div className="space-y-8">
            <div className="h-48 bg-white/5 rounded-2xl" />
            <div className="h-64 bg-white/5 rounded-2xl" />
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="relative overflow-hidden animate-fade-in font-sans min-h-screen">
      <Helmet>
        <title>Vrindopnishad Paath — वृंदोपनिषद् पाठ | Sacred Shlokas, Strotras & Devotional Poetry</title>
        <meta name="description" content="Vrindopnishad Paath (वृंदोपनिषद् पाठ) — Read and listen to authentic sacred Sanskrit shlokas, devotional strotras, spiritual poetry & Vedic wisdom from Vrindavan saints. Free online paath of Bhagavad Gita, mantras & hymns in Hindi, Sanskrit & English." />
        <meta name="keywords" content="vrindopnishad, vrindopnishad paath, वृंदोपनिषद्, वृंदोपनिषद् पाठ, vrindopnishad path, vrindopnishad app, vrindopnishad.in, sant vaani, sacred shlokas, sanskrit shlokas, strotras, devotional poetry, bhagavad gita, vedic wisdom, vrindavan, bhakti, श्लोक, स्तोत्र, कविता, वेद, उपनिषद, मंत्र, हिंदी भजन, radha krishna, premanand ji maharaj, barsana, nandgaav, govardhan, braj rasik, brajrasik, rasik sant" />
        <link rel="canonical" href="https://path.vrindopnishad.in/" />
        <meta name="geo.region" content="IN" />
        <meta name="geo.placename" content="Vrindavan, India" />
        <meta name="content-language" content="hi, en, sa" />
        <meta property="og:type" content="website" />
        <meta property="og:url" content="https://path.vrindopnishad.in/" />
        <meta property="og:site_name" content="Vrindopnishad — वृंदोपनिषद्" />
        <meta property="og:title" content="Vrindopnishad Paath — वृंदोपनिषद् पाठ | Sacred Digital Sanctuary" />
        <meta property="og:description" content="Read Vrindopnishad Paath online — sacred Sanskrit shlokas, strotras, devotional poetry & Vedic wisdom from Vrindavan saints. Free in Hindi, Sanskrit & English." />
        <meta property="og:image" content="https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png" />
        <meta property="og:locale" content="hi_IN" />
        <meta property="og:locale:alternate" content="en_IN" />
        <meta name="twitter:card" content="summary_large_image" />
        <meta name="twitter:title" content="Vrindopnishad Paath — वृंदोपनिषद् पाठ" />
        <meta name="twitter:description" content="Read Vrindopnishad Paath online — sacred Sanskrit shlokas, strotras, devotional poetry & Vedic wisdom." />
        <meta name="twitter:image" content="https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png" />
        <script type="application/ld+json">{JSON.stringify({
          "@context": "https://schema.org",
          "@type": "CollectionPage",
          "name": "Vrindopnishad Paath — वृंदोपनिषद् पाठ",
          "alternateName": ["Vrindopnishad", "वृंदोपनिषद्", "Vrindopnishad Path", "Sant Vaani"],
          "description": "Read Vrindopnishad Paath online — the largest digital collection of sacred Sanskrit shlokas, strotras, devotional poetry, and Vedic wisdom from Vrindavan saints.",
          "url": "https://path.vrindopnishad.in",
          "inLanguage": ["hi", "en", "sa"],
          "about": [
            { "@type": "Thing", "name": "Vrindopnishad", "alternateName": "वृंदोपनिषद्" },
            { "@type": "Thing", "name": "Vedic Knowledge", "alternateName": "वैदिक ज्ञान" },
            { "@type": "Thing", "name": "Bhakti", "alternateName": "भक्ति" },
            { "@type": "Thing", "name": "Sanskrit Shlokas", "alternateName": "संस्कृत श्लोक" }
          ],
          "publisher": {
            "@type": "Organization",
            "name": "Vrindopnishad",
            "alternateName": "वृंदोपनिषद्",
            "logo": {
              "@type": "ImageObject",
              "url": "https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png"
            }
          },
          "mainEntity": {
            "@type": "ItemList",
            "itemListElement": [
              { "@type": "ListItem", "position": 1, "name": "Sacred Verses (Shlokas) — श्लोक", "url": "https://path.vrindopnishad.in/category/shloka" },
              { "@type": "ListItem", "position": 2, "name": "Strotras (Devotional Hymns) — स्तोत्र", "url": "https://path.vrindopnishad.in/category/strotra" },
              { "@type": "ListItem", "position": 3, "name": "Spiritual Poetry — आध्यात्मिक कविता", "url": "https://path.vrindopnishad.in/category/poem" }
            ]
          }
        })}</script>
      </Helmet>

      {/* Dynamic Ambient Background Blobs */}
      <div 
        className="home-theme-glow-ambient top-[-250px] left-[-200px] md:w-[800px] md:h-[800px]" 
        style={{
          background: `radial-gradient(circle, rgba(var(--primary-rgb), 0.04) 0%, rgba(var(--primary-rgb), 0.01) 50%, transparent 70%)`
        }}
      />
      <div 
        className="home-theme-glow-ambient bottom-[20%] right-[-200px] md:w-[700px] md:h-[700px]" 
        style={{
          background: `radial-gradient(circle, rgba(var(--primary-rgb), 0.02) 0%, rgba(var(--primary-rgb), 0.005) 50%, transparent 70%)`
        }}
      />

      <div className="relative z-10 max-w-6xl mx-auto px-4 py-8">
        
        {/* Editorial Minimalist Hero block */}
        <div className="text-center pt-8 pb-12 max-w-2xl mx-auto">
          <h1 className="text-5xl md:text-6xl font-bold mb-2 tracking-tight text-minimal-gold font-headings">
            वृंदोपनिषद्
          </h1>
          <p className="text-xs uppercase tracking-[0.25em] text-white/40 block mb-6">Vrindopnishad Paath • Bliss of Vrindavan</p>
          
          {/* Sleek Search Input inside Hero */}
          <div className="relative w-full shadow-2xl rounded-2xl overflow-hidden border border-white/5 focus-within:border-primary/50 transition-colors">
            <Search className="absolute left-5 top-1/2 -translate-y-1/2 text-white/35" size={20} />
            <input 
              type="text" 
              placeholder={isHindiRoute ? "सन्त, ग्रन्थ, राग या वाणी खोजें..." : "Search Saints, Books, Ragas or Verses..."} 
              className="w-full h-14 bg-white/5 pl-14 pr-12 outline-none text-sm md:text-base font-medium"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
            {searchQuery && (
              <button 
                onClick={() => setSearchQuery('')}
                className="absolute right-5 top-1/2 -translate-y-1/2 text-white/40 hover:text-white transition-colors"
              >
                <X size={18} />
              </button>
            )}
          </div>

          {/* Search Results Overlay */}
          {searchQuery.trim().length >= 2 && (
            <div className="glass-card mt-4 p-6 text-left w-full border border-amber-500/20 shadow-2xl relative z-50 rounded-2xl max-h-[60vh] overflow-y-auto">
              <div className="flex justify-between items-center mb-6 pb-2 border-b border-white/5">
                <h3 className="text-xs font-bold text-primary uppercase tracking-wider">
                  {isHindiRoute ? "खोज परिणाम" : "Search Results"}
                </h3>
                <button 
                  onClick={() => setSearchQuery('')}
                  className="text-white/40 hover:text-white transition-colors"
                >
                  <X size={16} />
                </button>
              </div>

              {filteredResults.sants.length === 0 && 
               filteredResults.books.length === 0 && 
               filteredResults.ragas.length === 0 && 
               filteredResults.verses.length === 0 ? (
                 <div className="py-8 text-center text-white/40 text-sm">
                   {isHindiRoute ? "कोई परिणाम नहीं मिला" : "No results found. Try another query."}
                 </div>
              ) : (
                <div className="space-y-6">
                  {filteredResults.sants.length > 0 && (
                    <div>
                      <h4 className="text-xs font-bold text-white/40 uppercase tracking-widest mb-3">Saints / रसिक सन्त</h4>
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                        {filteredResults.sants.map(sant => (
                          <button
                            key={sant.cleanName}
                            onClick={() => openPreview(sant, 'saint')}
                            className="flex items-center gap-3 p-3 rounded-xl bg-white/5 hover:bg-white/10 border border-white/5 text-left w-full transition-colors group"
                          >
                            <div className="w-9 h-9 rounded-full bg-amber-500/10 text-amber-500 flex items-center justify-center font-bold text-sm shrink-0">
                              {sant.cleanName.charAt(0) === 'श' && sant.cleanName.charAt(4) ? sant.cleanName.charAt(4) : sant.cleanName.charAt(0)}
                            </div>
                            <div className="min-w-0">
                              <span className="font-bold text-sm text-white/90 group-hover:text-primary transition-colors block truncate">
                                {isHindiRoute ? sant.name : sant.hinglishName}
                              </span>
                              <span className="text-[10px] text-white/30">{sant.verses.length} verses</span>
                            </div>
                          </button>
                        ))}
                      </div>
                    </div>
                  )}

                  {filteredResults.books.length > 0 && (
                    <div>
                      <h4 className="text-xs font-bold text-white/40 uppercase tracking-widest mb-3">Books / ग्रन्थ</h4>
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                        {filteredResults.books.map(book => (
                          <button
                            key={book.name}
                            onClick={() => openPreview(book, 'book')}
                            className="flex items-center gap-3 p-3 rounded-xl bg-white/5 hover:bg-white/10 border border-white/5 text-left w-full transition-colors group"
                          >
                            <div className="w-9 h-9 rounded-lg bg-sky-500/10 text-sky-400 flex items-center justify-center shrink-0">
                              <Book size={16} />
                            </div>
                            <div className="min-w-0">
                              <span className="font-bold text-sm text-white/90 group-hover:text-primary transition-colors block truncate">
                                {book.name}
                              </span>
                              <span className="text-[10px] text-white/30">By {book.author}</span>
                            </div>
                          </button>
                        ))}
                      </div>
                    </div>
                  )}

                  {filteredResults.ragas.length > 0 && (
                    <div>
                      <h4 className="text-xs font-bold text-white/40 uppercase tracking-widest mb-3">Ragas / शास्त्रीय राग</h4>
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                        {filteredResults.ragas.map(raga => (
                          <button
                            key={raga.name}
                            onClick={() => openPreview(raga, 'raga')}
                            className="flex items-center gap-3 p-3 rounded-xl bg-white/5 hover:bg-white/10 border border-white/5 text-left w-full transition-colors group"
                          >
                            <div className="w-9 h-9 rounded-lg bg-emerald-500/10 text-emerald-400 flex items-center justify-center shrink-0">
                              <Music size={16} />
                            </div>
                            <div className="min-w-0">
                              <span className="font-bold text-sm text-white/90 group-hover:text-primary transition-colors block truncate">
                                {raga.name}
                              </span>
                              <span className="text-[10px] text-white/30">{raga.hinglishName}</span>
                            </div>
                          </button>
                        ))}
                      </div>
                    </div>
                  )}

                  {filteredResults.verses.length > 0 && (
                    <div>
                      <h4 className="text-xs font-bold text-white/40 uppercase tracking-widest mb-3">Verses / वाणी-पद</h4>
                      <div className="space-y-2">
                        {filteredResults.verses.map(verse => (
                          <button
                            key={verse.id}
                            onClick={() => openPreview(verse, 'verse')}
                            className="flex items-center justify-between p-3 rounded-xl bg-white/5 hover:bg-white/10 border border-white/5 text-left w-full transition-colors group"
                          >
                            <div className="min-w-0 pr-4">
                              <span className="font-bold text-sm text-white/90 group-hover:text-primary transition-colors block truncate">
                                {verse.title}
                              </span>
                              <p className="text-[11px] text-white/45 line-clamp-1 mt-0.5">
                                {verse.hindi_text || verse.english_translation || verse.description}
                              </p>
                            </div>
                            <ChevronRight size={16} className="text-white/20 group-hover:text-primary transition-colors shrink-0" />
                          </button>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              )}
            </div>
          )}
        </div>

        {/* 2-Column Responsive Layout Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 text-left mt-4">
          
          {/* Left Column: Feed (2/3 width) */}
          <div className="lg:col-span-2 space-y-10">
            
            {/* Daily Meditation Quote Block */}
            <div className="minimal-card relative overflow-hidden group">
              <div className="flex items-center gap-2 mb-4">
                <span className="w-2 h-2 rounded-full bg-primary animate-ping" />
                <span className="text-[10px] uppercase tracking-[0.25em] text-primary font-bold">
                  Daily Meditation • दैनिक स्वाध्याय
                </span>
              </div>

              <blockquote className="my-6">
                <p className="text-lg md:text-xl font-bold text-minimal-gold leading-loose whitespace-pre-line font-headings select-all text-center">
                  {dailyShloka.sanskrit}
                </p>
              </blockquote>

              <div className="border-t border-white/10 pt-4 mt-4">
                <div className="text-center mb-3">
                  <span className="text-[10px] font-bold text-amber-500/80 uppercase tracking-widest">
                    {dailyShloka.source}
                  </span>
                </div>
                
                <div className="grid md:grid-cols-2 gap-4 text-xs font-light leading-relaxed">
                  <div>
                    <h4 className="text-[9px] uppercase tracking-wider text-white/40 font-bold mb-1">Hindi Meaning</h4>
                    <p className="text-white/70">{dailyShloka.hindi}</p>
                  </div>
                  <div className="border-t md:border-t-0 md:border-l border-white/5 pt-3 md:pt-0 md:pl-4">
                    <h4 className="text-[9px] uppercase tracking-wider text-white/40 font-bold mb-1">English Translation</h4>
                    <p className="text-white/60 italic">{dailyShloka.english}</p>
                  </div>
                </div>
              </div>
            </div>

            {/* Dynamic Latest Verses Block */}
            {latestVerses.length > 0 && (
              <div>
                <h2 className="text-lg font-bold text-minimal-gold uppercase tracking-wider font-headings mb-5 pb-2 border-b border-white/5">
                  {isHindiRoute ? "नवीनतम वाणी एवं श्लोक" : "Latest Dynamic Verses"}
                </h2>
                <div className="space-y-4">
                  {latestVerses.map(verse => (
                    <Link
                      key={verse.id}
                      to={isHindiRoute ? `/hi/content/${verse.slug || verse.id}` : `/content/${verse.slug || verse.id}`}
                      onClick={(e) => {
                        e.preventDefault();
                        openPreview(verse, 'verse');
                      }}
                      className="glass-card p-5 block group hover:border-amber-500/25 transition-all shadow-md hover:shadow-xl"
                    >
                      <div className="flex justify-between items-start gap-4 mb-2">
                        <span className="text-[9px] uppercase tracking-wider text-amber-500/80 bg-amber-500/5 px-2 py-0.5 rounded border border-amber-500/10">
                          {verse.category}
                        </span>
                        {verse.audio_url && (
                          <AudioPlayButton 
                            track={verse} 
                            className="text-sky-400 bg-sky-500/5 border border-sky-500/10 p-1.5 rounded-full" 
                            size={12} 
                          />
                        )}
                      </div>
                      <h3 className="font-bold text-base text-white/90 group-hover:text-primary transition-colors leading-snug truncate">
                        {verse.cleanTitle || verse.title}
                      </h3>
                      <p className="text-white/45 text-xs line-clamp-2 mt-1.5 leading-relaxed font-light">
                        {verse.hindi_text || verse.english_translation || verse.description}
                      </p>
                    </Link>
                  ))}
                </div>
              </div>
            )}

            {/* Dynamic Books/Granthas Block */}
            {books.length > 0 && (
              <div>
                <div className="flex justify-between items-end mb-5">
                  <h2 className="text-lg font-bold text-minimal-gold uppercase tracking-wider font-headings pb-2">
                    {isHindiRoute ? "रसिक ग्रन्थ एवं वाणी संग्रह" : "Scriptures & Granthas"}
                  </h2>
                  <Link to={isHindiRoute ? "/hi/books" : "/books"} className="text-xs text-primary hover:underline font-semibold flex items-center gap-0.5">
                    {isHindiRoute ? "सभी देखें" : "View All"}
                    <ChevronRight size={14} />
                  </Link>
                </div>
                
                <div className="flex gap-4 overflow-x-auto pb-4 scrollbar-hide snap-x">
                  {books.slice(0, 8).map(book => (
                    <Link 
                      key={book.name} 
                      to={isHindiRoute ? `/hi/book/${book.slug}` : `/book/${book.slug}`}
                      onClick={(e) => {
                        e.preventDefault();
                        openPreview(book, 'book');
                      }}
                      className="w-72 flex-none glass-card p-4 rounded-2xl hover:border-amber-500/20 transition-all snap-start flex gap-4 border border-white/5 shadow-lg"
                    >
                      {/* Dynamic Gradient Cover */}
                      <div 
                        className="dynamic-book-cover shrink-0 text-white select-none text-[8px] font-bold flex flex-col justify-between"
                        style={{ background: getBookCoverGradient(book.name) }}
                      >
                        <div className="w-4 h-4 rounded-full border border-white/25 flex items-center justify-center mx-auto opacity-40">
                          ॐ
                        </div>
                        <span className="text-[9px] font-bold line-clamp-3 text-center leading-tight tracking-wide uppercase px-0.5">
                          {book.name.replace(/जी की वाणी/g, '').replace(/वाणी/g, '')}
                        </span>
                        <span className="text-[7px] text-amber-300 text-center uppercase tracking-widest font-headings opacity-75">
                          SANT VAANI
                        </span>
                      </div>

                      {/* Book Metadata */}
                      <div className="flex flex-col justify-between py-1 min-w-0">
                        <div>
                          <h3 className="font-bold text-sm text-white/90 group-hover:text-primary transition-colors leading-snug line-clamp-2">
                            {book.name}
                          </h3>
                          <span className="text-[10px] text-white/40 block mt-1 truncate">
                            By {book.author}
                          </span>
                        </div>
                        <span className="text-[9px] text-white/30 flex items-center gap-1 mt-2">
                          <FileText size={10} />
                          {book.verses.length} verses
                        </span>
                      </div>
                    </Link>
                  ))}
                </div>
              </div>
            )}

          </div>

          {/* Right Column: Sidebar (1/3 width) */}
          <div className="space-y-8">
            
            {/* Sidebar Block 1: Rasik Saints Circular Avatars Grid */}
            {saints.length > 0 && (
              <div className="sidebar-section-card">
                <div className="flex justify-between items-center mb-4 pb-2 border-b border-white/5">
                  <h3 className="text-xs font-bold text-minimal-gold uppercase tracking-wider">
                    {isHindiRoute ? "रसिक सन्त" : "Rasik Saints"}
                  </h3>
                  <Link to={isHindiRoute ? "/hi/saints" : "/saints"} className="text-[10px] text-primary hover:underline font-semibold">
                    {isHindiRoute ? "सभी" : "View All"}
                  </Link>
                </div>
                
                <div className="grid grid-cols-4 gap-3.5">
                  {saints.slice(0, 12).map(sant => (
                    <button
                      key={sant.cleanName}
                      onClick={() => openPreview(sant, 'saint')}
                      title={isHindiRoute ? sant.name : sant.hinglishName}
                      className="flex flex-col items-center group outline-none"
                    >
                      <div className="w-11 h-11 rounded-full bg-amber-500/10 border border-amber-500/20 group-hover:border-amber-500/50 flex items-center justify-center text-amber-500 font-bold text-base shadow-md group-hover:scale-105 transition-all duration-300">
                        {sant.cleanName.charAt(0) === 'श' && sant.cleanName.charAt(4) ? sant.cleanName.charAt(4) : sant.cleanName.charAt(0)}
                      </div>
                      <span className="text-[9px] text-white/50 group-hover:text-primary transition-colors block mt-1 truncate w-12 text-center">
                        {sant.cleanName.split(/\s+/)[0]}
                      </span>
                    </button>
                  ))}
                </div>
              </div>
            )}

            {/* Sidebar Block 2: Classical Ragas Melody Index */}
            {ragas.length > 0 && (
              <div className="sidebar-section-card">
                <div className="flex justify-between items-center mb-4 pb-2 border-b border-white/5">
                  <h3 className="text-xs font-bold text-minimal-gold uppercase tracking-wider">
                    {isHindiRoute ? "शास्त्रीय राग" : "Classical Ragas"}
                  </h3>
                  <Link to={isHindiRoute ? "/hi/ragas" : "/ragas"} className="text-[10px] text-primary hover:underline font-semibold">
                    {isHindiRoute ? "सभी" : "View All"}
                  </Link>
                </div>
                
                <div className="space-y-2">
                  {ragas.slice(0, 6).map(raga => (
                    <button
                      key={raga.name}
                      onClick={() => openPreview(raga, 'raga')}
                      className="w-full flex items-center justify-between p-2.5 rounded-xl bg-white/5 hover:bg-white/10 transition-colors border border-white/5 text-left text-xs group"
                    >
                      <div className="min-w-0 pr-2">
                        <span className="font-semibold text-white/90 group-hover:text-primary transition-colors block truncate">
                          {raga.name}
                        </span>
                        <span className="text-[9px] text-white/35 block truncate">{raga.hinglishName}</span>
                      </div>
                      <span className="text-[10px] text-white/40 bg-white/5 border border-white/15 px-2 py-0.5 rounded-md shrink-0 flex items-center gap-1">
                        <Music size={8} />
                        {raga.verses.length}
                      </span>
                    </button>
                  ))}
                </div>
              </div>
            )}

            {/* Sidebar Block 3: Dham & Categories Grid */}
            <div className="sidebar-section-card">
              <h3 className="text-xs font-bold text-minimal-gold uppercase tracking-wider mb-4 pb-2 border-b border-white/5">
                {isHindiRoute ? "श्रेणियां" : "Sanctuary Categories"}
              </h3>
              
              <div className="grid grid-cols-2 gap-3.5">
                <Link 
                  to="/category/sankirtan" 
                  className="p-3 rounded-xl bg-rose-500/5 hover:bg-rose-500/10 border border-rose-500/10 flex flex-col justify-between h-20 text-xs transition-colors group"
                >
                  <Heart size={16} className="text-rose-500" />
                  <div>
                    <span className="font-bold text-white/90 group-hover:text-primary transition-colors block">Sankirtan</span>
                    <span className="text-[9px] text-white/45">Lyrics</span>
                  </div>
                </Link>

                <Link 
                  to="/category/saint" 
                  className="p-3 rounded-xl bg-indigo-500/5 hover:bg-indigo-500/10 border border-indigo-500/10 flex flex-col justify-between h-20 text-xs transition-colors group"
                >
                  <Users size={16} className="text-indigo-500" />
                  <div>
                    <span className="font-bold text-white/90 group-hover:text-primary transition-colors block">Saints Bio</span>
                    <span className="text-[9px] text-white/45">Biographies</span>
                  </div>
                </Link>

                <Link 
                  to="/category/dham" 
                  className="p-3 rounded-xl bg-orange-500/5 hover:bg-orange-500/10 border border-orange-500/10 flex flex-col justify-between h-20 text-xs transition-colors group"
                >
                  <MapPin size={16} className="text-orange-500" />
                  <div>
                    <span className="font-bold text-white/90 group-hover:text-primary transition-colors block">Braj Dham</span>
                    <span className="text-[9px] text-white/45">Sacred Places</span>
                  </div>
                </Link>

                <Link 
                  to="/category/literature" 
                  className="p-3 rounded-xl bg-violet-500/5 hover:bg-violet-500/10 border border-violet-500/10 flex flex-col justify-between h-20 text-xs transition-colors group"
                >
                  <Book size={16} className="text-violet-500" />
                  <div>
                    <span className="font-bold text-white/90 group-hover:text-primary transition-colors block">Literature</span>
                    <span className="text-[9px] text-white/45">Vanis</span>
                  </div>
                </Link>
              </div>
            </div>

          </div>

        </div>

        {/* Minimalized Dynamic SEO Footer Content */}
        <div className="py-10 max-w-4xl mx-auto border-t border-white/5 mt-16 text-center text-xs text-white/35 leading-relaxed font-light">
          <p className="mb-2">
            Vrindopnishad Paath: Sacred dynamic portal curated for reading authentic Sanskrit shlokas, devotional strotras, and spiritual couplets.
          </p>
          <p>
            वृंदोपनिषद् पाठ: रसिक संतों की वाणी, स्तोत्र और वैदिक श्लोकों का एक अत्यंत सुंदर और सुगम डिजिटल संग्रह।
          </p>
        </div>

      </div>

      {/* Drawer Backdrop Overlay */}
      <div 
        className={`preview-drawer-backdrop ${selectedItem ? 'active' : ''}`}
        onClick={closePreview}
      />

      {/* Sliding Preview Drawer */}
      <div className={`preview-drawer ${selectedItem ? 'active' : ''}`}>
        <div className="drawer-drag-handle" />
        
        {selectedItem && (
          <div className="flex-1 flex flex-col overflow-hidden px-6 pt-4">
            {/* Header */}
            <div className="flex items-start justify-between gap-4 mb-4 pb-4 border-b border-white/5">
              <div className="min-w-0">
                <span className="text-[9px] uppercase tracking-[0.2em] text-primary font-bold block mb-1">
                  {previewType === 'saint' ? 'Holy Biography' : 
                   previewType === 'book' ? 'Scripture' : 
                   previewType === 'raga' ? 'Raga' : 'Verse'}
                </span>
                <h2 className="text-xl font-bold font-headings text-minimal-gold truncate">
                  {previewType === 'saint' ? (isHindiRoute ? selectedItem.name : selectedItem.hinglishName) :
                   previewType === 'book' ? selectedItem.name :
                   previewType === 'raga' ? selectedItem.name : selectedItem.title}
                </h2>
                {previewType === 'book' && selectedItem.author && (
                  <span className="text-xs text-white/40 block mt-1">
                    By {selectedItem.author}
                  </span>
                )}
                {previewType === 'raga' && (
                  <span className="text-xs text-white/40 block mt-0.5">
                    {selectedItem.hinglishName}
                  </span>
                )}
              </div>
              <button 
                onClick={closePreview}
                className="w-8 h-8 rounded-full bg-white/5 flex items-center justify-center text-white/40 hover:text-white transition-colors hover:bg-white/10 shrink-0"
              >
                <X size={16} />
              </button>
            </div>

            {/* Scrollable Container */}
            <div className="drawer-scroll-container">
              
              {/* Render for Saint */}
              {previewType === 'saint' && (
                <div>
                  <div className="drawer-tabs">
                    <button 
                      onClick={() => setDrawerTab('bio')}
                      className={`drawer-tab ${drawerTab === 'bio' ? 'active' : ''}`}
                    >
                      Biography
                    </button>
                    <button 
                      onClick={() => setDrawerTab('books')}
                      className={`drawer-tab ${drawerTab === 'books' ? 'active' : ''}`}
                    >
                      Books ({selectedItem.books ? selectedItem.books.length : 0})
                    </button>
                    <button 
                      onClick={() => setDrawerTab('verses')}
                      className={`drawer-tab ${drawerTab === 'verses' ? 'active' : ''}`}
                    >
                      Verses ({selectedItem.verses ? selectedItem.verses.length : 0})
                    </button>
                  </div>

                  {drawerTab === 'bio' && (
                    <div className="space-y-4">
                      {selectedItem.biography ? (
                        <p className="text-white/70 text-xs md:text-sm leading-relaxed whitespace-pre-line bg-white/5 p-4 rounded-xl border border-white/5">
                          {selectedItem.biography.text}
                        </p>
                      ) : (
                        <p className="text-white/40 text-center py-8 text-xs">Biography text not available in digital registry.</p>
                      )}
                    </div>
                  )}

                  {drawerTab === 'books' && (
                    <div className="grid grid-cols-1 gap-2">
                      {selectedItem.books && selectedItem.books.length > 0 ? (
                        selectedItem.books.map(bName => {
                          const matchedBookObj = books.find(b => b.name === bName);
                          return (
                            <button
                              key={bName}
                              onClick={() => {
                                if (matchedBookObj) {
                                  setSelectedItem(matchedBookObj);
                                  setPreviewType('book');
                                }
                              }}
                              className="p-3 text-left rounded-xl bg-white/5 hover:bg-white/10 border border-white/5 flex items-center justify-between text-xs font-bold w-full transition-colors group"
                            >
                              <span className="text-white/90 group-hover:text-primary transition-colors">{bName}</span>
                              <ChevronRight size={14} className="text-white/20 group-hover:text-primary transition-colors" />
                            </button>
                          );
                        })
                      ) : (
                        <p className="text-white/40 text-center py-8 text-xs">No books associated.</p>
                      )}
                    </div>
                  )}

                  {drawerTab === 'verses' && (
                    <div className="space-y-3">
                      {selectedItem.verses && selectedItem.verses.map(v => (
                        <VerseListItem key={v.id} verse={v} isHindiRoute={isHindiRoute} />
                      ))}
                    </div>
                  )}
                </div>
              )}

              {/* Render for Book */}
              {previewType === 'book' && (
                <div className="space-y-3">
                  {selectedItem.verses && selectedItem.verses.map(v => (
                    <VerseListItem key={v.id} verse={v} isHindiRoute={isHindiRoute} />
                  ))}
                </div>
              )}

              {/* Render for Raga */}
              {previewType === 'raga' && (
                <div className="space-y-3">
                  {selectedItem.verses && selectedItem.verses.map(v => (
                    <VerseListItem key={v.id} verse={v} isHindiRoute={isHindiRoute} />
                  ))}
                </div>
              )}

              {/* Render for Verse */}
              {previewType === 'verse' && (
                <div className="space-y-5 text-xs md:text-sm">
                  {selectedItem.audio_url && (
                    <div className="glass-card p-4 flex items-center justify-between border border-white/5 mb-4">
                      <span className="font-semibold text-white/80">Recitation Chanting:</span>
                      <AudioPlayButton 
                        track={selectedItem} 
                        className="bg-primary text-white p-3 rounded-full hover:scale-105 shadow-lg shadow-primary/20"
                        size={20}
                      />
                    </div>
                  )}

                  {selectedItem.sanskrit_text && (
                    <div className="bg-white/5 p-5 rounded-2xl border border-white/5 text-center">
                      <h5 className="text-[10px] uppercase tracking-wider text-amber-500/60 font-bold mb-3">Original Scripture Text</h5>
                      <p className="font-bold text-minimal-gold leading-loose whitespace-pre-line font-headings select-all text-base text-center py-2">
                        {selectedItem.sanskrit_text}
                      </p>
                    </div>
                  )}

                  {selectedItem.hindi_text && (
                    <div className="bg-white/5 p-4 rounded-xl border border-white/5">
                      <h5 className="text-[10px] uppercase tracking-wider text-white/40 font-bold mb-2">Translation / भावार्थ</h5>
                      <p className="text-white/70 leading-relaxed font-light">
                        {selectedItem.hindi_text}
                      </p>
                    </div>
                  )}

                  {selectedItem.english_translation && (
                    <div className="bg-white/5 p-4 rounded-xl border border-white/5">
                      <h5 className="text-[10px] uppercase tracking-wider text-white/40 font-bold mb-2">English Translation</h5>
                      <p className="text-white/60 leading-relaxed font-light italic">
                        {selectedItem.english_translation}
                      </p>
                    </div>
                  )}

                  {selectedItem.description && !selectedItem.hindi_text && !selectedItem.english_translation && (
                    <div className="bg-white/5 p-4 rounded-xl border border-white/5">
                      <h5 className="text-[10px] uppercase tracking-wider text-white/40 font-bold mb-2">Description</h5>
                      <p className="text-white/65 leading-relaxed font-light">
                        {selectedItem.description}
                      </p>
                    </div>
                  )}
                </div>
              )}

            </div>

            {/* Footer Navigation Link */}
            <div className="py-4 border-t border-white/5 flex gap-3 shrink-0">
              {previewType === 'saint' && (
                <Link
                  to={isHindiRoute ? `/hi/saint/${selectedItem.slug}` : `/saint/${selectedItem.slug}`}
                  onClick={closePreview}
                  className="btn-premium flex-1 text-center py-3 text-xs uppercase tracking-wider"
                >
                  Open Dedicated Page
                </Link>
              )}
              {previewType === 'book' && (
                <Link
                  to={isHindiRoute ? `/hi/book/${selectedItem.slug}` : `/book/${selectedItem.slug}`}
                  onClick={closePreview}
                  className="btn-premium flex-1 text-center py-3 text-xs uppercase tracking-wider"
                >
                  Open Dedicated Page
                </Link>
              )}
              {previewType === 'raga' && (
                <Link
                  to={isHindiRoute ? `/hi/raga/${selectedItem.slug}` : `/raga/${selectedItem.slug}`}
                  onClick={closePreview}
                  className="btn-premium flex-1 text-center py-3 text-xs uppercase tracking-wider"
                >
                  Open Dedicated Page
                </Link>
              )}
              {previewType === 'verse' && (
                <Link
                  to={isHindiRoute ? `/hi/content/${selectedItem.slug || selectedItem.id}` : `/content/${selectedItem.slug || selectedItem.id}`}
                  onClick={closePreview}
                  className="btn-premium flex-1 text-center py-3 text-xs uppercase tracking-wider"
                >
                  Open Dedicated Page
                </Link>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default HomePage;
