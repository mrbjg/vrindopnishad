'use client';

import React, { useState, useEffect, useContext } from 'react';
import { useParams, Link, useLocation } from 'react-router-dom';
import { ApiContext } from '../contexts/ClientProviders';
import {
  ArrowLeft,
  ArrowRight,
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
  FileText,
  Copy,
  Check,
  AlignLeft,
  RotateCcw,
  Loader2
} from 'lucide-react';
import { useSettings } from '../contexts/SettingsContext';
import { useTheme } from '../contexts/ThemeContext';
import FontWheel from '../components/FontWheel';
import AudioPlayButton from '../components/ui/AudioPlayButton';
import { Helmet } from 'react-helmet-async';
import StotraDetailPage from './StotraDetailPage';
import { transliterate } from '../utils/transliterate';
import { extractRelations, parseAuthorField, getNormalizedSaintSlug, getNormalizedBookSlug, getNormalizedBookName, slugify } from '../utils/relations';

const getInitials = (name) => {
  if (!name) return 'VV';
  const words = name.trim().split(/\s+/);
  if (words.length >= 2) {
    return (words[0][0] + words[1][0]).toUpperCase();
  }
  return name.slice(0, 2).toUpperCase();
};

const VALID_RAGAS = new Set([
  'कल्याण', 'कल्यान', 'केदार', 'केदारो', 'केदारौ', 'नट', 'सारंग', 'बिलावल', 'विलावल', 'काफी', 'काफ़ी', 'काफ़ी',
  'ललित', 'भैरव', 'भैरवी', 'भैरो', 'भैरों', 'भैरौं', 'भैंरु', 'सोरठ', 'सोरठा', 'सोरठि', 'मल्हार', 'मलार', 'मलहार',
  'आसावरी', 'असावरी', 'आसावारी', 'हिंडोल', 'हिंडोरा', 'विभास', 'बिभास', 'परज', 'खमाच', 'खमाज', 'खमांच', 'खम्माच', 'खम्माज',
  'बिहाग', 'विहाग', 'बिहागरो', 'बिहागरौ', 'विहागरो', 'विहागरौ', 'विहगरौ', 'यमन', 'ईमन', 'टोड़ी', 'तोड़ी', 'टोडी',
  'धनाश्री', 'कान्हरा', 'कान्हरो', 'कान्हरौ', 'कान्हरौं', 'कानरा', 'कानरौ', 'कानहरौ', 'कानहारौं', 'कन्हारो', 'जयजयवन्ती',
  'जयजयवंती', 'जैजैवंती', 'जैजैवन्ती', 'बागेश्री', 'देश', 'देस', 'पीलू', 'वृंदावनी', 'रामकली', 'रामग्री', 'देवगंधार',
  'देवगन्धार', 'सुहा', 'सुहाई', 'जैतश्री', 'जयतिश्री', 'मांड', 'माँड़', 'मारू', 'मालकौंस', 'मालकोंस', 'मालकोश', 'मालकोस',
  'मालकौस', 'श्री', 'अड़ाना', 'अड़ानो', 'अडानो', 'सिंधुरा', 'जौनपुरी', 'गूजरी', 'गोंड', 'गोड', 'गौड', 'गौड़', 'गौरी',
  'गोरी', 'गौर', 'कामोद', 'जंगला', 'झंझोटी', 'झँझोटी', 'झंझौटी', 'झिंझोटी', 'दरबारी', 'तिलककामोद', 'बहार', 'भीमपलासी',
  'भूपाल', 'भूपली', 'भुपाली', 'मेघ', 'हमीर', 'प्रभाती', 'अलहिया', 'अहीर', 'कलावती', 'कलिंगडा', 'कलिंगड़ा', 'कालंगड़ा',
  'कालिंगड़ा', 'कालिंगडा', 'खंजनाक्षी', 'खट', 'खाट', 'खिमटासिंधुका', 'गंधार', 'गन्धार', 'चर्चरी', 'चैती', 'ज़िला',
  'जिला', 'जै', 'तेतालौ', 'टेटलौ', 'धमाल', 'ध्रुपद', 'नाइकी', 'नायकी', 'नारायणी', 'पंचम', 'पटदीप', 'पूरबी', 'पूरवी',
  'पूरिया', 'पूर्वी', 'बरवा', 'बसंत', 'बसन्त', 'वसंत', 'वसन्त', 'भाल', 'मरवा', 'मालव', 'मुलतानी', 'मुल्तानी', 'योगिया',
  'ललित', 'लावनी', 'शहानौ', 'श्यामकल्याण', 'हमीर', 'हल्हैया'
]);

function extractCleanRaga(textSanskrit, textHindi, title) {
  const testExtract = (text) => {
    if (!text) return null;
    const lines = text.split('\n').map(l => l.trim()).filter(Boolean).slice(0, 3);
    for (const line of lines) {
      const lineRegex = /^[([]?\s*(राग\s+[^\s,;()\]\-]+)/;
      const match = line.match(lineRegex);
      if (match) return match[1];
    }
    return null;
  };

  const titleRegex = /(?:-\s*|,\s*|\s+)(राग\s+[^\s,;()\-]+)/;
  const cleanTitle = title || '';
  const titleMatch = cleanTitle.match(titleRegex);
  let candidate = null;
  if (titleMatch) {
    candidate = titleMatch[1];
  } else {
    candidate = testExtract(textSanskrit) || testExtract(textHindi);
  }

  if (candidate) {
    const rawRaga = candidate.split(/[,]/)[0].trim();
    const nameWithoutPrefix = rawRaga.replace(/^राग\s+/, '').trim();
    if (VALID_RAGAS.has(nameWithoutPrefix)) {
      return rawRaga;
    }
  }
  return null;
}

function extractFirstLine(title) {
  if (!title) return '';
  const parts = title.split(/\s+-\s+/);
  if (parts.length > 0) {
    return parts[0].trim().replace(/[()[\]{}]+$/, '').trim();
  }
  return title;
}
import { GLOSSARY_TERMS } from '../utils/glossaryTerms';
import { shareVerseCard } from '../utils/shareCard';
import PageSkeleton from '../components/ui/PageSkeleton';
import { splitVerseAndTranslation, cleanVerseOnly } from '../utils/textSplitter';
import { useSWR } from '../hooks/useSWR';

// Professional typographic scaling component for Sanskrit/Hindi & Hinglish verses.
// Provides elegant, consistent sizing based on viewport width and user preferences (sizeLevel).
// Uses micro-tuning for line length to prevent awkward clipping while maintaining stable sizes.
const AutoFitVerse = ({ text, sizeLevel = 2, fontStyle, isHindiRoute, centered = true, className = "", isRoman = false }) => {
  const cleanLines = React.useMemo(() => {
    if (!text) return [];
    let processed = text;

    // 1. Protect section headers enclosed in dandas, like "॥ दोहा ॥", "॥ चौपाई ॥", "॥ सोरठा ॥"
    const protectedBlocks = [];
    processed = processed.replace(/(?:॥|\|\||।|\|)\s*([^॥।\d\s\(\)\[\]]{2,12})\s*(?:॥|\|\||।|\|)/g, (match) => {
      protectedBlocks.push(match.trim());
      return ` __PB${protectedBlocks.length - 1}__`;
    });

    // 2. Protect verse numbers like "॥ १ ॥", "॥ १२ ॥", "। ३ ।", "(४)", "[५]", "१ ॥"
    processed = processed.replace(/(?:॥|\|\||।|\|)?\s*(?:\[\s*[०-९\d]+\s*\]|\(\s*[०-९\d]+\s*\)|[०-९\d]+)\s*(?:॥|\|\||।|\|)?/g, (match) => {
      const trimmed = match.trim();
      if (!trimmed || /^[०-९\d]+$/.test(trimmed)) return match;
      protectedBlocks.push(trimmed);
      return ` __PB${protectedBlocks.length - 1}__\n`;
    });

    // 3. Standardize normal verse endings to newline
    processed = processed.replace(/(।।|॥|\|\||।|\|)/g, "$1\n");
    processed = processed.replace(/(\s*-\s*श्री|\s*—\s*श्री)/g, "\n— श्री");

    // 4. Restore all protected blocks
    processed = processed.replace(/__PB(\d+)__/g, (match, index) => {
      const idx = parseInt(index, 10);
      return ` ${protectedBlocks[idx]}`;
    });

    // 5. Split lines and stop processing after attribution line (so no trailing explanations are included)
    const rawLines = processed
      .split('\n')
      .map(p => p.trim())
      .filter(Boolean);

    return rawLines;
  }, [text]);

  const maxLineLength = React.useMemo(() => {
    const verseLines = cleanLines.filter(line => {
      const isAttribution = line.startsWith('— श्री') || line.startsWith('- श्री');
      const isHeader = (line.startsWith('॥') && line.endsWith('॥') && !/[०-९\d]/.test(line)) ||
        (line.startsWith('।') && line.endsWith('।') && !/[०-९\d]/.test(line));
      return !isAttribution && !isHeader;
    });
    return Math.max(...verseLines.map(l => l.length), 1);
  }, [cleanLines]);

  // Premium, highly consistent fluid typography system
  // Base font size maps to sizeLevel 1-5 (very stable, minimal steps)
  // Sanskrit has slightly larger glyph presence than Roman transliteration
  const baseMapDeva = [1.25, 1.55, 1.9, 2.3, 2.8];
  const baseMapRoman = [1.05, 1.25, 1.5, 1.8, 2.15];

  const base = isRoman ? baseMapRoman[sizeLevel - 1] : baseMapDeva[sizeLevel - 1];

  // Dynamic tuning based on longest line length:
  // We apply a gentle, smooth scaling factor. Extremely long lines shrink slightly (max 15%)
  // to prevent clumsy wrapping. Short single-line couplets grow slightly (max 10%) for a premium display feel.
  let scale = 1.0;
  if (maxLineLength > 34) {
    // scale down smoothly for long lines
    scale = Math.max(0.85, 1.0 - (maxLineLength - 34) * 0.008);
  } else if (maxLineLength < 18) {
    // scale up smoothly for short lines
    scale = Math.min(1.1, 1.0 + (18 - maxLineLength) * 0.01);
  }

  const finalBaseRem = base * scale;

  // Fluid design rule: rem base + responsive viewport fraction, clamped in a strict range
  const minLimit = finalBaseRem * 0.85;
  const maxLimit = finalBaseRem * 1.15;
  const fluidFontSize = `clamp(${minLimit}rem, calc(${finalBaseRem}rem + 0.3vw), ${maxLimit}rem)`;

  return (
    <div
      className={`w-full flex flex-col ${centered ? 'items-center text-center' : 'items-start text-left'} space-y-4 ${className}`}
      style={{
        fontSize: fluidFontSize,
        lineHeight: isRoman ? '1.8' : '1.9',
        letterSpacing: isRoman ? '0.03em' : '0.015em',
        fontWeight: isRoman ? '400' : '500'
      }}
    >
      {cleanLines.map((line, idx) => {
        const isAttribution = /^[—–-]\s*(?:श्री|जगद्गुरु|स्वामी|हठ|रसिया|रसिक|सूरदास|मीरा|कबीर|हित|गोविन्द|गोविंद|भगवत|हरिदास|देव|रूप|सनातन|जीव|ललित|Jagadguru|Shri|Swami|Goswami)/i.test(line);
        const isHeader = (line.startsWith('॥') && line.endsWith('॥') && !/[०-९\d]/.test(line)) ||
          (line.startsWith('।') && line.endsWith('।') && !/[०-९\d]/.test(line));

        if (isAttribution) {
          return (
            <div
              key={idx}
              className="mt-6 pt-4 border-t border-[var(--glass-border)] text-[var(--primary-color)] font-semibold w-full block text-center select-text font-headings tracking-wide"
              style={{ fontSize: '0.9em', lineHeight: '1.6' }}
            >
              {line}
            </div>
          );
        }

        if (isHeader) {
          return (
            <div
              key={idx}
              className="font-bold text-center uppercase tracking-widest mt-8 mb-2 font-headings"
              style={{ color: 'var(--verse-header-color)', fontSize: '1.1rem', opacity: 0.95 }}
            >
              {line}
            </div>
          );
        }

        return (
          <div
            key={idx}
            className="verse-line-text select-text text-current whitespace-pre-wrap break-words w-full"
            style={{ wordBreak: 'keep-all', overflowWrap: 'break-word' }}
          >
            {line}
          </div>
        );
      })}
    </div>
  );
};

const ContentDetailPage = ({ initialContent, initialRelatedSaint, initialRelatedBook, initialRelatedRaga, initialRelatedVerses }) => {
  const params = useParams();
  const id = params?.id || params?.slug || '';
  const location = useLocation();
  const isHindiRoute = location.pathname.startsWith('/hi');
  const { apiService } = useContext(ApiContext);
  const { settings, updateSetting } = useSettings();
  const { isDark } = useTheme();
  const sizeLevel = settings.fontSize || 2;

  const checkIsTruncated = (str) => {
    if (!str) return true;
    const trimmed = str.trim();
    if (trimmed.length <= 120) return true;
    if (trimmed.length <= 350 && !/[॥।.\!\?\n\”\"']/.test(trimmed.slice(-3))) return true;
    return false;
  };

  const [rawContent, setRawContent] = useState(initialContent || (() => {
    if (typeof window !== 'undefined' && location.state?.item) {
      const stateItem = location.state.item;
      if (!checkIsTruncated(stateItem.sanskrit_text) && !checkIsTruncated(stateItem.hindi_text)) {
        return stateItem;
      }
    }
    const sessionCached = apiService.getCachedData(`id_${id}`);
    if (sessionCached && !sessionCached.isLightweight && !checkIsTruncated(sessionCached.sanskrit_text) && !checkIsTruncated(sessionCached.hindi_text)) {
      return sessionCached;
    }
    try {
      const memCached = apiService.getMemoryCachedItems();
      if (memCached && memCached.length > 0) {
        const decodedId = decodeURIComponent(id);
        const matched = memCached.find(item =>
          item.id?.toString() === id.toString() ||
          item.id?.toString() === decodedId.toString() ||
          item.slug === id ||
          item.slug === decodedId
        );
        if (matched && !checkIsTruncated(matched.sanskrit_text) && !checkIsTruncated(matched.hindi_text)) {
          return matched;
        }
      }
    } catch (e) { }
    return null;
  }));

  const isInitialTruncated = rawContent && (checkIsTruncated(rawContent.sanskrit_text) || checkIsTruncated(rawContent.hindi_text));

  const { data: fetchedData, isValidating } = useSWR(
    id ? `content_${id}` : null,
    async ({ signal }) => {
      const decodedId = decodeURIComponent(id);
      const stotraData = await apiService.getStotraBySlug(decodedId);
      if (stotraData) return { isStotra: true, stotraData };
      return await apiService.getContentById(decodedId, { signal });
    },
    {
      initialData: isInitialTruncated ? undefined : rawContent,
      revalidateOnMount: isInitialTruncated || !rawContent,
      dedupingInterval: 3000
    }
  );

  const content = React.useMemo(() => {
    const activeData = fetchedData || rawContent;
    if (!activeData) return null;

    let rawSanskrit = activeData.sanskrit_text || '';
    let rawHindi = activeData.hindi_text || '';
    let rawContentText = activeData.content_text || '';

    // Pick the longest text if sanskrit_text is truncated or missing lines
    let richestText = rawSanskrit;
    if (rawHindi.length > (richestText.length + 30) || (!richestText && rawHindi)) {
      richestText = rawHindi;
    }
    if (rawContentText.length > (richestText.length + 30) || (!richestText && rawContentText)) {
      richestText = rawContentText;
    }

    const finalVerseText = richestText || rawSanskrit || rawHindi;

    return {
      ...activeData,
      sanskrit_text: finalVerseText,
      hindi_text: finalVerseText,
      english_translation: ''
    };
  }, [fetchedData, rawContent]);

  const [loading, setLoading] = useState(() => {
    if (initialContent) return false;
    return !content;
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
      } catch (e) { }
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

  const [aiCache, setAiCache] = useState({});
  const [loadingAi, setLoadingAi] = useState(false);
  const [errorAi, setErrorAi] = useState("");
  const [aiLang, setAiLang] = useState("hi");
  const [isMounted, setIsMounted] = useState(false);
  const [copied, setCopied] = useState(false);
  const [autoExplain, setAutoExplain] = useState(() => {
    try {
      const saved = localStorage.getItem('auto_explain_ai');
      return saved ? saved === 'true' : false; // default to false
    } catch (e) {
      return false;
    }
  });

  const toggleAutoExplain = () => {
    setAutoExplain(prev => {
      const newVal = !prev;
      try {
        localStorage.setItem('auto_explain_ai', newVal ? 'true' : 'false');
      } catch (e) { }
      return newVal;
    });
  };

  useEffect(() => {
    setIsMounted(true);
    setAiLang(isHindiRoute ? "hi" : "en");
  }, [isHindiRoute]);

  // Reset AI state and cache when verse/id changes
  useEffect(() => {
    setAiCache({});
    setErrorAi("");
    setLoadingAi(false);
  }, [id]);

  // Auto-explain on mount/content load if enabled
  useEffect(() => {
    if (content && autoExplain && isMounted && !loadingAi && !aiCache[aiLang] && !errorAi) {
      handleExplainWithAI(aiLang);
    }
  }, [content, autoExplain, isMounted, aiLang]);

  // V5: Save last-read verse for Continue Reading
  useEffect(() => {
    if (content && content.slug) {
      try {
        localStorage.setItem('vrindopnishad_last_read', JSON.stringify({
          slug: content.slug || id,
          title: content.cleanTitle || content.title,
          author: content.author,
          timestamp: Date.now()
        }));
      } catch (e) { }
    }
  }, [content, id]);

  const currentExplanation = aiCache[aiLang] || "";

  const handleExplainWithAI = async (lang = aiLang) => {
    if (!content) return;

    if (aiCache[lang]) {
      return;
    }

    setLoadingAi(true);
    setErrorAi("");
    try {
      const res = await apiService.explainContent(
        content.id,
        content.sanskrit_text,
        content.hindi_text,
        content.author,
        content.title,
        lang
      );
      if (res && res.success) {
        setAiCache(prev => ({ ...prev, [lang]: res.explanation }));
      } else {
        setErrorAi(res.message || "Failed to generate explanation.");
      }
    } catch (err) {
      console.error(err);
      setErrorAi(isHindiRoute ? "व्याख्या प्राप्त करने में त्रुटि हुई। कृपया पुनः प्रयास करें।" : "Failed to fetch explanation. Please try again.");
    } finally {
      setLoadingAi(false);
    }
  };

  const handleLangSwitch = (lang) => {
    setAiLang(lang);

    // Check if the AI has been revealed/requested before
    const hasBeenRevealed = Object.values(aiCache).some(val => !!val);

    if (hasBeenRevealed || loadingAi) {
      if (!aiCache[lang]) {
        handleExplainWithAI(lang);
      }
    }
  };

  const handleCopy = async () => {
    if (!currentExplanation) return;
    try {
      await navigator.clipboard.writeText(currentExplanation);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch (e) {
      console.error(e);
    }
  };

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

  useEffect(() => {
    if (!content) return;

    setLoading(false);

    let active = true;

    // Defer concept scan to prevent thread blocking on mount
    const scanTimer = setTimeout(() => {
      if (active) performConceptScan(content);
    }, 40);

        // Defer the extraction of relations to avoid blocking UI rendering
        const timer = setTimeout(async () => {
          if (!active) return;
          try {
            const allItems = await apiService.getAllContent(null, 25000);
            const relations = extractRelations(allItems);

            // 1. Saint Matching
            const authorInfo = parseAuthorField(content.author || "");
            let saintName = authorInfo.saintName;
            if (!saintName && content.hindi_text) {
              const attrMatch = content.hindi_text.match(/[—–-]\s*([^\n,()]+)/);
              if (attrMatch) saintName = attrMatch[1].trim();
            }
            let matchedSaint = null;
            if (saintName) {
              const saintSlug = getNormalizedSaintSlug(saintName);
              matchedSaint = relations.sants.find(s => s.slug === saintSlug || s.name === saintName);
            }

            // 2. Grantha Matching
            let bookName = authorInfo.bookName;
            if (!bookName && content.hindi_text) {
              const lineMatch = content.hindi_text.match(/[—–-]\s*[^\n,]+,\s*([^\n()]+)/);
              if (lineMatch) bookName = lineMatch[1].trim();
            }
            let matchedBook = null;
            if (bookName) {
              const bookSlug = getNormalizedBookSlug(bookName);
              matchedBook = relations.books.find(b => b.slug === bookSlug || b.name === bookName);
            }

            const textToScan = [
              content.title,
              content.author,
              content.hindi_text,
              content.sanskrit_text,
              content.description
            ].filter(Boolean).join(' ').toLowerCase();

            if (textToScan.includes('सेवा कुंज') || textToScan.includes('सेवाकुंज') || textToScan.includes('seva kunj')) {
              matchedBook = relations.books.find(b => b.slug === 'seva-kunj-texts') || matchedBook;
            }

            // 3. Raga Matching
            const ragaName = extractCleanRaga(content.sanskrit_text, content.hindi_text, content.title);
            const matchedRaga = ragaName ? relations.ragas.find(r => r.name === ragaName) : null;

            // 4. Multi-Tier Recommendation Engine
            const currentTags = new Set((content.tags || []).map(t => t.toLowerCase()));
            const currentId = content.id?.toString();
            const currentAuthor = (content.author || '').toLowerCase();
            const currentCategory = (content.category || '').toLowerCase();

            const candidates = allItems.filter(item =>
              item.id?.toString() !== currentId &&
              item.category?.toLowerCase() !== 'saint'
            );

            const scoredList = candidates.map(item => {
              const itemTags = new Set((item.tags || []).map(t => t.toLowerCase()));
              let score = 0;
              let matchReason = isHindiRoute ? "सम्बन्धित पावन पद" : "Related Passage";

              const itemAuthor = (item.author || '').toLowerCase();
              const itemCategory = (item.category || '').toLowerCase();

              // Same Saint
              if (currentAuthor && itemAuthor && (itemAuthor === currentAuthor || (matchedSaint && itemAuthor.includes(matchedSaint.name.toLowerCase())))) {
                score += 6;
                matchReason = isHindiRoute ? `सन्त ${matchedSaint?.name ? matchedSaint.name.substring(0, 14) : 'रचित'}` : `By ${matchedSaint?.hinglishName || 'Same Saint'}`;
              }

              // Same Raga
              if (ragaName && ((item.sanskrit_text && item.sanskrit_text.includes(ragaName)) || (item.hindi_text && item.hindi_text.includes(ragaName)) || (item.title && item.title.includes(ragaName)))) {
                score += 5;
                matchReason = isHindiRoute ? `समान राग (${ragaName})` : `Same Raga (${ragaName})`;
              }

              // Tag overlap
              let tagMatches = 0;
              for (const tag of itemTags) {
                if (currentTags.has(tag) && tag !== 'vrindavaani') {
                  tagMatches++;
                  score += 3;
                }
              }
              if (tagMatches > 0 && score < 5) {
                matchReason = isHindiRoute ? "समान भाव / विषय" : "Matching Theme";
              }

              // Same Category
              if (currentCategory && itemCategory === currentCategory) {
                score += 2;
                if (score <= 2) {
                  matchReason = isHindiRoute ? `समान श्रेणी (${item.category})` : `Same ${item.category}`;
                }
              }

              return { item, score, matchReason };
            });

            scoredList.sort((a, b) => b.score - a.score);

            let recommendedItems = scoredList.filter(s => s.score > 0);

            // Guaranteed padding to 6 recommendations
            if (recommendedItems.length < 6) {
              const existingIds = new Set(recommendedItems.map(r => r.item.id));
              for (const candidate of candidates) {
                if (!existingIds.has(candidate.id)) {
                  recommendedItems.push({
                    item: candidate,
                    score: 1,
                    matchReason: isHindiRoute ? "अनुशंसित पावन पद्यावली" : "Recommended Reading"
                  });
                  existingIds.add(candidate.id);
                  if (recommendedItems.length >= 6) break;
                }
              }
            }

            if (active) {
              setRelatedSaint(matchedSaint || null);
              setRelatedBook(matchedBook || null);
              setRelatedRaga(matchedRaga || null);
              setRelatedVerses(recommendedItems.slice(0, 6));
            }
          } catch (err) {
            console.warn('Deferred relations loading failed:', err);
          }
        }, 60);

    return () => {
      active = false;
      clearTimeout(scanTimer);
      clearTimeout(timer);
    };
  }, [content, apiService, initialRelatedSaint, initialRelatedBook, initialRelatedRaga, initialRelatedVerses]);

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

  if (fetchedData?.isStotra) {
    return <StotraDetailPage stotra={fetchedData.stotraData} slug={id} />;
  }

  const showSkeleton = loading && !content;

  if (showSkeleton) {
    return <PageSkeleton variant="detail" />;
  }

  if (!loading && !content) {
    return (
      <div className="animate-fade-in">
        <Link to={isHindiRoute ? "/hi/lyrics" : "/lyrics"} className="inline-flex items-center gap-2 text-white/40 hover:text-white mb-8 transition-colors">
          <ArrowLeft size={18} />
          Back to Collection
        </Link>
        <div className="glass-card text-center py-24">
          <h2 className="text-3xl font-bold mb-6">Content not found</h2>
          <p className="text-white/40 mb-10 text-lg">The verse or poem you are looking for does not exist in our library.</p>
          <Link to={isHindiRoute ? "/hi/lyrics" : "/lyrics"} className="btn-sacred-gold px-10 py-3">
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
    ? `https://path.vrindopnishad.in/hi/lyrics/${content.slug || id}`
    : `https://path.vrindopnishad.in/lyrics/${content.slug || id}`;

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
    parsedSaintName = content.author && content.author !== 'Team VrindaVaani' ? content.author : '';
  }

  if (!parsedSaintName && titleVal.includes('-')) {
    const parts = titleVal.split(/\s+-\s+/);
    if (parts.length >= 2) {
      parsedSaintName = parts[parts.length - 1].trim();
    }
  }

  const effectiveSaintName = parsedSaintName || (content.author && content.author !== 'Team VrindaVaani' ? content.author : (isHindiRoute ? 'वैष्णव संत' : 'Vaishnava Saint'));
  const cleanSaint = effectiveSaintName ? effectiveSaintName.replace(/जी की वाणी/g, '').replace(/जी/g, '').replace(/महाप्रभु/g, '').trim() : (isHindiRoute ? 'वैष्णव संत' : 'Vaishnava Saint');
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
                  "item": isHindiRoute ? "https://path.vrindopnishad.in/hi/lyrics" : "https://path.vrindopnishad.in/lyrics"
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
                "@id": `https://path.vrindopnishad.in/lyrics/${content.slug || id}`
              },
              ...(content.image_url ? { "image": content.image_url } : {})
            })}
          </script>
        </Helmet>

        <article>
          {/* Breadcrumb */}
          <Link to={isHindiRoute ? "/hi/lyrics" : "/lyrics"} className="inline-flex items-center gap-2 text-stone-600 dark:text-white/50 hover:text-stone-900 dark:hover:text-white mb-4 transition-colors text-sm font-medium">
            <ArrowLeft size={16} />
            {isHindiRoute ? "संग्रह" : "Collection"}
          </Link>

          <div className="w-full px-0 py-4 md:px-6 md:py-6 mb-10 relative">
            {/* 1. Meta Row — spacious & clear */}
            <div className="flex flex-wrap items-center gap-3 text-left mb-6">
              {(() => {
                const displayAuthorName = effectiveSaintName;
                const saintSlug = getNormalizedSaintSlug(displayAuthorName);
                const granthSlug = cleanGranth ? getNormalizedBookSlug(cleanGranth) : null;
                return (
                  <>
                    <div className="flex items-center gap-2.5">
                      <div className="w-8 h-8 rounded-full bg-[rgba(var(--primary-rgb),0.12)] border border-[rgba(var(--primary-rgb),0.25)] flex items-center justify-center text-[var(--primary-color)] font-bold text-xs shrink-0">
                        {getInitials(displayAuthorName)}
                      </div>
                      {saintSlug ? (
                        <Link
                          to={isHindiRoute ? `/hi/saints/${saintSlug}` : `/saints/${saintSlug}`}
                          className="text-sm font-bold font-headings text-[var(--primary-color)] hover:opacity-80 transition-opacity"
                        >
                          {displayAuthorName}
                        </Link>
                      ) : (
                        <span className="text-sm font-bold font-headings text-[var(--text-color)]">
                          {displayAuthorName}
                        </span>
                      )}
                    </div>
                    <span className="opacity-30">·</span>
                    <span className={`sacred-badge text-[10px] py-1 px-3 ${getCategoryBadgeClass(content.category)}`}>
                      {content.category}
                    </span>
                    {granthSlug && cleanGranth && !cleanGranth.includes('वृंदोपनिषद्') && (
                      <>
                        <span className="opacity-30 hidden sm:inline">·</span>
                        <Link
                          to={isHindiRoute ? `/hi/granthas/${granthSlug}` : `/granthas/${granthSlug}`}
                          className="text-xs text-stone-700 dark:text-white/60 hover:text-[var(--primary-color)] transition-colors hidden sm:flex items-center gap-1.5 font-medium"
                        >
                          <BookOpen size={14} />
                          {cleanGranth}
                        </Link>
                      </>
                    )}
                  </>
                );
              })()}
            </div>

            {/* 2. Main Title — elegant breathing room */}
            <h1 className="text-3xl sm:text-4xl md:text-5xl font-bold font-headings leading-normal md:leading-snug my-6 text-[var(--text-color)]">
              {content.title}
            </h1>

            {/* 3. Reading Toolbar — high-end glassmorphic control bar */}
            <div className="flex items-center justify-between gap-3 py-3.5 px-4 sm:px-6 rounded-2xl border border-[rgba(var(--primary-rgb),0.2)] bg-gradient-to-r from-[rgba(var(--primary-rgb),0.06)] via-[var(--glass-bg)] to-[rgba(var(--primary-rgb),0.06)] backdrop-blur-xl my-8 shadow-md shadow-black/5">
              {/* Left: Quick Action Tools */}
              <div className="flex items-center gap-2 sm:gap-2.5">
                <button
                  onClick={toggleBookmark}
                  className={`flex items-center justify-center w-9 h-9 rounded-full border transition-all ${isBookmarked
                      ? 'bg-[rgba(var(--primary-rgb),0.15)] border-[var(--primary-color)] text-[var(--primary-color)] shadow-sm'
                      : 'border-[var(--glass-border)] bg-[var(--glass-bg)] text-stone-700 dark:text-white/60 hover:text-stone-900 dark:hover:text-white hover:border-[rgba(var(--primary-rgb),0.3)]'
                    }`}
                  title={isBookmarked ? (isHindiRoute ? "सहेजा गया" : "Saved") : (isHindiRoute ? "बुकमार्क" : "Bookmark")}
                  aria-label={isBookmarked ? "Remove bookmark" : "Add bookmark"}
                >
                  <Bookmark size={15} className={isBookmarked ? "fill-current" : ""} />
                </button>
                <button
                  onClick={() => shareVerseCard(content, isHindiRoute)}
                  className="flex items-center justify-center w-9 h-9 rounded-full border border-[var(--glass-border)] bg-[var(--glass-bg)] text-stone-700 dark:text-white/60 hover:text-stone-900 dark:hover:text-white hover:border-[rgba(var(--primary-rgb),0.3)] transition-all"
                  title={isHindiRoute ? "साझा करें" : "Share"}
                  aria-label="Share verse"
                >
                  <Share2 size={15} />
                </button>
                <button
                  onClick={() => {
                    setIsPaathMode(true);
                    try {
                      if (!document.fullscreenElement) {
                        document.documentElement.requestFullscreen().catch(() => { });
                      }
                    } catch (e) { }
                  }}
                  className="flex items-center justify-center w-9 h-9 rounded-full border border-[var(--glass-border)] bg-[var(--glass-bg)] text-stone-700 dark:text-white/60 hover:text-stone-900 dark:hover:text-white hover:border-[rgba(var(--primary-rgb),0.3)] transition-all"
                  title={isHindiRoute ? "पाठ मोड" : "Fullscreen"}
                  aria-label="Fullscreen reading mode"
                >
                  <Maximize2 size={15} />
                </button>
                <button
                  onClick={() => updateSetting('lineByLine', !settings.lineByLine)}
                  className={`flex items-center justify-center w-9 h-9 rounded-full border transition-all ${settings.lineByLine
                      ? 'bg-[rgba(var(--primary-rgb),0.15)] border-[var(--primary-color)] text-[var(--primary-color)]'
                      : 'border-[var(--glass-border)] bg-[var(--glass-bg)] text-stone-700 dark:text-white/60 hover:text-stone-900 dark:hover:text-white hover:border-[rgba(var(--primary-rgb),0.3)]'
                    }`}
                  title={settings.lineByLine ? (isHindiRoute ? "पंक्ति-दर-पंक्ति मोड चालू" : "Line-by-line mode active") : (isHindiRoute ? "पंक्ति-दर-पंक्ति मोड चालू करें" : "Toggle line-by-line mode")}
                  aria-label="Toggle line-by-line mode"
                >
                  <AlignLeft size={15} />
                </button>
              </div>

              {/* Center: Subtle Sanctum Status Badge */}
              <div className="hidden md:flex items-center gap-2 text-xs font-semibold text-[var(--primary-color)] bg-[rgba(var(--primary-rgb),0.1)] px-3.5 py-1.5 rounded-full border border-[rgba(var(--primary-rgb),0.25)]">
                <span className="w-1.5 h-1.5 rounded-full bg-[var(--primary-color)] animate-pulse"></span>
                <span>{isHindiRoute ? 'पावन पठन' : 'Sacred Reading'}</span>
              </div>

              {/* Right: Font Sizer */}
              <FontWheel
                compact={true}
                value={settings.fontSize}
                onChange={(size) => updateSetting('fontSize', size)}
              />
            </div>

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

            <div className="space-y-12">
              {content.sanskrit_text ? (
                <div className="relative group py-8 sm:py-16 border-b border-white/5 animate-fade-in">
                  {/* Decorative watermark */}
                  <div className="absolute inset-0 flex items-center justify-center opacity-[0.025] text-[12rem] font-serif pointer-events-none select-none">ॐ</div>

                  {/* Section label */}
                  <h2 className="content-section-heading text-[10px] sm:text-xs uppercase tracking-[0.45em] mb-8 sm:mb-12 flex items-center justify-center gap-4 py-2">
                    <span className="content-section-line h-px w-8 opacity-40"></span>
                    {isHindiRoute ? 'मूल पाठ' : 'Sanskrit Text'}
                    <span className="content-section-line h-px w-8 opacity-40"></span>
                  </h2>

                  {/* Verse body — dynamic size, centered */}
                  <div
                    className={`mx-auto w-full max-w-2xl ${settings.fontStyle === 'Sans' ? 'font-sans' :
                        settings.fontStyle === 'Inter' ? 'font-inter' :
                          'font-headings'
                      }`}
                    style={{ containerType: 'inline-size' }}
                  >
                    <AutoFitVerse
                      text={content.sanskrit_text}
                      sizeLevel={sizeLevel}
                      fontStyle={settings.fontStyle}
                      isHindiRoute={isHindiRoute}
                      centered={true}
                      className="content-verse-text hindi-text"
                    />
                  </div>
                </div>
              ) : (
                content.title ? (
                  <div className="relative group py-8 sm:py-16 border-b border-white/5 animate-fade-in text-center">
                    <div className="absolute inset-0 flex items-center justify-center opacity-[0.02] text-[12rem] font-serif pointer-events-none select-none">ॐ</div>
                    <h2 className="content-section-heading text-[10px] sm:text-xs uppercase tracking-[0.45em] mb-8 sm:mb-12 flex items-center justify-center gap-4 py-2">
                      <span className="content-section-line h-px w-8 opacity-40"></span>
                      {isHindiRoute ? 'प्रथम पंक्ति' : 'Opening Line'}
                      <span className="content-section-line h-px w-8 opacity-40"></span>
                    </h2>
                    <div className="mx-auto w-full max-w-2xl font-headings text-xl sm:text-2xl text-amber-100/90 leading-relaxed font-semibold italic">
                      "{extractFirstLine(content.title)}"
                    </div>
                    <p className="text-[10px] text-white/40 mt-6 tracking-wide uppercase">
                      {isHindiRoute ? 'मूल पाठ डेटाबेस में उपलब्ध नहीं है। दिव्य व्याख्या नीचे उपलब्ध है।' : 'Original text not in database. Dynamic AI commentary is available below.'}
                    </p>
                  </div>
                ) : null
              )}



              {(transliteratedSanskrit || transliteratedHindi) ? (
                <div className="py-8 sm:py-12 border-b border-white/5 animate-fade-in">
                  <h2 className="content-section-heading content-section-heading--hinglish text-[10px] sm:text-xs uppercase tracking-[0.4em] mb-6 sm:mb-8 flex items-center justify-center sm:justify-start gap-4 py-2">
                    <span className="content-section-line content-section-line--hinglish h-[1px] w-12 hidden sm:block"></span>
                    Hinglish Transliteration (रोमन पाठ)
                    <span className="content-section-line content-section-line--hinglish h-[1px] w-12 hidden sm:block"></span>
                  </h2>
                  <div
                    className={`w-full ${settings.fontStyle === 'Sans' ? 'font-sans' :
                        settings.fontStyle === 'Inter' ? 'font-inter' :
                          'font-headings'
                      }`}
                    style={{ containerType: 'inline-size' }}
                  >
                    <AutoFitVerse
                      text={transliteratedSanskrit || transliteratedHindi}
                      sizeLevel={sizeLevel}
                      fontStyle={settings.fontStyle}
                      isHindiRoute={isHindiRoute}
                      centered={false}
                      className="content-verse-text"
                      isRoman={true}
                    />
                  </div>
                </div>
              ) : null}

              {content.english_text && (
                <div>
                  <h2 className="content-section-heading text-xs uppercase tracking-[0.3em] mb-6 font-semibold">Transliteration</h2>
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

              {content.english_translation ? (
                <div className="py-12 animate-fade-in">
                  <h2 className="content-section-heading content-section-heading--english text-xs uppercase tracking-[0.3em] mb-10 flex items-center gap-3">
                    <span className="content-section-line content-section-line--english h-[1px] w-8"></span>
                    English Translation
                  </h2>
                  <div className="content-body-text leading-relaxed font-light" style={{
                    fontSize: sizeLevel === 1 ? '1.1rem' :
                      sizeLevel === 2 ? '1.4rem' :
                        sizeLevel === 3 ? '1.8rem' :
                          sizeLevel === 4 ? '2.2rem' : '2.5rem'
                  }}>
                    {content.english_translation}
                  </div>
                </div>
              ) : null}


              {content.audio_url && (
                <div className="pt-8 border-t border-white/5">
                  <h2 className="text-xl font-bold mb-6 flex items-center gap-3">
                    <Music size={24} className="text-amber-400" />
                    Listen to Audio
                  </h2>
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
                  <h2 className="text-xl font-bold mb-8 flex items-center gap-3">
                    <ImageIcon size={24} className="text-amber-400" />
                    Gallery
                  </h2>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {content.image_url && (
                      <img src={content.image_url} alt="Verse" width={800} height={600} loading="lazy" className="rounded-2xl w-full h-auto border border-white/10 hover:border-amber-400/30 transition-all shadow-2xl" />
                    )}
                    {content.image_urls?.map((url, idx) => (
                      <img key={idx} src={url} alt={`Verse ${idx + 1}`} width={800} height={600} loading="lazy" className="rounded-2xl w-full h-auto border border-white/10 hover:border-amber-400/30 transition-all shadow-2xl" />
                    ))}
                  </div>
                </div>
              )}

              {content.video_urls && content.video_urls.length > 0 && (
                <div className="pt-8 border-t border-white/5">
                  <h2 className="text-xl font-bold mb-8 flex items-center gap-3">
                    <Video size={24} className="text-primary" />
                    Videos
                  </h2>
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
                    className={`flex items-center justify-center w-11 h-11 shrink-0 aspect-square rounded-full border transition-all ${isBookmarked
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
                          document.documentElement.requestFullscreen().catch(() => { });
                        }
                      } catch (e) { }
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

              {/* Interactive AI Explanation & Spiritual Commentary Section */}
              <div className="mt-12 pt-8 border-t border-[var(--glass-border)] animate-fade-in text-left">
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
                  <div className="flex items-center gap-3">
                    <div className="w-9 h-9 rounded-full bg-[rgba(var(--primary-rgb),0.12)] border border-[rgba(var(--primary-rgb),0.25)] flex items-center justify-center text-[var(--primary-color)] shrink-0">
                      <Sparkles size={18} />
                    </div>
                    <div>
                      <h3 className="text-base sm:text-lg font-bold text-[var(--text-color)] font-headings flex items-center gap-2">
                        <span>{isHindiRoute ? "एआई दिव्य भावार्थ एवं व्याख्या" : "AI Spiritual Commentary & Explanation"}</span>
                      </h3>
                      <p className="text-xs text-stone-500 dark:text-white/40">
                        {isHindiRoute ? "पद के गूढ़ भाव एवं भक्ति अर्थ की एआई द्वारा विशद व्याख्या" : "Dynamic AI commentary & spiritual breakdown for this composition"}
                      </p>
                    </div>
                  </div>

                  {/* Language Toggle & Action Controls */}
                  <div className="flex items-center gap-2">
                    <div className="inline-flex p-1 rounded-xl bg-black/10 dark:bg-white/5 border border-[var(--glass-border)] text-xs">
                      <button
                        onClick={() => handleLangSwitch("hi")}
                        className={`px-3 py-1 rounded-lg font-medium transition-all ${aiLang === "hi" ? "bg-[var(--primary-color)] text-white font-bold shadow-sm" : "text-stone-600 dark:text-white/60 hover:text-[var(--text-color)]"}`}
                      >
                        हिंदी
                      </button>
                      <button
                        onClick={() => handleLangSwitch("en")}
                        className={`px-3 py-1 rounded-lg font-medium transition-all ${aiLang === "en" ? "bg-[var(--primary-color)] text-white font-bold shadow-sm" : "text-stone-600 dark:text-white/60 hover:text-[var(--text-color)]"}`}
                      >
                        English
                      </button>
                    </div>

                    {currentExplanation && (
                      <button
                        onClick={handleCopy}
                        className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl border border-[var(--glass-border)] bg-[var(--glass-bg)] hover:bg-[rgba(var(--primary-rgb),0.1)] text-xs font-semibold text-[var(--primary-color)] transition-all"
                        title={copied ? (isHindiRoute ? "प्रतिलिपि बनाई गई!" : "Copied!") : (isHindiRoute ? "प्रतिलिपि बनाएं" : "Copy Explanation")}
                      >
                        {copied ? <Check size={14} /> : <Copy size={14} />}
                        <span>{copied ? (isHindiRoute ? "प्रतिलिपि बनाई गई" : "Copied") : (isHindiRoute ? "कॉपी" : "Copy")}</span>
                      </button>
                    )}
                  </div>
                </div>

                {/* Explanation Content Box / Trigger Button */}
                {loadingAi ? (
                  <div className="p-8 rounded-2xl border border-[rgba(var(--primary-rgb),0.25)] bg-[rgba(var(--primary-rgb),0.05)] flex flex-col items-center justify-center gap-3 text-center">
                    <Loader2 size={24} className="animate-spin text-[var(--primary-color)]" />
                    <p className="text-xs font-medium text-[var(--text-color)] opacity-80">
                      {isHindiRoute ? "दिव्य व्याख्या एवं भावार्थ तैयार किया जा रहा है..." : "Generating spiritual AI commentary & explanation..."}
                    </p>
                  </div>
                ) : currentExplanation ? (
                  <div className="p-6 rounded-2xl border border-[var(--glass-border)] bg-[var(--glass-bg)] shadow-md text-stone-700 dark:text-white/80 text-sm sm:text-base leading-relaxed space-y-4 font-serif">
                    {currentExplanation.split('\n').filter(Boolean).map((para, pIdx) => (
                      <p key={pIdx} className="leading-relaxed">
                        {para}
                      </p>
                    ))}
                  </div>
                ) : errorAi ? (
                  <div className="p-5 rounded-2xl border border-red-500/20 bg-red-500/5 text-center space-y-3">
                    <p className="text-xs text-red-500 font-medium">{errorAi}</p>
                    <button
                      onClick={() => handleExplainWithAI(aiLang)}
                      className="px-4 py-2 rounded-xl bg-[var(--primary-color)] text-white text-xs font-bold shadow-md hover:opacity-90 transition-all inline-flex items-center gap-2"
                    >
                      <RotateCcw size={14} />
                      <span>{isHindiRoute ? "पुनः प्रयास करें" : "Retry AI Generation"}</span>
                    </button>
                  </div>
                ) : (
                  <div className="p-6 rounded-2xl border border-[rgba(var(--primary-rgb),0.25)] bg-[rgba(var(--primary-rgb),0.04)] flex flex-col sm:flex-row items-center justify-between gap-4">
                    <p className="text-xs text-stone-600 dark:text-white/70 text-center sm:text-left">
                      {isHindiRoute ? "पद के गूढ़ भाव एवं भक्ति अर्थ को एआई द्वारा विशद रूप से समझें" : "Generate detailed spiritual breakdown and contextual commentary powered by AI"}
                    </p>
                    <button
                      onClick={() => handleExplainWithAI(aiLang)}
                      className="shrink-0 px-5 py-2.5 rounded-xl bg-[var(--primary-color)] text-white text-xs font-bold shadow-md hover:shadow-lg transition-all flex items-center gap-2 group"
                    >
                      <Sparkles size={16} />
                      <span>{isHindiRoute ? "एआई व्याख्या देखें" : "Generate AI Explanation"}</span>
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>
        </article>


        {/* Knowledge Connections & Recommendations System */}
        {(() => {
          const hasConnections = !!(
            relatedSaint ||
            relatedBook ||
            relatedRaga ||
            (detectedConcepts && detectedConcepts.length > 0) ||
            (relatedVerses && relatedVerses.length > 0)
          );

          if (!hasConnections) return null;

          return (
            <div className="mt-20 mb-16 space-y-16 animate-fade-in text-left">
              {/* Section 1: Entity Graph Connections (Saint, Scripture, Raga, Concepts) */}
              {(relatedSaint || relatedBook || relatedRaga || (detectedConcepts && detectedConcepts.length > 0)) && (
                <section>
                  <div className="flex items-center gap-4 mb-8">
                    <div className="h-px flex-1 bg-gradient-to-r from-transparent via-[rgba(var(--primary-rgb),0.25)] to-transparent"></div>
                    <h2 className="text-lg sm:text-xl font-bold text-[var(--primary-color)] px-4 font-headings flex items-center gap-2">
                      <Sparkles size={18} className="text-[var(--primary-color)]" />
                      <span>{isHindiRoute ? "ज्ञान सम्बन्ध चित्र एवं सन्दर्भ" : "Knowledge Graph Connections"}</span>
                    </h2>
                    <div className="h-px flex-1 bg-gradient-to-r from-transparent via-[rgba(var(--primary-rgb),0.25)] to-transparent"></div>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
                    {/* Related Saint Card */}
                    {relatedSaint && (
                      <div className="glass-card p-5 rounded-2xl border border-[var(--glass-border)] bg-[var(--glass-bg)] flex flex-col justify-between hover:border-[rgba(var(--primary-rgb),0.35)] hover:shadow-lg transition-all duration-300 group">
                        <div className="space-y-3.5">
                          <div className="flex items-center justify-between border-b border-[var(--glass-border)] pb-2.5">
                            <span className="text-[10px] uppercase tracking-widest text-[var(--primary-color)] font-bold flex items-center gap-1.5">
                              <User size={13} />
                              {isHindiRoute ? "सम्बन्धित सन्त" : "Related Saint"}
                            </span>
                          </div>

                          <div className="flex items-center gap-3">
                            {relatedSaint.imageUrl ? (
                              <img
                                src={relatedSaint.imageUrl}
                                alt={relatedSaint.name}
                                width={42}
                                height={42}
                                className="w-10 h-10 rounded-full object-cover border border-[rgba(var(--primary-rgb),0.3)] shadow-sm"
                              />
                            ) : (
                              <div className="w-10 h-10 rounded-full bg-[rgba(var(--primary-rgb),0.12)] border border-[rgba(var(--primary-rgb),0.25)] flex items-center justify-center text-[var(--primary-color)] font-bold text-xs shrink-0">
                                {getInitials(relatedSaint.name)}
                              </div>
                            )}
                            <div className="overflow-hidden">
                              <h3 className="font-bold text-sm text-[var(--text-color)] leading-tight truncate">
                                {isHindiRoute ? relatedSaint.name : relatedSaint.hinglishName}
                              </h3>
                              <span className="text-[9px] text-[var(--primary-color)] opacity-80 font-medium tracking-wider block mt-0.5 uppercase">
                                {isHindiRoute ? "रसिक सन्त" : "Rasik Sant"}
                              </span>
                            </div>
                          </div>

                          <p className="text-[11px] text-stone-600 dark:text-white/60 leading-relaxed line-clamp-2">
                            {relatedSaint.biography
                              ? relatedSaint.biography.substring(0, 95).trim() + '...'
                              : (isHindiRoute ? 'संत का जीवन चरित्र एवं दिव्य वाणी।' : 'Explore saint\'s legacy.')}
                          </p>
                        </div>

                        <Link
                          to={isHindiRoute ? `/hi/saints/${relatedSaint.slug}` : `/saints/${relatedSaint.slug}`}
                          className="w-full text-center text-[11px] font-bold text-[var(--primary-color)] bg-[rgba(var(--primary-rgb),0.08)] hover:bg-[rgba(var(--primary-rgb),0.18)] border border-[rgba(var(--primary-rgb),0.2)] rounded-xl py-2 transition-all mt-4 block"
                        >
                          {isHindiRoute ? "जीवनी पढ़ें →" : "Read Biography →"}
                        </Link>
                      </div>
                    )}

                    {/* Related Grantha Card */}
                    {relatedBook && (
                      <div className="glass-card p-5 rounded-2xl border border-[var(--glass-border)] bg-[var(--glass-bg)] flex flex-col justify-between hover:border-[rgba(var(--primary-rgb),0.35)] hover:shadow-lg transition-all duration-300 group">
                        <div className="space-y-3.5">
                          <div className="flex items-center justify-between border-b border-[var(--glass-border)] pb-2.5">
                            <span className="text-[10px] uppercase tracking-widest text-[var(--primary-color)] font-bold flex items-center gap-1.5">
                              <BookOpen size={13} />
                              {isHindiRoute ? "सम्बन्धित ग्रन्थ" : "Related Scripture"}
                            </span>
                          </div>

                          <div className="flex items-center gap-3">
                            <div className="w-10 h-10 rounded-xl bg-[rgba(var(--primary-rgb),0.12)] border border-[rgba(var(--primary-rgb),0.25)] flex items-center justify-center text-[var(--primary-color)] shrink-0">
                              <BookOpen size={18} />
                            </div>
                            <div className="overflow-hidden">
                              <h3 className="font-bold text-sm text-[var(--text-color)] leading-tight truncate">
                                {relatedBook.name}
                              </h3>
                              <span className="text-[9px] text-[var(--primary-color)] opacity-80 font-medium tracking-wider block mt-0.5 uppercase">
                                {isHindiRoute ? "पावन ग्रन्थ" : "Sacred Text"}
                              </span>
                            </div>
                          </div>

                          <p className="text-[11px] text-stone-600 dark:text-white/60 leading-relaxed line-clamp-2">
                            {isHindiRoute
                              ? `${relatedBook.name} के दिव्य पद और पद्यावली।`
                              : `Spiritual collection of ${relatedBook.name}.`}
                          </p>
                        </div>

                        <Link
                          to={isHindiRoute ? `/hi/granthas/${relatedBook.slug}` : `/granthas/${relatedBook.slug}`}
                          className="w-full text-center text-[11px] font-bold text-[var(--primary-color)] bg-[rgba(var(--primary-rgb),0.08)] hover:bg-[rgba(var(--primary-rgb),0.18)] border border-[rgba(var(--primary-rgb),0.2)] rounded-xl py-2 transition-all mt-4 block"
                        >
                          {isHindiRoute ? "ग्रन्थ पाठ →" : "Read Scripture →"}
                        </Link>
                      </div>
                    )}

                    {/* Related Raga Card */}
                    {relatedRaga && (
                      <div className="glass-card p-5 rounded-2xl border border-[var(--glass-border)] bg-[var(--glass-bg)] flex flex-col justify-between hover:border-[rgba(var(--primary-rgb),0.35)] hover:shadow-lg transition-all duration-300 group">
                        <div className="space-y-3.5">
                          <div className="flex items-center justify-between border-b border-[var(--glass-border)] pb-2.5">
                            <span className="text-[10px] uppercase tracking-widest text-[var(--primary-color)] font-bold flex items-center gap-1.5">
                              <Music size={13} />
                              {isHindiRoute ? "सम्बन्धित राग" : "Related Raga"}
                            </span>
                          </div>

                          <div className="flex items-center gap-3">
                            <div className="w-10 h-10 rounded-xl bg-[rgba(var(--primary-rgb),0.12)] border border-[rgba(var(--primary-rgb),0.25)] flex items-center justify-center text-[var(--primary-color)] shrink-0">
                              <Music size={18} />
                            </div>
                            <div className="overflow-hidden">
                              <h3 className="font-bold text-sm text-[var(--text-color)] leading-tight truncate">
                                {relatedRaga.name}
                              </h3>
                              <span className="text-[9px] text-[var(--primary-color)] opacity-80 font-medium tracking-wider block mt-0.5 uppercase">
                                {isHindiRoute ? "शास्त्रीय राग" : "Classical Raga"}
                              </span>
                            </div>
                          </div>

                          <p className="text-[11px] text-stone-600 dark:text-white/60 leading-relaxed line-clamp-2">
                            {isHindiRoute
                              ? `${relatedRaga.name} में संकलित रस पद एवं कीर्तन।`
                              : `Verses composed in ${relatedRaga.name}.`}
                          </p>
                        </div>

                        <Link
                          to={isHindiRoute ? `/hi/ragas/${relatedRaga.slug || slugify(relatedRaga.name)}` : `/ragas/${relatedRaga.slug || slugify(relatedRaga.name)}`}
                          className="w-full text-center text-[11px] font-bold text-[var(--primary-color)] bg-[rgba(var(--primary-rgb),0.08)] hover:bg-[rgba(var(--primary-rgb),0.18)] border border-[rgba(var(--primary-rgb),0.2)] rounded-xl py-2 transition-all mt-4 block"
                        >
                          {isHindiRoute ? "राग पद देखें →" : "Explore Raga →"}
                        </Link>
                      </div>
                    )}

                    {/* Core Concepts Badges */}
                    {detectedConcepts && detectedConcepts.length > 0 && (
                      <div className="glass-card p-5 rounded-2xl border border-[var(--glass-border)] bg-[var(--glass-bg)] flex flex-col justify-between hover:border-[rgba(var(--primary-rgb),0.35)] hover:shadow-lg transition-all duration-300">
                        <div className="space-y-3.5 w-full">
                          <div className="flex items-center justify-between border-b border-[var(--glass-border)] pb-2.5">
                            <span className="text-[10px] uppercase tracking-widest text-[var(--primary-color)] font-bold flex items-center gap-1.5">
                              <Sparkles size={13} />
                              {isHindiRoute ? "प्रमुख अवधारणाएँ" : "Core Concepts"}
                            </span>
                          </div>

                          <div className="flex flex-wrap gap-1.5 pt-1 max-h-[110px] overflow-y-auto pr-1 custom-scrollbar">
                            {detectedConcepts.map(c => (
                              <Link
                                key={c.slug}
                                to={isHindiRoute ? `/hi/glossary/${c.slug}` : `/glossary/${c.slug}`}
                                className="px-2.5 py-1 rounded-xl bg-[rgba(var(--primary-rgb),0.08)] hover:bg-[rgba(var(--primary-rgb),0.18)] border border-[rgba(var(--primary-rgb),0.2)] text-[10px] font-bold text-[var(--primary-color)] transition-all select-none"
                              >
                                {isHindiRoute ? c.devanagari || c.term : c.term}
                              </Link>
                            ))}
                          </div>
                        </div>
                      </div>
                    )}
                  </div>
                </section>
              )}

              {/* Section 2: Recommended Verses Cards Grid */}
              {relatedVerses && relatedVerses.length > 0 && (
                <section>
                  <div className="flex items-center justify-between mb-8">
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-full bg-[rgba(var(--primary-rgb),0.12)] border border-[rgba(var(--primary-rgb),0.25)] flex items-center justify-center text-[var(--primary-color)]">
                        <FileText size={16} />
                      </div>
                      <div>
                        <h2 className="text-lg sm:text-xl font-bold text-[var(--text-color)] font-headings">
                          {isHindiRoute ? "संस्तुत पावन पद एवं पद्यावली" : "Recommended Verses & Passages"}
                        </h2>
                        <p className="text-xs text-stone-500 dark:text-white/40">
                          {isHindiRoute ? "आपकी रुचि एवं भाव के अनुसार चुनिंदा पद" : "Handpicked spiritual compositions matching your current context"}
                        </p>
                      </div>
                    </div>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
                    {relatedVerses.map((relObj, idx) => {
                      const v = relObj.item || relObj;
                      const matchReason = relObj.matchReason || (isHindiRoute ? "सम्बन्धित पद" : "Related Passage");
                      const authorName = v.author || 'श्री रसिकाचार्य';
                      const cleanTitle = v.cleanTitle || v.title;
                      const previewText = (() => {
                        const raw = v.hindi_text || v.sanskrit_text || '';
                        if (!raw) return '';
                        const lines = raw.split(/\r?\n/).map(l => l.trim()).filter(l => l && !l.startsWith('—') && !l.startsWith('-'));
                        return lines.slice(0, 2).join(' ') || cleanTitle;
                      })();

                      return (
                        <Link
                          key={v.id || idx}
                          to={isHindiRoute ? `/hi/lyrics/${v.slug || v.id}` : `/lyrics/${v.slug || v.id}`}
                          className="glass-card p-5 rounded-2xl border border-[var(--glass-border)] bg-[var(--glass-bg)] hover:border-[rgba(var(--primary-rgb),0.4)] hover:shadow-xl transition-all duration-300 flex flex-col justify-between group"
                        >
                          <div className="space-y-3">
                            {/* Card Header Meta */}
                            <div className="flex items-center justify-between gap-2">
                              <span className="text-[10px] font-bold px-2.5 py-0.5 rounded-full bg-[rgba(var(--primary-rgb),0.12)] text-[var(--primary-color)] border border-[rgba(var(--primary-rgb),0.25)]">
                                {matchReason}
                              </span>
                              <span className={`sacred-badge text-[9px] py-0.5 px-2 ${getCategoryBadgeClass(v.category)}`}>
                                {v.category}
                              </span>
                            </div>

                            {/* Title */}
                            <h3 className="font-bold text-base text-[var(--text-color)] group-hover:text-[var(--primary-color)] transition-colors font-headings leading-snug line-clamp-1">
                              {cleanTitle}
                            </h3>

                            {/* Author */}
                            <div className="flex items-center gap-2 text-xs text-stone-600 dark:text-white/60">
                              <div className="w-5 h-5 rounded-full bg-[rgba(var(--primary-rgb),0.1)] text-[var(--primary-color)] font-bold text-[9px] flex items-center justify-center shrink-0">
                                {getInitials(authorName)}
                              </div>
                              <span className="truncate font-medium">{authorName}</span>
                            </div>

                            {/* Verse Snippet */}
                            {previewText && (
                              <p className="text-xs text-stone-500 dark:text-white/50 italic leading-relaxed line-clamp-2 pt-1 border-t border-[var(--glass-border)]">
                                "{previewText}"
                              </p>
                            )}
                          </div>

                          {/* Footer Action */}
                          <div className="mt-4 pt-3 border-t border-[var(--glass-border)] flex items-center justify-between text-xs font-semibold text-[var(--primary-color)]">
                            <span>{isHindiRoute ? "पद पढ़ें" : "Read Verse"}</span>
                            <ArrowRight size={14} />
                          </div>
                        </Link>
                      );
                    })}
                  </div>
                </section>
              )}
            </div>
          );
        })()}

      </div>

      {isPaathMode && (
        <div
          className={`fixed inset-0 z-[99999] overflow-y-auto transition-all duration-300 ${paathTheme === 'sepia'
              ? 'bg-[#f5ebd6] text-[#2c2212]'
              : 'bg-[#09090b] text-[#e3ded0]'
            }`}
          style={{ fontFamily: "'Noto Serif Devanagari', 'Tiro Devanagari Sanskrit', serif" }}
        >
          {/* Controls Header */}
          <div className={`sticky top-0 z-[100000] w-full px-6 py-4 flex items-center justify-between backdrop-blur-md border-b ${paathTheme === 'sepia'
              ? 'bg-[#f5ebd6]/90 border-[#2c2212]/10'
              : 'bg-[#09090b]/90 border-[#e3ded0]/10'
            }`}>
            <div className="flex items-center gap-3">
              <button
                onClick={() => {
                  setIsPaathMode(false);
                  try {
                    if (document.fullscreenElement) {
                      document.exitFullscreen().catch(() => { });
                    }
                  } catch (e) { }
                }}
                className={`flex items-center gap-2 px-4 py-2 rounded-full border text-xs font-semibold ${paathTheme === 'sepia'
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
                  className={`px-3 py-1 rounded-full text-xs font-semibold flex items-center gap-1 transition-all ${paathTheme === 'sepia'
                      ? 'bg-[#2c2212] text-[#f5ebd6]'
                      : 'opacity-50'
                    }`}
                >
                  <Sun size={12} />
                  <span>{isHindiRoute ? 'पीताम्बर' : 'Sepia'}</span>
                </button>
                <button
                  onClick={() => setPaathTheme('dark')}
                  className={`px-3 py-1 rounded-full text-xs font-semibold flex items-center gap-1 transition-all ${paathTheme === 'dark'
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
          <div className="max-w-3xl mx-auto px-6 py-12 md:py-20 flex flex-col items-center text-center">
            {/* Header metadata */}
            <div className="mb-12 flex flex-col items-center gap-3">
              <span className={`text-[11px] uppercase tracking-[0.2em] font-semibold border px-3 py-1 rounded-full ${paathTheme === 'sepia' ? 'border-[#2c2212]/20' : 'border-[#e3ded0]/20'
                }`}>
                {content.category}
              </span>
              {(() => {
                const displayAuthorName = effectiveSaintName;
                const saintSlug = getNormalizedSaintSlug(displayAuthorName);
                return (
                  <div className="text-center mt-2">
                    <span className="text-[10px] uppercase tracking-[0.25em] font-bold block opacity-40 mb-1">
                      {isHindiRoute ? 'रचयिता / संत' : 'Author / Saint'}
                    </span>
                    {saintSlug ? (
                      <Link
                        to={isHindiRoute ? `/hi/saints/${saintSlug}` : `/saints/${saintSlug}`}
                        className="text-xl md:text-2xl font-bold font-headings tracking-wide text-[var(--primary-color)] hover:underline transition-all"
                      >
                        {displayAuthorName}
                      </Link>
                    ) : (
                      <span className="text-xl md:text-2xl font-bold font-headings tracking-wide text-[var(--primary-color)]">
                        {displayAuthorName}
                      </span>
                    )}
                  </div>
                );
              })()}
            </div>

            {/* Title */}
            <h1 className="text-3xl md:text-5xl font-bold mb-16 leading-[1.3]">
              {content.title}
            </h1>

            {/* Verse Texts */}
            <div className="w-full space-y-20">
              {content.sanskrit_text ? (
                <div className="space-y-6 w-full">
                  <div className="text-[10px] uppercase tracking-[0.3em] font-bold opacity-30">मूल पाठ (Sanskrit)</div>
                  <div className="w-full" style={{ containerType: 'inline-size' }}>
                    <AutoFitVerse
                      text={content.sanskrit_text}
                      sizeLevel={sizeLevel}
                      fontStyle={settings.fontStyle}
                      isHindiRoute={isHindiRoute}
                      centered={true}
                      className="content-verse-text hindi-text"
                    />
                  </div>
                </div>
              ) : (
                content.title && (
                  <div className="space-y-4 w-full text-center py-6">
                    <div className="text-[10px] uppercase tracking-[0.3em] font-bold opacity-30">{isHindiRoute ? 'प्रथम पंक्ति' : 'Opening Line'}</div>
                    <div className="text-xl font-semibold italic text-current/90">
                      "{extractFirstLine(content.title)}"
                    </div>
                  </div>
                )
              )}

              {(transliteratedSanskrit || transliteratedHindi) && (
                <div className="space-y-6 pt-10 border-t border-current/5 w-full">
                  <div className="text-[10px] uppercase tracking-[0.3em] font-bold opacity-30">रोमन पाठ (Romanized)</div>
                  <div className="w-full" style={{ containerType: 'inline-size' }}>
                    <AutoFitVerse
                      text={transliteratedSanskrit || transliteratedHindi}
                      sizeLevel={sizeLevel}
                      fontStyle={settings.fontStyle}
                      isHindiRoute={isHindiRoute}
                      centered={true}
                      className="content-verse-text"
                      isRoman={true}
                    />
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
