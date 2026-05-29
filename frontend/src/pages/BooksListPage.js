import React, { useState, useEffect, useContext, useRef } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { ApiContext } from '../App';
import { extractRelations } from '../utils/relations';
import { Book, ArrowLeft, Search, FileText } from 'lucide-react';
import { Helmet } from 'react-helmet-async';

const BooksListPage = () => {
  const location = useLocation();
  const isHindiRoute = location.pathname.startsWith('/hi');
  const { apiService } = useContext(ApiContext);
  
  const [books, setBooks] = useState(() => {
    try {
      const memCached = apiService.getMemoryCachedItems();
      if (memCached) {
        const relations = extractRelations(memCached);
        if (relations && relations.books.length > 0) return relations.books;
      }
    } catch { }
    return [];
  });
  const [loading, setLoading] = useState(() => {
    try {
      const memCached = apiService.getMemoryCachedItems();
      if (memCached) return false;
    } catch { }
    return true;
  });
  const [searchQuery, setSearchQuery] = useState('');
  const [visibleCount, setVisibleCount] = useState(12);
  const sentinelRef = useRef(null);

  useEffect(() => {
    setVisibleCount(12); 
  }, [searchQuery]);

  useEffect(() => {
    let active = true;
    const load = async () => {
      try {
        const allItems = await apiService.getAllContent(null, 10000);
        const relations = extractRelations(allItems);
        if (active) {
          setBooks(relations.books);
        }
      } catch (error) {
        console.error('Error loading books:', error);
      } finally {
        if (active) setLoading(false);
      }
    };
    load();
    return () => { active = false; };
  }, [apiService]);

  const filteredBooks = books.filter(b => 
    b.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    b.hinglishName.toLowerCase().includes(searchQuery.toLowerCase()) ||
    b.author.toLowerCase().includes(searchQuery.toLowerCase())
  );

  
  useEffect(() => {
    if (loading || filteredBooks.length <= visibleCount) return;

    const observer = new IntersectionObserver((entries) => {
      if (entries[0].isIntersecting) {
        setVisibleCount(prev => prev + 12);
      }
    }, {
      rootMargin: '200px'
    });

    const currentSentinel = sentinelRef.current;
    if (currentSentinel) {
      observer.observe(currentSentinel);
    }

    return () => {
      if (currentSentinel) {
        observer.unobserve(currentSentinel);
      }
    };
  }, [loading, filteredBooks.length, visibleCount]);

  return (
    <div className="animate-fade-in max-w-6xl mx-auto px-4 py-8">
      <Helmet>
        <title>{isHindiRoute ? "प्रमुख ग्रन्थ एवं रस शास्त्र | Vrindopnishad" : "Sacred Granthas & Books | Vrindopnishad"}</title>
        <meta name="description" content={isHindiRoute ? "ब्रज रस के प्रमुख ग्रन्थों, वाणियों और शास्त्रों का संग्रह।" : "Read and browse the sacred books, granthas and vanis written by the saints of Vrindavan."} />
        <link rel="canonical" href={isHindiRoute ? "https://path.vrindopnishad.in/hi/books" : "https://path.vrindopnishad.in/books"} />
      </Helmet>

      <div className="flex flex-col md:flex-row md:items-start md:items-center justify-between gap-4 mb-6 md:mb-8">
        <div className="flex flex-col items-start w-full md:w-auto text-left">
          <Link to="/" className="inline-flex items-center gap-2 text-[var(--text-color)]/40 hover:text-[var(--text-color)] mb-2 md:mb-3 transition-colors text-xs uppercase tracking-wider">
            <ArrowLeft size={14} />
            Back to Home
          </Link>
          <h1 className="text-2xl md:text-3xl lg:text-4xl font-bold font-headings text-sacred-gradient">
            {isHindiRoute ? "प्रमुख ग्रन्थ एवं वाणियाँ" : "Sacred Granthas & Vaanis"}
          </h1>
          <p className="text-[var(--text-color)]/60 text-xs md:text-sm mt-1">
            {isHindiRoute ? "रसिक संतों द्वारा रचित दिव्य ग्रन्थ और वाणी संग्रह" : "Treasury of classical devotional scriptures"}
          </p>
        </div>

        <div className="relative w-full md:w-80 max-w-xs">
          <div className="premium-search-container flex items-center pl-4 pr-6 h-11">
            <Search className="text-[var(--text-color)]/30 shrink-0 mr-3" size={16} />
            <input 
              type="text" 
              placeholder={isHindiRoute ? "ग्रन्थ खोजें..." : "Search Books..."} 
              className="w-full bg-transparent outline-none text-[var(--text-color)]/90 placeholder:text-[var(--text-color)]/35 h-full text-sm font-light"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>
        </div>
      </div>

      {loading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {[1, 2, 3, 4, 5, 6].map(i => (
            <div key={i} className="skeleton-card h-40">
              <div>
                <div className="skeleton w-24 h-4 rounded-full mb-3"></div>
                <div className="skeleton skeleton-title w-3/4 mb-3"></div>
                <div className="skeleton skeleton-text w-1/2 mb-0"></div>
              </div>
              <div className="pt-3 border-t border-[var(--glass-border)] flex justify-between items-center mt-4 w-full">
                <div className="skeleton w-16 h-4 rounded"></div>
                <div className="skeleton w-20 h-4 rounded"></div>
              </div>
            </div>
          ))}
        </div>
      ) : filteredBooks.length === 0 ? (
        <div className="text-center py-20 glass-card">
          <Book size={48} className="mx-auto text-[var(--text-color)]/20 mb-4" />
          <p className="text-[var(--text-color)]/55">{isHindiRoute ? "कोई ग्रन्थ नहीं मिले" : "No books found matching your search."}</p>
        </div>
      ) : (
        <>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredBooks.slice(0, visibleCount).map(book => (
              <Link 
                key={book.name} 
                to={isHindiRoute ? `/hi/book/${book.slug}` : `/book/${book.slug}`}
                className="glass-card group hover:border-[rgba(var(--primary-rgb),0.3)] transition-all duration-300 flex flex-col justify-between hover:shadow-2xl"
              >
                <div>
                  <span className="text-[10px] uppercase tracking-widest text-[var(--primary-color)] font-bold block mb-2">Grantha</span>
                  <h3 className="font-bold text-lg text-[var(--text-color)]/90 group-hover:text-[var(--primary-color)] transition-colors leading-tight mb-1">
                    {book.name}
                  </h3>
                  <span className="text-xs text-[var(--text-color)]/40 block">
                    By {isHindiRoute ? book.author : book.author}
                  </span>
                </div>
                
                <div className="pt-4 mt-6 border-t border-[var(--glass-border)] flex justify-between items-center text-xs">
                  <span className="text-[var(--text-color)]/40 flex items-center gap-1">
                    <FileText size={12} />
                    {book.verses.length} {book.verses.length === 1 ? 'Verse' : 'Verses'}
                  </span>
                  <span className="text-[var(--primary-color)] font-medium group-hover:translate-x-1 transition-transform">
                    {isHindiRoute ? "पाठ खोलें →" : "Read Book →"}
                  </span>
                </div>
              </Link>
            ))}
          </div>

          
          {filteredBooks.length > visibleCount && (
            <div ref={sentinelRef} className="py-10 flex justify-center w-full">
              <div className="w-8 h-8 border-2 border-[var(--primary-color)] border-t-transparent rounded-full animate-spin"></div>
            </div>
          )}
        </>
      )}
    </div>
  );
};

export default BooksListPage;
