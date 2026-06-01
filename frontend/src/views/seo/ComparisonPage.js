'use client';

import React from 'react';
import { Link } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';

const ComparisonPage = () => {
  const pageUrl = `${SITE_URL}/comparison-with-upanishads`;
  const title = 'Vrindopnishad vs Classical Upanishads — A Scholarly Comparison';
  const description = 'Compare Vrindopnishad with classical Upanishads. Understand the relationship between Vedantic knowledge tradition and Bhakti devotional wisdom.';

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
        <script type="application/ld+json">{JSON.stringify(generateBreadcrumbSchema([{ name: 'Home', path: '/' }, { name: 'Comparison with Upanishads', path: '/comparison-with-upanishads' }]))}</script>
      </Helmet>

      <article className="py-12">
        <header className="mb-12">
          <div className="badge border-indigo-400/30 text-indigo-400/80 bg-indigo-400/5 mb-4">Comparison</div>
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-white leading-tight">Vrindopnishad & Classical Upanishads</h1>
          <p className="text-lg text-white/60 leading-relaxed">A scholarly exploration of how Vrindopnishad relates to and extends the classical Upanishadic tradition.</p>
        </header>

        <section className="prose-content">
          <h2 className="text-2xl font-bold mb-4 text-white/90">What Are the Classical Upanishads?</h2>
          <p className="text-white/70 leading-relaxed mb-6">The Upanishads are the concluding portions of the Vedas — India's most ancient and authoritative scriptural texts. The word "Upanishad" literally means "sitting near" (a teacher to receive secret, sacred knowledge). There are traditionally 108 Upanishads, though scholars recognize between 10 and 13 as the "principal" or "mukhya" Upanishads: Isha, Kena, Katha, Prashna, Mundaka, Mandukya, Taittiriya, Aitareya, Chandogya, Brihadaranyaka, Shvetashvatara, Kaushitaki, and Maitri.</p>
          <p className="text-white/70 leading-relaxed mb-6">These texts, composed between approximately 800-200 BCE, represent the philosophical culmination of Vedic thought. They shift the focus from the ritualistic concerns of the earlier Vedic hymns to profound metaphysical inquiries about the nature of Brahman (the Absolute Reality), Atman (the individual self), the relationship between the two, and the means to liberation (moksha). The great mahavakyas (great sayings) of the Upanishads — such as "Tat Tvam Asi" (You Are That), "Aham Brahmasmi" (I Am Brahman), and "Sarvam Khalvidam Brahma" (All This Is Brahman) — are foundational to Indian <Link to="/philosophy" className="text-primary hover:underline">philosophical thought</Link>.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">How Vrindopnishad Relates to the Classical Tradition</h2>
          <p className="text-white/70 leading-relaxed mb-6">The relationship between Vrindopnishad and the classical Upanishads is one of continuity, deepening, and creative extension rather than opposition or replacement. The <Link to="/meaning" className="text-primary hover:underline">meaning of the name</Link> "Vrindopnishad" itself signals this relationship — by incorporating "Upanishad," the platform positions itself within the Upanishadic lineage while adding the distinctively devotional flavor of the Vrindavan tradition.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Key Points of Comparison</h2>

          <h3 className="text-xl font-semibold mb-3 text-white/85">Approach to the Absolute</h3>
          <p className="text-white/70 leading-relaxed mb-6">The classical Upanishads tend to describe Brahman in both personal (saguna) and impersonal (nirguna) terms, with different texts emphasizing different aspects. Vrindopnishad, following the Gaudiya Vaishnava interpretation, understands the personal aspect as primary — Brahman is ultimately a person (Bhagavan) whose most intimate form is Krishna. This is not a departure from the Upanishads but a particular reading of them, supported by texts like the Shvetashvatara Upanishad.</p>

          <h3 className="text-xl font-semibold mb-3 text-white/85">Method of Realization</h3>
          <p className="text-white/70 leading-relaxed mb-6">While the classical Upanishads emphasize jnana (knowledge) and dhyana (meditation) as the primary means of self-realization, Vrindopnishad follows the Bhakti tradition in emphasizing devotional love as the supreme method. However, this is not an either/or distinction — the <Link to="/teachings" className="text-primary hover:underline">teachings on Vrindopnishad</Link> show how knowledge and devotion complement each other.</p>

          <h3 className="text-xl font-semibold mb-3 text-white/85">Language and Accessibility</h3>
          <p className="text-white/70 leading-relaxed mb-6">The classical Upanishads are composed in Vedic Sanskrit — a highly specialized literary language accessible only to scholars. Vrindopnishad's content, while including Sanskrit originals, also offers Hindi and English translations, continuing the Bhakti movement's tradition of making spiritual wisdom accessible in common languages. This democratization of knowledge aligns with the Upanishadic spirit even while departing from its linguistic exclusivity.</p>

          <h3 className="text-xl font-semibold mb-3 text-white/85">Emotional Dimension</h3>
          <p className="text-white/70 leading-relaxed mb-6">Perhaps the most significant difference is the emotional dimension. The classical Upanishads maintain a relatively austere, philosophical tone. Vrindopnishad's content, rooted in the <Link to="/devotion" className="text-primary hover:underline">Bhakti tradition</Link>, is suffused with emotional intensity — longing, joy, love, separation, reunion. This emotional richness is not seen as inferior to philosophical rigor but as its natural complement and fulfillment.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">The Synthesis</h2>
          <p className="text-white/70 leading-relaxed mb-8">Vrindopnishad represents a creative synthesis of the classical Upanishadic tradition of deep philosophical inquiry with the Bhakti tradition of passionate devotional engagement. Rather than choosing between head and heart, it invites seekers to bring their whole being — intellect, emotion, will, and imagination — to the encounter with sacred truth. Explore the <Link to="/origin" className="text-primary hover:underline">historical origins</Link>, read the <Link to="/guide" className="text-primary hover:underline">complete guide</Link>, or dive into the <Link to="/content" className="text-primary hover:underline">content library</Link> to experience this synthesis firsthand.</p>
        </section>

        <InternalLinks exclude={['/comparison-with-upanishads']} count={4} />
      </article>
      <SEOFooter />
    </div>
  );
};

export default ComparisonPage;
