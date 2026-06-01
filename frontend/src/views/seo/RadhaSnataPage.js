'use client';

import React from 'react';
import { Link } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';

const RadhaSnataPage = () => {
  const pageUrl = `${SITE_URL}/what-is-radha-snata`;
  const title = 'What is Radha Snata? — Morning Pastimes & Spiritual Meaning';
  const description = 'Understand the concept of Radha Snata (Radha-snata-vibhusita) in Braj Rasik heritage. Explore its role in Asta-kaliya-lila and morning devotional meditations.';

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
        <script type="application/ld+json">{JSON.stringify(generateBreadcrumbSchema([{ name: 'Home', path: '/' }, { name: 'What is Radha Snata?', path: '/what-is-radha-snata' }]))}</script>
      </Helmet>

      <article className="py-12">
        <header className="mb-12">
          <div className="badge border-amber-400/30 text-amber-400/80 bg-amber-400/5 mb-4">Rasik Heritage</div>
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-white leading-tight">What is Radha Snata?</h1>
          <p className="text-lg text-white/60 leading-relaxed">Understanding the sacred morning pastimes (Pratah Leela) and spiritual meditation of Shri Radha's bath.</p>
        </header>

        <section className="prose-content">
          <h2 className="text-2xl font-bold mb-4 text-white/90">The Concept of Radha Snata (राधा स्नात)</h2>
          <p className="text-white/70 leading-relaxed mb-6">In the esoteric Vaishnava tradition of Vrindavan, particularly within the lineage of the Braj Rasik saints, <strong>Radha Snata</strong> (often referred to in Sanskrit verses as <em>Radha Snata-Vibhusita</em> — Srimati Radharani after completing Her divine morning bath and ornamentation) is not merely a physical action but a deep object of spiritual meditation (Smarana).</p>
          <p className="text-white/70 leading-relaxed mb-6">According to the Rasik scriptures, every moment of the Divine Couple, Shri Radha and Shri Krishna, is eternal, taking place in the spiritual realm of Nitya Vrindavan. The daily pastimes are structured into eight distinct periods of the day, known as the <strong>Asta-kaliya-lila</strong>. The morning pastime, occurring in the second period (<em>Dvitiya-Yama</em>, typically between 6:00 AM and 8:20 AM), is when Shri Radha returns to Her home in Yavat, takes Her sacred morning bath, is adorned with divine jewelry and clothing, and prepares delicious foods for Shri Krishna.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Significance in Asta-Kaliya-Lila</h2>
          <p className="text-white/70 leading-relaxed mb-6">During the morning hours, the Gopis and Manjaris (intimate maidservants) assist Srimati Radharani in Her bathing ritual. This pastime is rich with devotional sentiments (bhava):</p>
          <ul className="list-disc pl-6 text-white/70 mb-6 space-y-2">
            <li><strong>Snata (The Bath):</strong> Srimati Radharani is bathed with pure, scented waters infused with saffron, sandalwood paste, and fragrant flowers. This is described as a celebration of purity and divine beauty.</li>
            <li><strong>Vibhusita (The Adornment):</strong> Following the bath, the sakhis dress Her in brilliant blue garments (nilambari) and decorate Her with exquisite ornaments, including the legendary twelve ornaments and sixteen styles of makeup (Shringar).</li>
            <li><strong>The Meditation (Smarana):</strong> Rasik devotees meditate on this form of Radha Snata-Vibhusita to cultivate the mood of a maidservant (Manjari Bhava), desiring only to assist in the pleasure of the Divine Couple.</li>
          </ul>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Attribution in Rasik Texts</h2>
          <p className="text-white/70 leading-relaxed mb-6">The details of these morning rituals are vividly recorded in texts like the <em>Govinda-lilamrita</em> by Krishnadasa Kaviraja and the <em>Radha Rasa Sudhanidhi</em> (widely attributed to Prabodhananda Sarasvati or inspired by Hit Harivansh Mahaprabhu). These texts serve as contemplation guides for practitioners of Raganuga Bhakti, the path of spontaneous, loving devotion.</p>
          <p className="text-white/70 leading-relaxed mb-6">By meditating on Radha Snata, the devotee seeks to cleanse their own consciousness, aligning their heart with the pristine devotion exemplified by the sakhis of Vrindavan. It represents the awakening of devotional consciousness in the quiet, auspicious hours of the morning.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Practical Contemplation</h2>
          <p className="text-white/70 leading-relaxed mb-8">For seekers on the path of Braj Ras, reflecting on this pastime helps transition the mind from worldly thoughts to spiritual remembrance. The complete collection of <Link to="/content" className="text-primary hover:underline">devotional verses and vaanis</Link> contains direct references to these morning pastimes. Seekers can also study the lives of the <Link to="/saints" className="text-primary hover:underline">Braj Rasik Saints</Link> who experienced these leelas in deep trance.</p>
        </section>

        <InternalLinks exclude={['/what-is-radha-snata']} count={4} />
      </article>
      <SEOFooter />
    </div>
  );
};

export default RadhaSnataPage;
