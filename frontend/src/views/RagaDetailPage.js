'use client';

import React, { useState, useEffect, useContext } from 'react';
import { useParams, Link, useLocation } from 'react-router-dom';
import { ApiContext } from '../contexts/ClientProviders';
import { extractRelations } from '../utils/relations';
import { ArrowLeft, Music, FileText } from 'lucide-react';
import { Helmet } from 'react-helmet-async';

const RagaDetailPage = ({ initialRaga }) => {
  const { slug } = useParams();
  const location = useLocation();
  const isHindiRoute = location.pathname.startsWith('/hi');
  const { apiService } = useContext(ApiContext);

  const [raga, setRaga] = useState(initialRaga || (() => {
    try {
      const memCached = apiService.getMemoryCachedItems();
      if (memCached) {
        const relations = extractRelations(memCached);
        if (relations && relations.ragas.length > 0) {
          return relations.ragas.find(r => r.slug === slug) || null;
        }
      }
    } catch (e) {}
    return null;
  }));
  const [loading, setLoading] = useState(() => {
    if (initialRaga) return false;
    try {
      const memCached = apiService.getMemoryCachedItems();
      if (memCached) {
        const relations = extractRelations(memCached);
        if (relations && relations.ragas.length > 0) {
          return !relations.ragas.find(r => r.slug === slug);
        }
      }
    } catch (e) {}
    return true;
  });

  useEffect(() => {
    let active = true;
    if (initialRaga) {
      setLoading(false);
      return;
    }

    const getInitialRaga = () => {
      try {
        const memCached = apiService.getMemoryCachedItems();
        if (memCached) {
          const relations = extractRelations(memCached);
          if (relations && relations.ragas.length > 0) {
            return relations.ragas.find(r => r.slug === slug) || null;
          }
        }
      } catch (e) {}
      return null;
    };

    const initialVal = getInitialRaga();
    setRaga(initialVal);
    setLoading(initialVal === null);

    const load = async () => {
      try {
        const allItems = await apiService.getAllContent(null, 10000);
        const relations = extractRelations(allItems);
        const foundRaga = relations.ragas.find(r => r.slug === slug);
        if (active) {
          setRaga(foundRaga || null);
        }
      } catch (error) {
        console.error('Error loading raga details:', error);
      } finally {
        if (active) setLoading(false);
      }
    };
    load();
    return () => { active = false; };
  }, [slug, apiService, initialRaga]);

  if (loading) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-12 animate-pulse space-y-6">
        <div className="h-6 bg-white/10 rounded w-24" />
        <div className="h-10 bg-white/10 rounded w-1/3" />
        <div className="space-y-4 pt-8">
          {[1, 2, 3].map(i => (
            <div key={i} className="h-24 bg-white/5 rounded-xl w-full" />
          ))}
        </div>
      </div>
    );
  }

  if (!raga) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-24 text-center">
        <h2 className="text-3xl font-bold mb-4 font-headings">Raga not found</h2>
        <p className="text-white/40 mb-8">The musical scale you are looking for does not exist in our registry.</p>
        <Link to={isHindiRoute ? "/hi/ragas" : "/ragas"} className="btn-premium px-8 py-3">
          Explore All Ragas
        </Link>
      </div>
    );
  }

  return (
    <div className="animate-fade-in max-w-4xl mx-auto px-4 py-8">
      <Helmet>
        <title>{isHindiRoute ? `${raga.name} आधारित वाणी पद एवं संकीर्तन | Vrindopnishad` : `${raga.hinglishName} Devotional Songs | Vrindopnishad`}</title>
        <meta name="description" content={`Read and listen to the sacred spiritual verses composed in ${raga.hinglishName} with translations.`} />
        <link rel="canonical" href={isHindiRoute ? `https://path.vrindopnishad.in/hi/raga/${slug}` : `https://path.vrindopnishad.in/raga/${slug}`} />
      </Helmet>

      <Link 
        to={isHindiRoute ? "/hi/ragas" : "/ragas"} 
        className="inline-flex items-center gap-2 text-white/40 hover:text-white mb-8 transition-colors text-xs uppercase tracking-wider"
      >
        <ArrowLeft size={14} />
        {isHindiRoute ? "सभी राग" : "All Ragas"}
      </Link>

      <div className="mb-10 pb-8 border-b border-white/5">
        <span className="text-[10px] uppercase tracking-[0.25em] text-primary font-bold block mb-2">Classical Indian Melody</span>
        <h1 className="text-3xl md:text-5xl font-bold font-headings text-sacred-gradient mb-1">
          {raga.name}
        </h1>
        <p className="text-white/40 text-sm tracking-wide mt-1">
          Scale: {raga.hinglishName}
        </p>
      </div>

      <section>
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-bold font-headings text-minimal-gold flex items-center gap-2">
            <FileText size={20} className="text-primary" />
            {isHindiRoute ? "राग में रचित पद" : "Songs Composed in this Raga"}
          </h2>
          <span className="text-xs text-white/30">
            {raga.verses.length} {raga.verses.length === 1 ? 'song' : 'songs'}
          </span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {raga.verses.map((verse) => (
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
                {verse.parsedSaint && (
                  <span className="text-xs text-white/30 block mt-1">
                    By {verse.parsedSaint}
                  </span>
                )}
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

export default RagaDetailPage;
