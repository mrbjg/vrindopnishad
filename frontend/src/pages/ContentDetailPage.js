import React, { useState, useEffect, useContext } from 'react';
import { useParams, Link } from 'react-router-dom';
import { ApiContext } from '../App';
import {
  ArrowLeft,
  Music,
  Image as ImageIcon,
  Video
} from 'lucide-react';
import { useSettings } from '../contexts/SettingsContext';
import FontWheel from '../components/FontWheel';
import AudioPlayButton from '../components/ui/AudioPlayButton';
import { Helmet } from 'react-helmet-async';

const ContentDetailPage = () => {
  const { id } = useParams();
  const { apiService } = useContext(ApiContext);
  const { settings, updateSetting } = useSettings();
  const [content, setContent] = useState(() => apiService.getCachedData(`id_${id}`));
  const [loading, setLoading] = useState(!apiService.getCachedData(`id_${id}`));

  useEffect(() => {
    let active = true;

    const fetchContentData = async () => {
      try {
        const decodedId = decodeURIComponent(id);
        const data = await apiService.getContentById(decodedId);
        if (active) {
          setContent(data);
        }
      } catch (error) {
        console.error('Error fetching content:', error);
      } finally {
        if (active) {
          setLoading(false);
        }
      }
    };
    fetchContentData();

    return () => {
      active = false;
    };
  }, [id, apiService]);

  const formatVerseText = (text) => {
    if (!text) return null;

    // Feature Check: Line-by-Line Reading
    if (!settings.lineByLine) {
      return <div>{text}</div>;
    }

    // Split by । or ॥ (with optional verse numbers) or comma followed by space
    const parts = text.split(/([।॥]\s*(?:\[\d+\]|\(?\d+\)?)?|,\s)/g);

    const lines = [];
    let currentLine = "";

    for (let i = 0; i < parts.length; i++) {
      if (i % 2 === 0) {
        currentLine = parts[i];
      } else {
        currentLine += parts[i];
        if (currentLine.trim()) {
          lines.push(currentLine.trim());
        }
        currentLine = "";
      }
    }

    // Catch any trailing text
    if (currentLine.trim()) {
      lines.push(currentLine.trim());
    }

    // If no punctuation was found, just return original but trimmed
    if (lines.length === 0) return <div>{text}</div>;

    return lines.map((line, idx) => (
      <div key={idx} className="mb-3 last:mb-0">
        {line}
      </div>
    ));
  };

  const getCategoryBadgeClass = (category) => {
    switch (category?.toLowerCase()) {
      case 'shloka': return 'badge-shloka';
      case 'strotra': return 'badge-strotra';
      case 'poem': return 'badge-poem';
      case 'katha': return 'badge-katha';
      case 'sankirtan': return 'badge-sankirtan';
      case 'saint': return 'badge-saint';
      case 'dham': return 'badge-dham';
      case 'literature': return 'badge-literature';
      case 'general': return 'badge-general';
      default: return 'badge-general';
    }
  };

  const showSkeleton = loading && !content;

  if (showSkeleton) {
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

  if (!loading && !content) {
    return (
      <div className="animate-fade-in">
        <Link to="/content" className="inline-flex items-center gap-2 text-white/40 hover:text-white mb-8 transition-colors">
          <ArrowLeft size={18} />
          Back to Collection
        </Link>
        <div className="glass-card text-center py-24">
          <h2 className="text-3xl font-bold mb-6">Content not found</h2>
          <p className="text-white/40 mb-10 text-lg">The verse or poem you are looking for does not exist in our library.</p>
          <Link to="/content" className="btn-sacred-gold px-10 py-3">
            Explore All Content
          </Link>
        </div>
      </div>
    );
  }

  if (!content) {
    return (
      <div className="max-w-4xl mx-auto py-12">
        {/* Placeholder to keep layout clean during fast loads */}
      </div>
    );
  }

  return (
    <div className="animate-fade-in max-w-4xl mx-auto">
      <Helmet>
        <title>{`${content.title} — ${content.category} | ${content.author || 'Sant Vaani'} | Vrindopnishad`}</title>
        <meta name="description" content={`${content.title} — ${content.category} by ${content.author || 'Sant Vaani'}. ${content.sanskrit_text ? content.sanskrit_text.substring(0, 155) + '...' : content.hindi_text ? content.hindi_text.substring(0, 155) + '...' : content.description?.substring(0, 155) + '...'}`} />
        <meta name="keywords" content={`${content.title}, ${content.author || 'Sant Vaani'}, ${content.category}, Sanskrit Shloka, Hindi meaning, English translation, Vrindopnishad, Sant Vaani, sacred verse, devotional, spiritual wisdom`} />

        {/* Canonical Link */}
        <link rel="canonical" href={`https://path.vrindopnishad.in/content/${content.slug || id}`} />

        {/* Open Graph / social media tags */}
        <meta property="og:type" content="article" />
        <meta property="og:site_name" content="Sant-Vaani | Sacred Digital Sanctuary" />
        <meta property="og:title" content={`${content.title} - ${content.category}`} />
        <meta property="og:description" content={content.description?.substring(0, 160) || `Experience the divine ${content.category}: ${content.title} in the Sant-Vaani Sanctuary.`} />
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
            "@type": "BreadcrumbList",
            "itemListElement": [
              {
                "@type": "ListItem",
                "position": 1,
                "name": "Collection",
                "item": "https://path.vrindopnishad.in/content"
              },
              {
                "@type": "ListItem",
                "position": 2,
                "name": content.category || "Category",
                "item": `https://path.vrindopnishad.in/category/${(content.category || "").toLowerCase()}`
              },
              {
                "@type": "ListItem",
                "position": 3,
                "name": content.title || "Verse",
                "item": `https://path.vrindopnishad.in/content/${content.slug || id}`
              }
            ]
          })}
        </script>

        <script type="application/ld+json">
          {JSON.stringify({
            "@context": "https://schema.org",
            "@type": "ScholarlyArticle",
            "headline": content.title || "Sacred Verse",
            "description": content.description || `A sacred ${content.category || 'text'} from the Vrindopnishad Sant-Vaani repository.`,
            "author": {
              "@type": "Person",
              "name": content.author || "Sant Vaani"
            },
            "genre": content.category || "Sacred Literature",
            "inLanguage": ["hi", "sa", "en"],
            "keywords": `${content.title || ''}, ${content.category || ''}, ${content.author || ''}, Spiritual, Sanskrit, Divine Verses, Vrindopnishad`,
            "articleBody": `${content.sanskrit_text ? content.sanskrit_text + ' ' : ''}${content.hindi_text ? content.hindi_text + ' ' : ''}${content.english_translation || ''}`,
            "datePublished": content.created_at || new Date().toISOString(),
            "dateModified": content.updated_at || content.created_at || new Date().toISOString(),
            "publisher": {
              "@type": "Organization",
              "name": "Vrindopnishad",
              "logo": {
                "@type": "ImageObject",
                "url": "https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png"
              }
            },
            "mainEntityOfPage": {
              "@type": "WebPage",
              "@id": `https://path.vrindopnishad.in/content/${content.slug || id}`
            },
            ...(content.image_url ? { "image": content.image_url } : {})
          })}
        </script>
      </Helmet>

      <article>
        <Link to="/content" className="inline-flex items-center gap-2 text-white/40 hover:text-white mb-8 transition-colors">
          <ArrowLeft size={18} />
          Back to Collection
        </Link>

        <div className="glass-card reading-card p-8 md:p-14 mb-12 relative overflow-hidden">
          {/* Main Content Header - Overhauled for Mobile Relatability */}
          <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-10 mb-12 border-b border-white/5 pb-10">
            <div className="flex flex-col gap-6 w-full lg:w-auto">
              <div className="flex flex-col items-center lg:items-start gap-4">
                <span className={`sacred-badge ${getCategoryBadgeClass(content.category)}`}>
                  {content.category}
                </span>
                
                {content.author && (
                  <div className="flex flex-col items-center lg:items-start">
                    <span className="content-section-label text-[10px] uppercase tracking-[0.3em] mb-1 font-bold">Written By</span>
                    <span className={`text-sacred-gradient font-headings font-bold tracking-wide text-center lg:text-left ${
                      content.author.length > 25 ? 'text-lg' : 'text-xl sm:text-2xl'
                    }`}>
                      {content.author}
                    </span>
                  </div>
                )}
              </div>
            </div>

            {/* Reading Controls - Hidden on Mobile, Top-Right on Desktop */}
            <div className="hidden lg:flex flex-col items-center lg:items-end w-full lg:w-auto">
              <FontWheel 
                value={settings.fontSize} 
                onChange={(size) => updateSetting('fontSize', size)} 
              />
            </div>
          </div>

          <h1 
            className="text-4xl md:text-6xl font-bold mb-6 leading-[1.2] lg:leading-[1.3] pt-8 pb-4 text-sacred-gradient"
          >
            {content.title}
          </h1>

          {content.description && (
            <p 
              className="content-body-text font-light leading-relaxed mb-8 italic pl-6 break-words"
              style={{ 
                fontSize: `${Math.max(14, settings.fontSize * 1.2)}px`,
                wordBreak: 'break-word',
                paddingBottom: '0.1em',
                borderLeft: '4px solid hsl(var(--foreground) / 0.1)'
              }}
            >
              {content.description}
            </p>
          )}

          <div className="space-y-16">
            {content.sanskrit_text && (
              <div className="relative group py-8 sm:py-12 border-b border-white/5">
                <div className="absolute top-0 right-0 p-8 opacity-5 text-9xl font-serif pointer-events-none">ॐ</div>
                <h3 className="content-section-heading text-[10px] sm:text-xs uppercase tracking-[0.4em] mb-6 sm:mb-8 flex items-center justify-center sm:justify-start gap-4 py-2">
                  <span className="content-section-line h-[1px] w-12 hidden sm:block"></span>
                  Sanskrit Text
                  <span className="content-section-line h-[1px] w-12 hidden sm:block"></span>
                </h3>
                <div className={`text-center font-medium content-verse-text drop-shadow-lg hindi-text ${
                  settings.fontStyle === 'Sans' ? 'font-sans' :
                  settings.fontStyle === 'Inter' ? 'font-inter' :
                  'font-headings'
                }`} style={{
                  fontSize: settings.fontSize === 1 ? '1.5rem' :
                            settings.fontSize === 2 ? '2.2rem' :
                            settings.fontSize === 3 ? '3rem' :
                            settings.fontSize === 4 ? '4.5rem' : '6rem'
                }}>
                  {formatVerseText(content.sanskrit_text)}
                </div>
              </div>
            )}

            {content.hindi_text && (
              <div className="py-8 sm:py-12 border-b border-white/5">
                <h3 className="content-section-heading content-section-heading--hindi text-[10px] sm:text-xs uppercase tracking-[0.4em] mb-6 sm:mb-8 flex items-center justify-center sm:justify-start gap-4 py-2">
                  <span className="content-section-line content-section-line--hindi h-[1px] w-12 hidden sm:block"></span>
                  Hindi Meaning
                  <span className="content-section-line content-section-line--hindi h-[1px] w-12 hidden sm:block"></span>
                </h3>
                <div className={`content-verse-text hindi-text ${
                  settings.fontStyle === 'Sans' ? 'font-sans' :
                  settings.fontStyle === 'Inter' ? 'font-inter' :
                  'font-headings'
                }`} style={{
                  fontSize: settings.fontSize === 1 ? '1.2rem' :
                            settings.fontSize === 2 ? '1.8rem' :
                            settings.fontSize === 3 ? '2.5rem' :
                            settings.fontSize === 4 ? '3.8rem' : '5rem'
                }}>
                  {formatVerseText(content.hindi_text)}
                </div>
              </div>
            )}

            {content.english_text && (
              <div>
                <h3 className="content-section-heading text-xs uppercase tracking-[0.3em] mb-6 font-semibold">Transliteration</h3>
                <div className="content-body-text leading-relaxed font-inter" style={{
                  fontSize: settings.fontSize === 1 ? '0.9rem' :
                            settings.fontSize === 2 ? '1.1rem' :
                            settings.fontSize === 3 ? '1.4rem' :
                            settings.fontSize === 4 ? '1.8rem' : '2.4rem'
                }}>
                  {content.english_text}
                </div>
              </div>
            )}

            {content.english_translation && (
              <div className="py-12">
                <h3 className="content-section-heading content-section-heading--english text-xs uppercase tracking-[0.3em] mb-10 flex items-center gap-3">
                  <span className="content-section-line content-section-line--english h-[1px] w-8"></span>
                  English Translation
                </h3>
                <div className="content-body-text leading-relaxed font-light" style={{
                  fontSize: settings.fontSize === 1 ? '1.2rem' :
                            settings.fontSize === 2 ? '1.8rem' :
                            settings.fontSize === 3 ? '2.5rem' :
                            settings.fontSize === 4 ? '3.8rem' : '5rem'
                }}>
                  {content.english_translation}
                </div>
              </div>
            )}

            {/* Media Sections */}
            {content.audio_url && (
              <div className="pt-8 border-t border-white/5">
                <h3 className="text-xl font-bold mb-6 flex items-center gap-3">
                  <Music size={24} className="text-amber-400" />
                  Listen to Audio
                </h3>
                <div className="bg-white/5 rounded-2xl p-6 flex items-center gap-6 group hover:bg-white/10 transition-all border border-white/5 hover:border-amber-500/20">
                  <AudioPlayButton 
                    track={content} 
                    size={32} 
                    className="w-16 h-16 bg-amber-500 text-white shadow-lg shadow-amber-500/20" 
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
                  <ImageIcon size={24} className="text-amber-400" />
                  Gallery
                </h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {content.image_url && (
                    <img src={content.image_url} alt="Verse" loading="lazy" className="rounded-2xl w-full h-auto border border-white/10 hover:border-amber-400/30 transition-all shadow-2xl" />
                  )}
                  {content.image_urls?.map((url, idx) => (
                    <img key={idx} src={url} alt={`Verse ${idx + 1}`} loading="lazy" className="rounded-2xl w-full h-auto border border-white/10 hover:border-amber-400/30 transition-all shadow-2xl" />
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
            {/* End of Content - Mobile Appearance Dial */}
            <div className="lg:hidden mt-20 pt-10 border-t border-white/5 flex flex-col items-center gap-6">
              <span className="content-section-label text-[10px] uppercase tracking-[0.3em] font-bold">Reading Settings</span>
              <div className="w-full max-w-[320px]">
                <FontWheel 
                  value={settings.fontSize} 
                  onChange={(size) => updateSetting('fontSize', size)} 
                />
              </div>
            </div>
          </div>
        </div>
      </article>

      {/* SEO Internal Linking: Related Content Section */}
      <section className="mt-24 mb-12">
        <div className="flex items-center gap-4 mb-10">
          <div className="h-px flex-1 bg-gradient-to-r from-transparent to-white/10"></div>
          <h2 className="text-2xl font-bold text-sacred-gradient px-4">Related Braj Heritage</h2>
          <div className="h-px flex-1 bg-gradient-to-l from-transparent to-white/10"></div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {/* We'll pull a few items from the collection as related content */}
          {/* This increases page session duration and site crawl depth */}
          <Link to="/braj-rasik-heritage" className="glass-card p-6 group hover:border-amber-500/30 transition-all">
            <span className="text-[10px] uppercase tracking-widest text-amber-500 mb-3 block">Featured</span>
            <h4 className="text-lg font-bold mb-2 group-hover:text-amber-400 transition-colors">Explore Braj Rasik Heritage</h4>
            <p className="text-white/40 text-xs line-clamp-2">Discover the complete collection of saints, dham, and literature from the Braj tradition.</p>
          </Link>
          
          <Link to="/category/saint" className="glass-card p-6 group hover:border-amber-500/30 transition-all">
            <span className="text-[10px] uppercase tracking-widest text-white/30 mb-3 block">Explore More</span>
            <h4 className="text-lg font-bold mb-2 group-hover:text-amber-400 transition-colors">Rasik Saints Biography</h4>
            <p className="text-white/40 text-xs line-clamp-2">Read about the life and teachings of the great masters of Vrindavan.</p>
          </Link>

          <Link to="/content" className="glass-card p-6 group hover:border-amber-500/30 transition-all">
            <span className="text-[10px] uppercase tracking-widest text-white/30 mb-3 block">Collection</span>
            <h4 className="text-lg font-bold mb-2 group-hover:text-amber-400 transition-colors">Full Content Library</h4>
            <p className="text-white/40 text-xs line-clamp-2">Access our complete library of Sanskrit shlokas, Hindi strotras, and spiritual poetry.</p>
          </Link>
        </div>
      </section>
    </div>
  );
};

export default ContentDetailPage;
