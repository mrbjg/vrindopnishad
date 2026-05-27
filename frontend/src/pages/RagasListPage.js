import React, { useState, useEffect, useContext } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { ApiContext } from '../App';
import { extractRelations } from '../utils/relations';
import { Music, ArrowLeft, Search, FileText } from 'lucide-react';
import { Helmet } from 'react-helmet-async';

const RagasListPage = () => {
  const location = useLocation();
  const isHindiRoute = location.pathname.startsWith('/hi');
  const { apiService } = useContext(ApiContext);
  
  const [ragas, setRagas] = useState(() => {
    try {
      const cached = localStorage.getItem('vrindopnishad_ragas_cache');
      return cached ? JSON.parse(cached) : [];
    } catch { return []; }
  });
  const [loading, setLoading] = useState(() => {
    try { return !localStorage.getItem('vrindopnishad_ragas_cache'); }
    catch { return true; }
  });
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    let active = true;
    const load = async () => {
      try {
        const allItems = await apiService.getAllContent(null, 10000);
        const relations = extractRelations(allItems);
        if (active) {
          setRagas(relations.ragas);
          localStorage.setItem('vrindopnishad_ragas_cache', JSON.stringify(relations.ragas));
        }
      } catch (error) {
        console.error('Error loading ragas:', error);
      } finally {
        if (active) setLoading(false);
      }
    };
    load();
    return () => { active = false; };
  }, [apiService]);

  const filteredRagas = ragas.filter(r => 
    r.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    r.hinglishName.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="animate-fade-in max-w-6xl mx-auto px-4 py-8">
      <Helmet>
        <title>{isHindiRoute ? "रागों के अनुसार वाणी पद | Vrindopnishad" : "Ragas & Devotional Songs | Vrindopnishad"}</title>
        <meta name="description" content={isHindiRoute ? "शास्त्रीय रागों में निबंध ब्रज रस के पदों का वर्गीकरण।" : "Explore sacred songs and poetry categorized by classical Indian musical ragas."} />
        <link rel="canonical" href={isHindiRoute ? "https://path.vrindopnishad.in/hi/ragas" : "https://path.vrindopnishad.in/ragas"} />
      </Helmet>

      <div className="flex flex-col md:flex-row md:items-start md:items-center justify-between gap-4 mb-6 md:mb-8">
        <div>
          <Link to="/" className="inline-flex items-center gap-2 text-white/40 hover:text-white mb-2 md:mb-3 transition-colors text-xs uppercase tracking-wider">
            <ArrowLeft size={14} />
            Back to Home
          </Link>
          <h1 className="text-2xl md:text-3xl lg:text-4xl font-bold font-headings text-sacred-gradient">
            {isHindiRoute ? "रागों के अनुसार पद" : "Ragas & Devotional Tunes"}
          </h1>
          <p className="text-white/50 text-xs md:text-sm mt-1">
            {isHindiRoute ? "भारतीय शास्त्रीय रागों में आबद्ध दिव्य भजन एवं वाणी" : "Sankirtan categorized by traditional musical scales"}
          </p>
        </div>

        <div className="relative w-full md:w-80 max-w-xs">
          <div className="premium-search-container flex items-center pl-4 pr-6 h-11">
            <Search className="text-white/30 shrink-0 mr-3" size={16} />
            <input 
              type="text" 
              placeholder={isHindiRoute ? "राग खोजें..." : "Search Ragas..."} 
              className="w-full bg-transparent outline-none text-white/90 placeholder:text-white/35 h-full text-sm font-light"
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
                <div className="skeleton skeleton-title w-2/3 mb-3"></div>
                <div className="skeleton skeleton-text w-1/3 mb-0"></div>
              </div>
              <div className="pt-3 border-t border-white/5 flex justify-between items-center mt-4 w-full">
                <div className="skeleton w-16 h-4 rounded"></div>
                <div className="skeleton w-20 h-4 rounded"></div>
              </div>
            </div>
          ))}
        </div>
      ) : filteredRagas.length === 0 ? (
        <div className="text-center py-20 glass-card">
          <Music size={48} className="mx-auto text-white/20 mb-4" />
          <p className="text-white/40">{isHindiRoute ? "कोई राग नहीं मिले" : "No ragas found matching your search."}</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredRagas.map(raga => (
            <Link 
              key={raga.name} 
              to={isHindiRoute ? `/hi/raga/${raga.slug}` : `/raga/${raga.slug}`}
              className="glass-card group hover:border-amber-500/30 transition-all duration-300 flex flex-col justify-between hover:shadow-2xl"
            >
              <div>
                <span className="text-[10px] uppercase tracking-widest text-sky-400 font-bold block mb-2">Classical Raga</span>
                <h3 className="font-bold text-lg text-white/90 group-hover:text-primary transition-colors leading-tight">
                  {raga.name}
                </h3>
                <span className="text-xs text-white/30 block mt-1">
                  {raga.hinglishName}
                </span>
              </div>
              
              <div className="pt-4 mt-6 border-t border-white/5 flex justify-between items-center text-xs">
                <span className="text-white/30 flex items-center gap-1">
                  <FileText size={12} />
                  {raga.verses.length} {raga.verses.length === 1 ? 'Song' : 'Songs'}
                </span>
                <span className="text-primary font-medium group-hover:translate-x-1 transition-transform">
                  {isHindiRoute ? "गीत संग्रह खोलें →" : "Listen Songs →"}
                </span>
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
};

export default RagasListPage;
