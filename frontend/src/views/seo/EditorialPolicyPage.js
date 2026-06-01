'use client';

import React from 'react';
import { Helmet } from 'react-helmet-async';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';

const EditorialPolicyPage = () => {
  const pageUrl = `${SITE_URL}/editorial-policy`;
  const title = 'Editorial & Verification Policy — Vrindopnishad';
  const description = 'Read the editorial standards of Vrindopnishad. Learn how we verify Sanskrit shlokas, Braj Bhasha poetry, and translations for scriptural accuracy.';

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
        <script type="application/ld+json">{JSON.stringify(generateBreadcrumbSchema([{ name: 'Home', path: '/' }, { name: 'Editorial Policy', path: '/editorial-policy' }]))}</script>
      </Helmet>

      <article className="py-12">
        <header className="mb-12">
          <div className="badge border-blue-400/30 text-blue-400/80 bg-blue-400/5 mb-4">Standards</div>
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-white leading-tight">Editorial & Verification Policy</h1>
          <p className="text-lg text-white/60 leading-relaxed">Our commitment to absolute accuracy, scholarly review, and manuscript fidelity in digital scriptural publication.</p>
        </header>

        <section className="prose-content">
          <h2 className="text-2xl font-bold mb-4 text-white/90">Source Verification Standards</h2>
          <p className="text-white/70 leading-relaxed mb-6">
            Every verse (shloka, pad, or stotra) published on Vrindopnishad undergoes a strict multi-phase review process. We compile text exclusively from authoritative scriptural prints, critical editions published by established research centers (such as Vrindavan Research Institute and Gita Press), and verified temple manuscripts. No text is added to our public database without cross-referencing against at least three independent print editions to detect and fix typographical variations.
          </p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Translation & Commentary Guidelines</h2>
          <p className="text-white/70 leading-relaxed mb-6">
            Translations and commentaries on the platform are structured to preserve the original devotional sentiment (Bhav) while remaining philosophically consistent with the established commentaries of historical Acharyas (e.g., Sripad Sanatana Goswami, Sri Hit Harivansh Mahaprabhu). 
            Our guidelines require:
          </p>
          <ul className="list-disc pl-6 text-white/70 mb-6 space-y-2">
            <li><strong>Fidelity:</strong> Transliterations must strictly follow standard IAST (International Alphabet of Sanskrit Transliteration) schemas for English Roman outputs.</li>
            <li><strong>Clarity:</strong> Commentary must clearly distinguish between the original text translation and contemporary contextual explanation.</li>
            <li><strong>Sectarian Neutrality:</strong> Where different lineages (Sampradayas) hold varying interpretations of a verse, we present all prominent viewpoints objectively, giving equal respect to each tradition.</li>
          </ul>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Manuscript Preservation Focus</h2>
          <p className="text-white/70 leading-relaxed mb-6">
            In cases where medieval Braj Bhasha poetry exists in multiple dialect variations, we prioritize the reading documented in the oldest surviving pothis (handwritten paper books). We maintain a digital log of textual differences as footnotes to assist scholars and students conducting linguistic research.
          </p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Error Reporting & Corrections</h2>
          <p className="text-white/70 leading-relaxed mb-8">
            Despite our best efforts, typographical mistakes can occur during data ingestion. We encourage our readers, scholars, and devotees to report any errors. Our editorial team reviews reports within 48 hours and updates the production database instantly upon verification.
          </p>
        </section>

        <InternalLinks exclude={['/editorial-policy']} count={4} />
      </article>
      <SEOFooter />
    </div>
  );
};

export default EditorialPolicyPage;
