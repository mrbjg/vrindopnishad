import React, { useState, useEffect, useContext } from 'react';
import { useParams, Link, useLocation } from 'react-router-dom';
import { ApiContext } from '../App';
import { extractRelations, slugify } from '../utils/relations';
import { ArrowLeft, Music, FileText, Tag, BookOpen, Star, HelpCircle, GitCommit } from 'lucide-react';
import { Helmet } from 'react-helmet-async';
import { getSaintMetadata } from '../utils/saintMetadata';

const getInitials = (name) => {
  if (!name) return 'V';
  let clean = name.replace(/^(Shri|Swami|Sri|Shree|श्री|स्वामी|श्रीमद्)\s+/i, '').trim();
  if (!clean.length) clean = name;
  const first = clean.charAt(0);
  return first.match(/[a-zA-Z]/) ? first.toUpperCase() : first;
};

const SaintDetailPage = () => {
  const { slug } = useParams();
  const location = useLocation();
  const isHindiRoute = location.pathname.startsWith('/hi');
  const { apiService } = useContext(ApiContext);

  const [sant, setSant] = useState(() => {
    try {
      const cached = localStorage.getItem('vrindopnishad_saints_cache');
      if (cached) {
        const santsList = JSON.parse(cached);
        return santsList.find(s => s.slug === slug) || null;
      }
    } catch (e) {}
    return null;
  });
  const [loading, setLoading] = useState(() => {
    try {
      const cached = localStorage.getItem('vrindopnishad_saints_cache');
      if (cached) {
        const santsList = JSON.parse(cached);
        return !santsList.find(s => s.slug === slug);
      }
    } catch (e) {}
    return true;
  });
  const [activeDetailTab, setActiveDetailTab] = useState('bio');

  useEffect(() => {
    let active = true;
    const load = async () => {
      try {
        const allItems = await apiService.getAllContent(null, 10000);
        const relations = extractRelations(allItems);
        const foundSant = relations.sants.find(s => s.slug === slug);
        if (active) {
          setSant(foundSant || null);
          localStorage.setItem('vrindopnishad_saints_cache', JSON.stringify(relations.sants));
        }
      } catch (error) {
        console.error('Error loading saint details:', error);
      } finally {
        if (active) setLoading(false);
      }
    };
    load();
    return () => { active = false; };
  }, [slug, apiService]);

  if (loading) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-12 animate-pulse space-y-8">
        <div className="h-6 bg-white/10 rounded w-24" />
        <div className="flex items-center gap-6">
          <div className="w-20 h-20 rounded-full bg-white/10" />
          <div className="space-y-3 flex-1">
            <div className="h-8 bg-white/10 rounded w-1/3" />
            <div className="h-4 bg-white/5 rounded w-1/4" />
          </div>
        </div>
        <div className="h-32 bg-white/5 rounded-2xl w-full" />
      </div>
    );
  }

  if (!sant) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-24 text-center">
        <h2 className="text-3xl font-bold mb-4 font-headings">Saint not found</h2>
        <p className="text-white/40 mb-8">The master you are looking for does not exist in our registry.</p>
        <Link to={isHindiRoute ? "/hi/saints" : "/saints"} className="btn-premium px-8 py-3">
          Explore All Saints
        </Link>
      </div>
    );
  }

  // Load custom metadata if available
  const meta = getSaintMetadata(slug);

  const lineage = meta 
    ? (isHindiRoute ? meta.lineageHi : meta.lineageEn)
    : (isHindiRoute ? "वैष्णव संप्रदाय" : "Vaishnava Tradition");
  
  const timeline = meta 
    ? (isHindiRoute ? meta.timelineHi : meta.timelineEn)
    : (isHindiRoute ? "मध्यकालीन काल" : "Medieval Era");

  const places = meta 
    ? (isHindiRoute ? meta.associatedPlacesHi : meta.associatedPlacesEn)
    : (isHindiRoute ? "वृंदावन धाम" : "Vrindavan Dham");

  const bioText = meta 
    ? (isHindiRoute ? meta.biographyHi : meta.biographyEn)
    : (sant.biography?.text || (isHindiRoute ? "ब्रज परंपरा के वैष्णव संत।" : "Vaishnava saint of the Braj tradition."));

  return (
    <div className="animate-fade-in max-w-4xl mx-auto px-4 py-8">
      <Helmet>
        <title>{isHindiRoute ? `${sant.name} जीवनी एवं वाणी संग्रह | Vrindopnishad` : `${sant.hinglishName} Biography & Vaanis | Vrindopnishad`}</title>
        <meta name="description" content={bioText.substring(0, 160)} />
        <link rel="canonical" href={isHindiRoute ? `https://path.vrindopnishad.in/hi/saint/${slug}` : `https://path.vrindopnishad.in/saint/${slug}`} />
        
        {/* Structured Data: Person (Saint), Breadcrumb & FAQ (if available) */}
        <script type="application/ld+json">
          {JSON.stringify({
            "@context": "https://schema.org",
            "@graph": [
              {
                "@type": "Person",
                "@id": `https://path.vrindopnishad.in/saint/${slug}#person`,
                "name": sant.name,
                "alternateName": sant.hinglishName !== sant.name ? sant.hinglishName : undefined,
                "description": bioText.substring(0, 200),
                "url": `https://path.vrindopnishad.in/saint/${slug}`,
                "image": sant.image || "https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png",
                "knowsAbout": ["Vaishnavism", "Bhakti Yoga", "Braj Rasik Heritage", "Vrindavan"],
                "affiliation": {
                  "@type": "Organization",
                  "name": meta ? (isHindiRoute ? meta.associatedSampradayaHi : meta.associatedSampradayaEn) : "Vaishnava Sampradaya"
                }
              },
              {
                "@type": "BreadcrumbList",
                "@id": `https://path.vrindopnishad.in/saint/${slug}#breadcrumb`,
                "itemListElement": [
                  {
                    "@type": "ListItem",
                    "position": 1,
                    "name": isHindiRoute ? "होम" : "Home",
                    "item": isHindiRoute ? "https://path.vrindopnishad.in/hi" : "https://path.vrindopnishad.in/"
                  },
                  {
                    "@type": "ListItem",
                    "position": 2,
                    "name": isHindiRoute ? "संत" : "Saints",
                    "item": isHindiRoute ? "https://path.vrindopnishad.in/hi/saints" : "https://path.vrindopnishad.in/saints"
                  },
                  {
                    "@type": "ListItem",
                    "position": 3,
                    "name": isHindiRoute ? sant.name : sant.hinglishName,
                    "item": isHindiRoute ? `https://path.vrindopnishad.in/hi/saint/${slug}` : `https://path.vrindopnishad.in/saint/${slug}`
                  }
                ]
              },
              ...(meta && meta.faq ? [
                {
                  "@type": "FAQPage",
                  "@id": `https://path.vrindopnishad.in/saint/${slug}#faq`,
                  "mainEntity": meta.faq.map(f => ({
                    "@type": "Question",
                    "name": isHindiRoute ? f.qHi : f.qEn,
                    "acceptedAnswer": {
                      "@type": "Answer",
                      "text": isHindiRoute ? f.aHi : f.aEn
                    }
                  }))
                }
              ] : [])
            ]
          })}
        </script>
      </Helmet>

      <Link 
        to={isHindiRoute ? "/hi/saints" : "/saints"} 
        className="inline-flex items-center gap-2 text-white/40 hover:text-white mb-8 transition-colors text-xs uppercase tracking-wider"
      >
        <ArrowLeft size={14} />
        {isHindiRoute ? "सभी संत" : "All Saints"}
      </Link>

      {/* Header Profile Section */}
      <div className="flex flex-col sm:flex-row items-center gap-6 mb-8 pb-6 border-b border-white/5 text-center sm:text-left select-none">
        <div className="w-24 h-24 rounded-full bg-amber-500/10 border border-amber-500/20 flex items-center justify-center text-amber-500 font-bold text-4xl shadow-xl shrink-0">
          {getInitials(isHindiRoute ? sant.name : sant.hinglishName)}
        </div>
        <div className="flex-1 min-w-0">
          <div className="badge border-amber-500/20 text-amber-500 bg-amber-500/5 mb-2 uppercase tracking-widest text-[9px] font-bold">
            {isHindiRoute ? "रसिक संत जीवनी" : "Rasik Saint Biography"}
          </div>
          <h1 className="text-3xl md:text-4xl font-bold font-headings text-sacred-gradient mb-3 truncate">
            {isHindiRoute ? sant.name : sant.hinglishName}
          </h1>
          
          {/* Quick Facts Grid */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 text-left mt-3">
            <div className="bg-white/[0.015] border border-white/5 rounded-xl p-2.5">
              <span className="text-[8px] uppercase tracking-wider text-white/35 block">{isHindiRoute ? "परंपरा / Lineage" : "Lineage"}</span>
              <span className="text-xs font-bold text-white/80 block mt-0.5 truncate">{lineage}</span>
            </div>
            <div className="bg-white/[0.015] border border-white/5 rounded-xl p-2.5">
              <span className="text-[8px] uppercase tracking-wider text-white/35 block">{isHindiRoute ? "काल / Era" : "Era / Timeline"}</span>
              <span className="text-xs font-bold text-white/80 block mt-0.5 truncate">{timeline}</span>
            </div>
            <div className="bg-white/[0.015] border border-white/5 rounded-xl p-2.5">
              <span className="text-[8px] uppercase tracking-wider text-white/35 block">{isHindiRoute ? "साधना स्थल / Place" : "Associated Place"}</span>
              <span className="text-xs font-bold text-white/80 block mt-0.5 truncate">{places}</span>
            </div>
          </div>
        </div>
      </div>

      {/* Relational Knowledge Graph Card */}
      {meta && (
        <section className="mb-8 p-5 rounded-2xl border border-white/5 bg-white/[0.01] hover:border-amber-500/10 transition-all text-left">
          <h2 className="text-xs font-bold uppercase tracking-widest text-amber-500/80 mb-4 flex items-center gap-2">
            <GitCommit size={14} className="text-primary" />
            {isHindiRoute ? "आध्यात्मिक सम्बन्ध एवं परंपरा विवरण" : "Spiritual Lineage & Devotional Mood"}
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
            {meta.discipleOfEn && (
              <div className="py-2 border-b border-white/5 flex justify-between gap-4">
                <span className="text-white/40">{isHindiRoute ? "दीक्षा गुरु / पिता" : "Disciple of / Guru"}</span>
                <span className="font-bold text-white/80 text-right">{isHindiRoute ? meta.discipleOfHi : meta.discipleOfEn}</span>
              </div>
            )}
            {meta.influencedByEn && (
              <div className="py-2 border-b border-white/5 flex justify-between gap-4">
                <span className="text-white/40">{isHindiRoute ? "विचारधारा प्रभाव" : "Influenced by"}</span>
                <span className="font-bold text-white/80 text-right">{isHindiRoute ? meta.influencedByHi : meta.influencedByEn}</span>
              </div>
            )}
            {meta.associatedSampradayaEn && (
              <div className="py-2 border-b border-white/5 flex justify-between gap-4">
                <span className="text-white/40">{isHindiRoute ? "सम्बद्ध संप्रदाय" : "Associated Sampradaya"}</span>
                <span className="font-bold text-white/80 text-right">{isHindiRoute ? meta.associatedSampradayaHi : meta.associatedSampradayaEn}</span>
              </div>
            )}
            {meta.devotionalMoodEn && (
              <div className="py-2 border-b border-white/5 flex justify-between gap-4">
                <span className="text-white/40">{isHindiRoute ? "भक्ति भाव / रस" : "Devotional Mood (Bhav)"}</span>
                <span className="font-bold text-white/80 text-right">{isHindiRoute ? meta.devotionalMoodHi : meta.devotionalMoodEn}</span>
              </div>
            )}
          </div>
        </section>
      )}

      {/* Dynamic Detail Tabs */}
      <div className="flex bg-white/5 p-1 rounded-xl gap-1 mb-8 overflow-x-auto scrollbar-hide">
        {[
          { id: 'bio', label: isHindiRoute ? "जीवनी" : "Biography" },
          ...(meta ? [{ id: 'teachings', label: isHindiRoute ? "दर्शन एवं शिक्षा" : "Teachings" }] : []),
          { id: 'literary', label: isHindiRoute ? "साहित्य" : "Literary Works" },
          ...(meta && meta.faq ? [{ id: 'faq', label: isHindiRoute ? "प्रश्नोत्तर" : "FAQ" }] : [])
        ].map(tab => (
          <button
            key={tab.id}
            onClick={() => setActiveDetailTab(tab.id)}
            className={`flex-1 min-w-[80px] py-2 text-xs font-bold uppercase tracking-wider rounded-lg transition-all ${
              activeDetailTab === tab.id 
                ? 'bg-white/[0.04] border border-white/10 text-primary' 
                : 'text-white/45 hover:text-white/70'
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {/* Tab Contents */}
      <div className="min-h-[16rem]">
        {/* Tab 1: Biography */}
        {activeDetailTab === 'bio' && (
          <section className="mb-12 animate-fade-in text-left">
            <h2 className="text-xl font-bold font-headings text-minimal-gold mb-4 flex items-center gap-2">
              <BookOpen size={20} className="text-primary" />
              {isHindiRoute ? "जीवन चरित" : "Biography & History"}
            </h2>
            <div className="border-l-4 border-primary/50 bg-white/[0.02] dark:bg-white/[0.01] p-6 rounded-r-2xl text-sm leading-relaxed text-stone-600 dark:text-white/70 whitespace-pre-line border-y border-r border-white/5">
              {bioText}
            </div>
          </section>
        )}

        {/* Tab 2: Teachings */}
        {activeDetailTab === 'teachings' && meta && (
          <section className="mb-12 animate-fade-in text-left">
            <h2 className="text-xl font-bold font-headings text-minimal-gold mb-4 flex items-center gap-2">
              <Star size={20} className="text-primary" />
              {isHindiRoute ? "आध्यात्मिक दर्शन एवं उपदेश" : "Philosophy & Core Teachings"}
            </h2>
            <div className="border-l-4 border-amber-500/50 bg-white/[0.02] dark:bg-white/[0.01] p-6 rounded-r-2xl text-sm leading-relaxed text-stone-600 dark:text-white/70 whitespace-pre-line border-y border-r border-white/5">
              {isHindiRoute ? meta.teachingsHi : meta.teachingsEn}
            </div>
          </section>
        )}

        {/* Tab 3: Literary Works */}
        {activeDetailTab === 'literary' && (
          <section className="mb-12 animate-fade-in text-left space-y-6">
            {meta && (
              <div className="border-l-4 border-sky-500/50 bg-white/[0.02] dark:bg-white/[0.01] p-6 rounded-r-2xl text-sm leading-relaxed text-stone-600 dark:text-white/70 whitespace-pre-line border-y border-r border-white/5">
                <h3 className="font-bold text-xs uppercase text-sky-400 mb-2 tracking-wider">Literary Style & Focus</h3>
                <p>{isHindiRoute ? meta.literaryStyleHi : meta.literaryStyleEn}</p>
              </div>
            )}

            {sant.books.length > 0 ? (
              <div className="space-y-4">
                <h3 className="font-bold text-sm text-minimal-gold uppercase tracking-wider">
                  {isHindiRoute ? "रचित ग्रन्थ सूची" : "Scriptural Catalog"}
                </h3>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  {sant.books.map(book => {
                    const bookSlug = slugify(book);
                    return (
                      <Link 
                        key={book}
                        to={isHindiRoute ? `/hi/book/${bookSlug}` : `/book/${bookSlug}`}
                        className="glass-card p-4 group hover:border-amber-500/20 transition-all flex justify-between items-center"
                      >
                        <div>
                          <h3 className="font-bold text-sm text-white/90 group-hover:text-primary transition-colors">{book}</h3>
                          <span className="text-[10px] text-white/30 uppercase mt-1 block">Collection</span>
                        </div>
                        <ArrowLeft size={16} className="rotate-180 text-white/20 group-hover:text-primary group-hover:translate-x-1 transition-all" />
                      </Link>
                    );
                  })}
                </div>
              </div>
            ) : (
              <p className="text-white/40 text-center py-6 text-xs">No books indexed for this saint.</p>
            )}
          </section>
        )}

        {/* Tab 4: FAQ */}
        {activeDetailTab === 'faq' && meta && meta.faq && (
          <section className="mb-12 animate-fade-in text-left space-y-4">
            <h2 className="text-xl font-bold font-headings text-minimal-gold mb-4 flex items-center gap-2">
              <HelpCircle size={20} className="text-primary" />
              {isHindiRoute ? "अक्सर पूछे जाने वाले प्रश्न" : "Frequently Asked Questions"}
            </h2>
            <div className="space-y-4">
              {meta.faq.map((f, idx) => (
                <div key={idx} className="glass-card p-5 rounded-2xl border border-white/5 space-y-2">
                  <h3 className="font-bold text-sm text-white/95">{isHindiRoute ? f.qHi : f.qEn}</h3>
                  <p className="text-xs text-white/60 leading-relaxed font-light">{isHindiRoute ? f.aHi : f.aEn}</p>
                </div>
              ))}
            </div>
          </section>
        )}
      </div>

      {/* Topical Connections Section */}
      {meta && (meta.relatedSaints || meta.relatedGranthas || meta.associatedGlossary) && (
        <section className="mt-8 border-t border-white/5 pt-8 text-left">
          <h2 className="text-xl font-bold font-headings text-minimal-gold mb-6 flex items-center gap-2">
            <Tag size={20} className="text-primary" />
            {isHindiRoute ? "सम्बन्धित सन्दर्भ (Topical Connections)" : "Topical Connections"}
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {/* Related Saints */}
            {meta.relatedSaints && meta.relatedSaints.length > 0 && (
              <div className="glass-card p-5 rounded-2xl border border-white/5 space-y-3">
                <h3 className="font-bold text-xs uppercase tracking-wider text-amber-500/80">
                  {isHindiRoute ? "सम्बन्धित सन्त" : "Related Saints"}
                </h3>
                <div className="flex flex-wrap gap-2">
                  {meta.relatedSaints.map(s => (
                    <Link
                      key={s.slug}
                      to={isHindiRoute ? `/hi/saint/${s.slug}` : `/saint/${s.slug}`}
                      className="px-3 py-1.5 rounded-xl bg-white/[0.03] hover:bg-white/[0.08] border border-white/5 hover:border-amber-500/30 text-xs text-white/80 hover:text-primary transition-all select-none"
                    >
                      {isHindiRoute ? s.nameHi : s.nameEn}
                    </Link>
                  ))}
                </div>
              </div>
            )}

            {/* Related Granthas */}
            {meta.relatedGranthas && meta.relatedGranthas.length > 0 && (
              <div className="glass-card p-5 rounded-2xl border border-white/5 space-y-3">
                <h3 className="font-bold text-xs uppercase tracking-wider text-sky-400">
                  {isHindiRoute ? "प्रमुख ग्रन्थ" : "Key Scriptures"}
                </h3>
                <div className="flex flex-wrap gap-2">
                  {meta.relatedGranthas.map(g => (
                    <Link
                      key={g.slug}
                      to={isHindiRoute ? `/hi/book/${g.slug}` : `/book/${g.slug}`}
                      className="px-3 py-1.5 rounded-xl bg-white/[0.03] hover:bg-white/[0.08] border border-white/5 hover:border-sky-500/30 text-xs text-white/80 hover:text-sky-400 transition-all select-none"
                    >
                      {isHindiRoute ? g.nameHi : g.nameEn}
                    </Link>
                  ))}
                </div>
              </div>
            )}

            {/* Associated Glossary Concepts */}
            {meta.associatedGlossary && meta.associatedGlossary.length > 0 && (
              <div className="glass-card p-5 rounded-2xl border border-white/5 space-y-3">
                <h3 className="font-bold text-xs uppercase tracking-wider text-indigo-400">
                  {isHindiRoute ? "प्रमुख अवधारणाएँ" : "Core Concepts"}
                </h3>
                <div className="flex flex-wrap gap-2">
                  {meta.associatedGlossary.map(c => (
                    <Link
                      key={c.slug}
                      to={isHindiRoute ? `/hi/glossary/${c.slug}` : `/glossary/${c.slug}`}
                      className="px-3 py-1.5 rounded-xl bg-white/[0.03] hover:bg-white/[0.08] border border-white/5 hover:border-indigo-500/30 text-xs text-white/80 hover:text-indigo-400 transition-all select-none"
                    >
                      {isHindiRoute ? c.termHi : c.termEn}
                    </Link>
                  ))}
                </div>
              </div>
            )}
          </div>
        </section>
      )}

      {/* Verse collection */}
      <section className="mt-8 border-t border-white/5 pt-8">
        <h2 className="text-xl font-bold font-headings text-minimal-gold mb-6 flex items-center gap-2 text-left">
          <FileText size={20} className="text-primary" />
          {isHindiRoute ? `श्री ${sant.name} वाणी संग्रह` : `${sant.hinglishName} Collected Verses`}
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {sant.verses.map((verse) => (
            <Link
              key={verse.id}
              to={isHindiRoute ? `/hi/content/${verse.slug || verse.id}` : `/content/${verse.slug || verse.id}`}
              className="glass-card p-4 flex flex-col justify-between group hover:border-amber-500/20 transition-all min-h-[140px] text-left"
            >
              <div>
                <div className="flex justify-between items-start gap-4 mb-2">
                  <span className="text-[10px] uppercase tracking-wider text-amber-500/80 bg-amber-500/5 px-2.5 py-0.5 rounded border border-amber-500/10 font-bold">
                    {verse.category}
                  </span>
                  {verse.audio_url && (
                    <span className="text-sky-400 bg-sky-500/5 border border-sky-500/10 p-1.5 rounded-full hover:scale-105 transition-transform">
                      <Music size={12} />
                    </span>
                  )}
                </div>
                <h3 className="font-bold text-base text-white/90 group-hover:text-primary transition-colors leading-snug line-clamp-1 py-1">
                  {verse.cleanTitle}
                </h3>
              </div>
              <p className="text-white/45 text-xs line-clamp-2 leading-relaxed mt-2 select-none">
                {verse.hindi_text || verse.english_translation || verse.description}
              </p>
            </Link>
          ))}
        </div>
      </section>
    </div>
  );
};

export default SaintDetailPage;
