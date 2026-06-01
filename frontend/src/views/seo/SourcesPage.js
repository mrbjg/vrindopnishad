'use client';

import React from 'react';
import { Helmet } from 'react-helmet-async';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';

const SourcesPage = () => {
  const pageUrl = `${SITE_URL}/sources`;
  const title = 'Sources & Bibliography — Authentic Vaishnava Literature';
  const description = 'Explore the source bibliography of Vrindopnishad. Learn about the medieval manuscripts, printed editions, and citation methodology for our content.';

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
        <script type="application/ld+json">{JSON.stringify(generateBreadcrumbSchema([{ name: 'Home', path: '/' }, { name: 'Sources', path: '/sources' }]))}</script>
      </Helmet>

      <article className="py-12">
        <header className="mb-12">
          <div className="badge border-rose-400/30 text-rose-400/80 bg-rose-400/5 mb-4">Bibliography</div>
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-white leading-tight">Sources & Citation Bibliography</h1>
          <p className="text-lg text-white/60 leading-relaxed">The source materials, published editions, and citation methodology utilized to compile the Vrindopnishad library.</p>
        </header>

        <section className="prose-content">
          <h2 className="text-2xl font-bold mb-4 text-white/90">Primary Source Granthas</h2>
          <p className="text-white/70 leading-relaxed mb-6">
            Our digital library gathers verses from the canonical scriptures of Vaishnava and Vedic traditions. The core corpus includes:
          </p>
          <ul className="list-disc pl-6 text-white/70 mb-6 space-y-2">
            <li><strong>Siddhanta Pada & Kelimal:</strong> Sourced from the authorized prints of the Swami Haridas lineage, comparing editions from निधिवन (Nidhivan) and Baba Premlal Ji.</li>
            <li><strong>Hit Chaurasi Pada & Sphut Pada:</strong> Sourced from the critical editions of Radhavallabh Temple publications edited by Goswami Lalitacharan Ji.</li>
            <li><strong>Bayaalaas Leela:</strong> Sourced from the historical publications of Sri Dhruvdas Ji Maharaj compositions edited by Baba Krishnadas.</li>
            <li><strong>Bhagavad Gita & Upanishads:</strong> Verified against the critical texts published by Gita Press, Gorakhpur.</li>
          </ul>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Citation Methodology</h2>
          <p className="text-white/70 leading-relaxed mb-6">
            Each verse entry contains explicit metadata attributing it to its composer, original grantha, chapter (if applicable), and verse number. 
            For example, the citation format `Kelimal, Pad 12 (Swami Haridas)` indicates the Swami Haridas authorship and the twelfth poem of the Kelimal corpus. 
            This structured naming convention allows scholars to crosscheck our digital database against physical library prints seamlessly.
          </p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Institutional Acknowledgements</h2>
          <p className="text-white/70 leading-relaxed mb-8">
            We express our deepest gratitude to the librarians and archivists of the Vrindavan Research Institute (VRI), the Sarasvati Bhawan Library in Varanasi, and various traditional mathas (monasteries) in Braj. Their tireless efforts in preserving ancient manuscripts on palm-leaves and handmade papers make projects like Vrindopnishad possible.
          </p>
        </section>

        <InternalLinks exclude={['/sources']} count={4} />
      </article>
      <SEOFooter />
    </div>
  );
};

export default SourcesPage;
