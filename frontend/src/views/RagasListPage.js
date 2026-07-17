'use client';

import React, { useState, useEffect, useContext, useRef } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { ApiContext } from '../contexts/ClientProviders';
import { extractRelations } from '../utils/relations';
import { Music, ArrowLeft, Search, FileText } from 'lucide-react';
import { Helmet } from 'react-helmet-async';
import PageSkeleton from '../components/ui/PageSkeleton';

const RagasListPage = ({ initialRagas }) => {
  const location = useLocation();
  const isHindiRoute = location.pathname.startsWith('/hi');
  const { apiService } = useContext(ApiContext);
  
  const [ragas, setRagas] = useState(initialRagas || (() => {
    try {
      const memCached = apiService.getMemoryCachedItems();
      if (memCached) {
        const relations = extractRelations(memCached);
        if (relations && relations.ragas.length > 0) return relations.ragas;
      }
    } catch { }
    return [];
  }));
  const [loading, setLoading] = useState(() => {
    if (initialRagas) return false;
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
    if (initialRagas) {
      setLoading(false);
      return;
    }
    const load = async () => {
      try {
        const relations = await apiService.getRelations();
        if (active) {
          setRagas(relations.ragas);
        }
      } catch (error) {
        console.error('Error loading ragas:', error);
      } finally {
        if (active) setLoading(false);
      }
    };
    load();
    return () => { active = false; };
  }, [apiService, initialRagas]);

  const filteredRagas = ragas.filter(r => 
    r.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    r.hinglishName.toLowerCase().includes(searchQuery.toLowerCase())
  );

  
  useEffect(() => {
    if (loading || filteredRagas.length <= visibleCount) return;

    const observer = new IntersectionObserver((entries) => {
      if (entries[0].isIntersecting) {
        setVisibleCount(prev => prev + 36);
      }
    }, {
      rootMargin: '1000px'
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
  }, [loading, filteredRagas.length, visibleCount]);

  return (
    <div className="animate-fade-in max-w-6xl mx-auto px-4 py-8">
      <Helmet>
        <title>{isHindiRoute ? "रागों के अनुसार वाणी पद | Vrindopnishad" : "Ragas & Devotional Songs | Vrindopnishad"}</title>
        <meta name="description" content={isHindiRoute ? "शास्त्रीय रागों में निबंध वृन्दावन भक्ति के पदों का वर्गीकरण।" : "Explore sacred songs and poetry categorized by classical Indian musical ragas."} />
        <link rel="canonical" href={isHindiRoute ? "https://path.vrindopnishad.in/hi/ragas" : "https://path.vrindopnishad.in/ragas"} />
      </Helmet>

      <div className="flex flex-col md:flex-row md:items-start md:items-center justify-between gap-4 mb-6 md:mb-8">
        <div className="flex flex-col items-start w-full md:w-auto text-left">
          <Link to={isHindiRoute ? "/hi" : "/"} className="inline-flex items-center gap-2 text-[var(--text-color)]/40 hover:text-[var(--text-color)] mb-2 md:mb-3 transition-colors text-xs uppercase tracking-wider">
            <ArrowLeft size={14} />
            Back to Home
          </Link>
          <h1 className="text-2xl md:text-3xl lg:text-4xl font-bold font-headings text-sacred-gradient">
            {isHindiRoute ? "रागों के अनुसार पद" : "Ragas & Devotional Tunes"}
          </h1>
          <p className="text-[var(--text-color)]/60 text-xs md:text-sm mt-1">
            {isHindiRoute ? "भारतीय शास्त्रीय रागों में आबद्ध दिव्य भजन एवं वाणी" : "Sankirtan categorized by traditional musical scales"}
          </p>
        </div>

        <div className="relative w-full md:w-80 max-w-xs">
          <div className="premium-search-container flex items-center pl-4 pr-6 h-11">
            <Search className="text-[var(--text-color)]/30 shrink-0 mr-3" size={16} />
            <input 
              type="text" 
              placeholder={isHindiRoute ? "राग खोजें..." : "Search Ragas..."} 
              className="w-full bg-transparent outline-none text-[var(--text-color)]/90 placeholder:text-[var(--text-color)]/35 h-full text-sm font-light"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>
        </div>
      </div>

      {loading ? (
        <PageSkeleton variant="grid-only" count={6} />
      ) : filteredRagas.length === 0 ? (
        <div className="text-center py-20 glass-card">
          <Music size={48} className="mx-auto text-[var(--text-color)]/20 mb-4" />
          <p className="text-[var(--text-color)]/55">{isHindiRoute ? "कोई राग नहीं मिले" : "No ragas found matching your search."}</p>
        </div>
      ) : (
        <>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredRagas.slice(0, visibleCount).map(raga => (
              <Link 
                key={raga.name} 
                to={isHindiRoute ? `/hi/ragas/${raga.slug}` : `/ragas/${raga.slug}`}
                state={{ item: raga }}
                className="glass-card group hover:border-[rgba(var(--primary-rgb),0.3)] transition-all duration-300 flex flex-col justify-between hover:shadow-2xl"
              >
                <div>
                  <span className="text-[10px] uppercase tracking-widest text-[var(--primary-color)] font-bold block mb-2">Classical Raga</span>
                  <h3 className="font-bold text-lg text-[var(--text-color)]/90 group-hover:text-[var(--primary-color)] transition-colors leading-tight">
                    {raga.name}
                  </h3>
                  <span className="text-xs text-[var(--text-color)]/40 block mt-1">
                    {raga.hinglishName}
                  </span>
                </div>
                
                <div className="pt-4 mt-6 border-t border-[var(--glass-border)] flex justify-between items-center text-xs">
                  <span className="text-[var(--text-color)]/40 flex items-center gap-1">
                    <FileText size={12} />
                    {raga.verses ? raga.verses.length : (raga.verseIds ? raga.verseIds.length : 0)} {((raga.verses ? raga.verses.length : (raga.verseIds ? raga.verseIds.length : 0)) === 1) ? 'Song' : 'Songs'}
                  </span>
                  <span className="text-[var(--primary-color)] font-medium group-hover:translate-x-1 transition-transform">
                    {isHindiRoute ? "गीत संग्रह खोलें →" : "Listen Songs →"}
                  </span>
                </div>
              </Link>
            ))}
          </div>

          
          {filteredRagas.length > visibleCount && (
            <div ref={sentinelRef} className="py-10 flex justify-center w-full">
              <div className="w-8 h-8 border-2 border-[var(--primary-color)] border-t-transparent rounded-full animate-spin"></div>
            </div>
          )}
        </>
      )}
    </div>
  );
};

export default RagasListPage;
