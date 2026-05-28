import React, { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { 
  BookOpen, Search, HelpCircle, 
  MapPin, Award, BookOpen as BookIcon, ChevronRight,
  ArrowLeft, Heart, Sparkles
} from 'lucide-react';
import { categories, articles } from '../utils/kbArticles';

const KnowledgeBasePage = () => {
  const location = useLocation();
  const isHindiRoute = location.pathname.startsWith('/hi');
  const [searchQuery, setSearchQuery] = useState('');
  const [activeCategory, setActiveCategory] = useState('all');

  // Filtering logic
  const filteredArticles = articles.filter(art => {
    const title = isHindiRoute ? art.titleHi : art.titleEn;
    const desc = isHindiRoute ? art.descHi : art.descEn;
    const matchesSearch = title.toLowerCase().includes(searchQuery.toLowerCase()) || 
                          desc.toLowerCase().includes(searchQuery.toLowerCase()) ||
                          art.slug.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = activeCategory === 'all' || art.category === activeCategory;
    return matchesSearch && matchesCategory;
  });

  const getCategoryIcon = (cat) => {
    switch (cat) {
      case 'philosophy': return <Award size={18} className="text-amber-400" />;
      case 'traditions': return <Heart size={18} className="text-rose-400" />;
      case 'concepts': return <Sparkles size={18} className="text-purple-400" />;
      case 'guides': return <MapPin size={18} className="text-emerald-400" />;
      default: return <BookIcon size={18} className="text-blue-400" />;
    }
  };

  return (
    <div className="animate-fade-in w-full px-1 py-4">
      {/* SEO Metadata */}
      <Helmet>
        <title>{isHindiRoute ? "वैदिक ज्ञान कोष और रसिक विकी | Vrindopnishad" : "Vedic Knowledge Base & Rasik Wiki | Vrindopnishad"}</title>
        <meta name="description" content={isHindiRoute ? "ब्रज रस के दार्शनिक सिद्धांतों, रसिक आचार्यों के इतिहास और शब्दकोश का संग्रह।" : "A unified portal exploring Braj Bhakti, philosophy, saint biographies and devotee guides."} />
        <link rel="canonical" href={isHindiRoute ? "https://path.vrindopnishad.in/hi/knowledge-base" : "https://path.vrindopnishad.in/knowledge-base"} />
      </Helmet>

      {/* Page Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-4 border-b border-white/5 pb-4">
        <div>
          <Link to={isHindiRoute ? "/hi" : "/"} className="inline-flex items-center gap-1.5 text-white/40 hover:text-white mb-1.5 transition-colors text-[10px] uppercase tracking-wider">
            <ArrowLeft size={12} />
            {isHindiRoute ? "डैशबोर्ड पर वापस" : "Back to Dashboard"}
          </Link>
          <h1 className="text-xl md:text-2xl lg:text-3xl font-bold font-headings text-white flex items-center gap-2.5">
            <BookOpen className="text-purple-400 shrink-0" size={26} />
            {isHindiRoute ? "सनातन ज्ञान कोष (Rasik Wiki)" : "Sanctuary Knowledge Base"}
          </h1>
          <p className="text-white/50 text-xs mt-0.5 max-w-2xl">
            {isHindiRoute 
              ? "ब्रज रस भक्ति के रहस्य, सन्त परम्पराओं और वैदिक सिद्धांतों की खोज के लिए एकीकृत विकी।" 
              : "Discover the deep philosophical treatises, parikrama maps, and dictionaries of Braj devotion."}
          </p>
        </div>

        {/* Search Input */}
        <div className="relative w-full md:w-80 max-w-xs">
          <div className="flex items-center bg-white/[0.04] border border-white/10 rounded-xl pl-3 pr-4 h-9.5 text-sm focus-within:border-purple-500/50 focus-within:bg-white/[0.07] transition-all">
            <Search className="text-white/30 shrink-0 mr-2" size={14} />
            <input 
              type="text" 
              placeholder={isHindiRoute ? "ज्ञान कोष में खोजें..." : "Search Knowledge Base..."} 
              className="w-full bg-transparent outline-none text-white/90 placeholder:text-white/35 h-full text-xs font-light"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>
        </div>
      </div>

      {/* Category Tabs Row */}
      <div className="flex flex-wrap items-center bg-[#121215] border border-white/5 p-1 rounded-full gap-1 mb-5 overflow-x-auto">
        {categories.map((cat) => (
          <button
            key={cat.id}
            onClick={() => setActiveCategory(cat.id)}
            className={`px-4 py-2 rounded-full text-xs font-semibold tracking-wide transition-all shrink-0 border whitespace-nowrap ${
              activeCategory === cat.id
                ? 'bg-white text-zinc-950 border-white/30 shadow-md font-bold'
                : 'text-zinc-400 hover:text-white hover:bg-white/5 border-transparent'
            }`}
          >
            {isHindiRoute ? cat.labelHi : cat.labelEn}
          </button>
        ))}
      </div>

      {/* Articles Grid */}
      {filteredArticles.length === 0 ? (
        <div className="text-center py-20 bg-[#121215] border border-white/5 rounded-[1.5rem]">
          <HelpCircle size={48} className="mx-auto text-white/20 mb-4" />
          <p className="text-white/40 text-sm">
            {isHindiRoute ? "ज्ञान कोष में कोई लेख नहीं मिला।" : "No articles found matching your query."}
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {filteredArticles.map((art) => (
            <Link
              key={art.slug}
              to={isHindiRoute ? `/hi/${art.slug}` : `/${art.slug}`}
              className="glass-card group hover:border-purple-500/30 transition-all duration-300 flex flex-col justify-between hover:shadow-xl bg-[#121215] border border-white/5 rounded-2xl p-4"
            >
              <div>
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center gap-2">
                    {getCategoryIcon(art.category)}
                    <span className="text-[9px] uppercase tracking-widest text-zinc-500 font-bold">
                      {art.category}
                    </span>
                  </div>
                  <span className="text-[9px] font-mono text-zinc-500">{art.readTime}</span>
                </div>

                <h3 className="font-bold text-sm text-white group-hover:text-purple-300 transition-colors leading-tight mb-1.5">
                  {isHindiRoute ? art.titleHi : art.titleEn}
                </h3>
                <p className="text-zinc-400 text-xs font-light leading-relaxed mb-3.5 line-clamp-3">
                  {isHindiRoute ? art.descHi : art.descEn}
                </p>
              </div>

              <div className="pt-2.5 border-t border-white/5 flex justify-between items-center text-[10px] font-semibold">
                <span className="text-zinc-500 uppercase tracking-wide whitespace-nowrap shrink-0">Vedic Wiki</span>
                <span className="text-purple-400 flex items-center gap-1 group-hover:translate-x-1 transition-transform whitespace-nowrap shrink-0">
                  <ChevronRight size={12} />
                </span>
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
};

export default KnowledgeBasePage;
