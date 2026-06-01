'use client';

import React from 'react';
import { Link } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
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
        <script type="application/ld+json">{JSON.stringify(generateArticleSchema(title, description, pageUrl))}</script>
        <script type="application/ld+json">{JSON.stringify(generateBreadcrumbSchema([{ name: 'Home', path: '/' }, { name: 'Teachings', path: '/teachings' }]))}</script>
      </Helmet>

      <article className="py-12">
        <header className="mb-12">
          <div className="badge border-rose-400/30 text-rose-400/80 bg-rose-400/5 mb-4">Wisdom</div>
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-white leading-tight">Teachings of Vrindopnishad</h1>
          <p className="text-lg text-white/60 leading-relaxed">Core spiritual teachings and sacred lessons from the Vedic and Bhakti traditions.</p>
        </header>

        <section className="prose-content">
          <h2 className="text-2xl font-bold mb-4 text-white/90">The Foundation of All Teachings</h2>
          <p className="text-white/70 leading-relaxed mb-6">The teachings preserved on Vrindopnishad emerge from a unified spiritual vision that sees all of existence as an expression of divine love. This fundamental insight — that the universe is not a mechanical accident but a deliberate outpouring of divine creativity and affection — forms the bedrock upon which all specific teachings are built. Whether the subject is cosmology, ethics, meditation, devotional practice, or the nature of the soul, this underlying understanding of reality as love-permeated informs every perspective offered on the platform.</p>
          <p className="text-white/70 leading-relaxed mb-6">The great Vaishnava acharyas (teachers) whose works form the core of Vrindopnishad's collection did not teach abstract philosophy divorced from lived experience. Their <Link to="/philosophy" className="text-primary hover:underline">philosophical insights</Link> emerged from deep states of meditation, devotional ecstasy, and direct communion with the divine. When they spoke of Brahman (the Absolute), they spoke from experience. When they described the various rasas (flavors of divine love), they described states they had tasted. This experiential grounding gives the teachings a vitality and authenticity that purely academic discourse often lacks.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Teaching One: The Primacy of Bhakti</h2>
          <p className="text-white/70 leading-relaxed mb-6">The central teaching of the Vrindavan tradition — and therefore of Vrindopnishad — is that Bhakti (devotional love) is the supreme path to spiritual realization. While other paths (karma yoga, jnana yoga, raja yoga) are respected and acknowledged as valid, the tradition holds that devotional love is both the means and the end of the spiritual journey. This is not mere sentimentality but a profound metaphysical claim: that the ultimate nature of reality is personal and loving, and therefore the most direct way to know reality is through love.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Teaching Two: The Eternal Nature of the Soul</h2>
          <p className="text-white/70 leading-relaxed mb-6">The Bhagavad Gita's teaching that the soul (atman) is eternal, unborn, and undying is foundational to the Vrindopnishad worldview. The soul is understood not as a product of material nature but as an eternally existing spiritual entity — a spark of the divine consciousness that temporarily inhabits a material body. Understanding the <Link to="/meaning" className="text-primary hover:underline">deeper meaning</Link> of this teaching transforms one's entire relationship with life, death, suffering, and joy.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Teaching Three: Dharma and Righteous Living</h2>
          <p className="text-white/70 leading-relaxed mb-6">Vrindopnishad preserves extensive teachings on dharma — the principle of righteous, harmonious living that sustains both individual well-being and cosmic order. The concept of dharma in the Vedic tradition is far richer than any single English translation can capture. It encompasses duty, natural law, moral order, cosmic justice, and the inherent purpose of every being. The sacred verses on the platform illuminate the many dimensions of dharma, offering guidance for navigating the ethical complexities of modern life.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Teaching Four: The Power of Sacred Sound</h2>
          <p className="text-white/70 leading-relaxed mb-6">The Vedic tradition places extraordinary emphasis on the transformative power of sacred sound (shabda). The mantras, shlokas, and strotras preserved on Vrindopnishad are not merely literary compositions but carefully constructed sonic instruments designed to produce specific spiritual effects. When chanted with proper pronunciation and devotional intent, these sacred sounds are understood to purify the mind, awaken dormant spiritual faculties, and create a direct connection between the chanter and the divine. The <Link to="/devotion" className="text-primary hover:underline">devotional practice</Link> of chanting is explored in depth on the platform.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Teaching Five: Seva — The Path of Sacred Service</h2>
          <p className="text-white/70 leading-relaxed mb-6">The teaching of seva (selfless service) is woven throughout the content on Vrindopnishad. In the Bhakti tradition, service to the divine and to all living beings is not merely a moral obligation but a joyful expression of love. The highest form of seva is to serve the devotees of the Lord and to facilitate others' spiritual progress — a principle that animates Vrindopnishad's own mission of making sacred knowledge freely and widely accessible.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Teaching Six: The Grace of the Guru</h2>
          <p className="text-white/70 leading-relaxed mb-6">The <Link to="/origin" className="text-primary hover:underline">tradition from which Vrindopnishad originates</Link> places great emphasis on the role of the guru (spiritual teacher) in the seeker's journey. The guru is understood not merely as an instructor who imparts information but as a living channel of divine grace who can transmit spiritual awakening through their presence, words, and blessings. The guru-shishya (teacher-student) relationship is the primary vehicle through which the esoteric teachings of the tradition are transmitted across generations.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Applying the Teachings</h2>
          <p className="text-white/70 leading-relaxed mb-8">These teachings are not meant to remain theoretical but to be applied in daily life. The <Link to="/guide" className="text-primary hover:underline">complete beginner's guide</Link> offers practical approaches, while the <Link to="/faq" className="text-primary hover:underline">FAQ section</Link> addresses common questions. <Link to="/content" className="text-primary hover:underline">Browse the full content library</Link> to engage directly with the source texts.</p>
        </section>

        <InternalLinks exclude={['/teachings']} count={4} />
      </article>
      <SEOFooter />
    </div>
  );
};

export default TeachingsPage;
