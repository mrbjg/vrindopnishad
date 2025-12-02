import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import { API } from '../App';
import Navigation from '../components/Navigation';

const ContentListPage = () => {
  const [content, setContent] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all');

  useEffect(() => {
    fetchContent();
  }, [filter]);

  const fetchContent = async () => {
    try {
      setLoading(true);
      const params = filter !== 'all' ? { category: filter } : {};
      const response = await axios.get(`${API}/content`, { params });
      setContent(response.data.content || []);
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
          <h1 style={{ fontSize: '3rem', marginBottom: '1rem' }} data-testid="content-list-title">Sacred Collection</h1>
          <p style={{ fontSize: '1.2rem', color: '#5d3a1a' }}>Browse our collection of divine texts</p>
        </div>

        <div className="mb-4" style={{ display: 'flex', gap: '1rem', justifyContent: 'center', flexWrap: 'wrap' }}>
          <button
            className={`btn ${filter === 'all' ? 'btn-primary' : 'btn-outline'}`}
            onClick={() => setFilter('all')}
            data-testid="filter-all-btn"
          >
            All
          </button>
          <button
            className={`btn ${filter === 'shloka' ? 'btn-primary' : 'btn-outline'}`}
            onClick={() => setFilter('shloka')}
            data-testid="filter-shloka-btn"
          >
            Shlokas
          </button>
          <button
            className={`btn ${filter === 'strotra' ? 'btn-primary' : 'btn-outline'}`}
            onClick={() => setFilter('strotra')}
            data-testid="filter-strotra-btn"
          >
            Strotras
          </button>
          <button
            className={`btn ${filter === 'poem' ? 'btn-primary' : 'btn-outline'}`}
            onClick={() => setFilter('poem')}
            data-testid="filter-poem-btn"
          >
            Poems
          </button>
        </div>

        {loading ? (
          <div className="text-center mt-5">
            <div className="spinner"></div>
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
                    {item.audio_url && <span style={{ fontSize: '0.85rem', color: '#ff6b35' }}>🎵 Audio</span>}
                    {item.image_urls && item.image_urls.length > 0 && <span style={{ fontSize: '0.85rem', color: '#ff6b35' }}>🖼️ Images</span>}
                    {item.video_urls && item.video_urls.length > 0 && <span style={{ fontSize: '0.85rem', color: '#ff6b35' }}>🎬 Videos</span>}
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
