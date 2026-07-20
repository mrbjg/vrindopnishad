'use client';

import React, { useState, useEffect, useContext } from 'react';
import { useParams, Link, useLocation } from 'react-router-dom';
import { ApiContext } from '../contexts/ClientProviders';
import { extractRelations } from '../utils/relations';
import { ArrowLeft, Music, FileText } from 'lucide-react';
import { Helmet } from 'react-helmet-async';
import PageSkeleton from '../components/ui/PageSkeleton';
import { useSWR } from '../hooks/useSWR';

const RagaDetailPage = ({ initialRaga }) => {
  const { slug } = useParams();
  const location = useLocation();
  const isHindiRoute = location.pathname.startsWith('/hi');
  const { apiService } = useContext(ApiContext);

  const [raga, setRaga] = useState(initialRaga || (() => {
    if (typeof window !== 'undefined' && location.state?.item) {
      return location.state.item;
    }
    try {
      const memCached = apiService.getMemoryCachedItems();
      if (memCached) {
        const relations = extractRelations(memCached);
        if (relations && relations.ragas.length > 0) {
          const found = relations.ragas.find(r => r.slug === slug) || null;
          if (found && found.verseIds && !found.verses) {
            const contentMap = new Map(memCached.map(item => [item.id ? item.id.toString() : '', item]));
            found.verses = found.verseIds.map(id => contentMap.get(id?.toString())).filter(Boolean);
          }
          return found;
        }
      }
    } catch (e) {}
    return null;
  }));
  const [loading, setLoading] = useState(() => {
    if (initialRaga) return false;
    return !raga;
  });

  const { data: fetchedRaga } = useSWR(
    slug ? `raga_${slug}` : null,
    async ({ signal }) => {
      const relations = await apiService.getRelations({ signal });
      const foundRaga = relations.ragas.find(r => r.slug === slug);
      if (foundRaga) {
        if (foundRaga.verses && foundRaga.verses.length > 0) {
          // Already have verse objects — use them directly
        } else if (foundRaga.verseIds && foundRaga.verseIds.length > 0) {
          const allContent = await apiService.getAllContent(null, 25000);
          const contentMap = new Map(allContent.map(item => [item.id ? item.id.toString() : '', item]));
          foundRaga.verses = (foundRaga.verseIds || [])
            .map(id => contentMap.get(id?.toString()))
            .filter(Boolean);
        }
      }
      return foundRaga || null;
    },
    {
      initialData: raga,
      dedupingInterval: 3000
    }
  );

  useEffect(() => {
    if (fetchedRaga) {
      setRaga(fetchedRaga);
      setLoading(false);
    }
  }, [fetchedRaga]);

  useEffect(() => {
    if (initialRaga) {
      setRaga(initialRaga);
      setLoading(false);
      return;
    }
    if (raga) {
      setLoading(false);
    }
  }, [slug, initialRaga]);

  if (loading) {
    return <PageSkeleton variant="granth" />;
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
        <link rel="canonical" href={isHindiRoute ? `https://path.vrindopnishad.in/hi/ragas/${slug}` : `https://path.vrindopnishad.in/ragas/${slug}`} />
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
            {(raga.verses || raga.verseIds || []).length} {(raga.verses || raga.verseIds || []).length === 1 ? 'song' : 'songs'}
          </span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {(raga.verses || []).map((verse) => (
            <Link
              key={verse.id}
              to={isHindiRoute ? `/hi/lyrics/${verse.slug || verse.id}` : `/lyrics/${verse.slug || verse.id}`}
              state={{ item: verse }}
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
                {verse.sanskrit_text}
              </p>
            </Link>
          ))}
        </div>
      </section>
    </div>
  );
};

export default RagaDetailPage;
