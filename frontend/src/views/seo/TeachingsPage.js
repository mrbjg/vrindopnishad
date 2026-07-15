'use client';

import React from 'react';
import { Link } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';

const TeachingsPage = () => {
  const pageUrl = `${SITE_URL}/teachings`;
  const title = 'Teachings of Vrindopnishad — Key Spiritual Wisdom & Sacred Lessons';
  const description = 'Explore the core teachings of Vrindopnishad covering Bhakti yoga, self-realization, dharma, divine love, and the path to spiritual liberation.';

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
      </Helmet>

      <article className="py-12">
        <header className="mb-12">
          <div className="badge border-rose-400/30 text-rose-400/80 bg-rose-400/5 mb-4">Wisdom</div>
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-white leading-tight">Teachings of Vrindopnishad</h1>
          <p className="text-lg text-white/60 leading-relaxed">Core spiritual teachings and sacred lessons from the Vedic and Bhakti traditions.</p>
        </header>

        <section className="prose-content">
          <h2 className="text-2xl font-bold mb-4 text-white/90">The Foundation of All Teachings</h2>
          <p className="text-white/70 leading-relaxed mb-6">
            The core teachings of Vrindopnishad are derived from the practical realizations of the VrindaVaani Devotee saints. These instructions are not abstract intellectual theories; they are practical, heart-centered guidelines for waking the soul\'s innate capacity for divine love (*Prema*).
          </p>

          <h2>Scriptural Instruction on Humility and Chanting</h2>
          <p className="text-white/70 leading-relaxed mb-4">
            The fundamental mindset required to progress on the path of spontaneous devotion (*Raganuga Bhakti*) is described in this canonical Sanskrit verse:
          </p>
          <div className="verse-card">
            <p className="devanagari">तृणादपि सुनीचेन तरोरपि सहिष्णुना।</p>
            <p className="devanagari">अमानिना मानदेन कीर्तनीयः सदा हरिः॥</p>
            <p className="translation">
              <strong>Source Citation:</strong> <em>Sri Siksastakam (Verse 3) by Sri Chaitanya Mahaprabhu</em>. 
              <strong>Translation:</strong> One who thinks themselves lower than a blade of grass, who is more tolerant than a tree, who demands no respect for himself but offers all respect to others, can chant the holy name of the Lord constantly.
            </p>
          </div>

          <h2 className="text-2xl font-bold mb-4 text-white/90">The Six Core Pillars of Braj Devotion</h2>
          
          <h3>1. Constant Remembrance (Nama Japa)</h3>
          <p className="text-white/70 leading-relaxed mb-4">
            Reciting the holy name of God, especially the name "Radha" or the Mahamantra, is taught as the supreme purification tool for the mind in this age. As cited in <em>Siddhanta ke Pad (Pad 2) by Swami Haridas</em>, constant chanting stabilizes the breath and redirects sensory desires toward divine consciousness.
          </p>

          <h3>2. Swadhyaya & Bani Path</h3>
          <p className="text-white/70 leading-relaxed mb-4">
            Daily recitation of the written verses (*Vani*) of the realized acharyas is considered a direct form of saintly association (*Satsang*). The words are understood to carry the direct spiritual potency of the saint\'s realization.
          </p>

          <h3>3. Absolute Humility & Non-criticism (Amanina Manadena)</h3>
          <p className="text-white/70 leading-relaxed mb-4">
            A devotee must completely avoid finding fault in others (*Ninda*). Revering every living entity as a temple of the Divine is essential for preserving devotional stability.
          </p>

          <h3>4. Association with Truth (Sadhu Sanga)</h3>
          <p className="text-white/70 leading-relaxed mb-4">
            Keeping company with simple, dedicated practitioners protects the mind from digital and materialistic distractions.
          </p>

          <h3>5. Spontaneous Service (Raganuga Seva)</h3>
          <p className="text-white/70 leading-relaxed mb-4">
            Transitioning from formal rule-bound worship (*Vaidhi*) to spontaneous affection-driven service (*Raga*), serving the Divine Couple out of pure desire to bring Them happiness, as illustrated in <em>Hit Chaurasi (Pad 10)</em>.
          </p>

          <h3>6. Devotion to the Dham</h3>
          <p className="text-white/70 leading-relaxed mb-6">
            Treating the physical environment of Vrindavan, the dust (*Braj Raj*), and the Yamuna river with deep reverence, maintaining ecological cleanliness as a service to the transcendental playground.
          </p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Original Commentary on Practical Sadhana</h2>
          <p className="text-white/70 leading-relaxed mb-8">
            These teachings represent a practical path of interiorized meditation. Rather than recommending physical withdrawal from the world, the Rasik saints teach the transformation of consciousness within our daily duties. Seekers can begin with the <Link to="/guide" className="text-primary hover:underline">Sadhana Guide</Link> or resolve specific doubts in the <Link to="/faq" className="text-primary hover:underline">FAQ section</Link>.
          </p>
        </section>

        <InternalLinks exclude={['/teachings']} count={4} />
      </article>
      <SEOFooter />
    </div>
  );
};

export default TeachingsPage;
