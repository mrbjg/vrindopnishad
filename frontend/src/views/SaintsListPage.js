'use client';

import React, { useState, useEffect, useContext, useRef } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { ApiContext } from '../contexts/ClientProviders';
import { extractRelations } from '../utils/relations';
import { Users, ArrowLeft, Search, FileText } from 'lucide-react';
import { Helmet } from 'react-helmet-async';
import PageSkeleton from '../components/ui/PageSkeleton';

const getInitials = (name) => {
  if (!name) return 'V';
  let clean = name.replace(/^(Shri|Swami|Sri|Shree|श्री|स्वामी|श्रीमद्)\s+/i, '').trim();
  if (!clean.length) clean = name;
  const first = clean.charAt(0);
  return first.match(/[a-zA-Z]/) ? first.toUpperCase() : first;
};

const SaintsListPage = ({ initialSaints }) => {
  const location = useLocation();
  const isHindiRoute = location.pathname.startsWith('/hi');
  const { apiService } = useContext(ApiContext);
  
  const [saints, setSaints] = useState(initialSaints || (() => {
    try {
      const memCached = apiService.getMemoryCachedItems();
      if (memCached) {
        const relations = extractRelations(memCached);
        if (relations && relations.sants.length > 0) return relations.sants;
      }
    } catch { }
    return [];
  }));
  const [loading, setLoading] = useState(() => {
    if (initialSaints) return false;
    try {
      const memCached = apiService.getMemoryCachedItems();
      if (memCached) return false;
    } catch { }
    return true;
  });
  const queryParams = new URLSearchParams(location.search);
  const initialQuery = queryParams.get('q') || '';

  const [searchQuery, setSearchQuery] = useState(initialQuery);
  const [visibleCount, setVisibleCount] = useState(12);
  const sentinelRef = useRef(null);

  
  useEffect(() => {
    const q = new URLSearchParams(location.search).get('q') || '';
    setSearchQuery(q);
  }, [location.search]);

  useEffect(() => {
    setVisibleCount(12); 
  }, [searchQuery]);

  useEffect(() => {
    let active = true;
    if (initialSaints) {
      setLoading(false);
      return;
    }
    const load = async () => {
      try {
        const allItems = await apiService.getAllContent(null, 10000);
        const relations = extractRelations(allItems);
        if (active) {
          setSaints(relations.sants);
        }
      } catch (error) {
        console.error('Error loading saints:', error);
      } finally {
        if (active) setLoading(false);
      }
    };
    load();
    return () => { active = false; };
  }, [apiService, initialSaints]);

  const filteredSaints = saints.filter(s => 
    s.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    s.hinglishName.toLowerCase().includes(searchQuery.toLowerCase()) ||
    (s.lineage && s.lineage.toLowerCase().includes(searchQuery.toLowerCase())) ||
    (s.lineageEn && s.lineageEn.toLowerCase().includes(searchQuery.toLowerCase())) ||
    (s.timeline && s.timeline.toLowerCase().includes(searchQuery.toLowerCase())) ||
    (s.timelineEn && s.timelineEn.toLowerCase().includes(searchQuery.toLowerCase()))
  );

  
  useEffect(() => {
    if (loading || filteredSaints.length <= visibleCount) return;

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
  }, [loading, filteredSaints.length, visibleCount]);

  return (
    <div className="animate-fade-in max-w-6xl mx-auto px-4 py-8">
      <Helmet>
        <title>{isHindiRoute ? "सन्त और रसिक परम्परा | Vrindopnishad" : "Rasik Saints & Authors | Vrindopnishad"}</title>
        <meta name="description" content={isHindiRoute ? "वृंदावन के रसिक संतों और आचार्यों की जीवनी और वाणी का संग्रह।" : "Explore the sacred biographies and spiritual vanis of the great Rasik Saints of Vrindavan."} />
        <link rel="canonical" href={isHindiRoute ? "https://path.vrindopnishad.in/hi/saints" : "https://path.vrindopnishad.in/saints"} />
      </Helmet>

      <div className="flex flex-col md:flex-row md:items-start md:items-center justify-between gap-4 mb-6 md:mb-8">
        <div className="flex flex-col items-start w-full md:w-auto text-left">
          <Link to={isHindiRoute ? "/hi" : "/"} className="inline-flex items-center gap-2 text-[var(--text-color)]/40 hover:text-[var(--text-color)] mb-2 md:mb-3 transition-colors text-xs uppercase tracking-wider">
            <ArrowLeft size={14} />
            Back to Home
          </Link>
          <h1 className="text-2xl md:text-3xl lg:text-4xl font-bold font-headings text-sacred-gradient">
            {isHindiRoute ? "ब्रज के रसिक सन्त" : "Rasik Saints & Authors"}
          </h1>
          <p className="text-[var(--text-color)]/60 text-xs md:text-sm mt-1">
            {isHindiRoute ? "परम पावन रसिक संतों की वाणी एवं जीवन चरित्र" : "Sacred digital repository of devotional masters"}
          </p>
        </div>

        <div className="relative w-full md:w-80 max-w-xs">
          <div className="premium-search-container flex items-center pl-4 pr-6 h-11">
            <Search className="text-[var(--text-color)]/30 shrink-0 mr-3" size={16} />
            <input 
              type="text" 
              placeholder={isHindiRoute ? "संत खोजें..." : "Search Sants..."} 
              className="w-full bg-transparent outline-none text-[var(--text-color)]/90 placeholder:text-[var(--text-color)]/35 h-full text-sm font-light"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>
        </div>
      </div>

      {loading ? (
        <PageSkeleton variant="grid-only" count={6} />
      ) : filteredSaints.length === 0 ? (
        <div className="text-center py-20 glass-card">
          <Users size={48} className="mx-auto text-[var(--text-color)]/20 mb-4" />
          <p className="text-[var(--text-color)]/50">{isHindiRoute ? "कोई संत नहीं मिले" : "No saints found matching your search."}</p>
        </div>
      ) : (
        <>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredSaints.slice(0, visibleCount).map(sant => {
              const bioText = sant.biography?.text 
                ? (sant.biography.text.substring(0, 100) + '...')
                : `${sant.verses.length} verses available in library.`;

              return (
                <Link 
                  key={sant.cleanName} 
                  to={isHindiRoute ? `/hi/saints/${sant.slug}` : `/saints/${sant.slug}`}
                  className="glass-card group hover:border-[rgba(var(--primary-rgb),0.3)] transition-all duration-300 flex flex-col justify-between hover:shadow-2xl"
                >
                  <div>
                    <div className="flex items-center gap-4 mb-4">
                      <div className="w-14 h-14 rounded-full bg-[rgba(var(--primary-rgb),0.08)] border border-[rgba(var(--primary-rgb),0.2)] flex items-center justify-center text-[var(--primary-color)] font-bold text-xl group-hover:scale-105 transition-transform duration-300">
                        {getInitials(isHindiRoute ? sant.name : sant.hinglishName)}
                      </div>
                      <div>
                        <h3 className="font-bold text-lg text-[var(--text-color)]/90 group-hover:text-[var(--primary-color)] transition-colors leading-tight">
                          {isHindiRoute ? sant.name : sant.hinglishName}
                        </h3>
                        <span className="text-[10px] uppercase tracking-wider text-[var(--text-color)]/40 block mt-1">
                          {sant.books.length} {sant.books.length === 1 ? 'Book' : 'Books'}
                        </span>
                      </div>
                    </div>
                    <p className="text-[var(--text-color)]/60 text-xs leading-relaxed line-clamp-3">
                      {bioText}
                    </p>
                  </div>
                  
                  <div className="pt-4 mt-4 border-t border-[var(--glass-border)] flex justify-between items-center text-xs">
                    <span className="text-[var(--text-color)]/40 flex items-center gap-1">
                      <FileText size={12} />
                      {sant.verses.length} {sant.verses.length === 1 ? 'Verse' : 'Verses'}
                    </span>
                    <span className="text-[var(--primary-color)] font-medium group-hover:translate-x-1 transition-transform">
                      {isHindiRoute ? "वाणी संग्रह →" : "View Vaanis →"}
                    </span>
                  </div>
                </Link>
              );
            })}
          </div>

          
          {filteredSaints.length > visibleCount && (
            <div ref={sentinelRef} className="py-10 flex justify-center w-full">
              <div className="w-8 h-8 border-2 border-[var(--primary-color)] border-t-transparent rounded-full animate-spin"></div>
            </div>
          )}
        </>
      )}
    </div>
  );
};

export default SaintsListPage;
