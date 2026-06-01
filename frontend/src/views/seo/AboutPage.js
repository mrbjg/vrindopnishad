'use client';

import React from 'react';
import { Link } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';

const AboutPage = () => {
  const pageUrl = `${SITE_URL}/about`;
  const title = 'About Vrindopnishad — Archiving Sacred Braj Literature';
  const description = 'Learn about the mission, vision, and team behind Vrindopnishad. We digitally preserve ancient Sanskrit shlokas and teachings of Vrindavan rasik saints.';

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
        <script type="application/ld+json">{JSON.stringify(generateBreadcrumbSchema([{ name: 'Home', path: '/' }, { name: 'About', path: '/about' }]))}</script>
      </Helmet>

      <article className="py-12">
        <header className="mb-12">
          <div className="badge border-amber-400/30 text-amber-400/80 bg-amber-400/5 mb-4">Project Overview</div>
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-white leading-tight">About Vrindopnishad Project</h1>
          <p className="text-lg text-white/60 leading-relaxed">Dedicated to the digital preservation, verification, and dissemination of the rich devotional literature of the Braj region.</p>
        </header>

        <section className="prose-content">
          <h2 className="text-2xl font-bold mb-4 text-white/90">Our Vision & Mission</h2>
          <p className="text-white/70 leading-relaxed mb-6">
            The Vrindopnishad Project began as a collaborative effort to solve a major cultural problem: the decay and disappearance of ancient medieval manuscripts containing the compositions (Vaanis) of Braj Rasik saints. Written in dialects like Braj Bhasha and Sanskrit, these compositions have been preserved inside temples and private collections in Vrindavan, Barsana, and Radhakund. Our mission is to digitally archive, transliterate, translate, and explain these texts, making them available completely free of charge to researchers, devotees, and seekers worldwide.
          </p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Digital Ashram Framework</h2>
          <p className="text-white/70 leading-relaxed mb-6">
            We model this platform not just as a website, but as a digital ashram. In the Vedic tradition, an ashram is a sanctuary for contemplation, chanting, and learning. Vrindopnishad incorporates interactive components such as:
          </p>
          <ul className="list-disc pl-6 text-white/70 mb-6 space-y-2">
            <li><strong>Chanting Tools:</strong> Interactive Japa counters to assist daily spiritual practice.</li>
            <li><strong>Audio Chanting:</strong> High-fidelity audio recordings of Sanskrit shlokas and bhajans sung in traditional temple ragas to restore the oral transmission heritage.</li>
            <li><strong>Fuzzy Multilingual Search:</strong> Enabling seekers to search using Hindi, English, or Hinglish transliterations.</li>
          </ul>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Collaborative Stewardship</h2>
          <p className="text-white/70 leading-relaxed mb-6">
            Our platform operates under the direct supervision of Sanskrit scholars, manuscript editors, and veteran practitioners of the Braj Rasik lineages (including Gaudiya, Radhavallabh, and Haridasi traditions). We believe that the preservation of this wisdom must be done with utmost care, maintaining scriptural accuracy while leveraging modern technology to build a lightweight, fast, and accessible content hub.
          </p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Why It Matters</h2>
          <p className="text-white/70 leading-relaxed mb-8">
            In a fast-paced digital era, there is an urgent need for stabilizing spaces that offer authentic spiritual depth. By providing a clean, accessible, and structured library of sacred verses, we help users transition from digital noise to a state of inner peace and contemplation. Discover more in our <Link to="/what-is-vrindopnishad" className="text-primary hover:underline">definition guide</Link> and study our <Link to="/philosophy" className="text-primary hover:underline">spiritual philosophy</Link>.
          </p>
        </section>

        <InternalLinks exclude={['/about']} count={4} />
      </article>
      <SEOFooter />
    </div>
  );
};

export default AboutPage;
