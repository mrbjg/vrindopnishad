import React from 'react';
import GlossaryDetailPage from '../../../../src/views/seo/GlossaryDetailPage';
import Layout from '../../../../src/components/Layout';
import { getGlossaryTermBySlug, getGlossaryTerms } from '../../../../src/lib/contentData';
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

  const title = `${term.term} (${term.devanagari}) का अर्थ, परिभाषा और आध्यात्मिक संदर्भ | Vrindopnishad`;
  const description = `${term.term} (${term.devanagari}) क्या है? जानिए इसका संस्कृत अर्थ, परिभाषा, वैष्णव संप्रदाय में इसका महत्व और रसिक संतों के विचार।`;

  return {
    title,
    description,
    alternates: {
      canonical: `https://path.vrindopnishad.in/hi/glossary/${params.slug}`,
    },
    openGraph: {
      title,
      description,
      url: `https://path.vrindopnishad.in/hi/glossary/${params.slug}`,
      type: 'article',
    }
  };
}

export default function HindiGlossaryRoute({ params }) {
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
