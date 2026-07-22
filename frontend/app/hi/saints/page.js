import React from 'react';
import SaintsListPage from '../../../src/views/SaintsListPage';
import Layout from '../../../src/components/Layout';
import { getAllSaints } from '../../../src/lib/contentData';

export const metadata = {
  title: 'ब्रज के रसिक सन्त और परम्परा विवरण | वृंदोपनिषद्',
  description: 'वृंदावन के रसिक संतों और वैष्णव आचार्यों की जीवनी, इतिहास और दिव्य वाणी संग्रह। भक्ति रस के संतों के उपदेश हिंदी में पढ़ें।',
  alternates: {
    canonical: 'https://path.vrindopnishad.in/hi/saints',
  },
};

export default function HindiSaintsListRoute() {
  const saints = getAllSaints();
  const lightweightSaints = saints.map(s => {
    const totalVerses = typeof s.verses === 'number' ? s.verses
      : (Array.isArray(s.verses) ? s.verses.length
      : (typeof s.verseIds === 'number' ? s.verseIds
      : (Array.isArray(s.verseIds) ? s.verseIds.length : (s.verseCount || s.count || 0))));
    return {
      id: s.id,
      name: s.name || '',
      hinglishName: s.hinglishName || s.name || '',
      cleanName: s.cleanName || s.name || '',
      slug: s.slug || '',
      lineage: s.lineage || '',
      lineageEn: s.lineageEn || '',
      timeline: s.timeline || '',
      timelineEn: s.timelineEn || '',
      biography: s.biography || null,
      books: s.books ? s.books.slice(0, 5) : [],
      verseCount: totalVerses,
      count: totalVerses,
      verses: totalVerses,
      verseIds: s.verseIds ? s.verseIds.slice(0, 10) : []
    };
  });

  return (
    <Layout>
      <SaintsListPage initialSaints={lightweightSaints} />
    </Layout>
  );
}
export const revalidate = 604800;
