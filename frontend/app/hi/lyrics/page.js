import React from 'react';
import ContentListPage from '../../../src/views/ContentListPage';
import Layout from '../../../src/components/Layout';
import { getAllVersesLightweight } from '../../../src/lib/contentData';

export const metadata = {
  title: 'पुस्तकालय — सन्त वाणी, श्लोक, और स्तोत्र संग्रह | वृंदोपनिषद्',
  description: 'पवित्र संस्कृत श्लोक, स्तोत्र, और वृन्दावन के रसिक सन्तों की वाणी का संग्रह। अर्थ और व्याख्या सहित पढ़ें।',
  alternates: {
    canonical: 'https://path.vrindopnishad.in/hi/lyrics',
    languages: {
      'en': 'https://path.vrindopnishad.in/lyrics',
      'hi': 'https://path.vrindopnishad.in/hi/lyrics',
    }
  },
};

export default function HindiContentListRoute() {
  const verses = getAllVersesLightweight();
  const initialVerses = verses.slice(0, 50);
  const categories = ['shloka', 'strotra', 'poem'];

  return (
    <Layout>
      <ContentListPage
        initialContent={initialVerses}
        initialCategories={categories}
      />
    </Layout>
  );
}
export const revalidate = 604800;
