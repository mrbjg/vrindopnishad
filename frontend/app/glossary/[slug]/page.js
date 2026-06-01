import React from 'react';
import GlossaryDetailPage from '../../../src/views/seo/GlossaryDetailPage';
import Layout from '../../../src/components/Layout';
import { getGlossaryTermBySlug, getGlossaryTerms } from '../../../src/lib/contentData';
import { notFound } from 'next/navigation';

export async function generateStaticParams() {
  const terms = getGlossaryTerms();
  return terms.map(t => ({
    slug: encodeURIComponent(t.slug),
  }));
}

export async function generateMetadata({ params }) {
  const decodedSlug = decodeURIComponent(params.slug);
  const term = getGlossaryTermBySlug(decodedSlug);
  if (!term) return {};

  const title = `${term.term} Meaning, Definition & Theological Context | Vrindopnishad`;
  const description = `Explore the definition, Sanskrit meaning, etymology, and deep theological context of ${term.term} (${term.devanagari}) in Vrindavan Rasik devotion.`;

  return {
    title,
    description,
    alternates: {
      canonical: `https://path.vrindopnishad.in/glossary/${params.slug}`,
    },
    openGraph: {
      title,
      description,
      url: `https://path.vrindopnishad.in/glossary/${params.slug}`,
      type: 'article',
    }
  };
}

export default function GlossaryRoute({ params }) {
  const decodedSlug = decodeURIComponent(params.slug);
  const term = getGlossaryTermBySlug(decodedSlug);
  if (!term) {
    notFound();
  }

  return (
    <Layout>
      <GlossaryDetailPage />
    </Layout>
  );
}
export const revalidate = 86400;
