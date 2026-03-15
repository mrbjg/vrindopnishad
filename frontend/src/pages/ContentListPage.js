import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { apiService } from '../services/api';
import Navigation from '../components/Navigation';
import Loader from '../components/Loader';
import { Music, Image as ImageIcon, Video } from 'lucide-react';

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
      <div className="nebula"></div>
      <div className="grid-container" id="gridContainer">
        
        <h1 className="page-title" data-testid="content-list-title">वृंदोपनिषद्</h1>

        <div className="category-filter">
          <button
            className={`category-btn ${filter === 'all' ? 'active' : ''}`}
            onClick={() => setFilter('all')}
            data-testid="filter-all-btn"
          >
            All Content
          </button>
          <button
            className={`category-btn ${filter === 'shloka' ? 'active' : ''}`}
            onClick={() => setFilter('shloka')}
            data-testid="filter-shloka-btn"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{marginRight: '8px'}}><path d="M10 17h4" /><path d="M12 17v4" /><path d="M8 3v9a2 2 0 0 0 2 2h4a2 2 0 0 0 2-2V3" /></svg>
            Shlokas
          </button>
          <button
            className={`category-btn ${filter === 'strotra' ? 'active' : ''}`}
            onClick={() => setFilter('strotra')}
            data-testid="filter-strotra-btn"
          >
            <Music size={18} style={{marginRight: '8px'}} />
            Strotras
          </button>
          <button
            className={`category-btn ${filter === 'poem' ? 'active' : ''}`}
            onClick={() => setFilter('poem')}
            data-testid="filter-poem-btn"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{marginRight: '8px'}}><path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z" /><polyline points="14 2 14 8 20 8" /><line x1="16" x2="8" y1="13" y2="13" /><line x1="16" x2="8" y1="17" y2="17" /><line x1="10" x2="8" y1="9" y2="9" /></svg>
            Poems
          </button>
        </div>

        {loading ? (
          <div className="text-center mt-5">
            <Loader text="Loading content..." />
          </div>
        ) : content.length === 0 ? (
          <div className="card text-center" style={{ padding: '3rem', background: 'rgba(255,255,255,0.05)', color: 'white', border: '1px solid rgba(255,255,255,0.1)', borderRadius: '20px' }}>
            <h3 style={{fontFamily: 'var(--font-headings)'}}>No content available yet</h3>
            <p style={{ marginTop: '1rem', opacity: 0.8 }}>Please check back later.</p>
          </div>
        ) : (
          <div className="content-grid">
            {content.map((item) => (
              <Link
                key={item.id}
                to={`/content/${item.id}`}
                className="content-card"
                data-testid={`content-card-${item.id}`}
              >
                  <div className={`category-badge category-${item.category}`}>
                    {item.category}
                  </div>
                  <h3>{item.title}</h3>
                  {item.description && (
                    <p style={{ opacity: 0.8, marginBottom: '1rem', fontStyle: 'italic' }}>{item.description}</p>
                  )}
                  {item.sanskrit_text && (
                    <p className="sanskrit-text" style={{ fontSize: '1.1rem', marginTop: 'auto' }}>
                      {item.sanskrit_text.substring(0, 100)}{item.sanskrit_text.length > 100 ? '...' : ''}
                    </p>
                  )}
                  <div style={{ marginTop: '1rem', display: 'flex', gap: '0.8rem', flexWrap: 'wrap' }}>
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
              </Link>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default ContentListPage;
