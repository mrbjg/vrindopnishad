import React, { useState, useEffect, useContext } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Compass, Scroll, Music, FileText, ArrowRight, BookOpen, Heart, Star, Globe, Users, MapPin, Book, ChevronRight, X, Search } from 'lucide-react';
import { Helmet } from 'react-helmet-async';
import { useSettings, THEMES } from '../contexts/SettingsContext';
import ThemeIcon from '../components/ThemeIcon';
import { ApiContext } from '../App';
import { extractRelations } from '../utils/relations';
import AudioPlayButton from '../components/ui/AudioPlayButton';

const themeGroups = [
  {
    id: 'core',
    label: 'Core Energies',
    themes: ['dark', 'light']
  },
  {
    id: 'celestial',
    label: 'Celestial Realms',
    themes: ['night', 'space', 'void']
  },
  {
    id: 'seasonal',
    label: 'Seasonal Moods',
    themes: ['winter', 'snow', 'rainy', 'mountains', 'sunset', 'forest', 'ocean']
  }
];

const themeGradients = {
  dark: '#09090b',
  light: 'linear-gradient(135deg, #fdfbf7 0%, #eae5d9 100%)',
  night: '#030712',
  space: '#08070d',
  void: '#000000',
  winter: 'linear-gradient(135deg, #e0f2fe 0%, #f0f9ff 100%)',
  snow: 'linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%)',
  rainy: 'linear-gradient(135deg, #f1f5f9 0%, #cbd5e1 100%)',
  mountains: 'linear-gradient(135deg, #fafaf9 0%, #e7e5e4 100%)',
  sunset: 'linear-gradient(135deg, #fff7ed 0%, #ffedd5 100%)',
  forest: 'linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%)',
  ocean: 'linear-gradient(135deg, #ecfeff 0%, #cffafe 100%)'
};

const DAILY_SHLOKAS = [
  {
    source: "श्रीमद्भगवद्गीता २.४७ (Bhagavad Gita 2.47)",
    sanskrit: "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन ।\nमा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि ॥",
    hindi: "तुम्हारा अधिकार केवल कर्म करने पर है, उसके फलों पर कभी नहीं। इसलिए कर्म के फलों की चिंता मत करो और कर्म न करने के प्रति आसक्त मत हो।",
    english: "You have a right to perform your prescribed duties, but you are not entitled to the fruits of your actions. Never consider yourself to be the cause of your activities' results, nor be attached to inaction."
  },
  {
    source: "श्रीमद्भगवद्गीता १८.६६ (Bhagavad Gita 18.66)",
    sanskrit: "सर्वधर्मान्परित्यज्य मामेकं शरणं व्रज ।\nअहं त्वां सर्वपापेभ्यो मोक्षयिष्यामि मा शुचः ॥",
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
          <div className="space-y-4 text-xs md:text-sm">
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
  const { settings, updateSetting } = useSettings();
  const currentTheme = settings.theme || 'dark';
  const [activeTab, setActiveTab] = useState('core');
  
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
      b.hinglishName?.toLowerCase().includes(q) ||
      b.author?.toLowerCase().includes(q)
    );

    const matchedRagas = ragas.filter(r => 
      r.name?.toLowerCase().includes(q) || 
      r.hinglishName?.toLowerCase().includes(q)
    );

    const matchedVerses = allItems.filter(item => {
      if (item.category?.toLowerCase() === 'saint') return false;
      return (
        item.title?.toLowerCase().includes(q) ||
        item.hindi_text?.toLowerCase().includes(q) ||
        item.sanskrit_text?.toLowerCase().includes(q) ||
        item.english_translation?.toLowerCase().includes(q) ||
        item.description?.toLowerCase().includes(q)
      );
    });

    return {
      sants: matchedSants.slice(0, 5),
      books: matchedBooks.slice(0, 5),
      ragas: matchedRagas.slice(0, 5),
      verses: matchedVerses.slice(0, 10)
    };
  }, [searchQuery, saints, books, ragas, allItems]);

  const shlokaIndex = new Date().getDate() % DAILY_SHLOKAS.length;
  const dailyShloka = DAILY_SHLOKAS[shlokaIndex];

  return (
    <div className="relative overflow-hidden animate-fade-in font-sans min-h-screen">
      <Helmet>
        <title>Vrindopnishad Paath — वृंदोपनिषद् पाठ | Sacred Shlokas, Strotras & Devotional Poetry</title>
        <meta name="description" content="Vrindopnishad Paath (वृंदोपनिषद् पाठ) — Read and listen to authentic sacred Sanskrit shlokas, devotional strotras, spiritual poetry & Vedic wisdom from Vrindavan saints. Free online paath of Bhagavad Gita, mantras & hymns in Hindi, Sanskrit & English." />
        <meta name="keywords" content="vrindopnishad, vrindopnishad paath, वृंदोपनिषद्, वृंदोपनिषद् पाठ, vrindopnishad path, vrindopnishad app, vrindopnishad.in, sant vaani, sacred shlokas, sanskrit shlokas, strotras, devotional poetry, bhagavad gita, vedic wisdom, vrindavan, bhakti, श्लोक, स्तोत्र, कविता, वेद, उपनिषद, मंत्र, हिंदी भजन, radha krishna, premanand ji maharaj, barsana, nandgaav, govardhan, braj rasik, brajrasik, rasik sant" />
        <link rel="canonical" href="https://path.vrindopnishad.in/" />

        {/* Hindi-specific meta for Google India */}
        <meta name="geo.region" content="IN" />
        <meta name="geo.placename" content="Vrindavan, India" />
        <meta name="content-language" content="hi, en, sa" />

        {/* Open Graph */}
        <meta property="og:type" content="website" />
        <meta property="og:url" content="https://path.vrindopnishad.in/" />
        <meta property="og:site_name" content="Vrindopnishad — वृंदोपनिषद्" />
        <meta property="og:title" content="Vrindopnishad Paath — वृंदोपनिषद् पाठ | Sacred Digital Sanctuary" />
        <meta property="og:description" content="Read Vrindopnishad Paath online — sacred Sanskrit shlokas, strotras, devotional poetry & Vedic wisdom from Vrindavan saints. Free in Hindi, Sanskrit & English." />
        <meta property="og:image" content="https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png" />
        <meta property="og:locale" content="hi_IN" />
        <meta property="og:locale:alternate" content="en_IN" />

        {/* Twitter */}
        <meta name="twitter:card" content="summary_large_image" />
        <meta name="twitter:title" content="Vrindopnishad Paath — वृंदोपनिषद् पाठ" />
        <meta name="twitter:description" content="Read Vrindopnishad Paath online — sacred Sanskrit shlokas, strotras, devotional poetry & Vedic wisdom." />
        <meta name="twitter:image" content="https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png" />

        {/* JSON-LD: CollectionPage */}
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

      <div className="relative z-10">
        {/* Overhauled Hero Section with Mandala */}
        <div className="text-center pt-8 pb-12 md:pt-16 md:pb-20 max-w-4xl mx-auto px-4">
          <div className="premium-hero-card">
            {/* Minimalist Sacred Symbol */}
            <div className="sacred-symbol-minimal animate-fade-in">
              <div className="sacred-symbol-ring" />
              <div className="sacred-symbol-text">
                ॐ
              </div>
            </div>

            <h1 className="text-5xl md:text-7xl font-bold mb-4 tracking-tight text-minimal-gold font-headings">
              वृंदोपनिषद्
            </h1>
            <p className="text-xl md:text-2xl text-minimal-gold font-semibold tracking-widest mb-4">Vrindopnishad Paath</p>
            <p className="text-sm md:text-base text-white/60 font-light max-w-xl mx-auto leading-relaxed mb-8">
              पवित्र डिजिटल संग्रह — Sacred Digital Sanctuary for Shlokas, Strotras & Devotional Poetry from Vrindavan
            </p>

            <div className="flex flex-wrap justify-center gap-4">
              <Link to="/content" className="btn-premium px-8 py-3.5 text-sm shadow-lg hover:shadow-primary/20 transition-all duration-300 hover:scale-105">
                <Compass size={18} />
                Explore Paath
              </Link>
              <Link to="/category/shloka" className="px-8 py-3.5 rounded-full border border-white/15 hover:bg-white/5 hover:border-white/30 text-sm text-white/80 transition-all flex items-center gap-2 font-medium hover:scale-105">
                <Scroll size={18} className="text-primary" />
                Browse Shlokas
              </Link>
            </div>
          </div>
        </div>

        {/* Unified Instant Search Bar */}
        <div className="max-w-4xl mx-auto px-4 mb-16 relative">
          <div className="relative w-full">
            <Search className="absolute left-5 top-1/2 -translate-y-1/2 text-white/35 group-focus-within:text-primary transition-colors" size={20} />
            <input 
              type="text" 
              placeholder={isHindiRoute ? "सन्त, ग्रन्थ, राग या वाणी खोजें..." : "Search Saints, Books, Ragas or Verses..."} 
              className="w-full h-14 bg-white/5 border border-white/10 rounded-2xl pl-14 pr-12 outline-none focus:border-amber-500/50 transition-all text-sm md:text-base font-medium shadow-inner"
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

          {/* Search Results Dashboard */}
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
                  {/* Saints Match */}
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

                  {/* Books Match */}
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

                  {/* Ragas Match */}
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

                  {/* Verses Match */}
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

        {/* Premium Atmosphere Portal Selector */}
        <div className="max-w-4xl mx-auto px-4 mb-16">
          <div className="text-center mb-6">
            <span className="text-[10px] uppercase tracking-[0.3em] text-white/30 font-bold block mb-1">
              Atmospheric Presence
            </span>
            <h2 className="text-xl md:text-2xl font-bold text-minimal-gold font-headings">
              Choose Sanctuary Atmosphere
            </h2>
          </div>

          {/* Category Tabs */}
          <div className="flex justify-center mb-6">
            <div className="inline-flex rounded-full bg-white/5 p-1 border border-white/10 backdrop-blur-md">
              {themeGroups.map((group) => (
                <button
                  key={group.id}
                  onClick={() => setActiveTab(group.id)}
                  className={`px-4 py-2 rounded-full text-xs font-semibold tracking-wider transition-all duration-300 ${
                    activeTab === group.id
                      ? 'bg-primary text-white shadow-md'
                      : 'text-white/50 hover:text-white/85'
                  }`}
                >
                  {group.label}
                </button>
              ))}
            </div>
          </div>

          {/* Mini-grid with Swatches */}
          <div className="flex flex-wrap justify-center gap-3">
            {THEMES.filter(t => {
              const currentGroup = themeGroups.find(g => g.id === activeTab);
              return currentGroup ? currentGroup.themes.includes(t.id) : false;
            }).map((theme) => {
              const isActive = currentTheme === theme.id;
              return (
                <div
                  key={theme.id}
                  onClick={() => updateSetting('theme', theme.id)}
                  className={`theme-card-premium w-[130px] ${isActive ? 'active' : ''}`}
                >
                  <div className="theme-card-premium-inner">
                    <div className="theme-card-icon-wrap">
                      <ThemeIcon name={theme.icon} size={16} />
                    </div>
                    
                    {/* Miniature Swatch */}
                    <div 
                      className="w-4 h-4 rounded-full border border-white/20 shadow-inner mt-0.5"
                      style={{ background: themeGradients[theme.id] }}
                    />
                    
                    <span className="text-[11px] font-semibold tracking-wide text-center">
                      {theme.label}
                    </span>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Minimal Intro Section */}
        <div className="py-10 max-w-3xl mx-auto border-b border-white/5 px-4">
          <div className="text-center">
            <h2 className="text-2xl font-bold mb-5 text-minimal-gold font-headings">
              Vrindopnishad Paath — वृंदोपनिषद् पाठ क्या है?
            </h2>
            <p className="text-white/50 text-sm leading-relaxed mb-4">
              <strong className="text-white/80">Vrindopnishad</strong> (वृंदोपनिषद्) is the premier sacred digital sanctuary dedicated to preserving and sharing authentic spiritual and Vedic knowledge from the heart of Vrindavan. The word "Vrindopnishad" combines <em>Vrinda</em> (the sacred groves of Vrindavan, वृंदावन) and <em>Upanishad</em> (sacred knowledge, उपनिषद्), meaning "the sacred knowledge flowing from Vrindavan."
            </p>
            <p className="text-white/50 text-sm leading-relaxed mb-6">
              <strong className="text-white/80">Vrindopnishad Paath</strong> (वृंदोपनिषद् पाठ) refers to the practice of reading, reciting, and contemplating the sacred verses, shlokas (श्लोक), strotras (स्तोत्र), and devotional poetry (भक्ति कविता) curated on this platform.
            </p>
            <div className="flex flex-wrap justify-center gap-6">
              <Link to="/what-is-vrindopnishad" className="text-primary hover:underline text-xs flex items-center gap-1.5">
                <BookOpen size={12} /> What is Vrindopnishad? →
              </Link>
              <Link to="/meaning" className="text-primary hover:underline text-xs flex items-center gap-1.5">
                <Star size={12} /> Meaning & Etymology →
              </Link>
              <Link to="/origin" className="text-primary hover:underline text-xs flex items-center gap-1.5">
                <Globe size={12} /> Historical Origins →
              </Link>
            </div>
          </div>
        </div>

        {/* Categories Grid - Overhauled with Neon Glow Accents */}
        <div className="py-16 px-4 max-w-6xl mx-auto">
          <div className="flex items-center gap-4 mb-10">
            <div className="h-[1px] flex-1 bg-white/5"></div>
            <h2 className="text-sm font-semibold opacity-40 uppercase tracking-[0.2em] font-headings">पाठ श्रेणियाँ — Categories</h2>
            <div className="h-[1px] flex-1 bg-white/5"></div>
          </div>

          <div className="grid md:grid-cols-3 gap-6 font-sans">
            <Link 
              to="/category/shloka" 
              className="minimal-card group"
            >
               <div className="w-10 h-10 rounded-xl bg-amber-500/10 flex items-center justify-center text-amber-500 mb-5 group-hover:scale-110 transition-transform duration-300">
                 <Scroll size={20} />
               </div>
               <span className="text-[10px] uppercase tracking-widest text-amber-500/80 font-bold block mb-1">वेद और उपनिषद</span>
               <h3 className="text-base font-bold mb-2 text-white/90 group-hover:text-primary transition-colors">Sacred Verses — श्लोक</h3>
               <p className="text-white/40 text-xs leading-relaxed">
                 Dive into timeless Sanskrit shlokas from the Vedas, Upanishads, and Bhagavad Gita. Read Vrindopnishad paath of sacred verses with Hindi meaning.
               </p>
            </Link>

            <Link 
              to="/category/strotra" 
              className="minimal-card group"
            >
               <div className="w-10 h-10 rounded-xl bg-sky-500/10 flex items-center justify-center text-sky-500 mb-5 group-hover:scale-110 transition-transform duration-300">
                 <Music size={20} />
               </div>
               <span className="text-[10px] uppercase tracking-widest text-sky-500/80 font-bold block mb-1">भक्ति स्तोत्र</span>
               <h3 className="text-base font-bold mb-2 text-white/90 group-hover:text-primary transition-colors">Strotras — स्तोत्र</h3>
               <p className="text-white/40 text-xs leading-relaxed">
                 Experience the power of traditional devotional hymns and prayers. Listen and read strotras dedicated to Radha Krishna, Shiva, and Hanuman.
               </p>
            </Link>

            <Link 
              to="/category/poem" 
              className="minimal-card group"
            >
               <div className="w-10 h-10 rounded-xl bg-emerald-500/10 flex items-center justify-center text-emerald-500 mb-5 group-hover:scale-110 transition-transform duration-300">
                 <FileText size={20} />
               </div>
               <span className="text-[10px] uppercase tracking-widest text-emerald-500/80 font-bold block mb-1">आध्यात्मिक कविता</span>
               <h3 className="text-base font-bold mb-2 text-white/90 group-hover:text-primary transition-colors">Poems — कविताएँ</h3>
               <p className="text-white/40 text-xs leading-relaxed">
                 Explore classical and contemporary devotional poems, bhajans, and couplets from saints like Surdas, Meera Bai, and Kabir.
               </p>
            </Link>
          </div>
        </div>

        {/* Daily Meditative Shloka Widget */}
        <div className="py-12 max-w-3xl mx-auto px-4">
          <div className="minimal-card relative overflow-hidden group">
            <div className="flex items-center gap-2 mb-6">
              <span className="w-2 h-2 rounded-full bg-primary animate-ping" />
              <span className="text-[10px] uppercase tracking-[0.25em] text-primary font-bold">
                Daily Meditation • दैनिक स्वाध्याय
              </span>
            </div>

            <blockquote className="text-center my-8">
              <p className="text-xl md:text-2xl font-bold text-minimal-gold leading-loose whitespace-pre-line font-headings select-all">
                {dailyShloka.sanskrit}
              </p>
            </blockquote>

            <div className="border-t border-white/10 pt-6 mt-6">
              <div className="text-center mb-4">
                <span className="text-xs font-bold text-amber-500/80 uppercase tracking-widest">
                  {dailyShloka.source}
                </span>
              </div>
              
              <div className="grid md:grid-cols-2 gap-6 mt-4 text-left">
                <div>
                  <h4 className="text-[10px] uppercase tracking-wider text-white/40 font-bold mb-1.5">Hindi Meaning</h4>
                  <p className="text-xs text-white/70 leading-relaxed font-light">
                    {dailyShloka.hindi}
                  </p>
                </div>
                <div className="border-t md:border-t-0 md:border-l border-white/5 pt-4 md:pt-0 md:pl-6">
                  <h4 className="text-[10px] uppercase tracking-wider text-white/40 font-bold mb-1.5">English Translation</h4>
                  <p className="text-xs text-white/65 leading-relaxed font-light italic">
                    {dailyShloka.english}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Dynamic Relations Section: Saints, Books, Ragas */}
        {!loading && (
          <div className="py-12 max-w-6xl mx-auto px-4 space-y-16">
            
            {/* 1. Rasik Saints Carousel */}
            {saints.length > 0 && (
              <div>
                <div className="flex justify-between items-end mb-6">
                  <div>
                    <span className="text-[10px] uppercase tracking-[0.25em] text-primary font-bold block mb-1">Holy Biographies & Vaanis</span>
                    <h2 className="text-2xl font-bold font-headings text-minimal-gold">
                      {isHindiRoute ? "रसिक सन्त" : "Rasik Saints"}
                    </h2>
                  </div>
                  <Link to={isHindiRoute ? "/hi/saints" : "/saints"} className="text-xs text-primary hover:underline flex items-center gap-1 font-semibold">
                    {isHindiRoute ? "सभी देखें" : "View All"}
                    <ChevronRight size={14} />
                  </Link>
                </div>
                
                <div className="flex gap-4 overflow-x-auto pb-4 scrollbar-hide snap-x">
                  {saints.slice(0, 10).map(sant => (
                    <Link 
                      key={sant.cleanName} 
                      to={isHindiRoute ? `/hi/saint/${sant.slug}` : `/saint/${sant.slug}`}
                      onClick={(e) => {
                        e.preventDefault();
                        openPreview(sant, 'saint');
                      }}
                      className="w-40 flex-none glass-card p-4 rounded-2xl flex flex-col items-center text-center group hover:border-amber-500/20 transition-all snap-start"
                    >
                      <div className="w-16 h-16 rounded-full bg-amber-500/10 border border-amber-500/20 flex items-center justify-center text-amber-500 font-bold text-2xl mb-3 group-hover:scale-105 transition-transform duration-300">
                        {sant.cleanName.charAt(0) === 'श' && sant.cleanName.charAt(4) ? sant.cleanName.charAt(4) : sant.cleanName.charAt(0)}
                      </div>
                      <h3 className="font-bold text-sm text-white/90 group-hover:text-primary transition-colors line-clamp-1 w-full leading-tight">
                        {isHindiRoute ? sant.name : sant.hinglishName}
                      </h3>
                      <span className="text-[9px] uppercase tracking-wider text-white/30 block mt-1">
                        {sant.verses.length} {sant.verses.length === 1 ? 'Verse' : 'Verses'}
                      </span>
                    </Link>
                  ))}
                </div>
              </div>
            )}

            {/* 2. Books & Granthas Carousel */}
            {books.length > 0 && (
              <div>
                <div className="flex justify-between items-end mb-6">
                  <div>
                    <span className="text-[10px] uppercase tracking-[0.25em] text-primary font-bold block mb-1">Sacred Scriptures</span>
                    <h2 className="text-2xl font-bold font-headings text-minimal-gold">
                      {isHindiRoute ? "ग्रन्थ - रसिक वाणी" : "Books - Rasik Vanis"}
                    </h2>
                  </div>
                  <Link to={isHindiRoute ? "/hi/books" : "/books"} className="text-xs text-primary hover:underline flex items-center gap-1 font-semibold">
                    {isHindiRoute ? "सभी देखें" : "View All"}
                    <ChevronRight size={14} />
                  </Link>
                </div>
                
                <div className="flex gap-5 overflow-x-auto pb-4 scrollbar-hide snap-x">
                  {books.slice(0, 10).map(book => (
                    <Link 
                      key={book.name} 
                      to={isHindiRoute ? `/hi/book/${book.slug}` : `/book/${book.slug}`}
                      onClick={(e) => {
                        e.preventDefault();
                        openPreview(book, 'book');
                      }}
                      className="w-52 flex-none glass-card p-5 rounded-2xl group hover:border-amber-500/20 transition-all snap-start flex flex-col justify-between h-44 border border-white/10 hover:shadow-2xl"
                    >
                      <div>
                        <span className="text-[9px] uppercase tracking-widest text-amber-500 font-bold block mb-2">Grantha</span>
                        <h3 className="font-bold text-base text-white/90 group-hover:text-primary transition-colors leading-tight line-clamp-2">
                          {book.name}
                        </h3>
                        <span className="text-xs text-white/40 block mt-1 line-clamp-1">
                          By {book.author}
                        </span>
                      </div>
                      <span className="text-[10px] text-white/30 flex items-center gap-1 mt-4">
                        <FileText size={12} />
                        {book.verses.length} {book.verses.length === 1 ? 'Verse' : 'Verses'}
                      </span>
                    </Link>
                  ))}
                </div>
              </div>
            )}

            {/* 3. Ragas Carousel */}
            {ragas.length > 0 && (
              <div>
                <div className="flex justify-between items-end mb-6">
                  <div>
                    <span className="text-[10px] uppercase tracking-[0.25em] text-primary font-bold block mb-1">Sankirtan Tunes</span>
                    <h2 className="text-2xl font-bold font-headings text-minimal-gold">
                      {isHindiRoute ? "शास्त्रीय राग" : "Classical Ragas"}
                    </h2>
                  </div>
                  <Link to={isHindiRoute ? "/hi/ragas" : "/ragas"} className="text-xs text-primary hover:underline flex items-center gap-1 font-semibold">
                    {isHindiRoute ? "सभी देखें" : "View All"}
                    <ChevronRight size={14} />
                  </Link>
                </div>
                
                <div className="flex gap-4 overflow-x-auto pb-4 scrollbar-hide snap-x">
                  {ragas.slice(0, 10).map(raga => (
                    <Link 
                      key={raga.name} 
                      to={isHindiRoute ? `/hi/raga/${raga.slug}` : `/raga/${raga.slug}`}
                      onClick={(e) => {
                        e.preventDefault();
                        openPreview(raga, 'raga');
                      }}
                      className="w-48 flex-none glass-card p-4 rounded-xl group hover:border-amber-500/20 transition-all snap-start flex items-center justify-between"
                    >
                      <div className="min-w-0 pr-2">
                        <h3 className="font-bold text-sm text-white/90 group-hover:text-primary transition-colors truncate">
                          {raga.name}
                        </h3>
                        <span className="text-[10px] text-white/30 truncate block mt-0.5">{raga.hinglishName}</span>
                      </div>
                      <div className="w-8 h-8 rounded-lg bg-sky-500/10 text-sky-400 flex items-center justify-center shrink-0">
                        <Music size={16} />
                      </div>
                    </Link>
                  ))}
                </div>
              </div>
            )}
            
          </div>
        )}

        {/* Braj Heritage Section - Overhauled Grid */}
        <div className="py-12 px-4 max-w-6xl mx-auto">
          <div className="flex items-center gap-4 mb-10">
            <div className="h-[1px] flex-1 bg-white/5"></div>
            <h2 className="text-sm font-semibold opacity-40 uppercase tracking-[0.2em] font-headings">ब्रज रसिक विरासत — Braj Dham</h2>
            <div className="h-[1px] flex-1 bg-white/5"></div>
          </div>

          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 font-sans">
            <Link 
              to="/category/sankirtan" 
              className="minimal-card flex items-center gap-3 group"
              style={{ padding: '1rem 1.25rem' }}
            >
               <div className="w-9 h-9 rounded-lg bg-rose-500/10 flex items-center justify-center text-rose-500 shrink-0 group-hover:scale-110 transition-transform duration-300">
                 <Heart size={18} />
               </div>
               <div className="min-w-0">
                 <h3 className="font-bold text-sm text-white/90 truncate group-hover:text-primary transition-colors">Sankirtan</h3>
                 <p className="text-white/40 text-[10px] truncate">Lyrics & Bhajans</p>
               </div>
            </Link>

            <Link 
              to="/category/saint" 
              className="minimal-card flex items-center gap-3 group"
              style={{ padding: '1rem 1.25rem' }}
            >
               <div className="w-9 h-9 rounded-lg bg-indigo-500/10 flex items-center justify-center text-indigo-500 shrink-0 group-hover:scale-110 transition-transform duration-300">
                 <Users size={18} />
               </div>
               <div className="min-w-0">
                 <h3 className="font-bold text-sm text-white/90 truncate group-hover:text-primary transition-colors">Rasik Saints</h3>
                 <p className="text-white/40 text-[10px] truncate">Holy Biographies</p>
               </div>
            </Link>

            <Link 
              to="/category/dham" 
              className="minimal-card flex items-center gap-3 group"
              style={{ padding: '1rem 1.25rem' }}
            >
               <div className="w-9 h-9 rounded-lg bg-orange-500/10 flex items-center justify-center text-orange-500 shrink-0 group-hover:scale-110 transition-transform duration-300">
                 <MapPin size={18} />
               </div>
               <div className="min-w-0">
                 <h3 className="font-bold text-sm text-white/90 truncate group-hover:text-primary transition-colors">Braj Dham</h3>
                 <p className="text-white/40 text-[10px] truncate">Sacred Places</p>
               </div>
            </Link>

            <Link 
              to="/category/literature" 
              className="minimal-card flex items-center gap-3 group"
              style={{ padding: '1rem 1.25rem' }}
            >
               <div className="w-9 h-9 rounded-lg bg-violet-500/10 flex items-center justify-center text-violet-500 shrink-0 group-hover:scale-110 transition-transform duration-300">
                 <Book size={18} />
               </div>
               <div className="min-w-0">
                 <h3 className="font-bold text-sm text-white/90 truncate group-hover:text-primary transition-colors">Literature</h3>
                 <p className="text-white/40 text-[10px] truncate">Rasik Scriptures</p>
               </div>
            </Link>
          </div>
        </div>

        {/* Why Vrindopnishad Section - Clean Typography */}
        <div className="py-12 max-w-3xl mx-auto px-4">
          <h2 className="text-2xl font-bold mb-8 text-center text-minimal-gold font-headings">
            Why Read Vrindopnishad Paath Online?
          </h2>
          <div className="grid md:grid-cols-2 gap-6">
            <div className="flex gap-4 p-2">
              <div className="w-10 h-10 rounded-xl bg-amber-500/5 text-amber-500 flex items-center justify-center shrink-0 mt-1">
                <BookOpen size={20} />
              </div>
              <div>
                <h3 className="font-bold text-sm text-white/90 mb-1">645+ Curated Verses</h3>
                <p className="text-white/45 text-xs leading-relaxed">Authentic Sanskrit shlokas, strotras, and devotional poetry verified by traditional Vrindavan scholars.</p>
              </div>
            </div>

            <div className="flex gap-4 p-2">
              <div className="w-10 h-10 rounded-xl bg-sky-500/5 text-sky-500 flex items-center justify-center shrink-0 mt-1">
                <Globe size={20} />
              </div>
              <div>
                <h3 className="font-bold text-sm text-white/90 mb-1">Tri-lingual Translation</h3>
                <p className="text-white/45 text-xs leading-relaxed">Every verse features original Sanskrit/Hindi text accompanied by fluid English translations.</p>
              </div>
            </div>

            <div className="flex gap-4 p-2">
              <div className="w-10 h-10 rounded-xl bg-emerald-500/5 text-emerald-500 flex items-center justify-center shrink-0 mt-1">
                <Music size={20} />
              </div>
              <div>
                <h3 className="font-bold text-sm text-white/90 mb-1">Traditional Chanting</h3>
                <p className="text-white/45 text-xs leading-relaxed">Listen to high-quality audio narrations and traditional recitation styles to improve pronunciation.</p>
              </div>
            </div>

            <div className="flex gap-4 p-2">
              <div className="w-10 h-10 rounded-xl bg-rose-500/5 text-rose-500 flex items-center justify-center shrink-0 mt-1">
                <Heart size={20} />
              </div>
              <div>
                <h3 className="font-bold text-sm text-white/90 mb-1">A Free Spiritual Hub</h3>
                <p className="text-white/45 text-xs leading-relaxed">No subscriptions or hidden fees. We believe sacred wisdom should be open and accessible to all.</p>
              </div>
            </div>
          </div>
        </div>

        {/* Knowledge Hub - Premium Accordion Panel Grid */}
        <div className="py-12 max-w-3xl mx-auto px-4">
          <h2 className="text-2xl font-bold mb-8 text-center text-minimal-gold font-headings">
            वृंदोपनिषद् ज्ञान केंद्र — Knowledge Hub
          </h2>
          <div className="grid md:grid-cols-2 gap-4 font-sans">
            <Link to="/what-is-vrindopnishad" className="premium-hub-panel flex items-center justify-between group">
              <div className="min-w-0 pr-4">
                <span className="w-1.5 h-1.5 rounded-full bg-primary inline-block mr-2 align-middle opacity-60 group-hover:opacity-100 group-hover:scale-125 transition-all" />
                <h3 className="inline-block font-bold text-sm text-white/90 group-hover:text-primary transition-colors align-middle">What is Vrindopnishad?</h3>
                <p className="text-white/40 text-[11px] mt-1 pl-3.5 truncate">Introduction to the digital sanctuary</p>
              </div>
              <ArrowRight size={16} className="text-white/20 group-hover:text-primary group-hover:translate-x-1 transition-all shrink-0" />
            </Link>

            <Link to="/meaning" className="premium-hub-panel flex items-center justify-between group">
              <div className="min-w-0 pr-4">
                <span className="w-1.5 h-1.5 rounded-full bg-primary inline-block mr-2 align-middle opacity-60 group-hover:opacity-100 group-hover:scale-125 transition-all" />
                <h3 className="inline-block font-bold text-sm text-white/90 group-hover:text-primary transition-colors align-middle">Meaning — अर्थ</h3>
                <p className="text-white/40 text-[11px] mt-1 pl-3.5 truncate">Significance and spiritual definitions</p>
              </div>
              <ArrowRight size={16} className="text-white/20 group-hover:text-primary group-hover:translate-x-1 transition-all shrink-0" />
            </Link>

            <Link to="/origin" className="premium-hub-panel flex items-center justify-between group">
              <div className="min-w-0 pr-4">
                <span className="w-1.5 h-1.5 rounded-full bg-primary inline-block mr-2 align-middle opacity-60 group-hover:opacity-100 group-hover:scale-125 transition-all" />
                <h3 className="inline-block font-bold text-sm text-white/90 group-hover:text-primary transition-colors align-middle">Origin — उत्पत्ति</h3>
                <p className="text-white/40 text-[11px] mt-1 pl-3.5 truncate">Vrindavan roots and history</p>
              </div>
              <ArrowRight size={16} className="text-white/20 group-hover:text-primary group-hover:translate-x-1 transition-all shrink-0" />
            </Link>

            <Link to="/philosophy" className="premium-hub-panel flex items-center justify-between group">
              <div className="min-w-0 pr-4">
                <span className="w-1.5 h-1.5 rounded-full bg-primary inline-block mr-2 align-middle opacity-60 group-hover:opacity-100 group-hover:scale-125 transition-all" />
                <h3 className="inline-block font-bold text-sm text-white/90 group-hover:text-primary transition-colors align-middle">Philosophy — दर्शन</h3>
                <p className="text-white/40 text-[11px] mt-1 pl-3.5 truncate">Bhakti principles and Vedic path</p>
              </div>
              <ArrowRight size={16} className="text-white/20 group-hover:text-primary group-hover:translate-x-1 transition-all shrink-0" />
            </Link>

            <Link to="/teachings" className="premium-hub-panel flex items-center justify-between group">
              <div className="min-w-0 pr-4">
                <span className="w-1.5 h-1.5 rounded-full bg-primary inline-block mr-2 align-middle opacity-60 group-hover:opacity-100 group-hover:scale-125 transition-all" />
                <h3 className="inline-block font-bold text-sm text-white/90 group-hover:text-primary transition-colors align-middle">Teachings — शिक्षाएँ</h3>
                <p className="text-white/40 text-[11px] mt-1 pl-3.5 truncate">Key spiritual messages & insights</p>
              </div>
              <ArrowRight size={16} className="text-white/20 group-hover:text-primary group-hover:translate-x-1 transition-all shrink-0" />
            </Link>

            <Link to="/importance" className="premium-hub-panel flex items-center justify-between group">
              <div className="min-w-0 pr-4">
                <span className="w-1.5 h-1.5 rounded-full bg-primary inline-block mr-2 align-middle opacity-60 group-hover:opacity-100 group-hover:scale-125 transition-all" />
                <h3 className="inline-block font-bold text-sm text-white/90 group-hover:text-primary transition-colors align-middle">Importance — महत्व</h3>
                <p className="text-white/40 text-[11px] mt-1 pl-3.5 truncate">Why these texts matter today</p>
              </div>
              <ArrowRight size={16} className="text-white/20 group-hover:text-primary group-hover:translate-x-1 transition-all shrink-0" />
            </Link>
          </div>
        </div>

        {/* SEO Bottom Content - Clean Description */}
        <div className="py-12 max-w-3xl mx-auto px-4 border-t border-white/5">
          <h2 className="text-xl font-bold mb-4 text-white/90 font-headings">वृंदोपनिषद् पाठ — Vrindopnishad Paath Online</h2>
          <p className="text-white/45 text-xs leading-relaxed mb-4">
            Vrindopnishad Paath is the daily spiritual practice of reading sacred verses from the Vedas, Upanishads, Bhagavad Gita, and the devotional literature of Vrindavan. Our platform brings this ancient practice into the digital age, allowing seekers worldwide to engage with authentic spiritual texts.
          </p>
          <p className="text-white/45 text-xs leading-relaxed mb-4">
            वृंदोपनिषद् पाठ एक पवित्र आध्यात्मिक अभ्यास है जो वेदों, उपनिषदों, भगवद्गीता, और वृंदावन की भक्ति साहित्य के पवित्र श्लोकों को पढ़ने और सुनने की परंपरा है। हमारा मंच इस प्राचीन परंपरा को डिजिटल युग में लाता है।
          </p>
          <div className="flex flex-wrap gap-1.5 mt-6">
            {['vrindopnishad', 'vrindopnishad paath', 'वृंदोपनिषद्', 'श्लोक', 'स्तोत्र', 'भक्ति कविता', 'भगवद्गीता', 'radha krishna', 'vrindavan', 'sanskrit shlokas'].map(tag => (
              <span key={tag} className="px-2.5 py-0.5 rounded-full border border-white/5 text-white/30 text-[10px]">{tag}</span>
            ))}
          </div>
        </div>

        {/* Minimal Call to Action */}
        <div className="my-16 py-16 border-t border-b border-white/5 text-center relative overflow-hidden">
          <div className="relative z-10 max-w-2xl mx-auto px-4">
            <h2 className="text-2xl font-bold mb-2 text-white/95 font-headings">अपनी आध्यात्मिक यात्रा शुरू करें</h2>
            <p className="text-base text-white/60 mb-6 font-headings">Start Your Spiritual Journey</p>
            <p className="text-white/40 text-xs max-w-md mx-auto mb-8 leading-relaxed">
               Immerse yourself in sacred texts with audio narrations, beautiful imagery, and deep spiritual insights. Read Vrindopnishad Paath daily for inner peace and divine wisdom.
            </p>
            <Link to="/content" className="btn-premium px-10 py-3.5 text-sm shadow-xl hover:shadow-primary/20">
               Enter Presence — पाठ पढ़ें
               <ArrowRight size={16} />
            </Link>
          </div>
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
                      Books ({selectedItem.books.length})
                    </button>
                    <button 
                      onClick={() => setDrawerTab('verses')}
                      className={`drawer-tab ${drawerTab === 'verses' ? 'active' : ''}`}
                    >
                      Verses ({selectedItem.verses.length})
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
                      {selectedItem.books.length > 0 ? (
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
                      {selectedItem.verses.map(v => (
                        <VerseListItem key={v.id} verse={v} isHindiRoute={isHindiRoute} />
                      ))}
                    </div>
                  )}
                </div>
              )}

              {/* Render for Book */}
              {previewType === 'book' && (
                <div className="space-y-3">
                  {selectedItem.verses.map(v => (
                    <VerseListItem key={v.id} verse={v} isHindiRoute={isHindiRoute} />
                  ))}
                </div>
              )}

              {/* Render for Raga */}
              {previewType === 'raga' && (
                <div className="space-y-3">
                  {selectedItem.verses.map(v => (
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
