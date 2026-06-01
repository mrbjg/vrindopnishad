'use client';

import React from 'react';
import { Link } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';

const NityaViharPage = () => {
  const pageUrl = `${SITE_URL}/nitya-vihar-vs-nikunj-vihar`;
  const title = 'Nitya Vihar vs Nikunj Vihar — Differences & Spiritual Meaning';
  const description = 'Learn the difference between Nitya Vihar and Nikunj Vihar in Vrindavan theology. Explore the teachings of Swami Haridas and Hit Harivansh.';

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
        <script type="application/ld+json">{JSON.stringify(generateBreadcrumbSchema([{ name: 'Home', path: '/' }, { name: 'Nitya Vihar vs Nikunj Vihar', path: '/nitya-vihar-vs-nikunj-vihar' }]))}</script>
      </Helmet>

      <article className="py-12">
        <header className="mb-12">
          <div className="badge border-emerald-400/30 text-emerald-400/80 bg-emerald-400/5 mb-4">Philosophy & Siddhanta</div>
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-white leading-tight">Nitya Vihar vs Nikunj Vihar</h1>
          <p className="text-lg text-white/60 leading-relaxed">Understanding the concepts of eternal divine play (Nitya Vihar) and the intimate grove pastimes (Nikunj Vihar) in Braj Bhakti.</p>
        </header>

        <section className="prose-content">
          <h2 className="text-2xl font-bold mb-4 text-white/90">The Core Definitions</h2>
          <p className="text-white/70 leading-relaxed mb-6">In the spiritual traditions of Vrindavan, particularly within the <strong>Haridasi Sampradaya</strong> (founded by Swami Haridas) and the <strong>Radhavallabh Sampradaya</strong> (founded by Goswami Hit Harivansh Mahaprabhu), the terms <strong>Nitya Vihar</strong> (नित्य विहार) and <strong>Nikunj Vihar</strong> (निकुंज विहार) represent the pinnacle of devotional aesthetics (Rasa). While closely related, they highlight distinct aspects of the divine relationship between Shri Radha and Shri Krishna.</p>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 my-8">
            <div className="p-6 rounded-lg bg-white/5 border border-white/10">
              <h3 className="text-xl font-bold mb-2 text-white/90">Nitya Vihar</h3>
              <p className="text-white/70 text-sm leading-relaxed">Refers to the <strong>eternal, continuous, and timeless nature</strong> of the love-play. It has no beginning, no end, and no element of physical or emotional separation (viraha). It is always occurring in the present moment.</p>
            </div>
            <div className="p-6 rounded-lg bg-white/5 border border-white/10">
              <h3 className="text-xl font-bold mb-2 text-white/90">Nikunj Vihar</h3>
              <p className="text-white/70 text-sm leading-relaxed">Refers to the <strong>spatial setting and physical expression</strong> of this play. "Nikunj" means the secluded bowers or dynamic, lush green groves of Vrindavan where the most confidential pastimes unfold in privacy.</p>
            </div>
          </div>

          <h2 className="text-2xl font-bold mb-4 text-white/90">The Theological Differences</h2>
          <p className="text-white/70 leading-relaxed mb-6">Though often used together as "Nitya Nikunj Vihar," theological scholars and saints distinguish them as follows:</p>
          <ul className="list-disc pl-6 text-white/70 mb-6 space-y-2">
            <li><strong>State vs. Setting:</strong> <em>Nitya Vihar</em> is the state of constant union and mutual fascination between the divine lovers. <em>Nikunj Vihar</em> represents the aesthetic atmosphere, the forest alcoves decorated by nature, and the intimate service (Seva) performed by the Sahacharis (sakhis).</li>
            <li><strong>Aspect of Eternity:</strong> The word "Nitya" underscores that the leela is not subject to the laws of karma, reincarnation, or cosmic time. It is a completely spiritual, static yet dynamic flow of love. "Nikunj" emphasizes privacy and confidentiality, away from the majestic, formal aspects of divinity (Aishwarya) seen in Vaikuntha.</li>
            <li><strong>Upasana (Worship):</strong> Swami Haridas placed ultimate emphasis on worshiping the couple specifically as they reside together eternally in the Nikunj. For a Haridasi or Radhavallabhi practitioner, the goal is not Vaikuntha or Dwaraka, but entering the eternal Nikunj as a silent servant of the divine couple's pleasure.</li>
          </ul>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Elimination of Separation (Viraha-Abhava)</h2>
          <p className="text-white/70 leading-relaxed mb-6">Unlike other Bhakti lineages that highlight the intense pain of separation (Viraha) as the highest state of love, Nitya Vihar asserts that there is no separation in the eternal bowers of Vrindavan. Because Radha and Krishna are one soul in two bodies, their union is uninterrupted. Even when they appear to look away, it is only to experience the thrill of meeting again a microsecond later — an ever-fresh, ever-increasing flow of bliss (Pratipada-Nava-Nava-Rasa).</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Applying the Wisdom</h2>
          <p className="text-white/70 leading-relaxed mb-8">Understanding these concepts allows seekers to grasp the deep meanings behind the <Link to="/granthas" className="text-primary hover:underline">sacred granthas</Link> of Swami Haridas (Kelimal) and Hit Harivansh (Sphut Vaani). To dive deeper into these teachings, explore our <Link to="/philosophy" className="text-primary hover:underline">philosophy page</Link> or look up specific verses under the <Link to="/content" className="text-primary hover:underline">complete list of Vaani texts</Link>.</p>
        </section>

        <InternalLinks exclude={['/nitya-vihar-vs-nikunj-vihar']} count={4} />
      </article>
      <SEOFooter />
    </div>
  );
};

export default NityaViharPage;
