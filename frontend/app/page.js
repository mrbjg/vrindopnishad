import React from 'react';
import HomePage from '../src/views/HomePage';
import Layout from '../src/components/Layout';
import { getAllVerses, getAllSaints, getAllGranthas, getAllRagas, ensureDataLoaded } from '../src/lib/contentData';

export const metadata = {
  title: 'वृंदोपनिषद् पाठ - Braj Rasik Vani, Shlokas & Daily Chanting Sanctuary',
  description: 'Explore authentic Vedic Shlokas, Devotional Strotras, and Braj Rasik Vani with complete Hindi translations. Track your daily Chanting Malas and connect with Vrindavan wisdom.',
  alternates: {
    canonical: 'https://path.vrindopnishad.in',
  },
};

export default async function HomeRoute() {
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
