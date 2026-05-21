import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { Compass, Scroll, Music, FileText, ArrowRight, BookOpen, Heart, Star, Globe, Users, MapPin, Book } from 'lucide-react';
import { Helmet } from 'react-helmet-async';
import { useSettings, THEMES } from '../contexts/SettingsContext';
import ThemeIcon from '../components/ThemeIcon';

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

const HomePage = () => {
  const { settings, updateSetting } = useSettings();
  const currentTheme = settings.theme || 'dark';
  const [activeTab, setActiveTab] = useState('core');

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
    </div>
  );
};

export default HomePage;
