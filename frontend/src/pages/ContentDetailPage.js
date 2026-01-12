import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { apiService } from '../services/api';
import Navigation from '../components/Navigation';
import Loader from '../components/Loader';
import { ArrowLeft, Music, Image as ImageIcon, Video } from 'lucide-react';

const ContentDetailPage = () => {
  const { id } = useParams();
  const [content, setContent] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchContent();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  const fetchContent = async () => {
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

  if (loading) {
    return (
      <div>
        <Navigation />
        <div className="container mt-5 text-center">
          <Loader text="Loading content details..." />
        </div>
      </div>
    );
  }

  if (!content) {
    return (
      <div>
        <Navigation />
        <div className="container mt-5">
          <div className="card text-center" style={{ padding: '3rem' }}>
            <h2>Content not found</h2>
            <Link to="/content" className="btn btn-primary mt-3" data-testid="back-to-content-btn">
              Back to Content
            </Link>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div>
      <Navigation />
      <div className="container mt-4" style={{ maxWidth: '900px' }}>
        <Link to="/content" className="btn btn-outline mb-3" data-testid="back-btn" style={{ display: 'inline-flex', alignItems: 'center', gap: '0.5rem' }}>
          <ArrowLeft size={18} />
          Back to Collection
        </Link>

        <div className="card content-detail-card">
          <div className={`category-badge category-${content.category} mb-3`}>
            {content.category}
          </div>

          <h1 style={{ fontSize: 'clamp(1.5rem, 5vw, 2.5rem)', marginBottom: '1.5rem' }} data-testid="content-title">
            {content.title}
          </h1>

          {content.description && (
            <div className="mb-4">
              <p style={{ fontSize: '1.1rem', color: '#666', lineHeight: '1.6' }}>
                {content.description}
              </p>
            </div>
          )}

          <div className="decorative-border"></div>

          {content.sanskrit_text && (
            <div className="mb-4" data-testid="sanskrit-text-section">
              <h3 style={{ marginBottom: '1rem' }}>Sanskrit Text</h3>
              <div className="sanskrit-text" style={{ padding: '1.5rem', background: 'rgba(255, 107, 53, 0.05)', borderRadius: '12px' }}>
                {content.sanskrit_text}
              </div>
            </div>
          )}

          {content.hindi_text && (
            <div className="mb-4" data-testid="hindi-text-section">
              <h3 style={{ marginBottom: '1rem' }}>Hindi Text</h3>
              <div style={{ padding: '1.5rem', background: 'rgba(255, 215, 0, 0.05)', borderRadius: '12px', fontFamily: 'Cormorant Garamond, serif', fontSize: '1.2rem', lineHeight: '1.8' }}>
                {content.hindi_text}
              </div>
            </div>
          )}

          {content.english_text && (
            <div className="mb-4" data-testid="english-text-section">
              <h3 style={{ marginBottom: '1rem' }}>English Transliteration</h3>
              <div style={{ padding: '1.5rem', background: 'rgba(139, 37, 0, 0.05)', borderRadius: '12px', fontSize: '1.1rem', lineHeight: '1.8' }}>
                {content.english_text}
              </div>
            </div>
          )}

          {content.english_translation && (
            <div className="mb-4" data-testid="english-translation-section">
              <h3 style={{ marginBottom: '1rem' }}>English Translation</h3>
              <div style={{ padding: '1.5rem', background: 'rgba(156, 39, 176, 0.05)', borderRadius: '12px', fontSize: '1.05rem', lineHeight: '1.7', color: '#5d3a1a' }}>
                {content.english_translation}
              </div>
            </div>
          )}

          {content.audio_url && (
            <div className="mb-4" data-testid="audio-section">
              <h3 style={{ marginBottom: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <Music size={24} />
                Listen
              </h3>
              <div className="audio-player">
                <audio controls data-testid="audio-player">
                  <source src={content.audio_url} type="audio/mpeg" />
                  Your browser does not support the audio element.
                </audio>
              </div>
            </div>
          )}

          {(content.image_url || (content.image_urls && content.image_urls.length > 0)) && (
            <div className="mb-4" data-testid="images-section">
              <h3 style={{ marginBottom: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <ImageIcon size={24} />
                Sacred Imagery
              </h3>
              <div className="image-gallery">
                {content.image_url && (
                  <img
                    src={content.image_url}
                    alt={`${content.title}`}
                    className="gallery-image"
                    style={{ marginBottom: '1rem' }}
                  />
                )}
                {content.image_urls && content.image_urls.map((url, idx) => (
                  <img
                    key={idx}
                    src={url}
                    alt={`${content.title} ${idx + 1}`}
                    className="gallery-image"
                    data-testid={`gallery-image-${idx}`}
                  />
                ))}
              </div>
            </div>
          )}

          {content.video_urls && content.video_urls.length > 0 && (
            <div className="mb-4" data-testid="videos-section">
              <h3 style={{ marginBottom: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <Video size={24} />
                Video Content
              </h3>
              {content.video_urls.map((url, idx) => (
                <div key={idx} className="video-container mb-3">
                  <video controls data-testid={`video-player-${idx}`}>
                    <source src={url} type="video/mp4" />
                    Your browser does not support the video element.
                  </video>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default ContentDetailPage;
