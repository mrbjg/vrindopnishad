'use client';

import React from 'react';
import { Helmet } from 'react-helmet-async';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';

const ReferencesPage = () => {
  const pageUrl = `${SITE_URL}/references`;
  const title = 'References & Citations — Scriptural & Historical Bibliography';
  const description = 'Access the comprehensive references, research bibliography, and academic citations catalog compiled for the Vrindopnishad digital knowledge base.';

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
        <script type="application/ld+json">{JSON.stringify(generateBreadcrumbSchema([{ name: 'Home', path: '/' }, { name: 'References', path: '/references' }]))}</script>
      </Helmet>

      <article className="py-12">
        <header className="mb-12">
          <div className="badge border-amber-400/30 text-amber-400/80 bg-amber-400/5 mb-4">Citations</div>
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-white leading-tight">References &amp; Bibliography</h1>
          <p className="text-lg text-white/60 leading-relaxed">The research catalogs, academic publications, and historical manuscripts that form the foundation of Vrindopnishad.</p>
        </header>

        <section className="prose-content">
          <h2 className="text-2xl font-bold mb-4 text-white/90">Manuscript Catalogs &amp; Archives</h2>
          <p className="text-white/70 leading-relaxed mb-6">
            Our historical research is cross-referenced with catalogs from key Braj manuscript repositories:
          </p>
          <ul className="list-disc pl-6 text-white/70 mb-6 space-y-2">
            <li><strong>Vrindavan Research Institute (VRI) Catalogs:</strong> Volumes I-IV (Listing and description of Braj Bhasha and Sanskrit Vaishnava manuscripts).</li>
            <li><strong>Radhavallabh Temple Manuscripts:</strong> Critical collections cataloged by Baba Radha Sarveshvar Sharan Ji.</li>
            <li><strong>Pushtimargiya Granthalaya (Kankroli):</strong> Archives detailing the lineage of Shri Vitthalnath Ji and Shri Harirae Ji Vartas.</li>
          </ul>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Scholarly Publications &amp; Critical Editions</h2>
          <p className="text-white/70 leading-relaxed mb-6">
            The textual variants of the verses (Padas) are studied and compared across these prominent publications:
          </p>
          <ul className="list-disc pl-6 text-white/70 mb-6 space-y-2">
            <li><strong>Hit Chaurasi:</strong> Edited with commentary by Lalitacharan Goswami, Shri Radhavallabh Temple Trust, Vrindavan.</li>
            <li><strong>Swami Haridas aur Unka Sampraday:</strong> Historical and textual analysis by Dr. Sharan Bihari Goswami.</li>
            <li><strong>Chaurasi Vaishnavan Ki Varta:</strong> Critical edition with comments by Dwarkadas Parikh, Aligarh.</li>
            <li><strong>Braj Bhasha Sahitya ka Itihas:</strong> Devendra Pratap Singh, detailing the chronological history of Vaishnava poets in Mathura.</li>
          </ul>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Verification &amp; Authenticity</h2>
          <p className="text-white/70 leading-relaxed mb-8">
            Each verse, saint profile, and glossary definition published on Vrindopnishad goes through a thorough review process. By matching digital transcriptions against these verified editions and microfilm archives, we protect the theological accuracy and integrity of the sacred literature.
          </p>
        </section>

        <InternalLinks exclude={['/references']} count={4} />
      </article>
      <SEOFooter />
    </div>
  );
};

export default ReferencesPage;
