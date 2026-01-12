import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { apiService } from '../services/api';
import Navigation from '../components/Navigation';
import Loader from '../components/Loader';
import { Music, Image as ImageIcon, Video, Layers } from 'lucide-react';

const ContentListPage = () => {
  const [content, setContent] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all');

  useEffect(() => {
    fetchContent();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [filter]);

  const fetchContent = async () => {
    try {
      setLoading(true);
      const cat = filter !== 'all' ? filter : null;
      const data = await apiService.getAllContent(cat);
      setContent(data || []);
    } catch (error) {
      console.error('Error fetching content:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <Navigation />
      <div className="container mt-4">
        <div className="text-center mb-4">
          <h1 className="hero-title" style={{ fontSize: 'clamp(1.75rem, 5vw, 3rem)', marginBottom: '1rem' }} data-testid="content-list-title">Sacred Collection</h1>
          <p className="hero-subtitle" style={{ fontSize: 'clamp(1rem, 3vw, 1.2rem)', marginBottom: 0 }}>Browse our collection of divine texts</p>
        </div>

        <div className="mb-4" style={{ display: 'flex', gap: '1rem', justifyContent: 'center', flexWrap: 'wrap' }}>
          <button
            className={`btn ${filter === 'all' ? 'btn-primary' : 'btn-outline'}`}
            onClick={() => setFilter('all')}
            data-testid="filter-all-btn"
            style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}
          >
            <Layers size={18} />
            All
          </button>
          <button
            className={`btn ${filter === 'shloka' ? 'btn-primary' : 'btn-outline'}`}
            onClick={() => setFilter('shloka')}
            data-testid="filter-shloka-btn"
            style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M10 17h4" /><path d="M12 17v4" /><path d="M8 3v9a2 2 0 0 0 2 2h4a2 2 0 0 0 2-2V3" /></svg>
            Shlokas
          </button>
          <button
            className={`btn ${filter === 'strotra' ? 'btn-primary' : 'btn-outline'}`}
            onClick={() => setFilter('strotra')}
            data-testid="filter-strotra-btn"
            style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}
          >
            <Music size={18} />
            Strotras
          </button>
          <button
            className={`btn ${filter === 'poem' ? 'btn-primary' : 'btn-outline'}`}
            onClick={() => setFilter('poem')}
            data-testid="filter-poem-btn"
            style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z" /><polyline points="14 2 14 8 20 8" /><line x1="16" x2="8" y1="13" y2="13" /><line x1="16" x2="8" y1="17" y2="17" /><line x1="10" x2="8" y1="9" y2="9" /></svg>
            Poems
          </button>
        </div>

        {loading ? (
          <div className="text-center mt-5">
            <Loader text="Loading content..." />
          </div>
        ) : content.length === 0 ? (
          <div className="card text-center" style={{ padding: '3rem' }} data-testid="no-content-message">
            <h3>No content available yet</h3>
            <p style={{ color: '#666', marginTop: '1rem' }}>Please check back later or contact the administrator.</p>
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
                  <div className={`category-badge category-${item.category} mb-3`}>
                    {item.category}
                  </div>
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
                    {(item.audio_url) && (
                      <span style={{ fontSize: '0.85rem', color: '#ff6b35', display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                        <Music size={16} />
                        Audio
                      </span>
                    )}
                    {(item.image_url || (item.image_urls && item.image_urls.length > 0)) && (
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

export default ContentListPage;
