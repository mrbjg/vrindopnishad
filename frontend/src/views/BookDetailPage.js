'use client';

import React, { useState, useEffect, useContext } from 'react';
import { useParams, Link, useLocation } from 'react-router-dom';
import { ApiContext } from '../contexts/ClientProviders';
import { extractRelations } from '../utils/relations';
import { ArrowLeft, FileText, Music, User, Bookmark, ChevronDown, ChevronUp, Search } from 'lucide-react';
import { Helmet } from 'react-helmet-async';
import PageSkeleton from '../components/ui/PageSkeleton';
import { useSWR } from '../hooks/useSWR';

const BookDetailPage = ({ initialBook }) => {
  const params = useParams();
  const slug = params?.slug || '';
  const location = useLocation();
  const isHindiRoute = location.pathname.startsWith('/hi');
  const { apiService } = useContext(ApiContext);

  const [book, setBook] = useState(initialBook || (() => {
    if (typeof window !== 'undefined' && location.state?.item) {
      return location.state.item;
    }
    try {
      const memCached = apiService.getMemoryCachedItems();
      if (memCached) {
        const relations = extractRelations(memCached);
        if (relations && relations.books.length > 0) {
          const found = relations.books.find(b => b.slug === slug) || null;
          if (found && found.verseIds && !found.verses) {
            const contentMap = new Map(memCached.map(item => [item.id ? item.id.toString() : '', item]));
            found.verses = found.verseIds.map(id => contentMap.get(id?.toString())).filter(Boolean);
          }
          return found;
        }
      }
    } catch (e) { }
    return null;
  }));
  const [loading, setLoading] = useState(() => {
    if (initialBook) return false;
    return !book;
  });

  const { data: fetchedBook } = useSWR(
    slug ? `book_${slug}` : null,
    async () => {
      return await apiService.getBookBySlug(slug);
    },
    {
      initialData: book,
      dedupingInterval: 3000
    }
  );

  useEffect(() => {
    if (fetchedBook) {
      setBook(fetchedBook);
      setLoading(false);
    }
  }, [fetchedBook]);

  useEffect(() => {
    if (initialBook) {
      setBook(initialBook);
      setLoading(false);
      return;
    }
    if (book) {
      setLoading(false);
    }
  }, [slug, initialBook]);

  const [isBookmarked, setIsBookmarked] = useState(false);
  const [activeSkandhaKey, setActiveSkandhaKey] = useState(null);
  const [expandedChapters, setExpandedChapters] = useState({});
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    if (book) {
      try {
        const saved = localStorage.getItem('vrindopnishad_bookmarks');
        const bookmarks = saved ? JSON.parse(saved) : [];
        const found = bookmarks.some(b => b.type === 'book' && b.slug === book.slug);
        setIsBookmarked(found);
      } catch (e) { }
    }
  }, [book]);

  const toggleBookmark = () => {
    try {
      const saved = localStorage.getItem('vrindopnishad_bookmarks');
      let bookmarks = saved ? JSON.parse(saved) : [];
      if (isBookmarked) {
        bookmarks = bookmarks.filter(b => !(b.type === 'book' && b.slug === book.slug));
        setIsBookmarked(false);
      } else {
        bookmarks.push({
          type: 'book',
          slug: book.slug,
          name: book.name,
          author: book.author,
          addedAt: new Date().toISOString()
        });
        setIsBookmarked(true);
      }
      localStorage.setItem('vrindopnishad_bookmarks', JSON.stringify(bookmarks));
    } catch (e) {
      console.error(e);
    }
  };

  if (loading) {
    return <PageSkeleton variant="granth" />;
  }

  if (!book) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-24 text-center">
        <h2 className="text-3xl font-bold mb-4 font-headings">Book not found</h2>
        <p className="text-white/40 mb-8">The scripture you are looking for does not exist in our library.</p>
        <Link to={isHindiRoute ? "/hi/granthas" : "/granthas"} className="btn-premium px-8 py-3">
          Explore All Books
        </Link>
      </div>
    );
  }

  const bookHinglishName = book.hinglishName || book.name;
  const verses = book.verses || [];

  // Grouping & Sorting Helper Functions
  const getNumericPart = (str) => {
    if (!str) return null;
    const match = str.match(/\d+/);
    return match ? parseInt(match[0], 10) : null;
  };

  const getHindiNumericPart = (str) => {
    if (!str) return null;
    const map = {
      "प्रथम": 1, "द्वितीय": 2, "तृतीय": 3, "चतुर्थ": 4, "पंचम": 5, "षष्ठ": 6, "सप्तम": 7, "अष्टम": 8, "नवम": 9, "दशम": 10,
      "बालकाण्ड": 1, "अयोध्याकाण्ड": 2, "अरण्यकाण्ड": 3, "किष्किंधाकाण्ड": 4, "सुंदरकाण्ड": 5, "लंकाकाण्ड": 6, "उत्तरकाण्ड": 7,
      "बाल": 1, "अयोध्या": 2, "अरण्य": 3, "किष्किंधा": 4, "सुंदर": 5, "युद्ध": 6, "उत्तर": 7
    };
    for (const key in map) {
      if (str.includes(key)) {
        return map[key];
      }
    }
    return null;
  };

  const sortKeys = (keys) => {
    return [...keys].sort((a, b) => {
      const numA = getNumericPart(a) || getHindiNumericPart(a) || 999;
      const numB = getNumericPart(b) || getHindiNumericPart(b) || 999;
      if (numA !== numB) return numA - numB;
      return a.localeCompare(b);
    });
  };

  // Filter verses based on query
  const filteredVerses = verses.filter(v => {
    if (!searchQuery) return true;
    const query = searchQuery.toLowerCase().trim();
    const title = (v.title || '').toLowerCase();
    const sanskrit = (v.sanskrit_text || '').toLowerCase();
    const hindi = (v.hindi_text || '').toLowerCase();
    return title.includes(query) || sanskrit.includes(query) || hindi.includes(query);
  });

  // Nest verses into groups: Skandha -> Chapter -> Verses
  const groups = {};
  filteredVerses.forEach(v => {
    let skandhaKey = "99";
    let skandhaName = isHindiRoute ? "सभी अध्याय" : "All Chapters";
    let chapterKey = "1";
    let chapterName = isHindiRoute ? "अध्याय 1" : "Chapter 1";

    const tags = v.tags || [];
    const title = v.title || "";

    const skandhaTag = tags.find(t =>
      t.includes("स्कन्ध") || t.includes("काण्ड") ||
      t.toLowerCase().includes("skand") || t.toLowerCase().includes("kand")
    );
    if (skandhaTag) {
      // Normalize double tags like "बालकाण्ड काण्ड"
      skandhaName = skandhaTag.replace(/\s*काण्ड\s*काण्ड/g, 'काण्ड').replace(/\s*स्कन्ध\s*स्कन्ध/g, 'स्कन्ध').trim();
      skandhaKey = skandhaTag;
    }

    const chapterTag = tags.find(t =>
      t.includes("अध्याय") || t.includes("सर्ग") ||
      t.toLowerCase().includes("adhyay") || t.toLowerCase().includes("sarga") ||
      t.toLowerCase().includes("chapter")
    );
    if (chapterTag) {
      chapterName = chapterTag;
      chapterKey = chapterTag;
    }

    if (!groups[skandhaKey]) {
      groups[skandhaKey] = {
        name: skandhaName,
        chapters: {}
      };
    }

    if (!groups[skandhaKey].chapters[chapterKey]) {
      groups[skandhaKey].chapters[chapterKey] = {
        name: chapterName,
        verses: []
      };
    }

    groups[skandhaKey].chapters[chapterKey].verses.push(v);
  });

  const sortedSkandhaKeys = sortKeys(Object.keys(groups));
  const isSingleDefaultSkandha = sortedSkandhaKeys.length === 1 && sortedSkandhaKeys[0] === "99";

  // Auto-manage active skandha selection
  useEffect(() => {
    if (sortedSkandhaKeys.length > 0) {
      if (!activeSkandhaKey || !groups[activeSkandhaKey]) {
        setActiveSkandhaKey(sortedSkandhaKeys[0]);
      }
    } else {
      setActiveSkandhaKey(null);
    }
  }, [book, searchQuery, activeSkandhaKey]);

  // Auto-expand first chapter when active skandha or book changes
  useEffect(() => {
    if (activeSkandhaKey && groups[activeSkandhaKey]) {
      const chKeys = sortKeys(Object.keys(groups[activeSkandhaKey].chapters));
      if (chKeys.length > 0) {
        setExpandedChapters(prev => {
          if (chKeys.length === 1 || isSingleDefaultSkandha || !Object.keys(prev).length) {
            return { ...prev, [chKeys[0]]: true };
          }
          return prev;
        });
      }
    }
  }, [activeSkandhaKey, isSingleDefaultSkandha, book]);

  const toggleChapter = (chapterKey) => {
    setExpandedChapters(prev => ({
      ...prev,
      [chapterKey]: !prev[chapterKey]
    }));
  };

  return (
    <div className="animate-fade-in max-w-4xl mx-auto px-4 py-8">
      <Helmet>
        <title>{isHindiRoute ? `${book.name} ग्रन्थ पाठ एवं अनुवाद | Vrindopnishad` : `${bookHinglishName} Texts & Translation | Vrindopnishad`}</title>
        <meta name="description" content={`Read the sacred verses from ${bookHinglishName} with Hindi explanation, translation and audio chanting.`} />
        <link rel="canonical" href={isHindiRoute ? `https://path.vrindopnishad.in/hi/granthas/${slug}` : `https://path.vrindopnishad.in/granthas/${slug}`} />

        <script type="application/ld+json">
          {JSON.stringify({
            "@context": "https://schema.org",
            "@graph": [
              {
                "@type": "Book",
                "@id": `https://path.vrindopnishad.in/granthas/${slug}#book`,
                "name": book.name,
                "alternateName": bookHinglishName,
                "author": book.author ? {
                  "@type": "Person",
                  "name": book.author,
                  "url": book.authorSlug ? `https://path.vrindopnishad.in/saints/${book.authorSlug}` : undefined
                } : undefined,
                "url": `https://path.vrindopnishad.in/granthas/${slug}`,
                "inLanguage": isHindiRoute ? ["hi", "sa"] : ["en", "hi-Latn", "sa"],
                "description": `Read the sacred verses from ${bookHinglishName} with translations, commentaries and audio chanting.`
              },
              {
                "@type": "BreadcrumbList",
                "@id": `https://path.vrindopnishad.in/granthas/${slug}#breadcrumb`,
                "itemListElement": [
                  {
                    "@type": "ListItem",
                    "position": 1,
                    "name": isHindiRoute ? "होम" : "Home",
                    "item": isHindiRoute ? "https://path.vrindopnishad.in/hi" : "https://path.vrindopnishad.in/"
                  },
                  {
                    "@type": "ListItem",
                    "position": 2,
                    "name": isHindiRoute ? "ग्रन्थ" : "Books",
                    "item": isHindiRoute ? "https://path.vrindopnishad.in/hi/granthas" : "https://path.vrindopnishad.in/granthas"
                  },
                  {
                    "@type": "ListItem",
                    "position": 3,
                    "name": isHindiRoute ? book.name : bookHinglishName,
                    "item": isHindiRoute ? `https://path.vrindopnishad.in/hi/granthas/${slug}` : `https://path.vrindopnishad.in/granthas/${slug}`
                  }
                ]
              }
            ]
          })}
        </script>
      </Helmet>

      <Link
        to={isHindiRoute ? "/hi/granthas" : "/granthas"}
        className="inline-flex items-center gap-2 text-white/40 hover:text-white mb-8 transition-colors text-xs uppercase tracking-wider"
      >
        <ArrowLeft size={14} />
        {isHindiRoute ? "सभी ग्रन्थ" : "All Books"}
      </Link>

      <div className="mb-10 pb-8 border-b border-white/5 flex flex-col md:flex-row md:items-end justify-between gap-6">
        <div>
          <span className="text-[10px] uppercase tracking-[0.25em] text-primary font-bold block mb-2">Sacred Scripture</span>
          <h1 className="text-3xl md:text-5xl font-bold font-headings text-sacred-gradient mb-3">
            {book.name}
          </h1>
          {book.author && (
            <div className="flex items-center gap-2 mt-3 text-white/60 text-sm">
              <User size={14} className="text-primary" />
              <span>Author:</span>
              {book.authorSlug ? (
                <Link to={isHindiRoute ? `/hi/saints/${book.authorSlug}` : `/saints/${book.authorSlug}`} className="text-primary hover:underline font-medium">
                  {book.author}
                </Link>
              ) : (
                <span className="font-medium text-white/80">{book.author}</span>
              )}
            </div>
          )}
        </div>

        <button
          onClick={toggleBookmark}
          className={`flex items-center gap-2 px-5 py-2.5 rounded-full border transition-all text-xs font-semibold shrink-0 self-start md:self-auto ${isBookmarked
              ? 'bg-primary/10 border-primary/30 text-primary'
              : 'bg-white/5 border-white/10 hover:border-white/20 text-white/85 hover:text-white'
            }`}
        >
          <Bookmark size={14} className={isBookmarked ? 'fill-current' : ''} />
          <span>{isBookmarked ? (isHindiRoute ? 'सूची में सहेजा गया' : 'Saved to List') : (isHindiRoute ? 'पाठ सूची में जोड़ें' : 'Add to Bookmarks')}</span>
        </button>
      </div>

      <section>
        {/* Dynamic header and count */}
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-bold font-headings text-minimal-gold flex items-center gap-2">
            <FileText size={20} className="text-primary" />
            {isHindiRoute ? "ग्रन्थ के पद एवं श्लोक" : "Verses & Passages"}
          </h2>
          <span className="text-xs text-white/30">
            {filteredVerses.length} {filteredVerses.length === 1 ? 'item' : 'items'}
          </span>
        </div>

        {/* Search input field */}
        <div className="mb-6 relative">
          <input
            type="text"
            placeholder={isHindiRoute ? "शीर्षक, श्लोक या अर्थ खोजें..." : "Search title, verse or meaning..."}
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full bg-white/5 border border-white/10 rounded-xl px-11 py-3 text-sm focus:outline-none focus:border-primary/50 text-white/90 placeholder-white/30 transition-all shadow-inner"
          />
          <Search size={18} className="absolute left-4 top-1/2 -translate-y-1/2 text-white/30" />
          {searchQuery && (
            <button
              onClick={() => setSearchQuery('')}
              className="absolute right-4 top-1/2 -translate-y-1/2 text-white/40 hover:text-white text-xs transition-colors"
            >
              Clear
            </button>
          )}
        </div>

        {/* Skandha selectors: hidden if single general Skandha */}
        {!isSingleDefaultSkandha && sortedSkandhaKeys.length > 0 && (
          <div className="flex gap-2 overflow-x-auto pb-3 mb-6 scrollbar-hide border-b border-white/5">
            {sortedSkandhaKeys.map((sKey) => (
              <button
                key={sKey}
                onClick={() => setActiveSkandhaKey(sKey)}
                className={`px-4 py-2 rounded-lg text-xs font-bold whitespace-nowrap transition-all uppercase tracking-wider ${
                  activeSkandhaKey === sKey
                    ? 'bg-primary/20 border border-primary/40 text-primary'
                    : 'bg-white/5 border border-white/5 hover:bg-white/10 text-white/60 hover:text-white'
                }`}
              >
                {groups[sKey].name}
              </button>
            ))}
          </div>
        )}

        {/* Chapter Accordions */}
        {activeSkandhaKey && groups[activeSkandhaKey] ? (
          <div className="space-y-4">
            {sortKeys(Object.keys(groups[activeSkandhaKey].chapters)).map((chKey) => {
              const ch = groups[activeSkandhaKey].chapters[chKey];
              const isExpanded = !!expandedChapters[chKey];
              return (
                <div key={chKey} className="glass-card overflow-hidden border border-white/5 rounded-xl transition-all">
                  <button
                    onClick={() => toggleChapter(chKey)}
                    className="w-full px-5 py-4 flex items-center justify-between bg-white/[0.02] hover:bg-white/[0.04] transition-colors text-left"
                  >
                    <div className="flex items-center gap-3">
                      <span className="font-bold text-sm font-headings text-minimal-gold">{ch.name}</span>
                      <span className="text-[10px] bg-white/5 px-2 py-0.5 rounded text-white/45">
                        {ch.verses.length} {ch.verses.length === 1 ? 'verse' : 'verses'}
                      </span>
                    </div>
                    {isExpanded ? <ChevronUp size={16} className="text-white/40" /> : <ChevronDown size={16} className="text-white/40" />}
                  </button>

                  {isExpanded && (
                    <div className="p-4 bg-black/10 grid grid-cols-1 md:grid-cols-2 gap-4 border-t border-white/5 animate-slide-down">
                      {ch.verses.map((verse) => (
                        <Link
                          key={verse.id}
                          to={isHindiRoute ? `/hi/lyrics/${verse.slug || verse.id}` : `/lyrics/${verse.slug || verse.id}`}
                          state={{ item: verse }}
                          className="glass-card p-4 flex flex-col justify-between group hover:border-amber-500/20 transition-all min-h-[140px]"
                        >
                          <div>
                            <div className="flex justify-between items-start gap-4 mb-2">
                              <span className="text-[10px] uppercase tracking-wider text-amber-500/80 bg-amber-500/5 px-2 py-0.5 rounded border border-amber-500/10">
                                {verse.category}
                              </span>
                              {verse.audio_url && (
                                <span className="text-sky-400 bg-sky-500/5 border border-sky-500/10 p-1.5 rounded-full hover:scale-105 transition-transform">
                                  <Music size={12} />
                                </span>
                              )}
                            </div>
                            <h3 className="font-bold text-base text-[var(--text-color)] group-hover:text-primary transition-colors leading-snug line-clamp-1 py-1">
                              {verse.cleanTitle || verse.title || verse.name || (isHindiRoute ? 'पद / श्लोक' : 'Passage')}
                            </h3>
                          </div>
                          <p className="text-[var(--text-color)]/60 text-xs line-clamp-2 leading-relaxed mt-2">
                            {verse.sanskrit_text}
                          </p>
                        </Link>
                      ))}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        ) : (
          <div className="text-center py-12 text-white/30 text-sm">
            {isHindiRoute ? "कोई श्लोक या पद नहीं मिला।" : "No verses found."}
          </div>
        )}
      </section>
    </div>
  );
};

export default BookDetailPage;
