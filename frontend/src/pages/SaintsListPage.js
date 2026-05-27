import React, { useState, useEffect, useContext } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { ApiContext } from '../App';
import { extractRelations } from '../utils/relations';
import { Users, ArrowLeft, Search, FileText } from 'lucide-react';
import { Helmet } from 'react-helmet-async';

const getInitials = (name) => {
  if (!name) return 'V';
  let clean = name.replace(/^(Shri|Swami|Sri|Shree|श्री|स्वामी|श्रीमद्)\s+/i, '').trim();
  if (!clean.length) clean = name;
  const first = clean.charAt(0);
  return first.match(/[a-zA-Z]/) ? first.toUpperCase() : first;
};

const SaintsListPage = () => {
  const location = useLocation();
  const isHindiRoute = location.pathname.startsWith('/hi');
  const { apiService } = useContext(ApiContext);
  
  const [saints, setSaints] = useState(() => {
    try {
      const cached = localStorage.getItem('vrindopnishad_saints_cache');
      return cached ? JSON.parse(cached) : [];
    } catch { return []; }
  });
  const [loading, setLoading] = useState(() => {
    try { return !localStorage.getItem('vrindopnishad_saints_cache'); }
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
          setSaints(relations.sants);
          localStorage.setItem('vrindopnishad_saints_cache', JSON.stringify(relations.sants));
        }
      } catch (error) {
        console.error('Error loading saints:', error);
      } finally {
        if (active) setLoading(false);
      }
    };
    load();
    return () => { active = false; };
  }, [apiService]);

  const filteredSaints = saints.filter(s => 
    s.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    s.hinglishName.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="animate-fade-in max-w-6xl mx-auto px-4 py-8">
      <Helmet>
        <title>{isHindiRoute ? "सन्त और रसिक परम्परा | Vrindopnishad" : "Rasik Saints & Authors | Vrindopnishad"}</title>
        <meta name="description" content={isHindiRoute ? "वृंदावन के रसिक संतों और आचार्यों की जीवनी और वाणी का संग्रह।" : "Explore the sacred biographies and spiritual vanis of the great Rasik Saints of Vrindavan."} />
        <link rel="canonical" href={isHindiRoute ? "https://path.vrindopnishad.in/hi/saints" : "https://path.vrindopnishad.in/saints"} />
      </Helmet>

      <div className="flex flex-col md:flex-row md:items-start md:items-center justify-between gap-4 mb-6 md:mb-8">
        <div>
          <Link to="/" className="inline-flex items-center gap-2 text-white/40 hover:text-white mb-2 md:mb-3 transition-colors text-xs uppercase tracking-wider">
            <ArrowLeft size={14} />
            Back to Home
          </Link>
          <h1 className="text-2xl md:text-3xl lg:text-4xl font-bold font-headings text-sacred-gradient">
            {isHindiRoute ? "ब्रज के रसिक सन्त" : "Rasik Saints & Authors"}
          </h1>
          <p className="text-white/50 text-xs md:text-sm mt-1">
            {isHindiRoute ? "परम पावन रसिक संतों की वाणी एवं जीवन चरित्र" : "Sacred digital repository of devotional masters"}
          </p>
        </div>

        <div className="relative w-full md:w-80 max-w-xs">
          <div className="premium-search-container flex items-center pl-4 pr-6 h-11">
            <Search className="text-white/30 shrink-0 mr-3" size={16} />
            <input 
              type="text" 
              placeholder={isHindiRoute ? "संत खोजें..." : "Search Sants..."} 
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
            <div key={i} className="skeleton-card h-44 flex flex-col justify-between">
              <div className="flex items-center gap-4">
                <div className="skeleton w-14 h-14 rounded-full shrink-0"></div>
                <div className="flex-1 space-y-2.5">
                  <div className="skeleton skeleton-title w-3/4 mb-0"></div>
                  <div className="skeleton skeleton-text w-1/2 mb-0"></div>
                </div>
              </div>
              <div className="pt-3 border-t border-white/5 flex justify-between items-center mt-4 w-full">
                <div className="skeleton w-20 h-4 rounded"></div>
                <div className="skeleton w-16 h-4 rounded"></div>
              </div>
            </div>
          ))}
        </div>
      ) : filteredSaints.length === 0 ? (
        <div className="text-center py-20 glass-card">
          <Users size={48} className="mx-auto text-white/20 mb-4" />
          <p className="text-white/40">{isHindiRoute ? "कोई संत नहीं मिले" : "No saints found matching your search."}</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredSaints.map(sant => {
            const bioText = sant.biography?.text 
              ? (sant.biography.text.substring(0, 100) + '...')
              : `${sant.verses.length} verses available in library.`;

            return (
              <Link 
                key={sant.cleanName} 
                to={isHindiRoute ? `/hi/saint/${sant.slug}` : `/saint/${sant.slug}`}
                className="glass-card group hover:border-amber-500/30 transition-all duration-300 flex flex-col justify-between hover:shadow-2xl"
              >
                <div>
                  <div className="flex items-center gap-4 mb-4">
                    <div className="w-14 h-14 rounded-full bg-amber-500/10 border border-amber-500/20 flex items-center justify-center text-amber-500 font-bold text-xl group-hover:scale-105 transition-transform duration-300">
                      {getInitials(isHindiRoute ? sant.name : sant.hinglishName)}
                    </div>
                    <div>
                      <h3 className="font-bold text-lg text-white/90 group-hover:text-primary transition-colors leading-tight">
                        {isHindiRoute ? sant.name : sant.hinglishName}
                      </h3>
                      <span className="text-[10px] uppercase tracking-wider text-white/30 block mt-1">
                        {sant.books.length} {sant.books.length === 1 ? 'Book' : 'Books'}
                      </span>
                    </div>
                  </div>
                  <p className="text-white/50 text-xs leading-relaxed line-clamp-3">
                    {bioText}
                  </p>
                </div>
                
                <div className="pt-4 mt-4 border-t border-white/5 flex justify-between items-center text-xs">
                  <span className="text-white/30 flex items-center gap-1">
                    <FileText size={12} />
                    {sant.verses.length} {sant.verses.length === 1 ? 'Verse' : 'Verses'}
                  </span>
                  <span className="text-primary font-medium group-hover:translate-x-1 transition-transform">
                    {isHindiRoute ? "वाणी संग्रह →" : "View Vaanis →"}
                  </span>
                </div>
              </Link>
            );
          })}
        </div>
      )}
    </div>
  );
};

export default SaintsListPage;
