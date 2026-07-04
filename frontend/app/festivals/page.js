import React from 'react';
import Layout from '../../src/components/Layout';
import { FESTIVALS_DATA } from '../../src/data/festivalsData';
import { generatePageMetadata } from '../../src/lib/metadata';
import { generateBreadcrumbSchema, generateWebPageSchema } from '../../src/lib/schemas';
import JsonLd from '../../src/components/seo/JsonLd';
import Breadcrumbs from '../../src/components/seo/Breadcrumbs';

export const metadata = generatePageMetadata({
  title: 'Sacred Festivals of Vrindavan & Braj | Vrindopnishad',
  description: 'Explore the history, meaning, and traditional celebration details of the holy festivals of Vrindavan, including Jhulan Yatra, Radhashtami, and Sharad Purnima.',
  path: '/festivals',
  keywords: ['Vrindavan Festivals', 'Braj Utsav', 'Jhulan Yatra', 'Radhashtami', 'Vaishnava Festivals']
});

export default function FestivalsPage() {
  const base = 'https://path.vrindopnishad.in';
  const pageUrl = `${base}/festivals`;

  const breadcrumbs = [
    { name: 'Home', path: '/' },
    { name: 'Festivals', path: '/festivals' }
  ];

  const webpageSchema = generateWebPageSchema(
    'Sacred Festivals of Vrindavan & Braj | Vrindopnishad',
    'Explore the history, meaning, and traditional celebration details of the holy festivals of Vrindavan.',
    pageUrl
  );

  const festivals = Object.values(FESTIVALS_DATA);

  return (
    <>
      <JsonLd data={webpageSchema} />
      <Breadcrumbs items={breadcrumbs} />
      <Layout>
        <div className="max-w-4xl mx-auto px-4 py-8">
          <header className="mb-12 text-center md:text-left">
            <div className="inline-block border border-amber-500/30 text-amber-400 bg-amber-500/5 px-3 py-1 rounded-full text-xs font-medium tracking-wide mb-4">
              Braj Rasik Heritage
            </div>
            <h1 className="text-3xl md:text-5xl font-bold font-serif text-white mb-4">
              Sacred Festivals of Vrindavan
            </h1>
            <p className="text-sm md:text-base text-white/60 leading-relaxed max-w-2xl">
              Immerse yourself in the eternal celebrations of the Divine Couple. Explore the scriptural history, theological meanings, and traditional temple rituals of Braj Dham.
            </p>
          </header>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-16">
            {festivals.map((fest) => (
              <article
                key={fest.slug}
                className="p-6 border border-white/5 rounded-2xl bg-white/[0.01] hover:border-amber-500/20 hover:bg-white/[0.02] transition-all duration-300 flex flex-col justify-between group"
              >
                <div>
                  <div className="flex justify-between items-start gap-2 mb-3">
                    <h2 className="text-lg font-bold font-serif text-white group-hover:text-amber-400 transition-colors">
                      {fest.name}
                    </h2>
                    <span className="text-[10px] font-medium px-2 py-0.5 rounded-full bg-amber-500/10 text-amber-400 select-none">
                      {fest.timeline.split(' ')[0]}
                    </span>
                  </div>
                  <p className="text-xs text-white/50 leading-relaxed mb-4">
                    {fest.description}
                  </p>
                </div>
                <a
                  href={`/festivals/${fest.slug}`}
                  className="text-xs font-semibold text-amber-500 hover:text-amber-400 flex items-center gap-1 group-hover:translate-x-0.5 transition-all w-fit mt-2"
                >
                  <span>Explore History &amp; Rituals</span>
                  <span>→</span>
                </a>
              </article>
            ))}
          </div>
        </div>
      </Layout>
    </>
  );
}
export const revalidate = 604800;
