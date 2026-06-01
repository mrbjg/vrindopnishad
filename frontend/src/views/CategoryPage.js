'use client';

import React, { useState, useEffect, useContext, useRef } from 'react';
import { useParams, Link, useLocation } from 'react-router-dom';
import { ApiContext } from '../contexts/ClientProviders';
import { Scroll, Music, FileText, BookOpen, Music as MusicIcon, Image as ImageIcon, Video, ArrowLeft, ArrowRight, MapPin, Users, Book } from 'lucide-react';
import { Helmet } from 'react-helmet-async';

const CategoryPage = ({ category: propCategory }) => {
  const params = useParams();
  const category = propCategory || params.category;
  let location = null;
  try {
    location = useLocation();
  } catch (e) {}
  const isHindiRoute = location ? location.pathname.startsWith('/hi') : (typeof window !== 'undefined' ? window.location.pathname.startsWith('/hi') : false);
  const { apiService } = useContext(ApiContext);
  const cacheKey = `all_${category}_10000`;
  
  const getInitialData = () => {
    try {
      const filtered = apiService.getMemoryCachedCategoryItems(category);
      if (filtered && filtered.length > 0) return filtered;
    } catch (e) {}

    const cached = apiService.getCachedData(cacheKey);
    if (cached) return cached;
    return [];
  };

  const [content, setContent] = useState(() => getInitialData());
  const [loading, setLoading] = useState(() => getInitialData().length === 0);
  const [visibleCount, setVisibleCount] = useState(12);
  const sentinelRef = useRef(null);

  const categoryInfo = {
    shloka: {
      name: 'Shlokas',
      description: 'Sacred verses from Hindu scriptures',
      icon: Scroll,
      color: 'text-[var(--primary-color)]'
    },
    strotra: {
      name: 'Strotras',
      description: 'Devotional hymns and prayers',
      icon: Music,
      color: 'text-[var(--primary-color)]'
    },
    poem: {
      name: 'Poems',
      description: 'Spiritual and devotional poetry',
      icon: FileText,
      color: 'text-[var(--primary-color)]'
    },
    katha: {
      name: 'Kathas',
      description: 'Divine stories and spiritual narratives',
      icon: Scroll,
      color: 'text-[var(--primary-color)]'
    },
    sankirtan: {
      name: 'Sankirtan',
      description: 'Divine lyrics and devotional bhajans',
      icon: Music,
      color: 'text-[var(--primary-color)]'
    },
    saint: {
      name: 'Rasik Saints',
      description: 'Biographies and teachings of devotional masters',
      icon: Users,
      color: 'text-[var(--primary-color)]'
    },
    dham: {
      name: 'Braj Dham',
      description: 'Sacred places and heritage of Braj',
      icon: MapPin,
      color: 'text-[var(--primary-color)]'
    },
    literature: {
      name: 'Literature',
      description: 'Authentic Rasik texts and scriptures',
      icon: Book,
      color: 'text-[var(--primary-color)]'
    }
  };

  const getCategoryColorClasses = (cat) => {
    return { hover: 'hover:border-[rgba(var(--primary-rgb),0.3)] hover:shadow-[rgba(var(--primary-rgb),0.05)]' };
  };

  const getCategoryBadgeClass = (cat) => {
    switch (cat?.toLowerCase()) {
      case 'shloka': return 'badge-shloka';
      case 'strotra': return 'badge-strotra';
      case 'poem': return 'badge-poem';
      case 'katha': return 'badge-katha';
      case 'sankirtan': return 'badge-sankirtan';
      case 'saint': return 'badge-saint';
      case 'dham': return 'badge-dham';
      case 'literature': return 'badge-literature';
      default: return 'badge-general';
    }
  };

  useEffect(() => {
    let active = true;
    setVisibleCount(12); 

    
    const initialData = getInitialData();
    setContent(initialData);
    setLoading(initialData.length === 0);

    const load = async () => {
      try {
        const data = await apiService.getAllContent(category, 10000);
        if (active) {
          setContent(data || []);
        }
      } catch (error) {
        console.error('Error fetching content:', error);
      } finally {
        if (active) {
          setLoading(false);
        }
      }
    };
    
    load();
    
    return () => {
      active = false;
    };
    
  }, [category, apiService]);

  
  useEffect(() => {
    if (loading || content.length <= visibleCount) return;

    const observer = new IntersectionObserver((entries) => {
      if (entries[0].isIntersecting) {
        setVisibleCount(prev => prev + 12);
      }
    }, {
      rootMargin: '200px'
    });

    const currentSentinel = sentinelRef.current;
    if (currentSentinel) {
      observer.observe(currentSentinel);
    }

    return () => {
      if (currentSentinel) {
        observer.unobserve(currentSentinel);
      }
    };
  }, [loading, content.length, visibleCount]);

  const info = categoryInfo[category] || { name: category, description: '', icon: BookOpen, color: 'text-[var(--primary-color)]' };
  const IconComponent = info.icon;

  const showSkeleton = loading && content.length === 0;

  return (
    <div className="animate-fade-in">
      <Helmet>
        <html lang={isHindiRoute ? "hi" : "en"} />
        <title>{isHindiRoute ? `${info.name} (संग्रह) | Vrindopnishad` : `${info.name} Collection | Vrindopnishad`}</title>
        <meta name="description" content={isHindiRoute ? `${info.name} का संपूर्ण संग्रह। ${info.description || ''}` : `Read and listen to sacred ${info.name.toLowerCase()} in our spiritual library. ${info.description || ''}`} />
        <link rel="canonical" href={isHindiRoute ? `https://path.vrindopnishad.in/hi/category/${(category || "").toLowerCase()}` : `https://path.vrindopnishad.in/category/${(category || "").toLowerCase()}`} />
      </Helmet>
      <div className="mb-12">
        <Link to={isHindiRoute ? "/hi" : "/"} className="inline-flex items-center gap-2 text-[var(--text-color)]/40 hover:text-[var(--text-color)] mb-8 transition-colors">
          <ArrowLeft size={18} />
          Back to Home
        </Link>
        
        <div className="flex flex-col items-center text-center">
            <div className={`mb-6 p-6 rounded-full bg-[var(--glass-bg)] border border-[var(--glass-border)] ${info.color}`}>
                <IconComponent size={48} />
            </div>
            <h1 className="text-5xl font-bold mb-4 capitalize text-[var(--text-color)]">{info.name}</h1>
            <p className="text-[var(--text-color)]/60 max-w-lg mx-auto">{info.description}</p>
        </div>
      </div>

      {showSkeleton ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {[1,2,3,4,5,6].map(i => (
            <div key={i} className="glass-card flex flex-col justify-between h-72">
              <div>
                <div className="flex justify-between items-start mb-4">
                  <div className="skeleton w-20 h-6 rounded-full"></div>
                  <div className="skeleton w-6 h-6 rounded-full"></div>
                </div>
                <div className="skeleton skeleton-title w-3/4 mb-4"></div>
                <div className="space-y-2">
                  <div className="skeleton skeleton-text w-full"></div>
                  <div className="skeleton skeleton-text w-full"></div>
                  <div className="skeleton skeleton-text w-2/3"></div>
                </div>
              </div>
              <div className="pt-4 border-t border-[var(--glass-border)] flex gap-2">
                 <div className="skeleton w-12 h-4 rounded opacity-10"></div>
                 <div className="skeleton w-12 h-4 rounded opacity-10"></div>
              </div>
            </div>
          ))}
        </div>
      ) : (!loading && content.length === 0) ? (
        <div className="glass-card text-center py-24">
          <div className="text-[var(--text-color)]/20 mb-6 flex justify-center">
             <IconComponent size={64} />
          </div>
          <h3 className="text-2xl font-bold mb-4 text-[var(--text-color)]">No {info.name.toLowerCase()} available yet</h3>
          <p className="text-[var(--text-color)]/50 mb-10 text-lg">Please check back later or explore other categories.</p>
          <Link to={isHindiRoute ? "/hi" : "/"} className="btn-premium px-10 py-3">
             Back to Home
          </Link>
        </div>
      ) : content.length === 0 ? (
        <div className="py-12"></div>
      ) : (
        <>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {content.slice(0, visibleCount).map((item, index) => {
              const colors = getCategoryColorClasses(category);
              return (
                <Link 
                  key={`${item.id || item.slug || 'item'}-${index}`} 
                  to={isHindiRoute ? `/hi/content/${item.slug || item.id}` : `/content/${item.slug || item.id}`} 
                  className={`glass-card group flex flex-col justify-between transition-all duration-500 border border-[var(--glass-border)] ${colors.hover} hover:shadow-2xl`}
                >
                  <div>
                    <div className="flex justify-between items-start mb-4">
                      <span className={`badge transition-all duration-300 ${getCategoryBadgeClass(category)}`}>
                        {category}
                      </span>
                      <div className="text-[var(--text-color)]/20 transition-colors duration-300">
                        <ArrowRight size={20} className="group-hover:translate-x-1 transition-transform duration-500" />
                      </div>
                    </div>
                    <h3 className="text-xl font-bold mb-4 line-clamp-2 leading-tight transition-colors duration-300 text-[var(--text-color)]">
                      {item.title}
                    </h3>
                    <p className="text-[var(--text-color)]/65 text-sm line-clamp-4 leading-relaxed">
                      {item.hindi_text || item.english_translation || item.description}
                    </p>
                  </div>

                  <div className="pt-6 mt-6 border-t border-[var(--glass-border)] flex gap-4">
                    {item.audio_url && <MusicIcon size={16} className="text-[var(--text-color)]/30" />}
                    {item.image_urls && item.image_urls.length > 0 && <ImageIcon size={16} className="text-[var(--text-color)]/30" />}
                    {item.video_urls && item.video_urls.length > 0 && <Video size={16} className="text-[var(--text-color)]/30" />}
                  </div>
                </Link>
              );
            })}
          </div>

          
          {content.length > visibleCount && (
            <div ref={sentinelRef} className="py-10 flex justify-center w-full">
              <div className="w-8 h-8 border-2 border-[var(--primary-color)] border-t-transparent rounded-full animate-spin"></div>
            </div>
          )}
        </>
      )}
    </div>
  );
};

export default CategoryPage;
