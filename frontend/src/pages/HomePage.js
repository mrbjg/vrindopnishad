import React, { useState, useEffect, useContext, useMemo } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { ChevronRight, Music, FileText, ArrowRight, Volume2, Clock, X } from 'lucide-react';
import { Helmet } from 'react-helmet-async';
import { ApiContext } from '../App';
import { extractRelations } from '../utils/relations';
import AudioPlayButton from '../components/ui/AudioPlayButton';

/* ─── Daily Shloka Rotation ─── */
const DAILY_SHLOKAS = [
  {
    source: "श्रीमद्भगवद्गीता २.४७",
    sanskrit: "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन ।\nमा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि ॥",
    hindi: "तुम्हारा अधिकार केवल कर्म करने पर है, उसके फलों पर कभी नहीं। इसलिए कर्म के फलों की चिंता मत करो।",
    english: "You have a right to perform your prescribed duties, but you are not entitled to the fruits of your actions."
  },
  {
    source: "श्रीमद्भगवद्गीता १८.६६",
    sanskrit: "सर्वधर्मान्परित्यज्य मामेकं शरणं व्रज ।\nअहं तं सर्वपापेभ्यो मोक्षयिष्यामि मा शुचः ॥",
    hindi: "सभी धर्मों का त्याग करके केवल मेरी शरण में आओ। मैं तुम्हें सभी पापों से मुक्त कर दूंगा, शोक मत करो।",
    english: "Abandon all varieties of religion and just surrender unto Me. I shall deliver you from all sinful reactions. Do not fear."
  },
  {
    source: "श्रीमद्भगवद्गीता ४.७",
    sanskrit: "यदा यदा हि धर्मस्य ग्लानिर्भवति भारत ।\nअभ्युत्थानमधर्मस्य तदात्मानं सृजाम्यहम् ॥",
    hindi: "हे भारत! जब-जब धर्म की हानि होती है और अधर्म बढ़ता है, तब-तब मैं अवतार लेता हूँ।",
    english: "Whenever there is a decline in righteousness and an increase in unrighteousness, I manifest Myself on earth."
  }
];

/* ─── Gradient generator for book covers ─── */
const getBookGradient = (name) => {
  let h = 0;
  for (let i = 0; i < name.length; i++) h = name.charCodeAt(i) + ((h << 5) - h);
  const h1 = Math.abs(h % 360);
  const h2 = (h1 + 60) % 360;
  return `linear-gradient(135deg, hsl(${h1}, 75%, 26%) 0%, hsl(${h2}, 60%, 8%) 100%)`;
};

/* ─── Get initials for circular avatar ─── */
const getInitials = (name) => {
  if (!name) return 'V';
  let clean = name.replace(/^(Shri|Swami|Sri|Shree|श्री|स्वामी|श्रीमद्)\s+/i, '').trim();
  if (!clean.length) clean = name;
  const first = clean.charAt(0);
  return first.match(/[a-zA-Z]/) ? first.toUpperCase() : first;
};

/* ─── Cache Keys ─── */
const CACHE_KEY = 'vrindopnishad_all_content_cache';
const CACHE_TIME_KEY = 'vrindopnishad_all_content_time';
const CACHE_DURATION = 5 * 60 * 1000; // 5 minutes cache

/* ═══════════════════════════════════════════════════
   HOMEPAGE COMPONENT
   ═══════════════════════════════════════════════════ */
const HomePage = () => {
  const location = useLocation();
  const isHi = location.pathname.startsWith('/hi');
  const { apiService } = useContext(ApiContext);

  const [allItems, setAllItems] = useState([]);
  const [saints, setSaints] = useState([]);
  const [books, setBooks] = useState([]);
  const [ragas, setRagas] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showTranslation, setShowTranslation] = useState(false);

  // Drawer state
  const [selectedItem, setSelectedItem] = useState(null);
  const [previewType, setPreviewType] = useState(null);
  const [drawerTab, setDrawerTab] = useState('bio');

  const openPreview = (item, type) => { setSelectedItem(item); setPreviewType(type); setDrawerTab('bio'); };
  const closePreview = () => { setSelectedItem(null); setPreviewType(null); };

  useEffect(() => {
    let active = true;
    const load = async () => {
      try {
        const cachedData = localStorage.getItem(CACHE_KEY);
        const cachedTime = localStorage.getItem(CACHE_TIME_KEY);
        const now = Date.now();

        if (cachedData && cachedTime && (now - parseInt(cachedTime, 10) < CACHE_DURATION)) {
          const items = JSON.parse(cachedData);
          const rel = extractRelations(items);
          if (active) {
            setAllItems(items);
            setSaints(rel.sants);
            setBooks(rel.books);
            setRagas(rel.ragas);
            setLoading(false);
          }
          // Silent background update to keep data fresh
          apiService.getAllContent(null, 10000).then(freshItems => {
            localStorage.setItem(CACHE_KEY, JSON.stringify(freshItems));
            localStorage.setItem(CACHE_TIME_KEY, Date.now().toString());
            const freshRel = extractRelations(freshItems);
            if (active) {
              setAllItems(freshItems);
              setSaints(freshRel.sants);
              setBooks(freshRel.books);
              setRagas(freshRel.ragas);
            }
          }).catch(e => console.log('Background content refresh failed:', e));
        } else {
          const items = await apiService.getAllContent(null, 10000);
          localStorage.setItem(CACHE_KEY, JSON.stringify(items));
          localStorage.setItem(CACHE_TIME_KEY, now.toString());
          const rel = extractRelations(items);
          if (active) {
            setAllItems(items);
            setSaints(rel.sants);
            setBooks(rel.books);
            setRagas(rel.ragas);
            setLoading(false);
          }
        }
      } catch (e) {
        console.error('HomePage load:', e);
        if (active) setLoading(false);
      }
    };
    load();
    return () => { active = false; };
  }, [apiService]);

  const latestVerses = useMemo(() => allItems.filter(i => i.category?.toLowerCase() !== 'saint').slice(0, 6), [allItems]);
  const dailyShloka = DAILY_SHLOKAS[new Date().getDate() % DAILY_SHLOKAS.length];

  /* ── Category dynamic stats ── */
  const categoryStats = useMemo(() => {
    const counts = { shloka: 0, strotra: 0, poem: 0, raga: ragas.length };
    allItems.forEach(item => {
      const cat = item.category?.toLowerCase();
      if (counts[cat] !== undefined) {
        counts[cat]++;
      }
    });
    return counts;
  }, [allItems, ragas]);

  /* ── Loading State ── */
  if (loading) {
    return (
      <div className="relative max-w-6xl mx-auto px-4 py-12 animate-pulse text-left min-h-screen">
        <div className="h-64 bg-white/5 rounded-3xl mb-8" />
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
          {[...Array(4)].map((_, i) => <div key={i} className="h-24 bg-white/5 rounded-2xl" />)}
        </div>
        <div className="h-48 bg-white/5 rounded-3xl" />
      </div>
    );
  }

  return (
    <div className="relative overflow-hidden animate-fade-in font-sans min-h-screen">

      {/* ── SEO ── */}
      <Helmet>
        <title>Vrindopnishad Paath — वृंदोपनिषद् पाठ | Sacred Shlokas, Strotras &amp; Devotional Poetry</title>
        <meta name="description" content="Vrindopnishad Paath (वृंदोपनिषद् पाठ) — Read and listen to authentic sacred Sanskrit shlokas, devotional strotras, spiritual poetry &amp; Vedic wisdom from Vrindavan saints. Free online paath in Hindi, Sanskrit &amp; English." />
        <meta name="keywords" content="vrindopnishad, vrindopnishad paath, वृंदोपनिषद्, वृंदोपनिषद् पाठ, vrindopnishad path, vrindopnishad app, sant vaani, sacred shlokas, sanskrit shlokas, strotras, devotional poetry, bhagavad gita, vedic wisdom, vrindavan, bhakti, श्लोक, स्तोत्र, rasik sant, braj rasik, brajrasik, radha krishna, premanand ji maharaj, barsana, nandgaav, govardhan, rasik vaani, रसिक वाणी" />
        <link rel="canonical" href="https://path.vrindopnishad.in/" />
        <meta name="geo.region" content="IN" />
        <meta name="geo.placename" content="Vrindavan, India" />
        <meta name="content-language" content="hi, en, sa" />
        <meta property="og:type" content="website" />
        <meta property="og:url" content="https://path.vrindopnishad.in/" />
        <meta property="og:site_name" content="Vrindopnishad — वृंदोपनिषद्" />
        <meta property="og:title" content="Vrindopnishad Paath — वृंदोपनिषद् पाठ | Sacred Digital Sanctuary" />
        <meta property="og:description" content="Read sacred Sanskrit shlokas, Rasik Sant vaani, strotras &amp; Vedic wisdom online." />
        <meta property="og:image" content="https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png" />
        <meta property="og:locale" content="hi_IN" />
        <meta property="og:locale:alternate" content="en_IN" />
        <meta name="twitter:card" content="summary_large_image" />
        <meta name="twitter:title" content="Vrindopnishad Paath — वृंदोपनिषद् पाठ" />
        <meta name="twitter:description" content="Read sacred Sanskrit shlokas, Rasik Sant vaani &amp; Vedic wisdom online." />
        <meta name="twitter:image" content="https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png" />
        <script type="application/ld+json">{JSON.stringify({
          "@context": "https://schema.org", "@type": "CollectionPage",
          "name": "Vrindopnishad Paath — वृंदोपनिषद् पाठ",
          "alternateName": ["Vrindopnishad", "वृंदोपनिषद्", "Sant Vaani"],
          "description": "Largest digital collection of sacred Sanskrit shlokas, strotras, Rasik Sant vaani, and Vedic wisdom from Vrindavan.",
          "url": "https://path.vrindopnishad.in", "inLanguage": ["hi", "en", "sa"],
          "publisher": { "@type": "Organization", "name": "Vrindopnishad", "logo": { "@type": "ImageObject", "url": "https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png" }},
          "mainEntity": { "@type": "ItemList", "itemListElement": [
            { "@type": "ListItem", "position": 1, "name": "Rasik Sant Vaani", "url": "https://path.vrindopnishad.in/saints" },
            { "@type": "ListItem", "position": 2, "name": "Sacred Granthas", "url": "https://path.vrindopnishad.in/books" },
            { "@type": "ListItem", "position": 3, "name": "Classical Ragas", "url": "https://path.vrindopnishad.in/ragas" },
            { "@type": "ListItem", "position": 4, "name": "Sacred Verses", "url": "https://path.vrindopnishad.in/content" }
          ]}
        })}</script>
      </Helmet>

      {/* ── Ambient Glow Blobs ── */}
      <div className="home-theme-glow-ambient top-[-250px] left-[-200px] md:w-[800px] md:h-[800px]"
        style={{ background: `radial-gradient(circle, rgba(var(--primary-rgb), 0.03) 0%, rgba(var(--primary-rgb), 0.005) 50%, transparent 70%)` }} />
      <div className="home-theme-glow-ambient bottom-[20%] right-[-200px] md:w-[700px] md:h-[700px]"
        style={{ background: `radial-gradient(circle, rgba(var(--primary-rgb), 0.015) 0%, transparent 70%)` }} />

      <div className="relative z-10 max-w-6xl mx-auto px-4 py-4 animate-fade-in space-y-12 pt-6">

        {/* ═══ DAILY SWADHYAYA BANNER (HERO CAROUSEL CARD) ═══ */}
        <div className="glass-card p-6 md:p-8 rounded-3xl border border-amber-500/10 shadow-2xl relative overflow-hidden max-w-4xl mx-auto group">
          <div className="absolute top-0 right-0 p-6 opacity-[0.02] pointer-events-none">
            <ChevronRight size={180} className="text-amber-500" />
          </div>
          <div className="flex items-center justify-between mb-4 border-b border-white/5 pb-3">
            <div className="flex items-center gap-2">
              <span className="w-2 h-2 rounded-full bg-primary animate-ping" />
              <span className="text-[10px] uppercase tracking-[0.2em] text-white/50 font-bold">
                {isHi ? "दैनिक स्वाध्याय" : "Daily Swadhyaya"}
              </span>
            </div>
            <span className="text-[10px] font-bold text-amber-500 bg-amber-500/5 border border-amber-500/10 px-2 py-0.5 rounded-md uppercase tracking-wider">
              {dailyShloka.source.split(' ')[0]}
            </span>
          </div>

          <blockquote className="my-6 text-center">
            <p className="text-lg md:text-2xl font-bold text-minimal-gold leading-loose font-headings whitespace-pre-line select-all">
              {dailyShloka.sanskrit}
            </p>
          </blockquote>

          <div className="flex justify-center mb-2">
            <button onClick={() => setShowTranslation(!showTranslation)}
              className="text-[9px] uppercase tracking-widest text-white/55 hover:text-primary border border-white/10 hover:border-primary/30 px-3.5 py-1.5 rounded-full bg-white/[0.01] transition-all font-semibold">
              {showTranslation ? (isHi ? "भावार्थ छिपाएं" : "Hide Translation") : (isHi ? "भावार्थ देखें" : "Reveal Translation")}
            </button>
          </div>

          <div className={`overflow-hidden transition-all duration-500 ease-in-out ${showTranslation ? 'max-h-[300px] opacity-100 mt-6 border-t border-white/5 pt-5' : 'max-h-0 opacity-0'}`}>
            <div className="grid md:grid-cols-2 gap-6 text-xs font-light leading-relaxed text-left">
              <div>
                <span className="text-[9px] uppercase tracking-wider text-amber-500/60 font-bold block mb-1.5">भावार्थ (Hindi)</span>
                <p className="text-white/70">{dailyShloka.hindi}</p>
              </div>
              <div className="border-t md:border-t-0 md:border-l border-white/5 pt-4 md:pt-0 md:pl-6">
                <span className="text-[9px] uppercase tracking-wider text-sky-400/60 font-bold block mb-1.5">English</span>
                <p className="text-white/60 italic">{dailyShloka.english}</p>
              </div>
            </div>
          </div>
        </div>

        {/* ═══ CATEGORIES INHERITED GRID BLOCKS ═══ */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          {[
            { to: '/category/shloka', name: isHi ? 'वैदिक श्लोक' : 'Sacred Shlokas', label: 'Vedic', count: categoryStats.shloka, color: 'from-amber-500/20 to-yellow-600/5', border: 'border-amber-500/20', text: 'text-amber-400' },
            { to: '/category/strotra', name: isHi ? 'भक्ति स्तोत्र' : 'Divine Strotras', label: 'Devotional', count: categoryStats.strotra, color: 'from-sky-500/20 to-blue-600/5', border: 'border-sky-500/20', text: 'text-sky-400' },
            { to: '/category/poem', name: isHi ? 'संत कविताएँ' : 'Spiritual Poetry', label: 'Poems', count: categoryStats.poem, color: 'from-emerald-500/20 to-teal-600/5', border: 'border-emerald-500/20', text: 'text-emerald-400' },
            { to: '/ragas', name: isHi ? 'शास्त्रीय राग' : 'Sankirtan Ragas', label: 'Melodies', count: categoryStats.raga, color: 'from-rose-500/20 to-red-600/5', border: 'border-rose-500/20', text: 'text-rose-400' }
          ].map(c => (
            <Link key={c.to} to={c.to}
              className={`p-5 rounded-2xl bg-gradient-to-br ${c.color} border ${c.border} flex flex-col justify-between h-28 hover:scale-[1.02] transition-all group`}>
              <span className={`text-[10px] font-bold uppercase tracking-widest ${c.text}`}>{c.label}</span>
              <div>
                <h3 className="font-bold text-sm text-white/90 group-hover:text-primary transition-colors truncate">{c.name}</h3>
                <span className="text-[10px] text-white/35 mt-0.5 block font-light">{c.count} {c.count === 1 ? 'item' : 'items'} loaded</span>
              </div>
            </Link>
          ))}
        </div>

        {/* ═══ GRANTHAS SHOWCASE (STOREFRONT LIBRARY) ═══ */}
        {books.length > 0 && (
          <div className="space-y-5">
            <div className="flex justify-between items-end">
              <div>
                <span className="text-[9px] uppercase tracking-[0.25em] text-primary font-bold block mb-0.5">Sacred Library Catalog</span>
                <h2 className="text-xl md:text-2xl font-bold font-headings text-minimal-gold">{isHi ? "दिव्य ग्रन्थ एवं वाणी" : "Granthas & Scriptures"}</h2>
              </div>
              <Link to={isHi ? "/hi/books" : "/books"} className="text-xs text-primary hover:underline flex items-center gap-0.5 font-bold">
                {isHi ? "सभी ग्रन्थ" : "View All Granthas"}<ChevronRight size={14} />
              </Link>
            </div>

            <div className="flex gap-4 overflow-x-auto pb-4 pt-1 snap-x book-shelf-row">
              {books.slice(0, 8).map(book => (
                <div key={book.name} onClick={() => openPreview(book, 'book')}
                  className="w-80 flex-none glass-card p-4 rounded-2xl hover:border-amber-500/25 transition-all snap-start flex gap-4 border border-white/5 cursor-pointer group shadow-lg">
                  {/* CSS Designed Premium Book Cover */}
                  <div className="book-cover-premium shrink-0 text-white select-none shadow-xl"
                    style={{ background: getBookGradient(book.name) }}>
                    <div className="book-cover-inner-gold">
                      <div className="text-[8px] opacity-40 font-semibold tracking-widest">ॐ</div>
                      <span className="text-[9px] font-bold line-clamp-3 text-center leading-tight tracking-wide uppercase px-0.5 text-white/90 font-headings">
                        {book.name.replace(/जी की वाणी/g, '').replace(/वाणी/g, '').replace(/ग्रन्थ/g, '')}
                      </span>
                      <span className="text-[7px] text-white/60 uppercase tracking-widest font-headings font-bold opacity-60">SCRIPTURE</span>
                    </div>
                  </div>
                  {/* Book Metadata */}
                  <div className="flex flex-col justify-between py-1 min-w-0 flex-1">
                    <div className="space-y-1">
                      <h3 className="font-bold text-xs text-white/95 group-hover:text-primary transition-colors leading-snug line-clamp-2">{book.name}</h3>
                      <span className="text-[10px] text-white/40 block truncate">By {book.author ? book.author.replace(/जी/g, '') : 'Braj Rasik'}</span>
                    </div>
                    <div className="space-y-2">
                      <span className="text-[9px] text-white/30 flex items-center gap-1"><FileText size={10} />{book.verses.length} verses</span>
                      <button className="w-full bg-white/5 hover:bg-primary/20 text-white/70 hover:text-primary font-bold text-[9px] py-1 px-2 rounded-lg transition-colors border border-white/10 hover:border-primary/20 tracking-wider uppercase">
                        {isHi ? "वाणी पढ़ें" : "Read Now"}
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* ═══ RASIK SAINTS CREATOR SPOTLIGHT ═══ */}
        {saints.length > 0 && (
          <div className="space-y-5">
            <div className="flex justify-between items-end">
              <div>
                <span className="text-[9px] uppercase tracking-[0.25em] text-primary font-bold block mb-0.5">Divine Creators & Spiritual Guides</span>
                <h2 className="text-xl md:text-2xl font-bold font-headings text-minimal-gold">{isHi ? "परम पावन रसिक सन्त" : "Braj Rasik Saints"}</h2>
              </div>
              <Link to={isHi ? "/hi/saints" : "/saints"} className="text-xs text-primary hover:underline flex items-center gap-0.5 font-bold">
                {isHi ? "सभी सन्त" : "View All Saints"}<ChevronRight size={14} />
              </Link>
            </div>

            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-6 gap-4">
              {saints.slice(0, 6).map(sant => (
                <div key={sant.cleanName} onClick={() => openPreview(sant, 'saint')}
                  className="glass-card !p-3 rounded-2xl border border-white/5 hover:border-amber-500/20 text-center cursor-pointer group transition-all flex flex-col items-center justify-between space-y-3">
                  <div className="w-14 h-14 rounded-full bg-amber-500/5 border border-amber-500/10 group-hover:border-amber-500/40 flex items-center justify-center text-amber-500 font-bold text-lg shadow-inner group-hover:scale-105 transition-all duration-300">
                    {getInitials(isHi ? sant.name : sant.hinglishName)}
                  </div>
                  <div className="min-w-0 w-full px-1">
                    <h3 className="font-bold text-[11px] text-white/90 group-hover:text-primary transition-colors line-clamp-2 w-full leading-tight py-0.5 saint-card-title">
                      {isHi ? sant.name : sant.hinglishName}
                    </h3>
                    <span className="text-[9px] text-white/35 font-light block mt-0.5">{sant.verses.length} verses</span>
                  </div>
                  <span className="text-[8px] bg-amber-500/10 text-primary border border-amber-500/20 px-2 py-0.5 rounded-full uppercase tracking-wider font-bold">
                    Explore
                  </span>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* ═══ LATEST DEVOTIONAL FEED (BLOG STYLE GRID) ═══ */}
        {latestVerses.length > 0 && (
          <div className="space-y-5">
            <div className="flex justify-between items-end">
              <div>
                <span className="text-[9px] uppercase tracking-[0.25em] text-primary font-bold block mb-0.5">Freshly Curated Spiritual Wisdom</span>
                <h2 className="text-xl md:text-2xl font-bold font-headings text-minimal-gold">{isHi ? "नवीनतम वाणी एवं श्लोक" : "Latest Verse Feed"}</h2>
              </div>
              <Link to={isHi ? "/hi/content" : "/content"} className="text-xs text-primary hover:underline flex items-center gap-0.5 font-bold">
                {isHi ? "सम्पूर्ण वाणियाँ" : "View Library"}<ChevronRight size={14} />
              </Link>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {latestVerses.map(verse => {
                const excerpt = verse.hindi_text || verse.sanskrit_text || verse.english_translation || verse.description || "";
                const readingTime = Math.max(1, Math.ceil(excerpt.length / 120)) + " min read";
                return (
                  <div key={verse.id} onClick={() => openPreview(verse, 'verse')}
                    className="premium-content-card p-5 cursor-pointer flex flex-col justify-between space-y-4 group">
                    <div className="space-y-3">
                      <div className="flex items-center justify-between">
                        <span className="text-[9px] uppercase tracking-wider text-amber-500/80 bg-amber-500/5 px-2.5 py-0.5 rounded border border-amber-500/10 font-bold">
                          {verse.category}
                        </span>
                        <span className="text-[9px] text-white/30 flex items-center gap-1 font-light">
                          <Clock size={10} />
                          {readingTime}
                        </span>
                      </div>
                      <div className="space-y-1">
                        <h3 className="font-bold text-sm text-white/95 group-hover:text-primary transition-colors leading-snug line-clamp-2">
                          {verse.cleanTitle || verse.title}
                        </h3>
                        {verse.author && (
                          <span className="text-[10px] text-white/40 block font-light">
                            By {verse.author.replace(/जी/g, '')}
                          </span>
                        )}
                      </div>
                      <p className="text-[11px] text-white/45 font-light leading-relaxed line-clamp-3 select-none">
                        {excerpt}
                      </p>
                    </div>

                    <div className="flex items-center justify-between border-t border-white/5 pt-3 shrink-0">
                      <span className="text-[9px] uppercase tracking-wider text-white/35 flex items-center gap-1 font-bold group-hover:text-primary transition-colors">
                        Read Verse <ArrowRight size={10} />
                      </span>
                      {verse.audio_url && (
                        <div onClick={(e) => e.stopPropagation()} className="relative z-20">
                          <AudioPlayButton track={verse} className="bg-sky-500/10 text-sky-400 border border-sky-500/20 p-2 rounded-full hover:scale-105 transition-transform" size={14} />
                        </div>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* ═══ CLASSICAL RAGAS COMPACT INDEX ═══ */}
        {ragas.length > 0 && (
          <div className="glass-card p-5 rounded-2xl border border-white/5 space-y-4 max-w-4xl mx-auto shadow-md">
            <div className="flex justify-between items-center pb-2 border-b border-white/5">
              <h3 className="text-xs font-bold text-minimal-gold uppercase tracking-wider flex items-center gap-1.5 font-headings">
                <Music size={12} className="text-primary" />
                {isHi ? "राग रागिनियाँ" : "Classical Ragas"}
              </h3>
              <Link to={isHi ? "/hi/ragas" : "/ragas"} className="text-[10px] text-primary hover:underline font-bold">{isHi ? "सभी राग" : "View All"}</Link>
            </div>
            <div className="flex flex-wrap gap-2">
              {ragas.slice(0, 10).map(raga => (
                <button key={raga.name} onClick={() => openPreview(raga, 'raga')}
                  className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-white/5 hover:bg-white/10 border border-white/5 hover:border-white/10 text-xs text-left transition-all group">
                  <span className="font-semibold text-white/90 group-hover:text-primary transition-colors text-[11px]">{raga.name}</span>
                  <span className="text-[9px] text-white/35 font-light bg-white/5 px-1.5 py-0.5 rounded-md flex items-center gap-0.5 shrink-0">
                    <Volume2 size={8} />
                    {raga.verses.length}
                  </span>
                </button>
              ))}
            </div>
          </div>
        )}

        {/* ═══ GOOGLE SEO CONTEXT AND FOOTER ═══ */}
        <div className="py-8 max-w-4xl mx-auto border-t border-white/5 text-center text-xs text-white/35 leading-relaxed font-light space-y-4">
          <p>
            <strong className="text-white/55 font-bold">Vrindopnishad Paath (वृंदोपनिषद् पाठ)</strong> online sanctuary: Engage daily with authentic Vedic Sanskrit Shlokas (श्लोक), devotional hymns (Strotras / स्तोत्र), and spiritual poetry from Braj Dham saints including Premanand Ji Maharaj, Swami Haridas, Hit Harivansh, and other Braj rasiks. Access complete Hindi भावार्थ translations, English meanings, and classical Raga notations for devotional chanting and swadhyaya.
          </p>
          <p>
            वृंदोपनिषद् पाठ: रस उपासना और ब्रज रसिक संतों की वाणी का एक पवित्र डिजिटल संग्रह। हमारा उद्देश्य संस्कृत ग्रंथों, स्तोत्रों, और कविताओं के अमूल्य ज्ञान को सुगम और सुंदर रूप में जिज्ञासुओं तक पहुँचाना है।
          </p>
          <div className="flex flex-wrap justify-center gap-2 pt-2">
            {['vrindopnishad', 'vrindopnishad paath', 'वृंदोपनिषद्', 'श्लोक', 'स्तोत्र', 'रसिक वाणी', 'radha krishna', 'premanand ji', 'vrindavan', 'classical ragas', 'bhagavad gita'].map(tag => (
              <span key={tag} className="px-2.5 py-0.5 rounded-full border border-white/5 text-white/30 text-[9px] font-light">#{tag}</span>
            ))}
          </div>
        </div>

      </div>

      {/* ═══ PREVIEW DRAWER ═══ */}
      <div className={`preview-drawer-backdrop ${selectedItem ? 'active' : ''}`} onClick={closePreview} />
      <div className={`preview-drawer ${selectedItem ? 'active' : ''}`}>
        <div className="drawer-drag-handle" />
        {selectedItem && (
          <div className="flex-1 flex flex-col overflow-hidden px-6 pt-4">
            {/* Header */}
            <div className="flex items-start justify-between gap-4 mb-4 pb-4 border-b border-white/5">
              <div className="min-w-0">
                <span className="text-[9px] uppercase tracking-[0.2em] text-primary font-bold block mb-1">
                  {previewType === 'saint' ? 'Holy Biography' : previewType === 'book' ? 'Scripture' : previewType === 'raga' ? 'Raga' : 'Verse'}
                </span>
                <h2 className="text-xl font-bold font-headings text-minimal-gold truncate">
                  {previewType === 'saint' ? (isHi ? selectedItem.name : selectedItem.hinglishName) :
                   previewType === 'book' ? selectedItem.name : previewType === 'raga' ? selectedItem.name : selectedItem.title}
                </h2>
                {previewType === 'book' && selectedItem.author && <span className="text-xs text-white/40 block mt-1">By {selectedItem.author}</span>}
                {previewType === 'raga' && <span className="text-xs text-white/40 block mt-0.5">{selectedItem.hinglishName}</span>}
              </div>
              <button onClick={closePreview} className="w-8 h-8 rounded-full bg-white/5 flex items-center justify-center text-white/40 hover:text-white transition-colors hover:bg-white/10 shrink-0"><X size={16} /></button>
            </div>

            {/* Scrollable Content */}
            <div className="drawer-scroll-container">
              {/* Saint */}
              {previewType === 'saint' && (<div>
                <div className="drawer-tabs">
                  {['bio', 'books', 'verses'].map(tab => (
                    <button key={tab} onClick={() => setDrawerTab(tab)} className={`drawer-tab ${drawerTab === tab ? 'active' : ''}`}>
                      {tab === 'bio' ? 'Biography' : tab === 'books' ? `Books (${selectedItem.books?.length || 0})` : `Verses (${selectedItem.verses?.length || 0})`}
                    </button>
                  ))}
                </div>
                {drawerTab === 'bio' && (
                  selectedItem.biography
                    ? <p className="text-white/70 text-xs md:text-sm leading-relaxed whitespace-pre-line bg-white/5 p-4 rounded-xl border border-white/5">{selectedItem.biography.text}</p>
                    : <p className="text-white/40 text-center py-8 text-xs">Biography not available.</p>
                )}
                {drawerTab === 'books' && (<div className="grid grid-cols-1 gap-2">
                  {selectedItem.books?.length > 0 ? selectedItem.books.map(bName => {
                    const m = books.find(b => b.name === bName);
                    return (<button key={bName} onClick={() => { if (m) { setSelectedItem(m); setPreviewType('book'); }}}
                      className="p-3 text-left rounded-xl bg-white/5 hover:bg-white/10 border border-white/5 flex items-center justify-between text-xs font-bold w-full transition-colors group">
                      <span className="text-white/90 group-hover:text-primary transition-colors">{bName}</span>
                      <ChevronRight size={14} className="text-white/20 group-hover:text-primary transition-colors" />
                    </button>);
                  }) : <p className="text-white/40 text-center py-8 text-xs">No books.</p>}
                </div>)}
                {drawerTab === 'verses' && (<div className="space-y-2">
                  {selectedItem.verses?.map(v => (
                    <Link key={v.id} to={isHi ? `/hi/content/${v.slug || v.id}` : `/content/${v.slug || v.id}`} onClick={closePreview}
                      className="block p-3 rounded-xl bg-white/5 hover:bg-white/10 border border-white/5 text-xs font-bold text-white/85 hover:text-primary transition-colors truncate">{v.cleanTitle || v.title}</Link>
                  ))}
                </div>)}
              </div>)}

              {/* Book */}
              {previewType === 'book' && (<div className="space-y-2">
                {selectedItem.verses?.map(v => (
                  <Link key={v.id} to={isHi ? `/hi/content/${v.slug || v.id}` : `/content/${v.slug || v.id}`} onClick={closePreview}
                    className="block p-3 rounded-xl bg-white/5 hover:bg-white/10 border border-white/5 text-xs font-bold text-white/85 hover:text-primary transition-colors truncate">{v.cleanTitle || v.title}</Link>
                ))}
              </div>)}

              {/* Raga */}
              {previewType === 'raga' && (<div className="space-y-2">
                {selectedItem.verses?.map(v => (
                  <Link key={v.id} to={isHi ? `/hi/content/${v.slug || v.id}` : `/content/${v.slug || v.id}`} onClick={closePreview}
                    className="block p-3 rounded-xl bg-white/5 hover:bg-white/10 border border-white/5 text-xs font-bold text-white/85 hover:text-primary transition-colors truncate">{v.cleanTitle || v.title}</Link>
                ))}
              </div>)}

              {/* Verse */}
              {previewType === 'verse' && (<div className="space-y-5 text-xs md:text-sm">
                {selectedItem.audio_url && (
                  <div className="glass-card p-4 flex items-center justify-between border border-white/5 mb-4">
                    <span className="font-semibold text-white/80">Recitation:</span>
                    <AudioPlayButton track={selectedItem} className="bg-primary text-white p-3 rounded-full hover:scale-105 shadow-lg shadow-primary/20" size={20} />
                  </div>
                )}
                {selectedItem.sanskrit_text && (
                  <div className="bg-white/5 p-5 rounded-2xl border border-white/5 text-center">
                    <h5 className="text-[10px] uppercase tracking-wider text-amber-500/60 font-bold mb-3">Original Scripture</h5>
                    <p className="font-bold text-minimal-gold leading-loose whitespace-pre-line font-headings select-all text-base text-center py-2">{selectedItem.sanskrit_text}</p>
                  </div>
                )}
                {selectedItem.hindi_text && (
                  <div className="bg-white/5 p-4 rounded-xl border border-white/5">
                    <h5 className="text-[10px] uppercase tracking-wider text-white/40 font-bold mb-2">भावार्थ</h5>
                    <p className="text-white/70 leading-relaxed font-light">{selectedItem.hindi_text}</p>
                  </div>
                )}
                {selectedItem.english_translation && (
                  <div className="bg-white/5 p-4 rounded-xl border border-white/5">
                    <h5 className="text-[10px] uppercase tracking-wider text-white/40 font-bold mb-2">English</h5>
                    <p className="text-white/60 leading-relaxed font-light italic">{selectedItem.english_translation}</p>
                  </div>
                )}
                {selectedItem.description && !selectedItem.hindi_text && !selectedItem.english_translation && (
                  <div className="bg-white/5 p-4 rounded-xl border border-white/5">
                    <h5 className="text-[10px] uppercase tracking-wider text-white/40 font-bold mb-2">Description</h5>
                    <p className="text-white/65 leading-relaxed font-light">{selectedItem.description}</p>
                  </div>
                )}
              </div>)}
            </div>

            {/* Footer Link */}
            <div className="py-4 border-t border-white/5 flex gap-3 shrink-0">
              {previewType === 'saint' && (
                <Link to={isHi ? `/hi/saint/${selectedItem.slug}` : `/saint/${selectedItem.slug}`} onClick={closePreview}
                  className="btn-premium flex-1 text-center py-3 text-xs uppercase tracking-wider font-semibold">Open Full Page</Link>
              )}
              {previewType === 'book' && (
                <Link to={isHi ? `/hi/book/${selectedItem.slug}` : `/book/${selectedItem.slug}`} onClick={closePreview}
                  className="btn-premium flex-1 text-center py-3 text-xs uppercase tracking-wider font-semibold">Open Full Page</Link>
              )}
              {previewType === 'raga' && (
                <Link to={isHi ? `/hi/raga/${selectedItem.slug}` : `/raga/${selectedItem.slug}`} onClick={closePreview}
                  className="btn-premium flex-1 text-center py-3 text-xs uppercase tracking-wider font-semibold">Open Full Page</Link>
              )}
              {previewType === 'verse' && (
                <Link to={isHi ? `/hi/content/${selectedItem.slug || selectedItem.id}` : `/content/${selectedItem.slug || selectedItem.id}`} onClick={closePreview}
                  className="btn-premium flex-1 text-center py-3 text-xs uppercase tracking-wider font-semibold">Open Full Page</Link>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default HomePage;
