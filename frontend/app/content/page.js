import React from 'react';
import ContentListPage from '../../src/views/ContentListPage';
import Layout from '../../src/components/Layout';
import { getAllVersesLightweight } from '../../src/lib/contentData';

export const metadata = {
  title: 'Spiritual Library — All Sacred Verses, Shlokas & Strotras | Vrindopnishad',
  description: 'Explore the digital collection of authentic Sanskrit shlokas, devotional strotras, and spiritual poetry. Search by name, theme or keyword.',
  alternates: {
    canonical: 'https://path.vrindopnishad.in/content',
    languages: {
      'en': 'https://path.vrindopnishad.in/content',
      'hi': 'https://path.vrindopnishad.in/hi/content',
    }
  },
};

export default function ContentListRoute() {
  const verses = getAllVersesLightweight();
  const categories = ['shloka', 'strotra', 'poem'];

  return (
    <Layout>
      <ContentListPage
        initialContent={verses}
        initialCategories={categories}
      />
    </Layout>
  );
}
export const revalidate = 86400;
