'use client';

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
      
      <Helmet>
        <title>{isHindiRoute ? "वैदिक ज्ञान कोष और रसिक विकी | Vrindopnishad" : "Vedic Knowledge Base & Rasik Wiki | Vrindopnishad"}</title>
        <meta name="description" content={isHindiRoute ? "ब्रज रस के दार्शनिक सिद्धांतों, रसिक आचार्यों के इतिहास और शब्दकोश का संग्रह।" : "A unified portal exploring Braj Bhakti, philosophy, saint biographies and devotee guides."} />
        <link rel="canonical" href={isHindiRoute ? "https://path.vrindopnishad.in/hi/knowledge-base" : "https://path.vrindopnishad.in/knowledge-base"} />
      </Helmet>

      
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-4 border-b border-[var(--glass-border)] pb-4">
        <div>
          <Link to={isHindiRoute ? "/hi" : "/"} className="inline-flex items-center gap-1.5 text-[var(--text-color)]/40 hover:text-[var(--text-color)] mb-1.5 transition-colors text-[10px] uppercase tracking-wider">
            <ArrowLeft size={12} />
            {isHindiRoute ? "डैशबोर्ड पर वापस" : "Back to Dashboard"}
          </Link>
          <h1 className="text-xl md:text-2xl lg:text-3xl font-bold font-headings text-[var(--text-color)] flex items-center gap-2.5">
            <BookOpen className="text-[color:var(--primary-color)] shrink-0" size={26} />
            {isHindiRoute ? "सनातन ज्ञान कोष (Rasik Wiki)" : "Sanctuary Knowledge Base"}
          </h1>
          <p className="text-[var(--text-color)]/50 text-xs mt-0.5 max-w-2xl">
            {isHindiRoute 
              ? "ब्रज रस भक्ति के रहस्य, सन्त परम्पराओं और वैदिक सिद्धांतों की खोज के लिए एकीकृत विकी।" 
              : "Discover the deep philosophical treatises, parikrama maps, and dictionaries of Braj devotion."}
          </p>
        </div>

        
        <div className="relative w-full md:w-80 max-w-xs">
          <div className="flex items-center bg-[var(--text-color)]/[0.03] border border-[var(--glass-border)] rounded-xl pl-3 pr-4 h-9.5 text-sm focus-within:border-[rgba(var(--primary-rgb),0.5)] focus-within:bg-[var(--text-color)]/[0.06] transition-all">
            <Search className="text-[var(--text-color)]/30 shrink-0 mr-2" size={14} />
            <input 
              type="text" 
              placeholder={isHindiRoute ? "ज्ञान कोष में खोजें..." : "Search Knowledge Base..."} 
              className="w-full bg-transparent outline-none text-[var(--text-color)] placeholder:text-[var(--text-color)]/35 h-full text-xs font-light"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>
        </div>
      </div>

      
      <div className="flex items-center gap-2 mb-6 overflow-x-auto scrollbar-hide py-1.5 shrink-0">
        {categories.map((cat) => (
          <button
            key={cat.id}
            onClick={() => setActiveCategory(cat.id)}
            className={`px-5 py-2.5 rounded-full text-xs font-semibold tracking-wide transition-all shrink-0 border whitespace-nowrap ${
              activeCategory === cat.id
                ? 'active-gold border-transparent text-[var(--text-color)] shadow-lg shadow-amber-500/20'
                : 'bg-[var(--glass-bg)] border-[var(--glass-border)] text-[var(--text-color)]/60 hover:text-[var(--text-color)] hover:bg-[rgba(var(--primary-rgb),0.08)] font-light'
            }`}
          >
            {isHindiRoute ? cat.labelHi : cat.labelEn}
          </button>
        ))}
      </div>

      
      {filteredArticles.length === 0 ? (
        <div className="text-center py-20 bg-[var(--glass-bg)] border-[var(--glass-border)] text-[var(--text-color)] border rounded-[1.5rem]">
          <HelpCircle size={48} className="mx-auto text-[var(--text-color)]/20 mb-4" />
          <p className="text-[var(--text-color)]/40 text-sm">
            {isHindiRoute ? "ज्ञान कोष में कोई लेख नहीं मिला।" : "No articles found matching your query."}
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {filteredArticles.map((art) => (
            <Link
              key={art.slug}
              to={isHindiRoute ? `/hi/${art.slug}` : `/${art.slug}`}
              className="glass-card group hover:border-[rgba(var(--primary-rgb),0.3)] transition-all duration-300 flex flex-col justify-between hover:shadow-xl rounded-2xl p-4 bg-[var(--glass-bg)] border-[var(--glass-border)] text-[var(--text-color)]"
            >
              <div>
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center gap-2">
                    {getCategoryIcon(art.category)}
                    <span className="text-[9px] uppercase tracking-widest text-[var(--text-color)]/50 font-bold">
                      {art.category}
                    </span>
                  </div>
                  <span className="text-[9px] font-mono text-[var(--text-color)]/50">{art.readTime}</span>
                </div>

                <h3 className="font-bold text-sm text-[var(--text-color)] group-hover:text-[color:var(--primary-color)] transition-colors leading-tight mb-1.5">
                  {isHindiRoute ? art.titleHi : art.titleEn}
                </h3>
                <p className="text-[var(--text-color)]/70 text-xs font-light leading-relaxed mb-3.5 line-clamp-3">
                  {isHindiRoute ? art.descHi : art.descEn}
                </p>
              </div>

              <div className="pt-2.5 border-t border-[var(--glass-border)] flex justify-between items-center text-[10px] font-semibold">
                <span className="text-[var(--text-color)]/50 uppercase tracking-wide whitespace-nowrap shrink-0">Vedic Wiki</span>
                <span className="text-[color:var(--primary-color)] flex items-center gap-1 group-hover:translate-x-1 transition-transform whitespace-nowrap shrink-0">
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
