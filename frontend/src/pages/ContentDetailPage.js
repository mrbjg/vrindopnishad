import React, { useState, useEffect, useContext } from 'react';
import { useParams, Link } from 'react-router-dom';
import { ApiContext } from '../App';
import { ArrowLeft, Music, Image as ImageIcon, Video } from 'lucide-react';
import AudioPlayButton from '../components/ui/AudioPlayButton';
import { Helmet } from 'react-helmet-async';

const ContentDetailPage = () => {
  const { id } = useParams();
  const { apiService } = useContext(ApiContext);
  const [content, setContent] = useState(() => apiService.getCachedData(`id_${id}`));
  const [loading, setLoading] = useState(!apiService.getCachedData(`id_${id}`));

  useEffect(() => {
    const fetchContentData = async () => {
      try {
        setLoading(true);
        const data = await apiService.getContentById(id);
        setContent(data);
      } catch (error) {
        console.error('Error fetching content:', error);
      } finally {
        setLoading(false);
      }
    };
    fetchContentData();
  }, [id, apiService]);

  if (loading) {
    return (
      <div className="animate-fade-in max-w-4xl mx-auto py-12">
        <div className="skeleton w-32 h-6 mb-12 rounded"></div>
        
        <div className="space-y-12">
          {/* Title skeleton */}
          <div className="skeleton h-16 w-3/4 mb-10 rounded-xl"></div>
          
          {/* Description skeleton */}
          <div className="skeleton h-24 w-full mb-12 rounded-xl"></div>
          
          {/* Content sections skeletons */}
          <div className="space-y-16">
            <div className="py-12 border-b border-white/5">
              <div className="skeleton h-8 w-40 mb-8 rounded"></div>
              <div className="skeleton h-32 w-full rounded-2xl"></div>
            </div>
            <div className="py-12">
              <div className="skeleton h-8 w-40 mb-8 rounded"></div>
              <div className="skeleton h-48 w-full rounded-2xl"></div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (!content) {
    return (
      <div className="animate-fade-in">
        <Link to="/content" className="inline-flex items-center gap-2 text-white/40 hover:text-white mb-8 transition-colors">
          <ArrowLeft size={18} />
          Back to Collection
        </Link>
        <div className="glass-card text-center py-24">
          <h2 className="text-3xl font-bold mb-6">Content not found</h2>
          <p className="text-white/40 mb-10 text-lg">The verse or poem you are looking for does not exist in our library.</p>
          <Link to="/content" className="btn-premium px-10 py-3">
            Explore All Content
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="animate-fade-in max-w-4xl mx-auto">
      <Helmet>
        <title>{`${content.title} | ${content.author || 'VrindaVaani'}`}</title>
        <meta name="description" content={`Experience Divine Wisdom: ${content.title} by ${content.author || 'Sant Vaani'}. ${content.sanskrit_text ? content.sanskrit_text.substring(0, 160) : content.description?.substring(0, 160)}`} />
        <meta name="keywords" content={`${content.title}, ${content.author}, ${content.category}, Padma Purana, Vrindavan Dham, Hindu Shloka, Sanskrit Verses, Devotional Poetry, Spiritual Wisdom`} />
        
        {/* Canonical Link */}
        <link rel="canonical" href={`https://path.vrindopnishad.in/content/${id}`} />

        {/* Open Graph / social media tags */}
        <meta property="og:type" content="article" />
        <meta property="og:title" content={`${content.title} - ${content.category}`} />
        <meta property="og:description" content={content.description?.substring(0, 160) || `Read and listen to ${content.title} in the Sant-Vaani Sanctuary.`} />
        {content.image_url && <meta property="og:image" content={content.image_url} />}
        <meta property="article:section" content={content.category} />
        {content.author && <meta property="article:author" content={content.author} />}
        
        <meta name="twitter:card" content="summary_large_image" />
        <meta name="twitter:title" content={content.title} />
        <meta name="twitter:description" content={content.description?.substring(0, 160)} />

        {/* JSON-LD Structured Data for Search Ranking */}
        <script type="application/ld+json">
          {JSON.stringify({
            "@context": "https://schema.org",
            "@type": "ScholarlyArticle",
            "headline": content.title,
            "description": content.description || `A sacred ${content.category} from the Sant-Vaani repository.`,
            "author": {
              "@type": "Person",
              "name": content.author || "Sant Vaani"
            },
            "genre": content.category,
            "keywords": `${content.title}, ${content.category}, Spiritual, Sanskrit`,
            "articleBody": `${content.sanskrit_text ? content.sanskrit_text + ' ' : ''}${content.hindi_text ? content.hindi_text + ' ' : ''}${content.english_translation || ''}`,
            "publisher": {
              "@type": "Organization",
              "name": "VrindaVaani",
              "logo": {
                "@type": "ImageObject",
                "url": "https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png"
              }
            },
            "mainEntityOfPage": {
              "@type": "WebPage",
              "@id": `https://path.vrindopnishad.in/content/${id}`
            }
          })}
        </script>
      </Helmet>

      <Link to="/content" className="inline-flex items-center gap-2 text-white/40 hover:text-white mb-8 transition-colors">
        <ArrowLeft size={18} />
        Back to Collection
      </Link>

      <div className="glass-card reading-card p-8 md:p-12">
        <div className="flex justify-between items-start mb-8">
            <span className="badge border-primary/30 text-primary/80 uppercase tracking-tighter text-xs">
                {content.category}
            </span>
            {content.author && <span className="text-white/40 font-medium">By {content.author}</span>}
        </div>

        <h1 className="text-4xl md:text-6xl font-bold mb-10 leading-tight">
          {content.title}
        </h1>

        {content.description && (
          <p className="text-xl text-white/60 font-light leading-relaxed mb-12 italic border-l-4 border-white/10 pl-6">
            {content.description}
          </p>
        )}

        <div className="space-y-16">
          {content.sanskrit_text && (
            <div className="relative overflow-hidden group py-12 border-b border-white/5">
              <div className="absolute top-0 right-0 p-8 opacity-5 text-8xl font-serif">ॐ</div>
              <h3 className="text-xs uppercase tracking-[0.3em] text-white/20 mb-10 flex items-center gap-3">
                <span className="h-[1px] w-8 bg-white/10"></span>
                Sanskrit Text
              </h3>
              <div className="text-3xl md:text-5xl leading-[1.8] text-center font-medium text-white/95 drop-shadow-lg hindi-text">
                {content.sanskrit_text}
              </div>
            </div>
          )}

          {content.hindi_text && (
            <div className="py-12 border-b border-white/5">
              <h3 className="text-xs uppercase tracking-[0.3em] text-amber-500/40 mb-10 flex items-center gap-3">
                <span className="h-[1px] w-8 bg-amber-500/10"></span>
                Hindi Meaning
              </h3>
              <div className="text-xl md:text-3xl leading-[2.2] text-white/85 hindi-text">
                {content.hindi_text}
              </div>
            </div>
          )}

          {content.english_text && (
            <div>
              <h3 className="text-xs uppercase tracking-[0.3em] text-white/20 mb-6 font-semibold">Transliteration</h3>
              <div className="text-lg md:text-xl leading-relaxed text-white/60 font-inter">
                {content.english_text}
              </div>
            </div>
          )}

          {content.english_translation && (
            <div className="py-12">
              <h3 className="text-xs uppercase tracking-[0.3em] text-blue-400/40 mb-10 flex items-center gap-3">
                <span className="h-[1px] w-8 bg-blue-500/10"></span>
                English Translation
              </h3>
              <div className="text-lg md:text-2xl leading-relaxed text-white/70">
                {content.english_translation}
              </div>
            </div>
          )}

          {/* Media Sections */}
          {content.audio_url && (
            <div className="pt-8 border-t border-white/5">
              <h3 className="text-xl font-bold mb-6 flex items-center gap-3">
                <Music size={24} className="text-primary" />
                Listen to Audio
              </h3>
              <div className="bg-white/5 rounded-2xl p-6 flex items-center gap-6 group hover:bg-white/10 transition-all border border-white/5 hover:border-primary/20">
                <AudioPlayButton 
                  track={content} 
                  size={32} 
                  className="w-16 h-16 bg-primary text-white shadow-lg shadow-primary/20" 
                />
                <div>
                  <h4 className="font-bold text-lg mb-1">Divine Rendition</h4>
                  <p className="text-white/40 text-sm">Experience the sacred vibrations of this {content.category}</p>
                </div>
              </div>
            </div>
          )}

          {(content.image_url || (content.image_urls && content.image_urls.length > 0)) && (
            <div className="pt-8 border-t border-white/5">
              <h3 className="text-xl font-bold mb-8 flex items-center gap-3">
                <ImageIcon size={24} className="text-primary" />
                Gallery
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {content.image_url && (
                  <img src={content.image_url} alt="Verse" className="rounded-2xl w-full h-auto border border-white/10 hover:border-primary/30 transition-all shadow-2xl" />
                )}
                {content.image_urls?.map((url, idx) => (
                  <img key={idx} src={url} alt={`Verse ${idx + 1}`} className="rounded-2xl w-full h-auto border border-white/10 hover:border-primary/30 transition-all shadow-2xl" />
                ))}
              </div>
            </div>
          )}

          {content.video_urls && content.video_urls.length > 0 && (
            <div className="pt-8 border-t border-white/5">
              <h3 className="text-xl font-bold mb-8 flex items-center gap-3">
                <Video size={24} className="text-primary" />
                Videos
              </h3>
              <div className="space-y-6">
                {content.video_urls.map((url, idx) => (
                  <div key={idx} className="aspect-video rounded-3xl overflow-hidden border border-white/10 shadow-2xl">
                    <video controls className="w-full h-full object-cover">
                      <source src={url} type="video/mp4" />
                    </video>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default ContentDetailPage;
