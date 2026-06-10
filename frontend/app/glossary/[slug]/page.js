import React from 'react';
import GlossaryDetailPage from '../../../src/views/seo/GlossaryDetailPage';
import Layout from '../../../src/components/Layout';
import { getGlossaryTermBySlug, getGlossaryTerms } from '../../../src/lib/contentData';
import { notFound, permanentRedirect } from 'next/navigation';

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
      canonical: `https://path.vrindopnishad.in/glossary/${term.slug}`,
      languages: {
        'en': `https://path.vrindopnishad.in/glossary/${term.slug}`,
        'hi': `https://path.vrindopnishad.in/hi/glossary/${term.slug}`,
      }
    },
    openGraph: {
      title,
      description,
      url: `https://path.vrindopnishad.in/glossary/${term.slug}`,
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

  if (params.slug !== term.slug) {
    permanentRedirect(`/glossary/${term.slug}`);
  }

  const definedTermSchema = {
    "@context": "https://schema.org",
    "@type": "DefinedTerm",
    "name": term.term,
    "alternateName": term.devanagari,
    "description": term.definition,
    "inDefinedTermSet": {
      "@type": "DefinedTermSet",
      "name": "Vrindopnishad Glossary of Braj Rasik Theology",
      "url": "https://path.vrindopnishad.in/glossary"
    }
  };

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(definedTermSchema) }}
      />
      <Layout>
        <GlossaryDetailPage />
      </Layout>
    </>
  );
}
export const revalidate = 86400;
