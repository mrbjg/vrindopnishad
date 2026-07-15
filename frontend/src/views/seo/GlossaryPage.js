'use client';

import React, { useState } from 'react';
import { Helmet } from 'react-helmet-async';
import { Link, useLocation } from 'react-router-dom';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import { GLOSSARY_TERMS } from '../../utils/glossaryTerms';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';
import { Search, BookOpen, Sparkles, ArrowRight } from 'lucide-react';

const GlossaryPage = () => {
  const location = useLocation();
  const isHindiRoute = location.pathname.startsWith('/hi');
  const pageUrl = `${SITE_URL}${isHindiRoute ? '/hi' : ''}/glossary`;
  const title = isHindiRoute 
    ? 'वृन्दावाणि शब्दकोश — वृंदावन के आध्यात्मिक एवं दार्शनिक शब्द'
    : 'Vrindavan Devotional Glossary — Spiritual & Theological Terms';
  const description = isHindiRoute
    ? 'वृंदावन की रसिक परंपरा, नित्य विहार, निकुंज लीला, मंजरी भाव, और सेवा जैसे पारिभाषिक शब्दों की विस्तृत व्याख्या और संदर्भ।'
    : 'Explore the comprehensive Vrindavan Devotional Glossary of spiritual, theological, and devotional terms, including etymology, Hindi, and English definitions.';

  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('All');

  const categories = ['All', ...new Set(GLOSSARY_TERMS.map(t => t.category))];

  const filteredTerms = GLOSSARY_TERMS.filter(t => {
    const matchesSearch = t.term.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          t.devanagari.includes(searchTerm) ||
                          t.definition.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesCategory = selectedCategory === 'All' || t.category === selectedCategory;
    return matchesSearch && matchesCategory;
  });

  return (
    <div className="animate-fade-in max-w-5xl mx-auto px-4 py-8">
      <Helmet>
        <title>{title}</title>
        <meta name="description" content={description} />
        <link rel="canonical" href={pageUrl} />
        <meta property="og:title" content={title} />
        <meta property="og:description" content={description} />
        <meta property="og:url" content={pageUrl} />
        <meta property="og:type" content="article" />
        <script type="application/ld+json">{JSON.stringify(generateArticleSchema(title, description, pageUrl))}</script>
        <script type="application/ld+json">{JSON.stringify(generateBreadcrumbSchema([{ name: 'Home', path: '/' }, { name: 'Glossary', path: '/glossary' }]))}</script>
      </Helmet>

      <header className="mb-10 text-center max-w-3xl mx-auto">
        <div className="badge border-amber-500/20 text-amber-500 bg-amber-500/5 mb-3 uppercase tracking-widest text-[9px] font-bold">
          {isHindiRoute ? "आध्यात्मिक शब्दकोश" : "Spiritual Encyclopedia"}
        </div>
        <h1 className="text-3xl md:text-5xl font-bold font-headings text-sacred-gradient mb-4">
          {isHindiRoute ? "वृन्दावाणि शब्दकोश" : "Vrindavan Devotional Glossary"}
        </h1>
        <p className="text-white/60 text-sm leading-relaxed">
          {isHindiRoute 
            ? "वृंदावन के रसिक संप्रदायों के दार्शनिक सिद्धांतों, भक्ति भावों और पारिभाषिक शब्दों का प्रामाणिक संग्रह।" 
            : "A curated dictionary of theological terms, spiritual sentiments, and philosophical concepts from the rasik traditions of Vrindavan."}
        </p>
      </header>

      
      <div className="glass-card p-4 rounded-2xl border border-white/5 mb-8 flex flex-col md:flex-row gap-4 items-center justify-between">
        
        <div className="relative w-full md:w-80">
          <input
            type="text"
            placeholder={isHindiRoute ? "शब्द खोजें..." : "Search terms, Devanagari or meanings..."}
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full bg-white/5 border border-white/10 rounded-xl py-2 pl-10 pr-4 text-xs text-white outline-none focus:border-primary/50 transition-all"
          />
          <Search size={14} className="absolute left-3.5 top-3 text-white/30" />
        </div>

        
        <div className="flex flex-wrap gap-1.5 justify-center">
          {categories.map(cat => (
            <button
              key={cat}
              onClick={() => setSelectedCategory(cat)}
              className={`px-3 py-1.5 rounded-xl border text-[10px] font-bold uppercase tracking-wider transition-all ${
                selectedCategory === cat
                  ? 'border-primary bg-primary/10 text-primary'
                  : 'border-white/5 bg-white/2 text-white/50 hover:border-white/10'
              }`}
            >
              {cat}
            </button>
          ))}
        </div>
      </div>

      
      {filteredTerms.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {filteredTerms.map(t => (
            <Link
              key={t.term}
              to={isHindiRoute ? `/hi/glossary/${t.slug}` : `/glossary/${t.slug}`}
              className="glass-card p-5 rounded-2xl border border-white/5 hover:border-primary/20 transition-all flex flex-col justify-between group text-left"
            >
              <div className="space-y-3">
                <div className="flex justify-between items-start border-b border-white/5 pb-2.5">
                  <div>
                    <h3 className="text-lg font-bold text-white/95 group-hover:text-primary transition-colors leading-tight">{t.term}</h3>
                    <span className="text-xs text-primary font-bold font-headings block mt-0.5">{t.devanagari}</span>
                  </div>
                  <span className="text-[9px] uppercase tracking-wider text-white/30 bg-white/5 px-2 py-0.5 rounded-md font-bold">
                    {t.category}
                  </span>
                </div>
                <p className="text-xs text-white/70 leading-relaxed font-light">{t.definition}</p>
              </div>

              <div className="mt-4 pt-3 border-t border-white/5 flex items-center justify-between text-[10px] text-white/35 font-light italic leading-relaxed">
                {t.etymology ? (
                  <div className="flex items-center gap-1.5">
                    <BookOpen size={10} className="text-primary shrink-0" />
                    <span className="line-clamp-1">{t.etymology}</span>
                  </div>
                ) : (
                  <div></div>
                )}
                <span className="flex items-center gap-1 text-[9px] uppercase tracking-wider text-primary font-bold group-hover:translate-x-1 transition-transform">
                  {isHindiRoute ? "विस्तृत विवरण" : "Read More"} <ArrowRight size={10} />
                </span>
              </div>
            </Link>
          ))}
        </div>
      ) : (
        <div className="text-center py-20 glass-card rounded-2xl border border-white/5">
          <BookOpen size={48} className="text-white/15 mx-auto mb-4" />
          <h3 className="text-lg font-bold text-white/70">{isHindiRoute ? "कोई शब्द नहीं मिला" : "No terms found"}</h3>
          <p className="text-xs text-white/40 mt-1">{isHindiRoute ? "कृपया अपनी खोज बदलें।" : "Try adjusting your search query or category filters."}</p>
        </div>
      )}

      
      <section className="mt-16 bg-white/[0.015] border border-white/5 rounded-3xl p-8 max-w-4xl mx-auto text-left">
        <h2 className="text-lg font-bold text-minimal-gold mb-4 flex items-center gap-2">
          <Sparkles size={18} className="text-primary" />
          {isHindiRoute ? "वृन्दावन भक्ति भाषा दर्शन को समझना" : "Understanding the Language of Vrindavan Devotion"}
        </h2>
        <p className="text-xs text-white/60 leading-relaxed mb-4">
          {isHindiRoute 
            ? "वृंदावन के रसिक संतों द्वारा रचित पद और वाणियाँ मुख्य रूप से ब्रजभाषा में हैं, जिसमें गहरे संस्कृत दार्शनिक शब्द गुंथे हुए हैं। युगल सरकार के नित्य निकुंज विहार के गूढ़ अर्थों को समझने के लिए इन पारिभाषिक शब्दों का ज्ञान होना अनिवार्य है।"
            : "The poetry and verses (Vaanis) composed by the saints of Vrindavan are primarily in Braj Bhasha, a sweet western dialect of Hindi, interspersed with technical Sanskrit theological terms. To fully appreciate the emotional depth (Bhava) of their writings, one must familiarize oneself with these foundational concepts."}
        </p>
        <p className="text-xs text-white/60 leading-relaxed">
          {isHindiRoute
            ? "इस ज्ञानकोश में हमने इन शब्दों को शास्त्रीय शुद्धता और रसिक सिद्धांतों के साथ संकलित किया है ताकि साधक अपने नित्य स्वाध्याय और स्मरण में इनका लाभ उठा सकें।"
            : "For example, terms like Nikunj and Nitya Vihar form the core setting and activity of the supreme reality, indicating that divine union is the highest destination. In this encyclopedia, we collect and index these terms with scholarly precision to aid seekers in their daily Swadhyaya (study)."}
        </p>
      </section>

      <InternalLinks exclude={['/glossary']} count={4} />
      <SEOFooter />
    </div>
  );
};

export default GlossaryPage;
export { GLOSSARY_TERMS };
