import React, { useState, useEffect, useContext } from 'react';
import { useParams, Link, useLocation } from 'react-router-dom';
import { ApiContext } from '../App';
import { extractRelations, slugify } from '../utils/relations';
import { ArrowLeft, Book, Music, FileText, Tag, BookOpen } from 'lucide-react';
import { Helmet } from 'react-helmet-async';

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

  const [sant, setSant] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let active = true;
    const load = async () => {
      try {
        const allItems = await apiService.getAllContent(null, 10000);
        const relations = extractRelations(allItems);
        const foundSant = relations.sants.find(s => s.slug === slug);
        if (active) {
          setSant(foundSant || null);
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

  return (
    <div className="animate-fade-in max-w-4xl mx-auto px-4 py-8">
      <Helmet>
        <title>{isHindiRoute ? `${sant.name} जीवनी एवं वाणी संग्रह | Vrindopnishad` : `${sant.hinglishName} Biography & Vaanis | Vrindopnishad`}</title>
        <meta name="description" content={sant.biography?.text ? sant.biography.text.substring(0, 160) : `Complete collection of spiritual poetry and hymns written by ${sant.hinglishName}.`} />
        <link rel="canonical" href={isHindiRoute ? `https://path.vrindopnishad.in/hi/saint/${slug}` : `https://path.vrindopnishad.in/saint/${slug}`} />
        
        {/* Structured Data: Person & Breadcrumb */}
        <script type="application/ld+json">
          {JSON.stringify({
            "@context": "https://schema.org",
            "@graph": [
              {
                "@type": "Person",
                "@id": `https://path.vrindopnishad.in/saint/${slug}#person`,
                "name": sant.name,
                "alternateName": sant.hinglishName,
                "description": sant.biography?.text || `Vaishnava Saint and spiritual master of Braj.`,
                "url": `https://path.vrindopnishad.in/saint/${slug}`,
                "image": sant.image || "https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png",
                "knowsAbout": ["Vaishnavism", "Bhakti Yoga", "Braj Rasik Heritage", "Vrindavan"]
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
              }
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
      <div className="flex flex-col sm:flex-row items-center gap-6 mb-10 pb-8 border-b border-white/5 text-center sm:text-left">
        <div className="w-24 h-24 rounded-full bg-amber-500/10 border border-amber-500/20 flex items-center justify-center text-amber-500 font-bold text-4xl shadow-xl">
          {getInitials(isHindiRoute ? sant.name : sant.hinglishName)}
        </div>
        <div className="flex-1">
          <h1 className="text-3xl md:text-4xl font-bold font-headings text-sacred-gradient mb-2">
            {isHindiRoute ? sant.name : sant.hinglishName}
          </h1>
          {sant.biography?.rawItem?.tags && (
            <div className="flex flex-wrap justify-center sm:justify-start gap-2 mt-2">
              {sant.biography.rawItem.tags.map(t => (
                <span key={t} className="px-2.5 py-0.5 rounded-full border border-white/5 bg-white/5 text-[10px] text-white/40 uppercase tracking-wider flex items-center gap-1">
                  <Tag size={8} />
                  {t}
                </span>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Biography section */}
      {sant.biography && (
        <section className="mb-12">
          <h2 className="text-xl font-bold font-headings text-minimal-gold mb-4 flex items-center gap-2">
            <BookOpen size={20} className="text-primary" />
            {isHindiRoute ? "जीवन चरित (Biography)" : "Biography"}
          </h2>
          <div className="border-l-4 border-primary/50 bg-white/[0.02] dark:bg-white/[0.01] p-6 rounded-r-2xl text-sm leading-relaxed text-stone-600 dark:text-white/70 whitespace-pre-line border-y border-r border-white/5">
            {sant.biography.text}
          </div>
        </section>
      )}

      {/* Books list */}
      {sant.books.length > 0 && (
        <section className="mb-12">
          <h2 className="text-xl font-bold font-headings text-minimal-gold mb-4 flex items-center gap-2">
            <Book size={20} className="text-primary" />
            {isHindiRoute ? "प्रमुख ग्रन्थ एवं वाणी" : "Major Granthas & Vaanis"}
          </h2>
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
        </section>
      )}

      {/* Verse collection */}
      <section>
        <h2 className="text-xl font-bold font-headings text-minimal-gold mb-6 flex items-center gap-2">
          <FileText size={20} className="text-primary" />
          {isHindiRoute ? "वाणी संग्रह" : "Collected Verses"}
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {sant.verses.map((verse) => (
            <Link
              key={verse.id}
              to={isHindiRoute ? `/hi/content/${verse.slug || verse.id}` : `/content/${verse.slug || verse.id}`}
              className="glass-card p-4 flex flex-col justify-between group hover:border-amber-500/20 transition-all min-h-[140px]"
            >
              <div>
                <div className="flex justify-between items-start gap-4 mb-2">
                  <span className="text-[10px] uppercase tracking-wider text-amber-500/80 bg-amber-500/5 px-2 py-0.5 rounded border border-amber-500/10">
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
              <p className="text-white/40 text-xs line-clamp-2 leading-relaxed mt-2">
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
