import React, { useState, useEffect, useCallback, useContext } from 'react';
import { useParams, Link } from 'react-router-dom';
import { ApiContext } from '../App';
import { Scroll, Music, FileText, BookOpen, Music as MusicIcon, Image as ImageIcon, Video, ArrowLeft, ArrowRight } from 'lucide-react';

const CategoryPage = () => {
  const { category } = useParams();
  const { apiService } = useContext(ApiContext);
  const cacheKey = `all_${category}_50`;
  const [content, setContent] = useState(() => apiService.getCachedData(cacheKey) || []);
  const [loading, setLoading] = useState(!apiService.getCachedData(cacheKey));

  const categoryInfo = {
    shloka: {
      name: 'Shlokas',
      description: 'Sacred verses from Hindu scriptures',
      icon: Scroll,
      color: 'text-primary'
    },
    strotra: {
      name: 'Strotras',
      description: 'Devotional hymns and prayers',
      icon: Music,
      color: 'text-blue-400'
    },
    poem: {
      name: 'Poems',
      description: 'Spiritual and devotional poetry',
      icon: FileText,
      color: 'text-purple-400'
    }
  };

  const fetchContent = useCallback(async () => {
    try {
      setLoading(true);
      const data = await apiService.getAllContent(category);
      setContent(data || []);
    } catch (error) {
      console.error('Error fetching content:', error);
    } finally {
      setLoading(false);
    }
  }, [category, apiService]);

  useEffect(() => {
    fetchContent();
  }, [fetchContent]);

  const info = categoryInfo[category] || { name: category, description: '', icon: BookOpen, color: 'text-white' };
  const IconComponent = info.icon;

  return (
    <div className="animate-fade-in">
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

      {loading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {[1,2,3].map(i => (
            <div key={i} className="glass-card h-64 animate-pulse"></div>
          ))}
        </div>
      ) : content.length === 0 ? (
        <div className="glass-card text-center py-24">
          <div className="text-white/20 mb-6 flex justify-center">
             <IconComponent size={64} />
          </div>
          <h3 className="text-2xl font-bold mb-4">No {info.name.toLowerCase()} available yet</h3>
          <p className="text-white/40 mb-10">Please check back later or explore other categories.</p>
          <Link to="/" className="btn-premium px-10 py-3">
             Back to Home
          </Link>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {content.map((item) => (
            <Link key={item.id} to={`/content/${item.id}`} className="glass-card group flex flex-col justify-between hover:border-primary/30 hover:shadow-2xl hover:shadow-primary/5 transition-all duration-500">
              <div>
                <div className="flex justify-between items-start mb-4">
                  <span className={`badge border-white/10 text-white/60 transition-all duration-300`}>
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
          ))}
        </div>
      )}
    </div>
  );
};

export default CategoryPage;
