import React from 'react';
import SaintsListPage from '../../src/views/SaintsListPage';
import Layout from '../../src/components/Layout';
import { getAllSaints } from '../../src/lib/contentData';

import { generatePageMetadata } from '../../src/lib/metadata';

export const metadata = generatePageMetadata({
  title: 'Rasik Saints of Vrindavan & Braj | Vrindopnishad',
  description: 'Explore the holy lives, lineages, histories, and collection of spiritual vanis of the great Rasik Saints of Vrindavan.',
  path: '/saints',
  keywords: ['Rasik Saints', 'Vrindavan Saints', 'Vaishnava Acharyas', 'Saint Biographies']
});

export default function SaintsListRoute() {
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
export const revalidate = false;
