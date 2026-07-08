'use client';

import React from 'react';
import { Link } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';

const MeaningPage = () => {
  const pageUrl = `${SITE_URL}/meaning`;
  const title = 'Meaning of Vrindopnishad — Etymology & Spiritual Significance';
  const description = 'Explore the profound meaning of Vrindopnishad. Understand the Sanskrit etymology, spiritual symbolism, and deeper significance behind this sacred name.';

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
        <script type="application/ld+json">{JSON.stringify(generateBreadcrumbSchema([{ name: 'Home', path: '/' }, { name: 'Meaning', path: '/meaning' }]))}</script>
      </Helmet>

      <article className="py-12">
        <header className="mb-12">
          <div className="badge border-purple-400/30 text-purple-400/80 bg-purple-400/5 mb-4">Etymology</div>
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-white leading-tight">Meaning of Vrindopnishad (वृंदोपनिषद्)</h1>
          <p className="text-lg text-white/60 leading-relaxed">A deep exploration of the Sanskrit roots, spiritual symbolism, and layered significance behind the name Vrindopnishad.</p>
        </header>

        <section className="prose-content">
          <h2 className="text-2xl font-bold mb-4 text-white/90">Sanskrit Etymology</h2>
          <p className="text-white/70 leading-relaxed mb-6">The word "Vrindopnishad" (वृंदोपनिषद्) is a Sanskrit compound formed by uniting two rich terms. "Vrinda" (वृंदा) means a cluster of sacred Tulsi plants — the earthly manifestation of goddess Vrinda Devi. In Vrindavan's devotional literature, Vrinda is intimately connected with the divine pastoral landscape where Lord Krishna enacted his transcendent plays (leelas). The forest of Vrindavan itself takes its name from these sacred groves.</p>
          <p className="text-white/70 leading-relaxed mb-6">"Upanishad" (उपनिषद्) derives from three Sanskrit roots: "upa" (near), "ni" (down), and "sad" (to sit) — painting a picture of a student sitting near a teacher to receive sacred knowledge. The Upanishads are the culminating wisdom texts of the Vedic corpus, dealing with the ultimate nature of reality (Brahman), the self (Atman), and liberation (Moksha).</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">The Combined Significance</h2>
          <p className="text-white/70 leading-relaxed mb-6">When merged into "Vrindopnishad," the compound suggests "the sacred, esoteric knowledge that flows from Vrindavan" — spiritual wisdom from the most sacred landscape in Vaishnava devotion. This is not academic knowledge but transformative wisdom received in a state of devotional surrender. It bridges the jnana (knowledge) tradition represented by the Upanishads with the bhakti (devotion) tradition centered in Vrindavan. This synthesis reflects a profound theological insight: the highest knowledge and deepest devotion are complementary paths leading to the same transcendent reality. Understanding this <Link to="/what-is-vrindopnishad" className="text-primary hover:underline">foundational concept</Link> is essential.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Vrinda — The Sacred Grove</h2>
          <p className="text-white/70 leading-relaxed mb-6">In Vaishnava theology, Vrinda Devi (Tulsi Devi) is the presiding deity of Vrindavan. "Vrindavan" means "the forest of Vrinda." According to sacred narratives, Vrinda Devi is an eternal associate of Radha and Krishna who maintains the divine forest. Every tree, every flower in Vrindavan is under her loving care. By invoking Vrinda, the platform signals its deep connection to this sacred <Link to="/origin" className="text-primary hover:underline">spiritual heritage</Link> — aspiring to be a digital space where divine knowledge unfolds naturally.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Upanishad — Sacred Transmission</h2>
          <p className="text-white/70 leading-relaxed mb-6">The Upanishadic tradition represents perhaps the most profound philosophical achievement of ancient India. Principal texts like the Isha, Kena, Katha, and Chandogya explore questions of ultimate meaning with astonishing depth. When Vrindopnishad incorporates "Upanishad" into its name, it commits to maintaining this standard of depth. The <Link to="/comparison-with-upanishads" className="text-primary hover:underline">comparison with classical Upanishads</Link> reveals this connection in detail.</p>
          <p className="text-white/70 leading-relaxed mb-6">The Upanishadic method emphasizes direct experience over information transfer. The teacher creates conditions for the student's own realization. Vrindopnishad's design reflects this pedagogy — content presented as wisdom to contemplate, not data to consume.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Layers of Meaning</h2>
          <p className="text-white/70 leading-relaxed mb-6">Like all great Sanskrit compounds, Vrindopnishad yields different meanings depending on approach. For the devotee: "the secret teaching of Vrindavan." For the <Link to="/philosophy" className="text-primary hover:underline">philosopher</Link>: "the Upanishad of the collective." For the poet: "the sacred truth hidden in the garden." The <Link to="/teachings" className="text-primary hover:underline">teachings</Link> reflect all these layers, meeting each seeker where they are.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">The Living Meaning</h2>
          <p className="text-white/70 leading-relaxed mb-8">The meaning of Vrindopnishad continues to unfold as the platform grows. Each new verse, each seeker finding insight — all expand what Vrindopnishad means. The platform embodies a central Upanishadic insight: truth is not a destination but an ever-deepening journey. <Link to="/lyrics" className="text-primary hover:underline">Explore the sacred content</Link> and discover the <Link to="/importance" className="text-primary hover:underline">importance of this wisdom</Link> yourself.</p>
        </section>

        <InternalLinks exclude={['/meaning']} count={4} />
      </article>
      <SEOFooter />
    </div>
  );
};

export default MeaningPage;
