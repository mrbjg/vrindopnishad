'use client';

import React, { useState, useEffect, useContext } from 'react';
import { useParams, Link, useLocation } from 'react-router-dom';
import { ApiContext } from '../contexts/ClientProviders';
import { extractRelations } from '../utils/relations';
import { ArrowLeft, FileText, Music, User, Bookmark } from 'lucide-react';
import { Helmet } from 'react-helmet-async';
import PageSkeleton from '../components/ui/PageSkeleton';

const BookDetailPage = ({ initialBook }) => {
  const params = useParams();
  const slug = params?.slug || '';
  const location = useLocation();
  const isHindiRoute = location.pathname.startsWith('/hi');
  const { apiService } = useContext(ApiContext);

  const [book, setBook] = useState(initialBook || (() => {
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
    } catch (e) {}
    return null;
  }));
  const [loading, setLoading] = useState(() => {
    if (initialBook) return false;
    try {
      const memCached = apiService.getMemoryCachedItems();
      if (memCached) {
        const relations = extractRelations(memCached);
        if (relations && relations.books.length > 0) {
          return !relations.books.find(b => b.slug === slug);
        }
      }
    } catch (e) {}
    return true;
  });

  useEffect(() => {
    let active = true;

    if (initialBook) {
      setBook(initialBook);
      setLoading(false);
      return;
    }

    const getInitialBook = () => {
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
      } catch (e) {}
      return null;
    };

    const cachedBook = getInitialBook();
    setBook(cachedBook);
    setLoading(cachedBook === null);

    const load = async () => {
      try {
        const relations = await apiService.getRelations();
        const foundBook = relations.books.find(b => b.slug === slug);
        if (foundBook) {
          const allContent = await apiService.getAllContent(null, 5000);
          const contentMap = new Map(allContent.map(item => [item.id ? item.id.toString() : '', item]));
          foundBook.verses = (foundBook.verseIds || [])
            .map(id => contentMap.get(id?.toString()))
            .filter(Boolean);
        }
        if (active) {
          setBook(foundBook || null);
        }
      } catch (error) {
        console.error('Error loading book details:', error);
      } finally {
        if (active) setLoading(false);
      }
    };
    load();
    return () => { active = false; };
  }, [slug, apiService, initialBook]);

  const [isBookmarked, setIsBookmarked] = useState(false);

  useEffect(() => {
    if (book) {
      try {
        const saved = localStorage.getItem('vrindopnishad_bookmarks');
        const bookmarks = saved ? JSON.parse(saved) : [];
        const found = bookmarks.some(b => b.type === 'book' && b.slug === book.slug);
        setIsBookmarked(found);
      } catch (e) {}
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
          className={`flex items-center gap-2 px-5 py-2.5 rounded-full border transition-all text-xs font-semibold shrink-0 self-start md:self-auto ${
            isBookmarked 
              ? 'bg-primary/10 border-primary/30 text-primary' 
              : 'bg-white/5 border-white/10 hover:border-white/20 text-white/85 hover:text-white'
          }`}
        >
          <Bookmark size={14} className={isBookmarked ? 'fill-current' : ''} />
          <span>{isBookmarked ? (isHindiRoute ? 'सूची में सहेजा गया' : 'Saved to List') : (isHindiRoute ? 'पाठ सूची में जोड़ें' : 'Add to Bookmarks')}</span>
        </button>
      </div>

      <section>
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-bold font-headings text-minimal-gold flex items-center gap-2">
            <FileText size={20} className="text-primary" />
            {isHindiRoute ? "ग्रन्थ के पद एवं श्लोक" : "Verses & Passages"}
          </h2>
          <span className="text-xs text-white/30">
            {(book.verses || book.verseIds || []).length} {(book.verses || book.verseIds || []).length === 1 ? 'item' : 'items'}
          </span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {(book.verses || []).map((verse) => (
            <Link
              key={verse.id}
              to={isHindiRoute ? `/hi/lyrics/${verse.slug || verse.id}` : `/lyrics/${verse.slug || verse.id}`}
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
                <h3 className="font-bold text-base text-white/90 group-hover:text-primary transition-colors leading-snug line-clamp-1 py-1">
                  {verse.cleanTitle}
                </h3>
              </div>
              <p className="text-white/40 text-xs line-clamp-2 leading-relaxed mt-2">
                {verse.hindi_text || verse.english_translation || verse.description}
              </p>
            </Link>
          ))}
        </div>
      </section>
    </div>
  );
};

export default BookDetailPage;
