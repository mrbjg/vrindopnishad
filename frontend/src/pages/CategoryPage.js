import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { apiService } from '../services/api';
import Navigation from '../components/Navigation';
import { Scroll, Music, FileText, BookOpen, Music as MusicIcon, Image as ImageIcon, Video } from 'lucide-react';

const CategoryPage = () => {
  const { category } = useParams();
  const [content, setContent] = useState([]);
  const [loading, setLoading] = useState(true);

  const categoryInfo = {
    shloka: {
      name: 'Shlokas',
      description: 'Sacred verses from Hindu scriptures',
      icon: Scroll
    },
    strotra: {
      name: 'Strotras',
      description: 'Devotional hymns and prayers',
      icon: Music
    },
    poem: {
      name: 'Poems',
      description: 'Spiritual and devotional poetry',
      icon: FileText
    }
  };

  useEffect(() => {
    fetchContent();
  }, [category]);

  const fetchContent = async () => {
    try {
      setLoading(true);
      const data = await apiService.getAllContent(category);
      setContent(data || []);
    } catch (error) {
      console.error('Error fetching content:', error);
    } finally {
      setLoading(false);
    }
  };

  const info = categoryInfo[category] || { name: category, description: '', icon: BookOpen };
  const IconComponent = info.icon;

  return (
    <div>
      <Navigation />
      <div className="container mt-4">
        <div className="text-center mb-4">
          <div className="category-icon-large" style={{ marginBottom: '1rem', display: 'flex', justifyContent: 'center', color: '#ff6b35' }}>
            <IconComponent size={60} strokeWidth={1.5} />
          </div>
          <h1 className="hero-title" style={{ fontSize: 'clamp(1.75rem, 5vw, 3rem)', marginBottom: '0.5rem' }} data-testid="category-title">{info.name}</h1>
          <p className="hero-subtitle" style={{ fontSize: 'clamp(1rem, 3vw, 1.2rem)', marginBottom: 0 }}>{info.description}</p>
        </div>

        {loading ? (
          <div className="text-center mt-5">
            <div className="spinner"></div>
          </div>
        ) : content.length === 0 ? (
          <div className="card text-center" style={{ padding: '3rem' }} data-testid="no-content-message">
            <h3>No {info.name.toLowerCase()} available yet</h3>
            <p style={{ color: '#666', marginTop: '1rem' }}>Please check back later or explore other categories.</p>
            <Link to="/" className="btn btn-primary mt-3" data-testid="back-home-btn">
              Back to Home
            </Link>
          </div>
        ) : (
          <div className="content-grid">
            {content.map((item) => (
              <Link
                key={item.id}
                to={`/content/${item.id}`}
                style={{ textDecoration: 'none' }}
                data-testid={`content-card-${item.id}`}
              >
                <div className="card">
                  <h3 style={{ marginBottom: '1rem' }}>{item.title}</h3>
                  {item.description && (
                    <p style={{ color: '#666', marginBottom: '1rem' }}>{item.description}</p>
                  )}
                  {item.sanskrit_text && (
                    <p className="sanskrit-text" style={{ fontSize: '1rem', marginTop: '1rem' }}>
                      {item.sanskrit_text.substring(0, 100)}{item.sanskrit_text.length > 100 ? '...' : ''}
                    </p>
                  )}
                  <div style={{ marginTop: '1rem', display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
                    {item.audio_url && (
                      <span style={{ fontSize: '0.85rem', color: '#ff6b35', display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                        <MusicIcon size={16} />
                        Audio
                      </span>
                    )}
                    {item.image_urls && item.image_urls.length > 0 && (
                      <span style={{ fontSize: '0.85rem', color: '#ff6b35', display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                        <ImageIcon size={16} />
                        Images
                      </span>
                    )}
                    {item.video_urls && item.video_urls.length > 0 && (
                      <span style={{ fontSize: '0.85rem', color: '#ff6b35', display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                        <Video size={16} />
                        Videos
                      </span>
                    )}
                  </div>
                </div>
              </Link>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default CategoryPage;
