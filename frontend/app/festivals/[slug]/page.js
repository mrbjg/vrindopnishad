import React from 'react';
import { notFound } from 'next/navigation';
import Layout from '../../../src/components/Layout';
import { FESTIVALS_DATA } from '../../../src/data/festivalsData';
import { generatePageMetadata } from '../../../src/lib/metadata';
import { generateBreadcrumbSchema, generateArticleSchema } from '../../../src/lib/schemas';
import JsonLd from '../../../src/components/seo/JsonLd';
import Breadcrumbs from '../../../src/components/seo/Breadcrumbs';
import FAQ from '../../../src/components/seo/FAQ';
import ShareButtons from '../../../src/components/seo/ShareButtons';
import RelatedContent, { RelatedItem } from '../../../src/components/seo/RelatedContent';

export async function generateStaticParams() {
  return Object.keys(FESTIVALS_DATA).map(slug => ({ slug }));
}

export const dynamicParams = true;

export async function generateMetadata({ params }) {
  const fest = FESTIVALS_DATA[params.slug];
  if (!fest) return {};

  return generatePageMetadata({
    title: `${fest.name} — History, Meaning & Celebration | Vrindopnishad`,
    description: fest.description,
    path: `/festivals/${fest.slug}`,
    keywords: [fest.name, 'Braj Festivals', 'Vrindavan History', 'Temple Rituals']
  });
}

export default function FestivalDetailPage({ params }) {
  const fest = FESTIVALS_DATA[params.slug];
  if (!fest) {
    notFound();
  }

  const base = 'https://path.vrindopnishad.in';
  const pageUrl = `${base}/festivals/${fest.slug}`;

  const breadcrumbs = [
    { name: 'Home', path: '/' },
    { name: 'Festivals', path: '/festivals' },
    { name: fest.name, path: `/festivals/${fest.slug}` }
  ];

  const articleSchema = generateArticleSchema(
    `${fest.name} — History, Meaning & Celebration | Vrindopnishad`,
    fest.description,
    pageUrl,
    '2026-01-10',
    '2026-06-27',
    'Braj Rasik Heritage Board'
  );

  const relatedItems = Object.values(FESTIVALS_DATA)
    .filter(f => f.slug !== fest.slug)
    .map(f => ({
      name: f.name,
      slug: f.slug,
      type: 'festival'
    }));

  return (
    <>
      <JsonLd data={articleSchema} />
      <Breadcrumbs items={breadcrumbs} />
      <Layout>
        <div className="max-w-3xl mx-auto px-4 py-8">
          <article className="prose-content">
            <header className="mb-8 border-b border-white/5 pb-8">
              <div className="flex flex-wrap items-center gap-2 mb-3">
                <span className="text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-full bg-amber-500/10 text-amber-400 select-none">
                  Monsoon Festival
                </span>
                <span className="text-xs text-white/40">
                  Timeline: {fest.timeline}
                </span>
              </div>
              <h1 className="text-3xl md:text-5xl font-bold font-serif text-white mb-4">
                {fest.name}
              </h1>
              <p className="text-sm md:text-base text-white/70 leading-relaxed font-serif italic border-l-2 border-amber-500/50 pl-4 my-4">
                {fest.description}
              </p>
            </header>

            <section className="space-y-6 text-white/75 text-xs md:text-sm leading-relaxed">
              <div>
                <h2 className="text-lg md:text-xl font-bold font-serif text-white/90 mb-3">
                  Historical Roots &amp; Origin
                </h2>
                <p>{fest.history}</p>
              </div>

              <div>
                <h2 className="text-lg md:text-xl font-bold font-serif text-white/90 mb-3">
                  Spiritual &amp; Theological Meaning
                </h2>
                <p>{fest.meaning}</p>
              </div>

              <div>
                <h2 className="text-lg md:text-xl font-bold font-serif text-white/90 mb-3">
                  Traditional Celebration &amp; Rituals
                </h2>
                <p>{fest.celebration}</p>
              </div>
            </section>

            <ShareButtons title={`Read about ${fest.name} on Vrindopnishad`} />

            <FAQ questions={fest.faqs} title={`Frequently Asked Questions about ${fest.name}`} />

            <RelatedContent items={relatedItems} title="Other Sacred Festivals" />
          </article>
        </div>
      </Layout>
    </>
  );
}
export const revalidate = 604800;
