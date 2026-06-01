'use client';

import React from 'react';
import { Link } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';

const PhilosophyPage = () => {
  const pageUrl = `${SITE_URL}/philosophy`;
  const title = 'Philosophy of Vrindopnishad — Vedantic Wisdom & Bhakti Principles';
  const description = 'Explore the philosophical framework of Vrindopnishad, blending Vedantic wisdom with Bhakti devotion. Learn about Achintya Bheda Abheda and Rasa theory.';

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
        <script type="application/ld+json">{JSON.stringify(generateBreadcrumbSchema([{ name: 'Home', path: '/' }, { name: 'Philosophy', path: '/philosophy' }]))}</script>
      </Helmet>

      <article className="py-12">
        <header className="mb-12">
          <div className="badge border-sky-400/30 text-sky-400/80 bg-sky-400/5 mb-4">Philosophy</div>
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-white leading-tight">Philosophy of Vrindopnishad</h1>
          <p className="text-lg text-white/60 leading-relaxed">The philosophical framework blending Vedantic knowledge and Bhakti devotion.</p>
        </header>

        <section className="prose-content">
          <h2 className="text-2xl font-bold mb-4 text-white/90">The Philosophical Foundation</h2>
          <p className="text-white/70 leading-relaxed mb-6">Vrindopnishad's philosophical framework draws from the rich tapestry of Indian darshana (philosophical vision), with particular emphasis on the Vedanta tradition as interpreted through the lens of Bhakti (devotional) theology. The platform's approach to knowledge is rooted in the understanding that intellectual comprehension and heartfelt devotion are not separate pursues but intertwined aspects of a single spiritual journey. This integration of head and heart, jnana and bhakti, is what gives Vrindopnishad its distinctive philosophical character.</p>
          <p className="text-white/70 leading-relaxed mb-6">At the core of this philosophy lies the concept of "Achintya Bheda Abheda" (अचिन्त्य भेद अभेद) — the "inconceivable simultaneous oneness and difference" between the individual soul, the material world, and the Supreme. This theological framework, articulated by Sri Chaitanya Mahaprabhu in the 16th century, resolves the apparent contradiction between the Advaita (non-dualist) and Dvaita (dualist) schools of Vedanta by proposing that the relationship between God and creation is simultaneously one of identity and difference — a paradox that transcends rational categorization but is directly experienceable through devotion.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Rasa Theory — The Philosophy of Spiritual Aesthetics</h2>
          <p className="text-white/70 leading-relaxed mb-6">Perhaps the most distinctive philosophical contribution of the Vrindavan tradition — and therefore of Vrindopnishad — is the fully developed Rasa theory of spiritual experience. Originally articulated in Bharata Muni's Natyashastra as a theory of dramatic aesthetics, Rasa theory was transformed by Rupa Goswami and other Gaudiya Vaishnava theologians into a comprehensive framework for understanding the varieties and depths of the soul's relationship with the divine.</p>
          <p className="text-white/70 leading-relaxed mb-6">According to this framework, the soul's natural relationship with the Supreme can be expressed through five primary rasas (devotional flavors): shanta (peaceful contemplation), dasya (reverent servitude), sakhya (intimate friendship), vatsalya (parental affection), and madhurya (conjugal love). The <Link to="/teachings" className="text-primary hover:underline">teachings on Vrindopnishad</Link> include texts that explore each of these rasas in depth, offering seekers a nuanced understanding of the many ways divine love can be experienced and expressed.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Knowledge as Devotion</h2>
          <p className="text-white/70 leading-relaxed mb-6">Vrindopnishad's philosophy rejects the false dichotomy between knowledge (jnana) and devotion (bhakti) that has sometimes divided Indian philosophical discourse. Following the <Link to="/meaning" className="text-primary hover:underline">deeper meaning embedded in its name</Link>, the platform understands genuine knowledge as inherently devotional — to truly know the divine is to love the divine, and to truly love is to know. The Upanishadic quest for Brahman and the Bhakti saint's yearning for Krishna are understood as two expressions of the same fundamental human aspiration for transcendence.</p>
          <p className="text-white/70 leading-relaxed mb-6">This philosophical stance has practical implications for how content is presented on the platform. Texts are not merely analyzed intellectually but presented in ways that invite contemplative engagement. The audio features, the visual aesthetics, the careful attention to typography and spacing — all serve to create an environment where knowledge can transform into experience, where reading becomes a form of meditation, and where the boundary between study and worship dissolves.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">The Ethics of Preservation</h2>
          <p className="text-white/70 leading-relaxed mb-6">Vrindopnishad also embodies a philosophy of cultural and spiritual preservation. The platform operates from the conviction that the <Link to="/devotion" className="text-primary hover:underline">devotional traditions</Link> it preserves are not merely historical artifacts but living streams of wisdom that continue to offer genuine solutions to contemporary existential challenges. In a world increasingly characterized by materialism, ecological crisis, and existential anxiety, the Vedic and Bhakti traditions offer alternative frameworks for understanding human purpose, fostering genuine happiness, and living in harmony with nature.</p>
          <p className="text-white/70 leading-relaxed mb-6">The <Link to="/origin" className="text-primary hover:underline">origins of these traditions</Link> stretch back millennia, yet their philosophical insights remain strikingly relevant. The Upanishadic understanding of consciousness, the Bhagavad Gita's teachings on action without attachment, the Bhakti poets' celebration of divine love as the supreme reality — these philosophical threads, woven together on Vrindopnishad, form a tapestry of wisdom that speaks directly to the deepest needs of the human spirit.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Practical Application</h2>
          <p className="text-white/70 leading-relaxed mb-8">Philosophy without practice is mere speculation. Vrindopnishad's philosophy finds practical expression in how seekers engage with the platform. The <Link to="/guide" className="text-primary hover:underline">complete guide</Link> offers structured pathways for applying these philosophical principles in daily life. Whether through daily reading of sacred verses, contemplative engagement with devotional poetry, or systematic study of philosophical texts — the platform provides tools for transforming philosophical understanding into lived spiritual experience. Explore the <Link to="/faq" className="text-primary hover:underline">FAQ section</Link> for answers to common philosophical questions.</p>
        </section>

        <InternalLinks exclude={['/philosophy']} count={4} />
      </article>
      <SEOFooter />
    </div>
  );
};

export default PhilosophyPage;
