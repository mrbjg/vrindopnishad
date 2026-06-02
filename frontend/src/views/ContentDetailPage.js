'use client';

import React, { useState, useEffect, useContext } from 'react';
import { useParams, Link, useLocation } from 'react-router-dom';
import { ApiContext } from '../contexts/ClientProviders';
import {
  ArrowLeft,
  Music,
  Image as ImageIcon,
  Video,
  Bookmark,
  Maximize2,
  Minimize2,
  Sun,
  Moon,
  Share2,
  User,
  BookOpen,
  Sparkles,
  FileText
} from 'lucide-react';
import { useSettings } from '../contexts/SettingsContext';
import { useTheme } from '../contexts/ThemeContext';
import FontWheel from '../components/FontWheel';
import AudioPlayButton from '../components/ui/AudioPlayButton';
import { Helmet } from 'react-helmet-async';
import { transliterate } from '../utils/transliterate';
import { extractRelations, parseAuthorField, getNormalizedSaintSlug, getNormalizedBookSlug, getNormalizedBookName } from '../utils/relations';
import { GLOSSARY_TERMS } from '../utils/glossaryTerms';
import { shareVerseCard } from '../utils/shareCard';
import PageSkeleton from '../components/ui/PageSkeleton';

const ContentDetailPage = ({ initialContent, initialRelatedSaint, initialRelatedBook, initialRelatedRaga, initialRelatedVerses }) => {
  const params = useParams();
  const id = params?.id || params?.slug || '';
  const location = useLocation();
  const isHindiRoute = location.pathname.startsWith('/hi');
  const { apiService } = useContext(ApiContext);
  const { settings, updateSetting } = useSettings();
  const { isDark } = useTheme();
  const sizeLevel = settings.fontSize || 2;

  const [content, setContent] = useState(initialContent || (() => {
    const sessionCached = apiService.getCachedData(`id_${id}`);
    if (sessionCached && !sessionCached.isLightweight) return sessionCached;
    try {
      const memCached = apiService.getMemoryCachedItems();
      if (memCached && memCached.length > 0) {
        const decodedId = decodeURIComponent(id);
        const matched = memCached.find(item => 
          (item.id?.toString() === id.toString() ||
          item.id?.toString() === decodedId.toString() ||
          item.slug === id ||
          item.slug === decodedId) && !item.isLightweight
        );
        if (matched) return matched;
      }
    } catch (e) {}
    return null;
  }));
  
  const [loading, setLoading] = useState(() => {
    if (initialContent) return false;
    const sessionCached = apiService.getCachedData(`id_${id}`);
    if (sessionCached && !sessionCached.isLightweight) return false;
    try {
      const memCached = apiService.getMemoryCachedItems();
      if (memCached && memCached.length > 0) {
        const decodedId = decodeURIComponent(id);
        const matched = memCached.find(item => 
          (item.id?.toString() === id.toString() ||
          item.id?.toString() === decodedId.toString() ||
          item.slug === id ||
          item.slug === decodedId) && !item.isLightweight
        );
        if (matched) return false;
      }
    } catch (e) {}
    return true;
  });
  
  const [relatedSaint, setRelatedSaint] = useState(initialRelatedSaint || null);
  const [relatedBook, setRelatedBook] = useState(initialRelatedBook || null);
  const [relatedRaga, setRelatedRaga] = useState(initialRelatedRaga || null);
  const [relatedVerses, setRelatedVerses] = useState(initialRelatedVerses || []);
  const [detectedConcepts, setDetectedConcepts] = useState([]);

  const [isBookmarked, setIsBookmarked] = useState(false);
  const [isPaathMode, setIsPaathMode] = useState(false);
  const [paathTheme, setPaathTheme] = useState('sepia'); // 'sepia' or 'dark'

  useEffect(() => {
    if (isPaathMode) {
      setPaathTheme(isDark ? 'dark' : 'sepia');
    }
  }, [isPaathMode, isDark]);

  useEffect(() => {
    if (content) {
      try {
        const saved = localStorage.getItem('vrindopnishad_bookmarks');
        const bookmarks = saved ? JSON.parse(saved) : [];
        const found = bookmarks.some(b => b.type === 'verse' && b.id?.toString() === content.id?.toString());
        setIsBookmarked(found);
      } catch (e) {}
    }
  }, [content]);

  const toggleBookmark = () => {
    try {
      const saved = localStorage.getItem('vrindopnishad_bookmarks');
      let bookmarks = saved ? JSON.parse(saved) : [];
      if (isBookmarked) {
        bookmarks = bookmarks.filter(b => !(b.type === 'verse' && b.id?.toString() === content.id?.toString()));
        setIsBookmarked(false);
      } else {
        bookmarks.push({
          type: 'verse',
          id: content.id,
          slug: content.slug,
          title: content.title,
          author: content.author,
          category: content.category,
          addedAt: new Date().toISOString()
        });
        setIsBookmarked(true);
      }
      localStorage.setItem('vrindopnishad_bookmarks', JSON.stringify(bookmarks));
    } catch (e) {
      console.error(e);
    }
  };

  useEffect(() => {
    let active = true;

    const performConceptScan = (itemData) => {
      if (!itemData) return;
      const scannedText = [
        itemData.title,
        itemData.sanskrit_text,
        itemData.hindi_text,
        itemData.english_translation,
        itemData.description
      ].filter(Boolean).join(' ').toLowerCase();

      const matchedConcepts = GLOSSARY_TERMS.filter(term => {
        const engName = (term.term || '').toLowerCase();
        const devName = (term.devanagari || '').toLowerCase();
        const wordRegexEng = new RegExp('\\b' + engName.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&') + '\\b', 'i');
        const hasEngMatch = wordRegexEng.test(scannedText);
        const hasDevMatch = devName && scannedText.includes(devName);
        return hasEngMatch || hasDevMatch;
      });
      setDetectedConcepts(matchedConcepts);
    };

    if (initialContent) {
      setContent(initialContent);
      setRelatedSaint(initialRelatedSaint || null);
      setRelatedBook(initialRelatedBook || null);
      setRelatedRaga(initialRelatedRaga || null);
      setRelatedVerses(initialRelatedVerses || []);
      performConceptScan(initialContent);
      setLoading(false);
      return;
    }

    const getInitialContent = () => {
      const sessionCached = apiService.getCachedData(`id_${id}`);
      if (sessionCached && !sessionCached.isLightweight) return sessionCached;
      try {
        const memCached = apiService.getMemoryCachedItems();
        if (memCached && memCached.length > 0) {
          const decodedId = decodeURIComponent(id);
          return memCached.find(item => 
            (item.id?.toString() === id.toString() ||
            item.id?.toString() === decodedId.toString() ||
            item.slug === id ||
            item.slug === decodedId) && !item.isLightweight
          ) || null;
        }
      } catch (e) {}
      return null;
    };

    const cachedContent = getInitialContent();
    setContent(cachedContent);
    performConceptScan(cachedContent);
    setLoading(cachedContent === null);

    const fetchContentData = async () => {
      try {
        const decodedId = decodeURIComponent(id);
        const data = await apiService.getContentById(decodedId);
        if (active) {
          setContent(data);
          performConceptScan(data);
          
          const allItems = await apiService.getAllContent(null, 10000);
          const relations = extractRelations(allItems);
          
          const authorInfo = parseAuthorField(data.author || "");
          let matchedSaint = null;
          if (authorInfo.saintName) {
            const saintSlug = getNormalizedSaintSlug(authorInfo.saintName);
            matchedSaint = relations.sants.find(s => s.slug === saintSlug);
          }
          
          let matchedBook = null;
          if (authorInfo.bookName) {
            const bookSlug = getNormalizedBookSlug(authorInfo.bookName);
            matchedBook = relations.books.find(b => b.slug === bookSlug);
          }

          const textToScan = [
            data.title,
            data.author,
            data.hindi_text,
            data.sanskrit_text,
            data.english_translation,
            data.description
          ].filter(Boolean).join(' ').toLowerCase();
          
          const isSevaKunj = textToScan.includes('सेवा कुंज') || 
                             textToScan.includes('सेवाकुंज') || 
                             textToScan.includes('seva kunj') || 
                             textToScan.includes('sewakunj') || 
                             textToScan.includes('seva-kunj') || 
                             textToScan.includes('सेवा सुख') ||
                             (data.tags && data.tags.some(t => t.toLowerCase().includes('seva') || t.toLowerCase().includes('kunj')));
          
          if (isSevaKunj) {
            matchedBook = relations.books.find(b => b.slug === 'seva-kunj-texts') || matchedBook;
          }
          
          let ragaName = null;
          const ragaRegex = /(राग\s+[^\s,;()-]+)/;
          const cleanTitle = data.title || "";
          const matchTitle = cleanTitle.match(ragaRegex);
          const matchSanskrit = data.sanskrit_text?.match(ragaRegex);
          const matchHindi = data.hindi_text?.match(ragaRegex);
          if (matchTitle) ragaName = matchTitle[1];
          else if (matchSanskrit) ragaName = matchSanskrit[1];
          else if (matchHindi) ragaName = matchHindi[1];
          if (ragaName) ragaName = ragaName.split(/[,]/)[0].trim();
          
          const matchedRaga = ragaName ? relations.ragas.find(r => r.name === ragaName) : null;
          
          const categoryVerses = allItems.filter(item => 
            item.category === data.category && 
            item.id?.toString() !== data.id?.toString() &&
            item.category?.toLowerCase() !== 'saint'
          ).slice(0, 3);
          
          setRelatedSaint(matchedSaint || null);
          setRelatedBook(matchedBook || null);
          setRelatedRaga(matchedRaga || null);
          setRelatedVerses(categoryVerses);
        }
      } catch (error) {
        console.error('Error fetching content:', error);
      } finally {
        if (active) {
          setLoading(false);
        }
      }
    };
    fetchContentData();

    return () => {
      active = false;
    };
  }, [id, apiService, initialContent, initialRelatedSaint, initialRelatedBook, initialRelatedRaga, initialRelatedVerses]);

  const formatVerseText = (text) => {
    if (!text) return null;

    const rawLines = text.split(/\r?\n/);

    if (!settings.lineByLine) {
      return (
        <div style={{ whiteSpace: 'pre-wrap' }}>
          {text}
        </div>
      );
    }

    const finalLines = [];
    
    for (const rawLine of rawLines) {
      if (!rawLine.trim()) {
        finalLines.push("");
        continue;
      }

      const parts = rawLine.split(/([।॥|]+\s*(?:\[\d+\]|\(?\d+\)?)?|\.{1,2}\s*(?:\[\d+\]|\(?\d+\)?)?)/g);
      
      let currentLine = "";
      for (let i = 0; i < parts.length; i++) {
        if (i % 2 === 0) {
          currentLine = parts[i];
        } else {
          currentLine += parts[i];
          if (currentLine.trim()) {
            finalLines.push(currentLine.trim());
          }
          currentLine = "";
        }
      }
      if (currentLine.trim()) {
        finalLines.push(currentLine.trim());
      }
    }

    if (finalLines.length === 0) return <div style={{ whiteSpace: 'pre-wrap' }}>{text}</div>;

    return finalLines.map((line, idx) => {
      if (line === "") {
        return <div key={idx} className="h-4" />;
      }
      return (
        <div key={idx} className="mb-3 last:mb-0">
          {line}
        </div>
      );
    });
  };

  const getCategoryBadgeClass = (category) => {
    switch (category?.toLowerCase()) {
      case 'shloka': return 'badge-shloka';
      case 'strotra': return 'badge-strotra';
      case 'poem': return 'badge-poem';
      case 'katha': return 'badge-katha';
      case 'sankirtan': return 'badge-sankirtan';
      case 'saint': return 'badge-saint';
      case 'dham': return 'badge-dham';
      case 'literature': return 'badge-literature';
      case 'general': return 'badge-general';
      default: return 'badge-general';
    }
  };

  const showSkeleton = loading && !content;

  if (showSkeleton) {
    return <PageSkeleton variant="detail" />;
  }

  if (!loading && !content) {
    return (
      <div className="animate-fade-in">
        <Link to={isHindiRoute ? "/hi/content" : "/content"} className="inline-flex items-center gap-2 text-white/40 hover:text-white mb-8 transition-colors">
          <ArrowLeft size={18} />
          Back to Collection
        </Link>
        <div className="glass-card text-center py-24">
          <h2 className="text-3xl font-bold mb-6">Content not found</h2>
          <p className="text-white/40 mb-10 text-lg">The verse or poem you are looking for does not exist in our library.</p>
          <Link to={isHindiRoute ? "/hi/content" : "/content"} className="btn-sacred-gold px-10 py-3">
            Explore All Content
          </Link>
        </div>
      </div>
    );
  }

  const titleDeva = content.title || "";
  const titleHing = transliterate(titleDeva);
  const displayTitle = isHindiRoute
    ? (titleHing && titleHing !== titleDeva ? `${titleDeva} (${titleHing})` : titleDeva)
    : (titleHing && titleHing !== titleDeva ? `${titleHing} (${titleDeva})` : titleDeva);

  const authorDeva = content.author || "";
  const authorHing = transliterate(authorDeva);
  const displayAuthor = isHindiRoute
    ? (authorHing && authorHing !== authorDeva ? `${authorDeva} (${authorHing})` : authorDeva)
    : (authorHing && authorHing !== authorDeva ? `${authorHing} (${authorDeva})` : authorDeva);

  const transliteratedSanskrit = content.sanskrit_text ? transliterate(content.sanskrit_text) : "";
  const transliteratedHindi = content.hindi_text ? transliterate(content.hindi_text) : "";

  const fullArticleBody = [
    content.sanskrit_text,
    transliteratedSanskrit,
    content.hindi_text,
    transliteratedHindi,
    content.english_translation
  ].filter(Boolean).join(" \n");

  const canonicalUrl = isHindiRoute
    ? `https://path.vrindopnishad.in/hi/content/${content.slug || id}`
    : `https://path.vrindopnishad.in/content/${content.slug || id}`;

  // Parse Granth, Pad, and Saint for title
  let parsedSaintName = "";
  let parsedGranthName = "";
  let padNumber = "";
  
  const titleVal = content.title || "";
  const tParts = titleVal.split(/\s+-\s+/);
  if (tParts.length >= 2) {
    padNumber = tParts[0].trim();
    const relText = tParts[1].trim();
    const bracketMatch = relText.match(/\(([^)]+)\)$/);
    const bracketContent = bracketMatch ? bracketMatch[1].trim() : "";
    const cleanRelText = bracketMatch ? relText.replace(/\(([^)]+)\)$/, '').trim() : relText;
    const relSplit = cleanRelText.split(/\s*,\s*/);
    
    if (relSplit.length >= 2) {
      parsedSaintName = relSplit[0].trim();
      parsedGranthName = relSplit[1].trim();
    } else if (relSplit.length === 1) {
      const val = relSplit[0].trim();
      if (val.includes('वाणी') || val.includes('सागर') || val.includes('शतक') || val.includes('महिमामृत') || val.includes('दोहे') || val.includes('ग्रंथावली') || val.includes('पदावली') || val.includes('शत') || val.includes('केलिमाल') || val.includes('चौरासी')) {
        parsedGranthName = val;
      } else {
        parsedSaintName = val;
      }
    }
    
    if (!parsedGranthName && bracketContent) {
      parsedGranthName = bracketContent.replace(/\d+/g, '').replace(/[१२३४५६७८९०]+/g, '').trim();
    }
  } else {
    padNumber = titleVal;
  }

  if (!parsedSaintName) {
    parsedSaintName = content.author && content.author !== 'Braj Rasik Heritage' ? content.author : '';
  }

  const cleanSaint = parsedSaintName ? parsedSaintName.replace(/जी की वाणी/g, '').replace(/जी/g, '').replace(/महाप्रभु/g, '').trim() : (isHindiRoute ? 'वैष्णव संत' : 'Vaishnava Saint');
  const cleanGranth = parsedGranthName ? parsedGranthName.trim() : (isHindiRoute ? 'वृंदोपनिषद् ग्रन्थ' : 'Vrindopnishad Granth');
  
  let formattedPad = padNumber;
  if (!isHindiRoute) {
    formattedPad = formattedPad
      .replace(/पद्/g, 'Pad')
      .replace(/पद/g, 'Pad')
      .replace(/श्लोक/g, 'Shloka')
      .replace(/१/g, '1').replace(/२/g, '2').replace(/३/g, '3').replace(/४/g, '4')
      .replace(/५/g, '5').replace(/६/g, '6').replace(/७/g, '7').replace(/८/g, '8')
      .replace(/९/g, '9').replace(/०/g, '0');
  }

  const helmetTitle = `${cleanGranth} — ${formattedPad} | ${cleanSaint} | Vrindopnishad`;
  
  const helmetDescription = isHindiRoute
    ? `${cleanSaint} द्वारा रचित ${content.title} (ग्रन्थ: ${cleanGranth})। हिन्दी, संस्कृत, ब्रजभाषा और अंग्रेजी रोमन अनुवाद (with meaning, commentary) में बिल्कुल निःशुल्क (completely free) पढ़ें।`
    : `Read and explore ${content.title} by ${cleanSaint} from the grantha ${cleanGranth}. Completely free online access with meaning, translation, and commentary. Available in Hindi, Sanskrit, Braj Bhasha, and English transliteration (with meaning, complete collection).`;

  return (
    <>
      <div className="animate-fade-in max-w-4xl mx-auto">
        <Helmet>
        <html lang={isHindiRoute ? "hi" : "en"} />
        <title>{helmetTitle}</title>
        <meta name="description" content={helmetDescription} />
        <meta name="keywords" content={`${content.title}, ${titleHing}, ${content.author || 'Sant Vaani'}, ${authorHing}, ${content.category}, Sanskrit Shloka, Hindi meaning, English translation, Vrindopnishad, Sant Vaani, sacred verse, devotional, spiritual wisdom, Hinglish transliteration, roman hindi lyrics, ${titleHing} bhajan lyrics`} />

        
        <link rel="canonical" href={canonicalUrl} />

        
        <meta property="og:type" content="article" />
        <meta property="og:site_name" content="Sant-Vaani | Sacred Digital Sanctuary" />
        <meta property="og:title" content={helmetTitle} />
        <meta property="og:description" content={helmetDescription} />
        {content.image_url && <meta property="og:image" content={content.image_url} />}
        <meta property="article:section" content={content.category} />
        {content.author && <meta property="article:author" content={content.author} />}

        <meta name="twitter:card" content="summary_large_image" />
        <meta name="twitter:title" content={helmetTitle} />
        <meta name="twitter:description" content={helmetDescription} />

        
        <script type="application/ld+json">
          {JSON.stringify({
            "@context": "https://schema.org",
            "@type": "BreadcrumbList",
            "itemListElement": [
              {
                "@type": "ListItem",
                "position": 1,
                "name": isHindiRoute ? "संग्रह" : "Collection",
                "item": isHindiRoute ? "https://path.vrindopnishad.in/hi/content" : "https://path.vrindopnishad.in/content"
              },
              {
                "@type": "ListItem",
                "position": 2,
                "name": content.category || "Category",
                "item": isHindiRoute 
                  ? `https://path.vrindopnishad.in/hi/category/${(content.category || "").toLowerCase()}`
                  : `https://path.vrindopnishad.in/category/${(content.category || "").toLowerCase()}`
              },
              {
                "@type": "ListItem",
                "position": 3,
                "name": displayTitle,
                "item": canonicalUrl
              }
            ]
          })}
        </script>

        <script type="application/ld+json">
          {JSON.stringify({
            "@context": "https://schema.org",
            "@type": "CreativeWork",
            "name": content.title,
            "headline": content.title,
            "alternativeHeadline": titleHing !== titleDeva ? (isHindiRoute ? titleHing : titleDeva) : undefined,
            "description": helmetDescription,
            "author": {
              "@type": "Person",
              "name": cleanSaint
            },
            "genre": content.category || "Sacred Literature",
            "inLanguage": ["sa", "hi", "braj"],
            "keywords": `${content.title || ''}, ${titleHing}, ${content.category || ''}, ${content.author || ''}, ${authorHing}, Spiritual, Sanskrit, Divine Verses, Vrindopnishad`,
            "articleBody": fullArticleBody,
            "datePublished": content.created_at || new Date().toISOString(),
            "dateModified": content.updated_at || content.created_at || new Date().toISOString(),
            "publisher": {
              "@type": "Organization",
              "name": "Vrindopnishad",
              "logo": {
                "@type": "ImageObject",
                "url": "https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png"
              }
            },
            "mainEntityOfPage": {
              "@type": "WebPage",
              "@id": `https://path.vrindopnishad.in/content/${content.slug || id}`
            },
            ...(content.image_url ? { "image": content.image_url } : {})
          })}
        </script>
      </Helmet>

      <article>
        <Link to={isHindiRoute ? "/hi/content" : "/content"} className="inline-flex items-center gap-2 text-white/40 hover:text-white mb-8 transition-colors">
          <ArrowLeft size={18} />
          Back to Collection
        </Link>

        <div className="w-full px-0 py-4 md:px-14 md:py-14 mb-12 relative overflow-hidden">
          
          <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-10 mb-12 border-b border-white/5 pb-10">
            <div className="flex flex-col gap-6 w-full lg:w-auto">
              <div className="flex flex-col items-center lg:items-start gap-4">
                <span className={`sacred-badge ${getCategoryBadgeClass(content.category)}`}>
                  {content.category}
                </span>
                
                {content.author && (
                  <div className="flex flex-col items-center lg:items-start">
                    <span className="content-section-label text-[10px] uppercase tracking-[0.3em] mb-1 font-bold">Written By</span>
                    <span className={`text-sacred-gradient font-headings font-bold tracking-wide text-center lg:text-left ${
                      content.author.length > 25 ? 'text-lg' : 'text-xl sm:text-2xl'
                    }`}>
                      {content.author}
                    </span>
                  </div>
                )}
              </div>
            </div>

            
            <div className="hidden lg:flex items-center gap-4">
              <button
                onClick={toggleBookmark}
                className={`flex items-center justify-center w-10 h-10 shrink-0 aspect-square rounded-full border transition-all ${
                  isBookmarked 
                    ? 'bg-primary/20 border-primary text-primary' 
                    : 'bg-white/5 border-white/10 hover:border-white/20 text-white/60 hover:text-white'
                }`}
                title={isBookmarked ? (isHindiRoute ? "सहेजा गया" : "Saved Bookmark") : (isHindiRoute ? "बुकमार्क करें" : "Add Bookmark")}
              >
                <Bookmark size={16} className={isBookmarked ? "fill-current" : ""} />
              </button>
              <button
                onClick={() => shareVerseCard(content, isHindiRoute)}
                className="flex items-center justify-center w-10 h-10 shrink-0 aspect-square rounded-full border bg-white/5 border-white/10 hover:border-white/20 text-white/60 hover:text-white transition-all"
                title={isHindiRoute ? "सुंदर छवि साझा करें" : "Share Image Card"}
              >
                <Share2 size={16} />
              </button>
              <button
                onClick={() => {
                  setIsPaathMode(true);
                  try {
                    if (!document.fullscreenElement) {
                      document.documentElement.requestFullscreen().catch(() => {});
                    }
                  } catch (e) {}
                }}
                className="flex items-center justify-center w-10 h-10 shrink-0 aspect-square rounded-full border bg-white/5 border-white/10 hover:border-white/20 text-white/60 hover:text-white transition-all"
                title={isHindiRoute ? "पाठ मोड (एकाग्रता)" : "Paath Mode (Distraction-Free)"}
              >
                <Maximize2 size={16} />
              </button>
              <FontWheel 
                value={settings.fontSize} 
                onChange={(size) => updateSetting('fontSize', size)} 
              />
            </div>
          </div>

          <h1 
            className="text-4xl md:text-6xl font-bold mb-6 leading-[1.2] lg:leading-[1.3] pt-8 pb-4 text-sacred-gradient"
          >
            {content.title}
          </h1>

          {content.description && (
            <p 
              className="content-body-text font-light leading-relaxed mb-8 italic pl-6 break-words"
              style={{ 
                fontSize: `${14 + (sizeLevel - 1) * 2}px`,
                wordBreak: 'break-word',
                paddingBottom: '0.1em',
                borderLeft: '4px solid hsl(var(--foreground) / 0.1)'
              }}
            >
              {content.description}
            </p>
          )}

          <div className="space-y-16">
            {content.sanskrit_text && (
              <div className="relative group py-8 sm:py-12 border-b border-white/5">
                <div className="absolute top-0 right-0 p-8 opacity-5 text-9xl font-serif pointer-events-none">ॐ</div>
                <h3 className="content-section-heading text-[10px] sm:text-xs uppercase tracking-[0.4em] mb-6 sm:mb-8 flex items-center justify-center sm:justify-start gap-4 py-2">
                  <span className="content-section-line h-[1px] w-12 hidden sm:block"></span>
                  Sanskrit Text
                  <span className="content-section-line h-[1px] w-12 hidden sm:block"></span>
                </h3>
                <div className={`text-center font-medium content-verse-text hindi-text ${
                  settings.fontStyle === 'Sans' ? 'font-sans' :
                  settings.fontStyle === 'Inter' ? 'font-inter' :
                  'font-headings'
                }`} style={{
                  fontSize: sizeLevel === 1 ? '1.25rem' :
                            sizeLevel === 2 ? '1.6rem' :
                            sizeLevel === 3 ? '2.0rem' :
                            sizeLevel === 4 ? '2.5rem' : '3.0rem'
                }}>
                  {formatVerseText(content.sanskrit_text)}
                </div>
              </div>
            )}

            {content.hindi_text && (
              <div className="py-8 sm:py-12 border-b border-white/5">
                <h3 className="content-section-heading content-section-heading--hindi text-[10px] sm:text-xs uppercase tracking-[0.4em] mb-6 sm:mb-8 flex items-center justify-center sm:justify-start gap-4 py-2">
                  <span className="content-section-line content-section-line--hindi h-[1px] w-12 hidden sm:block"></span>
                  Hindi Meaning
                  <span className="content-section-line content-section-line--hindi h-[1px] w-12 hidden sm:block"></span>
                </h3>
                <div className={`content-verse-text hindi-text ${
                  settings.fontStyle === 'Sans' ? 'font-sans' :
                  settings.fontStyle === 'Inter' ? 'font-inter' :
                  'font-headings'
                }`} style={{
                  fontSize: sizeLevel === 1 ? '1.1rem' :
                            sizeLevel === 2 ? '1.4rem' :
                            sizeLevel === 3 ? '1.8rem' :
                            sizeLevel === 4 ? '2.2rem' : '2.5rem'
                }}>
                  {formatVerseText(content.hindi_text)}
                </div>
              </div>
            )}

            {(transliteratedSanskrit || transliteratedHindi) && (
              <div className="py-8 sm:py-12 border-b border-white/5">
                <h3 className="content-section-heading content-section-heading--hinglish text-[10px] sm:text-xs uppercase tracking-[0.4em] mb-6 sm:mb-8 flex items-center justify-center sm:justify-start gap-4 py-2">
                  <span className="content-section-line content-section-line--hinglish h-[1px] w-12 hidden sm:block"></span>
                  Hinglish Transliteration (रोमन पाठ)
                  <span className="content-section-line content-section-line--hinglish h-[1px] w-12 hidden sm:block"></span>
                </h3>
                <div className={`content-verse-text font-inter tracking-wide leading-relaxed text-white/80 ${
                  settings.fontStyle === 'Sans' ? 'font-sans' :
                  settings.fontStyle === 'Inter' ? 'font-inter' :
                  'font-headings'
                }`} style={{
                  fontSize: sizeLevel === 1 ? '1.0rem' :
                            sizeLevel === 2 ? '1.3rem' :
                            sizeLevel === 3 ? '1.6rem' :
                            sizeLevel === 4 ? '2.0rem' : '2.4rem'
                }}>
                  {transliteratedSanskrit ? formatVerseText(transliteratedSanskrit) : formatVerseText(transliteratedHindi)}
                </div>
              </div>
            )}

            {content.english_text && (
              <div>
                <h3 className="content-section-heading text-xs uppercase tracking-[0.3em] mb-6 font-semibold">Transliteration</h3>
                <div className="content-body-text leading-relaxed font-inter" style={{
                  fontSize: sizeLevel === 1 ? '0.9rem' :
                            sizeLevel === 2 ? '1.1rem' :
                            sizeLevel === 3 ? '1.3rem' :
                            sizeLevel === 4 ? '1.5rem' : '1.8rem'
                }}>
                  {content.english_text}
                </div>
              </div>
            )}

            {content.english_translation && (
              <div className="py-12">
                <h3 className="content-section-heading content-section-heading--english text-xs uppercase tracking-[0.3em] mb-10 flex items-center gap-3">
                  <span className="content-section-line content-section-line--english h-[1px] w-8"></span>
                  English Translation
                </h3>
                <div className="content-body-text leading-relaxed font-light" style={{
                  fontSize: sizeLevel === 1 ? '1.1rem' :
                            sizeLevel === 2 ? '1.4rem' :
                            sizeLevel === 3 ? '1.8rem' :
                            sizeLevel === 4 ? '2.2rem' : '2.5rem'
                }}>
                  {content.english_translation}
                </div>
              </div>
            )}

            
            {content.audio_url && (
              <div className="pt-8 border-t border-white/5">
                <h3 className="text-xl font-bold mb-6 flex items-center gap-3">
                  <Music size={24} className="text-amber-400" />
                  Listen to Audio
                </h3>
                <div className="bg-white/5 rounded-2xl p-6 flex items-center gap-6 group hover:bg-white/10 transition-all border border-white/5 hover:border-amber-500/20">
                  <AudioPlayButton 
                    track={content} 
                    size={32} 
                    className="w-16 h-16 bg-amber-500 text-white shadow-lg shadow-amber-500/20" 
                  />
                  <div>
                    <h4 className="font-bold text-lg mb-1">Divine Rendition</h4>
                    <p className="text-white/40 text-sm">Experience the sacred vibrations of this {content.category}</p>
                  </div>
                </div>
              </div>
            )}

            {(content.image_url || (content.image_urls && content.image_urls.length > 0)) && (
              <div className="pt-8 border-t border-white/5">
                <h3 className="text-xl font-bold mb-8 flex items-center gap-3">
                  <ImageIcon size={24} className="text-amber-400" />
                  Gallery
                </h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {content.image_url && (
                    <img src={content.image_url} alt="Verse" loading="lazy" className="rounded-2xl w-full h-auto border border-white/10 hover:border-amber-400/30 transition-all shadow-2xl" />
                  )}
                  {content.image_urls?.map((url, idx) => (
                    <img key={idx} src={url} alt={`Verse ${idx + 1}`} loading="lazy" className="rounded-2xl w-full h-auto border border-white/10 hover:border-amber-400/30 transition-all shadow-2xl" />
                  ))}
                </div>
              </div>
            )}

            {content.video_urls && content.video_urls.length > 0 && (
              <div className="pt-8 border-t border-white/5">
                <h3 className="text-xl font-bold mb-8 flex items-center gap-3">
                  <Video size={24} className="text-primary" />
                  Videos
                </h3>
                <div className="space-y-6">
                  {content.video_urls.map((url, idx) => (
                    <div key={idx} className="aspect-video rounded-3xl overflow-hidden border border-white/10 shadow-2xl">
                      <video controls className="w-full h-full object-cover">
                        <source src={url} type="video/mp4" />
                      </video>
                    </div>
                  ))}
                </div>
              </div>
            )}
            
            <div className="lg:hidden mt-20 pt-10 border-t border-white/5 flex flex-col items-center gap-6">
              <span className="content-section-label text-[10px] uppercase tracking-[0.3em] font-bold">Reading Settings</span>
              <div className="flex items-center gap-4">
                <button
                  onClick={toggleBookmark}
                  className={`flex items-center justify-center w-11 h-11 shrink-0 aspect-square rounded-full border transition-all ${
                    isBookmarked 
                      ? 'bg-primary/20 border-primary text-primary' 
                      : 'bg-white/5 border-white/10 text-white/60'
                  }`}
                >
                  <Bookmark size={18} className={isBookmarked ? "fill-current" : ""} />
                </button>
                <button
                  onClick={() => shareVerseCard(content, isHindiRoute)}
                  className="flex items-center justify-center w-11 h-11 shrink-0 aspect-square rounded-full border bg-white/5 border-white/10 text-white/60"
                >
                  <Share2 size={18} />
                </button>
                <button
                  onClick={() => {
                    setIsPaathMode(true);
                    try {
                      if (!document.fullscreenElement) {
                        document.documentElement.requestFullscreen().catch(() => {});
                      }
                    } catch (e) {}
                  }}
                  className="flex items-center justify-center w-11 h-11 shrink-0 aspect-square rounded-full border bg-white/5 border-white/10 text-white/60"
                >
                  <Maximize2 size={18} />
                </button>
              </div>
              <div className="w-full max-w-[320px]">
                <FontWheel 
                  value={settings.fontSize} 
                  onChange={(size) => updateSetting('fontSize', size)} 
                />
              </div>
            </div>
          </div>
        </div>
      </article>

      
      {/* Knowledge Graph Connections */}
      {(() => {
        const hasConnections = !!(
          relatedSaint ||
          relatedBook ||
          (detectedConcepts && detectedConcepts.length > 0) ||
          (relatedVerses && relatedVerses.length > 0)
        );

        if (!hasConnections) return null;

        let colsCount = 0;
        if (relatedSaint) colsCount++;
        if (relatedBook) colsCount++;
        if (detectedConcepts && detectedConcepts.length > 0) colsCount++;
        if (relatedVerses && relatedVerses.length > 0) colsCount++;

        const gridColsClass = 
          colsCount === 1 ? 'grid-cols-1 max-w-md mx-auto' :
          colsCount === 2 ? 'grid-cols-1 md:grid-cols-2 max-w-3xl mx-auto' :
          colsCount === 3 ? 'grid-cols-1 md:grid-cols-3 max-w-5xl mx-auto' :
          'grid-cols-1 md:grid-cols-2 lg:grid-cols-4';

        return (
          <section className="mt-24 mb-12 animate-fade-in text-left">
            <div className="flex items-center gap-4 mb-10">
              <div className="h-px flex-1 bg-gradient-to-r from-transparent to-white/10"></div>
              <h2 className="text-xl font-bold text-sacred-gradient px-4 font-headings">
                {isHindiRoute ? "ज्ञान सम्बन्ध चित्र" : "Knowledge Graph Connections"}
              </h2>
              <div className="h-px flex-1 bg-gradient-to-l from-transparent to-white/10"></div>
            </div>

            <div className={`grid ${gridColsClass} gap-6`}>
              {/* Related Saint */}
              {relatedSaint && (
                <div className="glass-card p-5 rounded-2xl border border-white/5 flex flex-col justify-between hover:border-amber-500/20 hover:shadow-lg hover:shadow-amber-500/[0.02] transition-all duration-300">
                  <div className="space-y-4">
                    <div className="flex items-center justify-between border-b border-white/5 pb-3">
                      <span className="text-[10px] uppercase tracking-widest text-amber-500/90 font-bold flex items-center gap-1.5">
                        <User size={13} className="text-amber-500" />
                        {isHindiRoute ? "सम्बन्धित सन्त" : "Related Saint"}
                      </span>
                    </div>
                    
                    <div className="flex items-center gap-3">
                      {relatedSaint.imageUrl ? (
                        <img 
                          src={relatedSaint.imageUrl} 
                          alt={relatedSaint.name} 
                          className="w-10 h-10 rounded-full object-cover border border-amber-500/10"
                        />
                      ) : (
                        <div className="w-10 h-10 rounded-full bg-amber-500/10 border border-amber-500/20 flex items-center justify-center text-amber-500 font-bold text-xs uppercase">
                          {(isHindiRoute ? relatedSaint.name : relatedSaint.hinglishName)[0]}
                        </div>
                      )}
                      <div>
                        <h3 className="font-bold text-sm text-white/95 leading-tight">
                          {isHindiRoute ? relatedSaint.name : relatedSaint.hinglishName}
                        </h3>
                        <span className="text-[9px] text-white/35 font-light uppercase tracking-wider block mt-0.5">
                          {isHindiRoute ? "रसिक सन्त" : "Braj Rasik"}
                        </span>
                      </div>
                    </div>

                    <p className="text-[11px] text-white/45 leading-relaxed line-clamp-3">
                      {relatedSaint.biography 
                        ? relatedSaint.biography.substring(0, 120).trim() + '...' 
                        : (isHindiRoute ? 'संत का जीवन चरित्र और विवरण।' : 'Explore the saint\'s legacy.')}
                    </p>
                  </div>

                  <Link
                    to={isHindiRoute ? `/hi/saints/${relatedSaint.slug}` : `/saints/${relatedSaint.slug}`}
                    className="w-full text-center text-[10px] uppercase tracking-wider text-amber-500 bg-amber-500/5 hover:bg-amber-500/10 border border-amber-500/10 hover:border-amber-500/30 rounded-xl py-2 font-bold transition-all mt-4 block"
                  >
                    {isHindiRoute ? "जीवनी पढ़ें →" : "Read Biography →"}
                  </Link>
                </div>
              )}

              {/* Related Grantha */}
              {relatedBook && (
                <div className="glass-card p-5 rounded-2xl border border-white/5 flex flex-col justify-between hover:border-sky-500/20 hover:shadow-lg hover:shadow-sky-500/[0.02] transition-all duration-300">
                  <div className="space-y-4">
                    <div className="flex items-center justify-between border-b border-white/5 pb-3">
                      <span className="text-[10px] uppercase tracking-widest text-sky-400 font-bold flex items-center gap-1.5">
                        <BookOpen size={13} className="text-sky-400" />
                        {isHindiRoute ? "सम्बन्धित ग्रन्थ" : "Related Scripture"}
                      </span>
                    </div>

                    <div className="flex items-center gap-3">
                      {relatedBook.imageUrl ? (
                        <img 
                          src={relatedBook.imageUrl} 
                          alt={relatedBook.name} 
                          className="w-10 h-10 rounded-lg object-cover border border-sky-500/10"
                        />
                      ) : (
                        <div className="w-10 h-10 rounded-lg bg-sky-500/10 border border-sky-500/20 flex items-center justify-center text-sky-400 font-bold text-xs uppercase">
                          <BookOpen size={14} />
                        </div>
                      )}
                      <div>
                        <h3 className="font-bold text-sm text-white/95 leading-tight line-clamp-1">
                          {relatedBook.name}
                        </h3>
                        <span className="text-[9px] text-white/35 font-light uppercase tracking-wider block mt-0.5">
                          {isHindiRoute ? "पवित्र ग्रन्थ" : "Sacred Text"}
                        </span>
                      </div>
                    </div>

                    <p className="text-[11px] text-white/45 leading-relaxed line-clamp-3">
                      {isHindiRoute 
                        ? `${relatedBook.name} के संकलित पद और पद्यावली।` 
                        : `Collected verses and spiritual commentary from the scripture ${relatedBook.name}.`}
                    </p>
                  </div>

                  <Link
                    to={isHindiRoute ? `/hi/granthas/${relatedBook.slug}` : `/granthas/${relatedBook.slug}`}
                    className="w-full text-center text-[10px] uppercase tracking-wider text-sky-400 bg-sky-400/5 hover:bg-sky-400/10 border border-sky-400/10 hover:border-sky-400/30 rounded-xl py-2 font-bold transition-all mt-4 block"
                  >
                    {isHindiRoute ? "ग्रन्थ पाठ →" : "Read Scripture →"}
                  </Link>
                </div>
              )}

              {/* Related Concepts */}
              {detectedConcepts && detectedConcepts.length > 0 && (
                <div className="glass-card p-5 rounded-2xl border border-white/5 flex flex-col justify-start hover:border-indigo-500/20 hover:shadow-lg hover:shadow-indigo-500/[0.02] transition-all duration-300">
                  <div className="space-y-4 w-full">
                    <div className="flex items-center justify-between border-b border-white/5 pb-3">
                      <span className="text-[10px] uppercase tracking-widest text-indigo-400 font-bold flex items-center gap-1.5">
                        <Sparkles size={13} className="text-indigo-400" />
                        {isHindiRoute ? "प्रमुख अवधारणाएँ" : "Core Concepts"}
                      </span>
                    </div>

                    <div className="flex flex-wrap gap-2 pt-1">
                      {detectedConcepts.map(c => (
                        <Link
                          key={c.slug}
                          to={isHindiRoute ? `/hi/glossary/${c.slug}` : `/glossary/${c.slug}`}
                          className="px-2.5 py-1 rounded-xl bg-indigo-500/5 hover:bg-indigo-500/10 border border-indigo-500/10 hover:border-indigo-500/30 text-[10px] font-medium text-indigo-300 hover:text-indigo-200 transition-all select-none"
                        >
                          {isHindiRoute ? c.devanagari || c.term : c.term}
                        </Link>
                      ))}
                    </div>
                  </div>
                </div>
              )}

              {/* Related Verses */}
              {relatedVerses && relatedVerses.length > 0 && (
                <div className="glass-card p-5 rounded-2xl border border-white/5 flex flex-col justify-start hover:border-emerald-500/20 hover:shadow-lg hover:shadow-emerald-500/[0.02] transition-all duration-300">
                  <div className="space-y-4 w-full">
                    <div className="flex items-center justify-between border-b border-white/5 pb-3">
                      <span className="text-[10px] uppercase tracking-widest text-emerald-400 font-bold flex items-center gap-1.5">
                        <FileText size={13} className="text-emerald-400" />
                        {isHindiRoute ? "सम्बन्धित पद" : "Related Verses"}
                      </span>
                    </div>

                    <div className="space-y-2">
                      {relatedVerses.map(v => (
                        <Link
                          key={v.id}
                          to={isHindiRoute ? `/hi/content/${v.slug || v.id}` : `/content/${v.slug || v.id}`}
                          className="flex items-center gap-2 text-[11px] text-white/70 hover:text-emerald-400 transition-colors py-1 group border-b border-white/[0.02] last:border-0 text-left"
                        >
                          <span className="w-1.5 h-1.5 rounded-full bg-emerald-500/40 group-hover:bg-emerald-400 shrink-0"></span>
                          <span className="truncate">{v.cleanTitle || v.title}</span>
                        </Link>
                      ))}
                    </div>
                  </div>
                </div>
              )}
            </div>
          </section>
        );
      })()}

      </div>

      {isPaathMode && (
        <div 
          className={`fixed inset-0 z-[9999] overflow-y-auto transition-all duration-300 ${
            paathTheme === 'sepia' 
              ? 'bg-[#f5ebd6] text-[#2c2212]' 
              : 'bg-[#09090b] text-[#e3ded0]'
          }`}
          style={{ fontFamily: "'Noto Serif Devanagari', 'Tiro Devanagari Sanskrit', serif" }}
        >
          {/* Controls Header */}
          <div className={`sticky top-0 z-[10000] w-full px-6 py-4 flex items-center justify-between backdrop-blur-md border-b ${
            paathTheme === 'sepia' 
              ? 'bg-[#f5ebd6]/90 border-[#2c2212]/10' 
              : 'bg-[#09090b]/90 border-[#e3ded0]/10'
          }`}>
            <div className="flex items-center gap-3">
              <button
                onClick={() => {
                  setIsPaathMode(false);
                  try {
                    if (document.fullscreenElement) {
                      document.exitFullscreen().catch(() => {});
                    }
                  } catch (e) {}
                }}
                className={`flex items-center gap-2 px-4 py-2 rounded-full border text-xs font-semibold ${
                  paathTheme === 'sepia'
                    ? 'border-[#2c2212]/20 hover:bg-[#2c2212]/5 text-[#2c2212]'
                    : 'border-[#e3ded0]/20 hover:bg-[#e3ded0]/5 text-[#e3ded0]'
                }`}
              >
                <Minimize2 size={14} />
                <span>{isHindiRoute ? 'सामान्य मोड' : 'Exit Paath Mode'}</span>
              </button>
            </div>

            <div className="flex items-center gap-6">
              {/* Theme Switcher */}
              <div className="flex items-center gap-1 rounded-full border p-0.5 border-current/10">
                <button
                  onClick={() => setPaathTheme('sepia')}
                  className={`px-3 py-1 rounded-full text-xs font-semibold flex items-center gap-1 transition-all ${
                    paathTheme === 'sepia'
                      ? 'bg-[#2c2212] text-[#f5ebd6]'
                      : 'opacity-50'
                  }`}
                >
                  <Sun size={12} />
                  <span>{isHindiRoute ? 'पीताम्बर' : 'Sepia'}</span>
                </button>
                <button
                  onClick={() => setPaathTheme('dark')}
                  className={`px-3 py-1 rounded-full text-xs font-semibold flex items-center gap-1 transition-all ${
                    paathTheme === 'dark'
                      ? 'bg-[#e3ded0] text-[#09090b]'
                      : 'opacity-50'
                  }`}
                >
                  <Moon size={12} />
                  <span>{isHindiRoute ? 'श्यामल' : 'Dark'}</span>
                </button>
              </div>

              {/* Font Size controls */}
              <div className="hidden sm:block">
                <FontWheel 
                  value={settings.fontSize} 
                  onChange={(size) => updateSetting('fontSize', size)} 
                />
              </div>
            </div>
          </div>

          {/* Reading Area */}
          <div className="max-w-3xl mx-auto px-6 py-12 md:py-24 flex flex-col items-center text-center">
            {/* Header metadata */}
            <div className="mb-12 flex flex-col items-center gap-3">
              <span className={`text-[11px] uppercase tracking-[0.2em] font-semibold border px-3 py-1 rounded-full ${
                paathTheme === 'sepia' ? 'border-[#2c2212]/20' : 'border-[#e3ded0]/20'
              }`}>
                {content.category}
              </span>
              {content.author && (
                <div className="text-center mt-2">
                  <span className="text-[10px] uppercase tracking-[0.25em] font-bold block opacity-40 mb-1">रचयिता / Author</span>
                  <span className="text-xl md:text-2xl font-bold tracking-wide">
                    {content.author}
                  </span>
                </div>
              )}
            </div>

            {/* Title */}
            <h1 className="text-3xl md:text-5xl font-bold mb-16 leading-[1.3]">
              {content.title}
            </h1>

            {/* Verse Texts */}
            <div className="w-full space-y-20">
              {content.sanskrit_text && (
                <div className="space-y-6">
                  <div className="text-[10px] uppercase tracking-[0.3em] font-bold opacity-30">मूल पाठ (Sanskrit)</div>
                  <div 
                    className="leading-[1.8] font-medium"
                    style={{
                      fontSize: sizeLevel === 1 ? '1.5rem' :
                                sizeLevel === 2 ? '1.9rem' :
                                sizeLevel === 3 ? '2.4rem' :
                                sizeLevel === 4 ? '3.0rem' : '3.6rem'
                    }}
                  >
                    {formatVerseText(content.sanskrit_text)}
                  </div>
                </div>
              )}

              {content.hindi_text && (
                <div className="space-y-6 pt-10 border-t border-current/5">
                  <div className="text-[10px] uppercase tracking-[0.3em] font-bold opacity-30">भावार्थ (Hindi)</div>
                  <div 
                    className="leading-[1.8] font-medium"
                    style={{
                      fontSize: sizeLevel === 1 ? '1.3rem' :
                                sizeLevel === 2 ? '1.7rem' :
                                sizeLevel === 3 ? '2.1rem' :
                                sizeLevel === 4 ? '2.6rem' : '3.1rem'
                    }}
                  >
                    {formatVerseText(content.hindi_text)}
                  </div>
                </div>
              )}

              {(transliteratedSanskrit || transliteratedHindi) && (
                <div className="space-y-6 pt-10 border-t border-current/5">
                  <div className="text-[10px] uppercase tracking-[0.3em] font-bold opacity-30">रोमन पाठ (Romanized)</div>
                  <div 
                    className="leading-[1.8] font-sans opacity-95 tracking-wide"
                    style={{
                      fontSize: sizeLevel === 1 ? '1.2rem' :
                                sizeLevel === 2 ? '1.5rem' :
                                sizeLevel === 3 ? '1.9rem' :
                                sizeLevel === 4 ? '2.3rem' : '2.8rem'
                    }}
                  >
                    {transliteratedSanskrit ? formatVerseText(transliteratedSanskrit) : formatVerseText(transliteratedHindi)}
                  </div>
                </div>
              )}

              {content.english_translation && (
                <div className="space-y-6 pt-10 border-t border-current/5">
                  <div className="text-[10px] uppercase tracking-[0.3em] font-bold opacity-30">Translation (English)</div>
                  <div 
                    className="leading-[1.8] font-light opacity-95"
                    style={{
                      fontSize: sizeLevel === 1 ? '1.25rem' :
                                sizeLevel === 2 ? '1.6rem' :
                                sizeLevel === 3 ? '2.0rem' :
                                sizeLevel === 4 ? '2.4rem' : '2.8rem'
                    }}
                  >
                    {content.english_translation}
                  </div>
                </div>
              )}
            </div>

            <div className="sm:hidden mt-20 pt-8 border-t border-current/5 w-full flex flex-col items-center gap-4">
              <span className="text-[10px] uppercase tracking-[0.3em] font-bold opacity-40">अक्षर आकार / Text Size</span>
              <FontWheel 
                value={settings.fontSize} 
                onChange={(size) => updateSetting('fontSize', size)} 
              />
            </div>
            <div className="mt-24 mb-12 flex items-center gap-2 opacity-20 justify-center">
              <span className="text-xl">ॐ</span>
              <span className="text-xs tracking-[0.4em] uppercase">वृंदोपनिषद्</span>
              <span className="text-xl">ॐ</span>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default ContentDetailPage;
