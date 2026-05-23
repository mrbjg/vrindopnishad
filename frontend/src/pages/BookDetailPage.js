import React, { useState, useEffect, useContext } from 'react';
import { useParams, Link, useLocation } from 'react-router-dom';
import { ApiContext } from '../App';
import { extractRelations } from '../utils/relations';
import { ArrowLeft, FileText, Music, User } from 'lucide-react';
import { Helmet } from 'react-helmet-async';

const BookDetailPage = () => {
  const { slug } = useParams();
  const location = useLocation();
  const isHindiRoute = location.pathname.startsWith('/hi');
  const { apiService } = useContext(ApiContext);

  const [book, setBook] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let active = true;
    const load = async () => {
      try {
        const allItems = await apiService.getAllContent(null, 10000);
        const relations = extractRelations(allItems);
        const foundBook = relations.books.find(b => b.slug === slug);
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
  }, [slug, apiService]);

  if (loading) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-12 animate-pulse space-y-6">
        <div className="h-6 bg-white/10 rounded w-24" />
        <div className="h-10 bg-white/10 rounded w-1/3" />
        <div className="h-4 bg-white/5 rounded w-1/4" />
        <div className="space-y-4 pt-8">
          {[1, 2, 3].map(i => (
            <div key={i} className="h-24 bg-white/5 rounded-xl w-full" />
          ))}
        </div>
      </div>
    );
  }

  if (!book) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-24 text-center">
        <h2 className="text-3xl font-bold mb-4 font-headings">Book not found</h2>
        <p className="text-white/40 mb-8">The scripture you are looking for does not exist in our library.</p>
        <Link to={isHindiRoute ? "/hi/books" : "/books"} className="btn-premium px-8 py-3">
          Explore All Books
        </Link>
      </div>
    );
  }

  return (
    <div className="animate-fade-in max-w-4xl mx-auto px-4 py-8">
      <Helmet>
        <title>{isHindiRoute ? `${book.name} ग्रन्थ पाठ एवं अनुवाद | Vrindopnishad` : `${book.hinglishName} Texts & Translation | Vrindopnishad`}</title>
        <meta name="description" content={`Read the sacred verses from ${book.hinglishName} with Hindi explanation, translation and audio chanting.`} />
        <link rel="canonical" href={isHindiRoute ? `https://path.vrindopnishad.in/hi/book/${slug}` : `https://path.vrindopnishad.in/book/${slug}`} />
      </Helmet>

      <Link 
        to={isHindiRoute ? "/hi/books" : "/books"} 
        className="inline-flex items-center gap-2 text-white/40 hover:text-white mb-8 transition-colors text-xs uppercase tracking-wider"
      >
        <ArrowLeft size={14} />
        {isHindiRoute ? "सभी ग्रन्थ" : "All Books"}
      </Link>

      <div className="mb-10 pb-8 border-b border-white/5">
        <span className="text-[10px] uppercase tracking-[0.25em] text-primary font-bold block mb-2">Sacred Scripture</span>
        <h1 className="text-3xl md:text-5xl font-bold font-headings text-sacred-gradient mb-3">
          {book.name}
        </h1>
        {book.author && (
          <div className="flex items-center gap-2 mt-3 text-white/60 text-sm">
            <User size={14} className="text-primary" />
            <span>Author:</span>
            {book.authorSlug ? (
              <Link to={isHindiRoute ? `/hi/saint/${book.authorSlug}` : `/saint/${book.authorSlug}`} className="text-primary hover:underline font-medium">
                {book.author}
              </Link>
            ) : (
              <span className="font-medium text-white/80">{book.author}</span>
            )}
          </div>
        )}
      </div>

      <section>
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-bold font-headings text-minimal-gold flex items-center gap-2">
            <FileText size={20} className="text-primary" />
            {isHindiRoute ? "ग्रन्थ के पद एवं श्लोक" : "Verses & Passages"}
          </h2>
          <span className="text-xs text-white/30">
            {book.verses.length} {book.verses.length === 1 ? 'item' : 'items'}
          </span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {book.verses.map((verse) => (
            <Link
              key={verse.id}
              to={isHindiRoute ? `/hi/content/${verse.slug || verse.id}` : `/content/${verse.slug || verse.id}`}
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
