'use client';

import React, { useState } from 'react';
import { useParams, Link, useLocation } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { BookOpen, Sparkles, ArrowLeft, User, Book, Link2, Quote } from 'lucide-react';
import { GLOSSARY_TERMS } from '../../utils/glossaryTerms';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';

const GlossaryDetailPage = () => {
  const { slug } = useParams();
  const location = useLocation();
  const isHindiRoute = location.pathname.startsWith('/hi');

  
  const termData = GLOSSARY_TERMS.find(t => t.slug === slug.toLowerCase());

  const [activeLangTab, setActiveLangTab] = useState(isHindiRoute ? 'hi' : 'en');

  if (!termData) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-24 text-center">
        <h2 className="text-3xl font-bold mb-4 font-headings">Term not found</h2>
        <p className="text-white/40 mb-8">The theological term you are looking for is not in our spiritual encyclopedia.</p>
        <Link to={isHindiRoute ? "/hi/glossary" : "/glossary"} className="btn-premium px-8 py-3">
          Back to Glossary
        </Link>
      </div>
    );
  }

  const pageUrl = `${SITE_URL}${isHindiRoute ? '/hi' : ''}/glossary/${termData.slug}`;
  const title = isHindiRoute 
    ? `${termData.term} (${termData.devanagari}) का अर्थ, परिभाषा और आध्यात्मिक संदर्भ`
    : `${termData.term} Meaning, Definition & Theological Context in Vrindavan Devotion`;
  const description = isHindiRoute
    ? `${termData.term} (${termData.devanagari}) क्या है? जानिए इसका संस्कृत अर्थ, परिभाषा, वैष्णव संप्रदाय में इसका महत्व और रसिक संतों के विचार।`
    : `Explore the definition, Sanskrit meaning, etymology, and deep theological context of ${termData.term} (${termData.devanagari}) in Vrindavan Rasik devotion.`;

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
        <script type="application/ld+json">
          {JSON.stringify(generateBreadcrumbSchema([
            { name: 'Home', path: '/' },
            { name: 'Glossary', path: '/glossary' },
            { name: termData.term, path: `/glossary/${termData.slug}` }
          ]))}
        </script>
        
        <script type="application/ld+json">
          {JSON.stringify({
            "@context": "https://schema.org",
            "@type": "FAQPage",
            "mainEntity": [
              {
                "@type": "Question",
                "name": `What is the meaning of ${termData.term} in Braj devotion?`,
                "acceptedAnswer": {
                  "@type": "Answer",
                  "text": termData.definition
                }
              },
              {
                "@type": "Question",
                "name": `What is the Sanskrit etymology of ${termData.term}?`,
                "acceptedAnswer": {
                  "@type": "Answer",
                  "text": termData.etymology
                }
              }
            ]
          })}
        </script>
      </Helmet>

      <Link 
        to={isHindiRoute ? "/hi/glossary" : "/glossary"} 
        className="inline-flex items-center gap-2 text-white/40 hover:text-white mb-8 transition-colors text-xs uppercase tracking-wider text-left"
      >
        <ArrowLeft size={14} />
        {isHindiRoute ? "शब्दकोश पर लौटें" : "Back to Glossary"}
      </Link>

      <header className="mb-10 text-left max-w-4xl">
        <div className="badge border-indigo-500/20 text-indigo-400 bg-indigo-500/5 mb-3 uppercase tracking-widest text-[9px] font-bold">
          {termData.category} • Braj Glossary
        </div>
        <div className="flex flex-col md:flex-row md:items-baseline gap-2 md:gap-4 mb-4">
          <h1 className="text-3xl md:text-5xl font-bold font-headings text-sacred-gradient">
            {termData.term}
          </h1>
          <span className="text-2xl md:text-3xl text-primary font-headings font-bold">{termData.devanagari}</span>
        </div>
        <p className="text-white/80 text-sm leading-relaxed border-l-2 border-primary/50 pl-4 py-1.5 bg-white/[0.01]">
          {termData.definition}
        </p>
      </header>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 items-stretch mb-12">
        
        <div className="lg:col-span-2 space-y-6 text-left">
          <div className="glass-card p-6 rounded-3xl border border-white/5 space-y-6">
            <div className="flex justify-between items-center border-b border-white/5 pb-4">
              <h2 className="text-md font-bold text-minimal-gold flex items-center gap-2">
                <Sparkles size={16} className="text-primary" />
                {isHindiRoute ? "विस्तृत दार्शनिक एवं आध्यात्मिक विवेचन" : "Theological Context & Philosophy"}
              </h2>
              
              <div className="flex bg-white/5 p-0.5 rounded-lg gap-0.5">
                <button 
                  onClick={() => setActiveLangTab('en')}
                  className={`px-2.5 py-1 text-[9px] font-bold uppercase rounded-md transition-all ${activeLangTab === 'en' ? 'bg-primary/20 text-primary border border-primary/20' : 'text-white/40 hover:text-white/60'}`}
                >
                  English
                </button>
                <button 
                  onClick={() => setActiveLangTab('hi')}
                  className={`px-2.5 py-1 text-[9px] font-bold uppercase rounded-md transition-all ${activeLangTab === 'hi' ? 'bg-primary/20 text-primary border border-primary/20' : 'text-white/40 hover:text-white/60'}`}
                >
                  हिंदी
                </button>
              </div>
            </div>

            <div className="text-xs text-white/75 leading-relaxed space-y-4 font-light whitespace-pre-line">
              {activeLangTab === 'hi' ? termData.theologicalContextHi : termData.theologicalContextEn}
            </div>
          </div>

          
          {termData.references && (
            <div className="glass-card p-6 rounded-3xl border border-white/5 space-y-3 bg-white/[0.015]">
              <h3 className="font-bold text-xs uppercase tracking-wider text-white/45 flex items-center gap-1.5">
                <Quote size={12} className="text-primary" />
                {isHindiRoute ? "शास्त्र प्रमाण एवं सन्दर्भ" : "Scriptural Citations & Authority References"}
              </h3>
              <p className="text-xs text-white/70 italic font-serif pl-4 border-l-2 border-white/10">
                "{termData.references}"
              </p>
            </div>
          )}
        </div>

        
        <div className="space-y-6 text-left">
          
          <div className="glass-card p-6 rounded-3xl border border-white/5 space-y-4 bg-white/[0.015]">
            <h3 className="font-bold text-xs uppercase tracking-wider text-minimal-gold flex items-center gap-1.5">
              <BookOpen size={14} className="text-primary" />
              {isHindiRoute ? "व्युत्पत्ति एवं अर्थ" : "Etymology & Root"}
            </h3>
            <p className="text-[11px] text-white/70 leading-relaxed font-light italic">
              {termData.etymology}
            </p>
          </div>

          
          {(termData.relatedSaints || termData.relatedGranthas) && (
            <div className="glass-card p-6 rounded-3xl border border-white/5 space-y-4">
              <h3 className="font-bold text-xs uppercase tracking-wider text-minimal-gold flex items-center gap-1.5">
                <Link2 size={14} className="text-primary" />
                {isHindiRoute ? "सम्बंधित सम्बन्ध सूत्र" : "Knowledge Graph Nodes"}
              </h3>
              
              {termData.relatedSaints && termData.relatedSaints.length > 0 && (
                <div className="space-y-2.5">
                  <span className="text-[9px] uppercase tracking-wider text-white/30 block font-bold">{isHindiRoute ? "रसिक सन्त" : "Associated Saints"}</span>
                  <div className="flex flex-col gap-1.5">
                    {termData.relatedSaints.map(s => (
                      <Link 
                        key={s.slug} 
                        to={isHindiRoute ? `/hi/saints/${s.slug}` : `/saints/${s.slug}`}
                        className="flex items-center gap-2 p-2 rounded-xl bg-white/[0.02] border border-white/5 hover:border-amber-500/20 text-xs text-white/70 hover:text-primary transition-all"
                      >
                        <User size={12} className="text-amber-500/60" />
                        <span className="font-medium">{s.nameEn}</span>
                      </Link>
                    ))}
                  </div>
                </div>
              )}

              {termData.relatedGranthas && termData.relatedGranthas.length > 0 && (
                <div className="space-y-2.5 pt-2">
                  <span className="text-[9px] uppercase tracking-wider text-white/30 block font-bold">{isHindiRoute ? "सम्बद्ध ग्रन्थ" : "Associated Scriptures"}</span>
                  <div className="flex flex-col gap-1.5">
                    {termData.relatedGranthas.map(g => (
                      <Link 
                        key={g.slug} 
                        to={isHindiRoute ? `/hi/granthas/${g.slug}` : `/granthas/${g.slug}`}
                        className="flex items-center gap-2 p-2 rounded-xl bg-white/[0.02] border border-white/5 hover:border-sky-500/20 text-xs text-white/70 hover:text-sky-400 transition-all"
                      >
                        <Book size={12} className="text-sky-400/60" />
                        <span className="font-medium">{g.nameEn}</span>
                      </Link>
                    ))}
                  </div>
                </div>
              )}
            </div>
          )}
        </div>
      </div>

      <InternalLinks exclude={[`/glossary/${termData.slug}`]} count={4} />
      <SEOFooter />
    </div>
  );
};

export default GlossaryDetailPage;
