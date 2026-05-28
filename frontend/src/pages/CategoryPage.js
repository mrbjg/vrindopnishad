import React, { useState, useEffect, useContext } from 'react';
import { useParams, Link, useLocation } from 'react-router-dom';
import { ApiContext } from '../App';
import { Scroll, Music, FileText, BookOpen, Music as MusicIcon, Image as ImageIcon, Video, ArrowLeft, ArrowRight, MapPin, Users, Book } from 'lucide-react';
import { Helmet } from 'react-helmet-async';

const CategoryPage = () => {
  const { category } = useParams();
  const location = useLocation();
  const isHindiRoute = location.pathname.startsWith('/hi');
  const { apiService } = useContext(ApiContext);
  const cacheKey = `all_${category}_10000`;
  
  const getInitialData = () => {
    const cached = apiService.getCachedData(cacheKey);
    if (cached) return cached;
    try {
      const fullCache = localStorage.getItem('vrindopnishad_all_content_cache') || localStorage.getItem('sanctuary_content_cache');
      if (fullCache) {
        const parsed = JSON.parse(fullCache);
        const filtered = parsed.filter(item => item.category?.toLowerCase() === category?.toLowerCase());
        if (filtered.length > 0) return filtered;
      }
    } catch (e) {}
    return [];
  };

  const [content, setContent] = useState(() => getInitialData());
  const [loading, setLoading] = useState(() => getInitialData().length === 0);

  const categoryInfo = {
    shloka: {
      name: 'Shlokas',
      description: 'Sacred verses from Hindu scriptures',
      icon: Scroll,
      color: 'text-amber-400'
    },
    strotra: {
      name: 'Strotras',
      description: 'Devotional hymns and prayers',
      icon: Music,
      color: 'text-sky-400'
    },
    poem: {
      name: 'Poems',
      description: 'Spiritual and devotional poetry',
      icon: FileText,
      color: 'text-emerald-400'
    },
    katha: {
      name: 'Kathas',
      description: 'Divine stories and spiritual narratives',
      icon: Scroll,
      color: 'text-orange-400'
    },
    sankirtan: {
      name: 'Sankirtan',
      description: 'Divine lyrics and devotional bhajans',
      icon: Music,
      color: 'text-rose-400'
    },
    saint: {
      name: 'Rasik Saints',
      description: 'Biographies and teachings of devotional masters',
      icon: Users,
      color: 'text-indigo-400'
    },
    dham: {
      name: 'Braj Dham',
      description: 'Sacred places and heritage of Braj',
      icon: MapPin,
      color: 'text-orange-400'
    },
    literature: {
      name: 'Literature',
      description: 'Authentic Rasik texts and scriptures',
      icon: Book,
      color: 'text-violet-400'
    }
  };

  const getCategoryColorClasses = (cat) => {
    switch (cat?.toLowerCase()) {
      case 'shloka': return { hover: 'hover:border-amber-400/30 hover:shadow-amber-400/5' };
      case 'strotra': return { hover: 'hover:border-sky-400/30 hover:shadow-sky-400/5' };
      case 'poem': return { hover: 'hover:border-emerald-400/30 hover:shadow-emerald-400/5' };
      case 'katha': return { hover: 'hover:border-orange-400/30 hover:shadow-orange-400/5' };
      case 'sankirtan': return { hover: 'hover:border-rose-400/30 hover:shadow-rose-400/5' };
      case 'saint': return { hover: 'hover:border-indigo-400/30 hover:shadow-indigo-400/5' };
      case 'dham': return { hover: 'hover:border-orange-400/30 hover:shadow-orange-400/5' };
      case 'literature': return { hover: 'hover:border-violet-400/30 hover:shadow-violet-400/5' };
      default: return { hover: 'hover:border-slate-400/30 hover:shadow-slate-400/5' };
    }
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

    const load = async () => {
      const cacheKey = `all_${category}_10000`;
      let cachedData = apiService.getCachedData(cacheKey);

      if (!cachedData) {
        try {
          const fullCache = localStorage.getItem('vrindopnishad_all_content_cache') || localStorage.getItem('sanctuary_content_cache');
          if (fullCache) {
            const parsed = JSON.parse(fullCache);
            const filtered = parsed.filter(item => item.category?.toLowerCase() === category?.toLowerCase());
            if (filtered.length > 0) {
              cachedData = filtered;
            }
          }
        } catch (e) {}
      }

      if (cachedData && cachedData.length > 0) {
        if (active) {
          setContent(cachedData);
          setLoading(false);
        }
      } else {
        if (active) {
          setLoading(true);
        }
      }

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

  const info = categoryInfo[category] || { name: category, description: '', icon: BookOpen, color: 'text-white' };
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
        <Link to="/" className="inline-flex items-center gap-2 text-white/40 hover:text-white mb-8 transition-colors">
          <ArrowLeft size={18} />
          Back to Home
        </Link>
        
        <div className="flex flex-col items-center text-center">
            <div className={`mb-6 p-6 rounded-full bg-white/5 border border-white/10 ${info.color}`}>
                <IconComponent size={48} />
            </div>
            <h1 className="text-5xl font-bold mb-4 capitalize">{info.name}</h1>
            <p className="text-white/50 max-w-lg mx-auto">{info.description}</p>
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
              <div className="pt-4 border-t border-white/5 flex gap-2">
                 <div className="skeleton w-12 h-4 rounded opacity-10"></div>
                 <div className="skeleton w-12 h-4 rounded opacity-10"></div>
              </div>
            </div>
          ))}
        </div>
      ) : (!loading && content.length === 0) ? (
        <div className="glass-card text-center py-24">
          <div className="text-white/20 mb-6 flex justify-center">
             <IconComponent size={64} />
          </div>
          <h3 className="text-2xl font-bold mb-4">No {info.name.toLowerCase()} available yet</h3>
          <p className="text-white/40 mb-10 text-lg">Please check back later or explore other categories.</p>
          <Link to="/" className="btn-premium px-10 py-3">
             Back to Home
          </Link>
        </div>
      ) : content.length === 0 ? (
        <div className="py-12"></div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {content.map((item) => {
            const colors = getCategoryColorClasses(category);
            return (
              <Link 
                key={item.id} 
                to={`/content/${item.id}`} 
                className={`glass-card group flex flex-col justify-between transition-all duration-500 border border-white/10 ${colors.hover} hover:shadow-2xl`}
              >
                <div>
                  <div className="flex justify-between items-start mb-4">
                    <span className={`badge transition-all duration-300 ${getCategoryBadgeClass(category)}`}>
                      {category}
                    </span>
                    <div className="text-white/10 transition-colors duration-300">
                      <ArrowRight size={20} className="group-hover:translate-x-1 transition-transform duration-500" />
                    </div>
                  </div>
                  <h3 className="text-xl font-bold mb-4 line-clamp-2 leading-tight transition-colors duration-300">
                    {item.title}
                  </h3>
                  <p className="text-white/50 text-sm line-clamp-4 leading-relaxed">
                    {item.hindi_text || item.english_translation || item.description}
                  </p>
                </div>

                <div className="pt-6 mt-6 border-t border-white/5 flex gap-4">
                  {item.audio_url && <MusicIcon size={16} className="text-white/20" />}
                  {item.image_urls && item.image_urls.length > 0 && <ImageIcon size={16} className="text-white/20" />}
                  {item.video_urls && item.video_urls.length > 0 && <Video size={16} className="text-white/20" />}
                </div>
              </Link>
            );
          })}
        </div>
      )}
    </div>
  );
};

export default CategoryPage;
