import React from 'react';
import { Link } from 'react-router-dom';
import Navigation from '../components/Navigation';
import InstallApp from '../components/InstallApp';
import { Compass, Scroll, Music, FileText, ArrowRight } from 'lucide-react';

const HomePage = () => {
  return (
    <div>
      <Navigation />
      <div className="hero">
        <div className="hero-content fade-in">
          <div className="om-symbol mb-3">ॐ</div>
          <h1 className="hero-title" data-testid="app-title">Vrindopnishad</h1>
          <p className="hero-subtitle" data-testid="app-subtitle">
            A sacred repository of Hindu Vaidik Sanskriti<br />
            Explore timeless wisdom through Shlokas, Strotras, and devotional poetry
          </p>
          <div style={{ display: 'flex', gap: '1rem', justifyContent: 'center', flexWrap: 'wrap' }}>
            <Link to="/content" className="btn btn-primary" data-testid="explore-content-btn">
              <Compass size={20} style={{ marginRight: '0.5rem' }} />
              Explore Content
            </Link>
            <Link to="/category/shloka" className="btn btn-secondary" data-testid="browse-shlokas-btn">
              <Scroll size={20} style={{ marginRight: '0.5rem' }} />
              Browse Shlokas
            </Link>
          </div>
        </div>
      </div>

      <div className="container mt-5">
        <div className="text-center mb-5">
          <h2 style={{ fontSize: '2.5rem', marginBottom: '1rem' }}>Categories</h2>
          <div className="decorative-border"></div>
        </div>

        <div className="content-grid">
          <Link to="/category/shloka" style={{ textDecoration: 'none' }}>
            <div className="card" data-testid="category-shloka-card">
              <div className="category-badge category-shloka mb-3" style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', justifyContent: 'center' }}>
                <Scroll size={18} />
                <span>Shlokas</span>
              </div>
              <h3 style={{ marginBottom: '1rem' }}>Sacred Verses</h3>
              <p style={{ color: '#666', lineHeight: '1.6' }}>
                Divine verses from Hindu scriptures including the Bhagavad Gita, Upanishads, and Vedas
              </p>
            </div>
          </Link>

          <Link to="/category/strotra" style={{ textDecoration: 'none' }}>
            <div className="card" data-testid="category-strotra-card">
              <div className="category-badge category-strotra mb-3" style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', justifyContent: 'center' }}>
                <Music size={18} />
                <span>Strotras</span>
              </div>
              <h3 style={{ marginBottom: '1rem' }}>Devotional Hymns</h3>
              <p style={{ color: '#666', lineHeight: '1.6' }}>
                Traditional hymns and prayers dedicated to various deities and divine forms
              </p>
            </div>
          </Link>

          <Link to="/category/poem" style={{ textDecoration: 'none' }}>
            <div className="card" data-testid="category-poem-card">
              <div className="category-badge category-poem mb-3" style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', justifyContent: 'center' }}>
                <FileText size={18} />
                <span>Poems</span>
              </div>
              <h3 style={{ marginBottom: '1rem' }}>Spiritual Poetry</h3>
              <p style={{ color: '#666', lineHeight: '1.6' }}>
                Devotional and spiritual poetry expressing the essence of Hindu philosophy
              </p>
            </div>
          </Link>
        </div>
      </div>

      <InstallApp />

      <div className="container mt-5" style={{ paddingBottom: '2rem' }}>
        <div className="card" style={{ background: 'linear-gradient(135deg, #fff5e6 0%, #ffe4b5 100%)', textAlign: 'center', padding: 'clamp(1.5rem, 5vw, 3rem)' }}>
          <h2 style={{ marginBottom: '1rem', fontSize: 'clamp(1.25rem, 4vw, 1.75rem)' }}>Experience Divine Wisdom</h2>
          <p style={{ fontSize: 'clamp(0.9rem, 3vw, 1.1rem)', color: '#5d3a1a', marginBottom: '1.5rem', maxWidth: '700px', margin: '0 auto 1.5rem', lineHeight: 1.6 }}>
            Read, Listen, and Immerse yourself in the sacred texts with audio narrations, beautiful imagery, and video content
          </p>
          <Link to="/content" className="btn btn-primary" data-testid="start-journey-btn">
            <ArrowRight size={20} style={{ marginRight: '0.5rem' }} />
            Start Your Journey
          </Link>
        </div>
      </div>
    </div>
  );
};

export default HomePage;
