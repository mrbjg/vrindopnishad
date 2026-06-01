'use client';

import React from 'react';
import { Link } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';

const GuidePage = () => {
  const pageUrl = `${SITE_URL}/guide`;
  const title = 'Complete Guide to Vrindopnishad — Your Spiritual Journey Starts Here';
  const description = 'A comprehensive beginner-friendly guide to Vrindopnishad. Learn how to navigate the platform, understand its content, and begin your spiritual exploration.';

  return (
    <div className="animate-fade-in max-w-4xl mx-auto">
      <Helmet>
        <title>{title}</title>
        <meta name="description" content={description} />
        <link rel="canonical" href={pageUrl} />
        <meta property="og:title" content={title} />
        <meta property="og:description" content={description} />
        <meta property="og:url" content={pageUrl} />
        <meta property="og:type" content="article" />
        <script type="application/ld+json">{JSON.stringify(generateArticleSchema(title, description, pageUrl))}</script>
        <script type="application/ld+json">{JSON.stringify(generateBreadcrumbSchema([{ name: 'Home', path: '/' }, { name: 'Guide', path: '/guide' }]))}</script>
      </Helmet>

      <article className="py-12">
        <header className="mb-12">
          <div className="badge border-green-400/30 text-green-400/80 bg-green-400/5 mb-4">Getting Started</div>
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-white leading-tight">Complete Guide to Vrindopnishad</h1>
          <p className="text-lg text-white/60 leading-relaxed">Everything you need to know to begin your spiritual journey with Vrindopnishad.</p>
        </header>

        <section className="prose-content">
          <h2 className="text-2xl font-bold mb-4 text-white/90">Welcome to Your Spiritual Journey</h2>
          <p className="text-white/70 leading-relaxed mb-6">Welcome to Vrindopnishad — a sacred digital sanctuary dedicated to preserving and sharing the spiritual wisdom of India's Vedic and Bhakti traditions. Whether you are a lifelong devotee or a curious newcomer, this guide will help you navigate the platform and make the most of its rich spiritual offerings. For a full introduction, see <Link to="/what-is-vrindopnishad" className="text-primary hover:underline">What is Vrindopnishad?</Link></p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Step 1: Understanding the Content Categories</h2>
          <p className="text-white/70 leading-relaxed mb-6">Vrindopnishad organizes its content into three main categories, each representing a distinct tradition of spiritual literature:</p>
          <p className="text-white/70 leading-relaxed mb-4"><strong className="text-white/80">Sacred Verses (Shlokas)</strong> — These are Sanskrit verses from the Vedas, Upanishads, Bhagavad Gita, and other scriptural texts. Each shloka is presented with the original Sanskrit, a Hindi transliteration, and an English explanation. Shlokas are the foundational texts of Hindu <Link to="/philosophy" className="text-primary hover:underline">philosophy</Link> and spirituality.</p>
          <p className="text-white/70 leading-relaxed mb-4"><strong className="text-white/80">Strotras (Devotional Hymns)</strong> — These are structured devotional prayers and hymns, often composed by great saints and acharyas. Strotras are traditionally chanted during worship and are believed to invoke specific spiritual blessings. Learn more about the <Link to="/devotion" className="text-primary hover:underline">devotional tradition</Link> behind them.</p>
          <p className="text-white/70 leading-relaxed mb-6"><strong className="text-white/80">Spiritual Poetry (Poems)</strong> — This category includes both classical and contemporary devotional poetry. From the medieval compositions of Surdas and Meera Bai to the living poetic traditions of Vrindavan, these works express the depths of divine love in accessible, emotionally resonant language.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Step 2: Navigating the Platform</h2>
          <p className="text-white/70 leading-relaxed mb-6">The <Link to="/" className="text-primary hover:underline">homepage</Link> provides quick access to all three content categories. Click on any category card to browse its contents. You can also use the <Link to="/content" className="text-primary hover:underline">content library</Link> page to search through the entire collection, filter by category, and discover content that resonates with your interests.</p>
          <p className="text-white/70 leading-relaxed mb-6">Each content page features the full text, often with audio playback for hearing the traditional chanting. The dark, contemplative interface is designed to create a distraction-free reading environment — think of it as entering a digital temple where every element supports your spiritual engagement.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Step 3: Suggested Reading Paths</h2>
          <p className="text-white/70 leading-relaxed mb-6">Depending on your interests and background, here are some suggested ways to explore Vrindopnishad:</p>
          <p className="text-white/70 leading-relaxed mb-4"><strong className="text-white/80">For Beginners:</strong> Start with the spiritual poetry section, which is often the most accessible. Then explore the strotras for a deeper devotional experience, and finally approach the shlokas for philosophical depth.</p>
          <p className="text-white/70 leading-relaxed mb-4"><strong className="text-white/80">For Scholars:</strong> Begin with the Sanskrit shlokas, cross-referencing with the <Link to="/comparison-with-upanishads" className="text-primary hover:underline">Upanishadic comparison</Link>. Explore the <Link to="/meaning" className="text-primary hover:underline">etymology and meaning</Link> section for linguistic insights.</p>
          <p className="text-white/70 leading-relaxed mb-6"><strong className="text-white/80">For Devotees:</strong> Head directly to the strotras and devotional poetry. Use the audio features for chanting practice. Read the <Link to="/teachings" className="text-primary hover:underline">teachings</Link> for spiritual guidance.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Step 4: Making It a Daily Practice</h2>
          <p className="text-white/70 leading-relaxed mb-6">The greatest benefit from Vrindopnishad comes through regular, contemplative engagement. Consider setting aside 10-15 minutes each day for spiritual reading. Choose a quiet time — early morning or late evening works best for most people. Read slowly, allowing the words to resonate. If audio is available, listen to the chanting as you read. This daily practice can gradually transform your inner landscape, bringing greater peace, clarity, and purpose to your life.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Step 5: Going Deeper</h2>
          <p className="text-white/70 leading-relaxed mb-6">Once you've familiarized yourself with the platform's basic offerings, explore the deeper dimensions: Read about the <Link to="/origin" className="text-primary hover:underline">origins</Link> of the traditions preserved here. Engage with the <Link to="/philosophy" className="text-primary hover:underline">philosophical framework</Link>. Understand the <Link to="/importance" className="text-primary hover:underline">importance</Link> of preservation work. These contextual pages will enrich your engagement with the primary content.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Quick Reference</h2>
          <div className="glass-card p-6 mb-8">
            <p className="text-white/70 leading-relaxed mb-2">🏠 <Link to="/" className="text-primary hover:underline">Homepage</Link> — Category overview and quick navigation</p>
            <p className="text-white/70 leading-relaxed mb-2">📚 <Link to="/content" className="text-primary hover:underline">Content Library</Link> — Browse and search all content</p>
            <p className="text-white/70 leading-relaxed mb-2">❓ <Link to="/faq" className="text-primary hover:underline">FAQ</Link> — Common questions answered</p>
            <p className="text-white/70 leading-relaxed mb-2">🌐 <a href="https://vrindopnishad.in" className="text-primary hover:underline" target="_blank" rel="noopener noreferrer">Main Website</a> — Vrindopnishad official site</p>
          </div>
        </section>

        <InternalLinks exclude={['/guide']} count={4} />
      </article>
      <SEOFooter />
    </div>
  );
};

export default GuidePage;
