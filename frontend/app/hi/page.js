import React from 'react';
import HomePage from '../../src/views/HomePage';
import Layout from '../../src/components/Layout';
import { getAllVerses, getAllSaints, getAllGranthas, getAllRagas, ensureDataLoaded } from '../../src/lib/contentData';

export const metadata = {
  title: 'वृंदोपनिषद् पाठ | श्री वृन्दावन धाम सन्त वाणी',
  description: 'वृंदोपनिषद् पाठ — वृन्दावन के रसिक सन्तों की वाणी, पवित्र संस्कृत श्लोक, स्तोत्र, और आध्यात्मिक ज्ञान को हिन्दी और संस्कृत में पढ़ें।',
  alternates: {
    canonical: 'https://path.vrindopnishad.in/hi',
  },
};

export default async function HindiHomeRoute() {
  await ensureDataLoaded();
  const verses = getAllVerses();
  const saints = getAllSaints();
  const books = getAllGranthas();
  const ragas = getAllRagas();

  const rawSaints = saints.map(s => s.rawItem).filter(Boolean);
  const initialAllItems = [...verses, ...rawSaints];

  const websiteSchema = {
    "@context": "https://schema.org",
    "@type": "WebSite",
    "name": "Vrindopnishad",
    "url": "https://path.vrindopnishad.in/hi",
    "potentialAction": {
      "@type": "SearchAction",
      "target": "https://path.vrindopnishad.in/hi/content?q={search_term_string}",
      "query-input": "required name=search_term_string"
    }
  };

  const orgSchema = {
    "@context": "https://schema.org",
    "@type": "Organization",
    "name": "Vrindopnishad",
    "url": "https://path.vrindopnishad.in/hi",
    "logo": "https://path.vrindopnishad.in/official-logo-dark.svg"
  };

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(websiteSchema) }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(orgSchema) }}
      />
      <Layout>
        <HomePage
          initialAllItems={initialAllItems}
          initialSaints={saints}
          initialBooks={books}
          initialRagas={ragas}
        />
      </Layout>
    </>
  );
}
export const revalidate = 86400;
