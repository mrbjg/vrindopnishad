import React from 'react';
import HomePage from '../src/views/HomePage';
import Layout from '../src/components/Layout';
import { getAllVerses, getAllSaints, getAllGranthas, getAllRagas } from '../src/lib/contentData';

export const metadata = {
  title: 'Vrindopnishad Paath — वृंदोपनिषद् पाठ | Sacred Digital Sanctuary',
  description: 'Vrindopnishad Paath (वृंदोपनिषद् पाठ) — Read and listen to authentic sacred Sanskrit shlokas, devotional strotras, spiritual poetry & Vedic wisdom from Vrindavan saints.',
  alternates: {
    canonical: 'https://path.vrindopnishad.in',
  },
};

export default function HomeRoute() {
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
    "url": "https://path.vrindopnishad.in",
    "potentialAction": {
      "@type": "SearchAction",
      "target": "https://path.vrindopnishad.in/content?q={search_term_string}",
      "query-input": "required name=search_term_string"
    }
  };

  const orgSchema = {
    "@context": "https://schema.org",
    "@type": "Organization",
    "name": "Vrindopnishad",
    "url": "https://path.vrindopnishad.in",
    "logo": "https://path.vrindopnishad.in/official-logo-dark.svg",
    "sameAs": [
      "https://facebook.com/vrindopnishad",
      "https://instagram.com/vrindopnishad",
      "https://twitter.com/vrindopnishad"
    ]
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
