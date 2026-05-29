import React, { useState, useEffect, useContext, useRef, useMemo } from 'react';
import { Link, useSearchParams } from 'react-router-dom';
import { ApiContext } from '../App';
import { Search, ArrowRight, Tag, Sparkles, Brain } from 'lucide-react';
import AudioPlayButton from '../components/ui/AudioPlayButton';
import { Helmet } from 'react-helmet-async';
import { getSearchSuggestions, expandHinglishQuery } from '../utils/hinglishSearch';
import { semanticSearch } from '../utils/semanticSearch';

const ContentListPage = () => {
  const { apiService } = useContext(ApiContext);
  const [searchParams] = useSearchParams();
  const urlQuery = searchParams.get('q') || '';
  const urlCategory = searchParams.get('category') || null;

  const [content, setContent] = useState(() => {
    try {
      const memCached = apiService.getMemoryCachedItems();
      if (memCached && memCached.length > 0) {
        if (urlCategory) {
          const targetCat = urlCategory.toLowerCase().trim();
          return memCached.filter(item => item.category?.toLowerCase() === targetCat);
        }
        return memCached;
      }
      return [];
    } catch { return []; }
  });
  const [categories, setCategories] = useState(() => apiService.getCachedData('categories') || []);
  const [loading, setLoading] = useState(!content.length);
  const [selectedCategory, setSelectedCategory] = useState(urlCategory);
  const [searchQuery, setSearchQuery] = useState(urlQuery);
  const [debouncedSearch, setDebouncedSearch] = useState(urlQuery);
  const [suggestions, setSuggestions] = useState([]);
  const [showSuggestions, setShowSuggestions] = useState(false);
  const [aiResults, setAiResults] = useState([]);
  const [aiLoading, setAiLoading] = useState(false);
  const searchRef = useRef(null);
  const [visibleCount, setVisibleCount] = useState(12);
  const sentinelRef = useRef(null);

  // Sync state with URL search params changes
  useEffect(() => {
    const q = searchParams.get('q') || '';
    const cat = searchParams.get('category') || null;
    setSearchQuery(q);
    setSelectedCategory(cat);
  }, [searchParams]);

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedSearch(searchQuery);
      setSuggestions(getSearchSuggestions(searchQuery));
    }, 200);
    return () => clearTimeout(timer);
  }, [searchQuery]);

  // Close suggestions on click outside
  useEffect(() => {
    const handleClick = (e) => {
      if (searchRef.current && !searchRef.current.contains(e.target)) {
        setShowSuggestions(false);
      }
    };
    document.addEventListener('mousedown', handleClick);
    return () => document.removeEventListener('mousedown', handleClick);
  }, []);

  // AI Semantic Search (runs in background, doesn't block UI)
  useEffect(() => {
    if (debouncedSearch.length < 3) { setAiResults([]); return; }
    let cancelled = false;
    setAiLoading(true);
    semanticSearch(debouncedSearch).then(results => {
      if (!cancelled) {
        setAiResults(results);
        setAiLoading(false);
      }
    }).catch(() => { if (!cancelled) setAiLoading(false); });
    return () => { cancelled = true; };
  }, [debouncedSearch]);

  useEffect(() => {
    let active = true;

    const fetchContent = async () => {
      setVisibleCount(12);
      if (content.length === 0 && active) {
        setLoading(true);
      }
      
      try {
        const fullData = await apiService.getAllContent(selectedCategory, 10000);
        const cats = await apiService.getCategories();
        
        if (active) {
          setContent(fullData);
          setCategories(cats);
        }
      } catch (error) {
        console.error('Error fetching content:', error);
      } finally {
        if (active) setLoading(false);
      }
    };

    fetchContent();
    return () => {
      active = false;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedCategory, apiService]);

  const expandedTerms = useMemo(() => {
    return expandHinglishQuery(debouncedSearch);
  }, [debouncedSearch]);

  const filteredContent = useMemo(() => {
    if (!debouncedSearch) return content;
    return content.filter(item => {
      const searchableText = [
        item.title,
        item.hindi_text,
        item.english_translation,
        item.english_text,
        item.description,
        item.author,
        item.category,
        item.slug,
        ...(item.tags || [])
      ].filter(Boolean).join(' ').toLowerCase();

      return expandedTerms.some(term => searchableText.includes(term.toLowerCase()));
    });
  }, [content, debouncedSearch, expandedTerms]);

  // Infinite Scroll Observer
  useEffect(() => {
    if (loading || filteredContent.length <= visibleCount) return;

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
  }, [loading, filteredContent.length, visibleCount]);



  const getCategoryColorClasses = (category) => {
    return { 
      bg: 'bg-[var(--primary-color)]', 
      hover: 'hover:border-[rgba(var(--primary-rgb),0.3)] hover:shadow-[rgba(var(--primary-rgb),0.05)]',
      text: 'text-[var(--primary-color)]' 
    };
  };

  const getCategoryBadgeClass = (category) => {
    switch (category?.toLowerCase()) {
      case 'shloka': return 'badge-shloka';
      case 'strotra': return 'badge-strotra';
      case 'poem': return 'badge-poem';
      case 'katha': return 'badge-orange';
      case 'general': return 'badge-indigo';
      default: return 'badge-slate';
    }
  };

  const showSkeleton = loading && content.length === 0;

  return (
    <div className="animate-fade-in">
      <Helmet>
        <title>{selectedCategory ? `${selectedCategory}s — Sacred ${selectedCategory} Collection` : 'All Sacred Verses, Shlokas, Strotras & Poetry'} | Vrindopnishad</title>
        <meta name="description" content={`Browse ${filteredContent.length}+ ${selectedCategory || 'sacred shlokas, strotras, poems, and devotional hymns'} in Hindi, Sanskrit & English. The largest curated spiritual repository from Vrindavan saints at Vrindopnishad.`} />
        <meta name="keywords" content={`${selectedCategory || 'shlokas, strotras, poems'}, Sanskrit verses, Hindi mantras, spiritual collection, Vrindopnishad, Sant Vaani, devotional content`} />
        <link rel="canonical" href={`https://path.vrindopnishad.in/content${selectedCategory ? `?category=${selectedCategory}` : ''}`} />

        <script type="application/ld+json">
          {JSON.stringify({
            "@context": "https://schema.org",
            "@type": "CollectionPage",
            "name": `${selectedCategory ? `${selectedCategory}s Collection` : 'Sacred Spiritual Repository'} — Vrindopnishad`,
            "description": `Browse ${filteredContent.length}+ ${selectedCategory || 'sacred spiritual texts'} — shlokas, strotras, and devotional poetry in Hindi, Sanskrit & English.`,
            "url": `https://path.vrindopnishad.in/content${selectedCategory ? `?category=${selectedCategory}` : ''}`,
            "inLanguage": ["hi", "en", "sa"],
            "numberOfItems": filteredContent.length,
            "publisher": {
              "@type": "Organization",
              "name": "Vrindopnishad"
            }
          })}
        </script>
      </Helmet>
      <div className="flex flex-col md:flex-row md:items-start md:items-center justify-between gap-4 mb-6 md:mb-8">
        <div>
          <h1 className="text-2xl md:text-3xl lg:text-4xl font-bold mb-1 md:mb-2 tracking-tight text-[var(--text-color)]">Spiritual Repository</h1>
          <p className="text-[var(--text-color)]/60 text-xs md:text-sm">Explore the vast collection of sacred content</p>
        </div>

        <div className="relative w-full md:w-96 max-w-md" ref={searchRef}>
          <div className="premium-search-container flex items-center pl-4 pr-6 h-12">
            <Search className="text-[var(--text-color)]/30 shrink-0 mr-3" size={18} />
            <input 
              type="text" 
              placeholder="Search in Hindi, English or Hinglish..." 
              className="w-full bg-transparent outline-none text-[var(--text-color)]/90 placeholder:text-[var(--text-color)]/35 h-full text-sm font-light"
              value={searchQuery}
              onChange={(e) => { setSearchQuery(e.target.value); setShowSuggestions(true); }}
              onFocus={() => setShowSuggestions(true)}
            />
          </div>
          {/* Hinglish Suggestions Dropdown */}
          {showSuggestions && suggestions.length > 0 && (
            <div className="absolute top-full left-0 right-0 mt-2 bg-[#1a1a24] border border-white/10 rounded-2xl shadow-2xl shadow-black/50 z-50 overflow-hidden">
              <div className="px-4 py-2 border-b border-white/5 flex items-center gap-2">
                <Sparkles size={12} className="text-amber-400" />
                <span className="text-[10px] uppercase tracking-widest text-[var(--text-color)]/30">Hinglish suggestions</span>
              </div>
              {suggestions.map((s, i) => (
                <button
                  key={i}
                  className="w-full px-4 py-3 text-left hover:bg-white/5 transition-colors flex items-center justify-between group"
                  onClick={() => {
                    setSearchQuery(s.text);
                    setShowSuggestions(false);
                  }}
                >
                  <span className="text-[var(--text-color)]/70 group-hover:text-[var(--text-color)] transition-colors">{s.text}</span>
                  <span className="text-amber-400/60 text-sm font-headings">{s.hindi}</span>
                </button>
              ))}
            </div>
          )}
        </div>
      </div>

      <div className="flex gap-3 overflow-x-auto pb-6 scrollbar-hide mb-8">
        <button 
          onClick={() => setSelectedCategory(null)}
          className={`px-6 py-2 rounded-full border transition-all duration-300 flex-none ${!selectedCategory ? 'active-gold border-transparent text-[var(--text-color)] shadow-lg shadow-amber-500/20' : 'bg-white/5 border-white/10 text-[var(--text-color)]/40 hover:border-[var(--glass-border)]'}`}
        >
          All
        </button>
        {categories.map(cat => {
          const colors = getCategoryColorClasses(cat);
          return (
            <button 
              key={cat}
              onClick={() => setSelectedCategory(cat)}
              className={`px-6 py-2 rounded-full border transition-all duration-300 flex-none capitalize ${selectedCategory === cat ? `${colors.bg} border-transparent text-[var(--text-color)] shadow-lg shadow-amber-500/20` : 'bg-white/5 border-white/10 text-[var(--text-color)]/60 hover:border-[var(--glass-border)]'}`}
            >
              {cat}s
            </button>
          );
        })}
      </div>

      {showSkeleton ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {[1,2,3,4,5,6].map(i => (
            <div key={i} className="skeleton-card flex flex-col justify-between h-72">
              <div>
                <div className="flex justify-between items-start mb-4">
                  <div className="skeleton w-20 h-6 rounded-full"></div>
                  <div className="skeleton w-6 h-6 rounded-full"></div>
                </div>
                <div className="skeleton skeleton-title w-3/4 mb-4"></div>
                <div className="space-y-2">
                  <div className="skeleton skeleton-text w-full"></div>
                  <div className="skeleton skeleton-text w-full"></div>
                  <div className="skeleton skeleton-text w-2/3"></div>
                </div>
              </div>
              <div className="pt-4 border-t border-[var(--glass-border)] flex gap-2">
                 <div className="skeleton w-16 h-5 rounded-md"></div>
                 <div className="skeleton w-16 h-5 rounded-md"></div>
              </div>
            </div>
          ))}
        </div>
      ) : (
        <>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {filteredContent.slice(0, visibleCount).map((item, index) => {
            const colors = getCategoryColorClasses(item.category);
            return (
              <Link 
                to={`/content/${item.slug || item.id}`} 
                key={`${item.slug || item.id || 'item'}-${index}`} 
                className={`glass-card group flex flex-col justify-between transition-all duration-500 border border-[var(--glass-border)] ${colors.hover} hover:shadow-2xl`}
              >
                <div>
                  <div className="flex justify-between items-start mb-4">
                    <span className={`badge transition-all duration-300 ${getCategoryBadgeClass(item.category)}`}>
                      {item.category}
                    </span>
                    <div className="flex items-center gap-3 text-[var(--text-color)]/20 transition-all duration-300">
                      <AudioPlayButton track={item} />
                      <ArrowRight size={20} className={`group-hover:translate-x-1 transition-transform duration-500`} />
                    </div>
                  </div>
                <h3 className="text-xl font-bold mb-4 line-clamp-2 leading-snug transition-colors py-1 text-[var(--text-color)]">
                  {item.title}
                </h3>
                <p className="text-[var(--text-color)]/60 text-sm line-clamp-3 leading-relaxed mb-6">
                  {item.hindi_text ? <span className="hindi-text">{item.hindi_text}</span> : item.english_translation}
                </p>
              </div>
              
              <div className="pt-4 border-t border-[var(--glass-border)] flex flex-wrap gap-2">
                {item.tags?.slice(0, 3).map(tag => (
                  <span key={tag} className="text-[10px] uppercase tracking-wider text-[var(--text-color)]/45 flex items-center gap-1 bg-white/5 px-2 py-1 rounded">
                    <Tag size={10} />
                    {tag}
                  </span>
                ))}
              </div>
            </Link>
          );
        })}
      </div>

      {/* Scroll Sentinel Loader */}
      {filteredContent.length > visibleCount && (
        <div ref={sentinelRef} className="py-10 flex justify-center w-full">
          <div className="w-8 h-8 border-2 border-amber-400 border-t-transparent rounded-full animate-spin"></div>
        </div>
      )}
        </>
      )}

      {!loading && filteredContent.length === 0 && (
        <div className="text-center py-24 glass-card">
           <Search size={48} className="mx-auto text-[var(--text-color)]/20 mb-6" />
           <p className="text-[var(--text-color)]/50">No content found matching your search.</p>
        </div>
      )}

      {/* AI Semantic Recommendations */}
      {debouncedSearch.length >= 3 && (aiResults.length > 0 || aiLoading) && (
        <section className="mt-16">
          <div className="flex items-center gap-3 mb-8">
            <div className="p-2 bg-purple-500/10 rounded-xl">
              <Brain size={20} className="text-purple-400" />
            </div>
            <div>
              <h3 className="text-lg font-bold flex items-center gap-2 text-[var(--text-color)]">
                AI Recommendations
                <span className="text-[9px] uppercase tracking-widest text-purple-400 bg-purple-500/10 px-2 py-0.5 rounded-full">Semantic</span>
              </h3>
              <p className="text-[var(--text-color)]/30 text-xs">Powered by multilingual AI — understands meaning across Hindi, English & Sanskrit</p>
            </div>
          </div>

          {aiLoading ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {[1,2,3].map(i => (
                <div key={i} className="glass-card h-36 animate-pulse">
                  <div className="flex items-center gap-2 mb-4">
                    <div className="skeleton w-16 h-5 rounded-full" />
                    <div className="skeleton w-10 h-4 rounded" />
                  </div>
                  <div className="skeleton w-3/4 h-5 rounded mb-2" />
                  <div className="skeleton w-full h-3 rounded" />
                </div>
              ))}
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {aiResults.map((item, i) => (
                <Link
                  key={item.id || item.slug || `${item.title || 'ai'}-${i}`}
                  to={`/content/${item.slug || item.id}`}
                  className="glass-card group hover:border-purple-400/30 transition-all duration-300 relative overflow-hidden"
                >
                  <div className="absolute top-0 right-0 px-3 py-1 bg-purple-500/10 rounded-bl-xl">
                    <span className="text-[10px] text-purple-300 font-mono">{Math.round(item.score * 100)}%</span>
                  </div>
                  <span className="text-[10px] uppercase tracking-widest text-purple-400/60 mb-2 block">{item.category}</span>
                  <h4 className="text-base font-bold mb-2 line-clamp-2 group-hover:text-purple-300 transition-colors text-[var(--text-color)]">{item.title}</h4>
                  {item.author && (
                    <p className="text-[var(--text-color)]/30 text-xs">— {item.author}</p>
                  )}
                </Link>
              ))}
            </div>
          )}
        </section>
      )}
    </div>
  );
};

export default ContentListPage;
