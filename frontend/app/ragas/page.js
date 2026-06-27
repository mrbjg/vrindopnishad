import React from 'react';
import RagasListPage from '../../src/views/RagasListPage';
import Layout from '../../src/components/Layout';
import { getAllRagas } from '../../src/lib/contentData';

import { generatePageMetadata } from '../../src/lib/metadata';

export const metadata = generatePageMetadata({
  title: 'Ragas & Devotional Songs | Vrindopnishad',
  description: 'Explore sacred songs and poetry categorized by classical Indian musical ragas.',
  path: '/ragas',
  keywords: ['Ragas', 'Classical Music', 'Braj Bhajans', 'Sangeet Devotion']
});

export default function RagasListRoute() {
  const ragas = getAllRagas();

  return (
    <Layout>
      <RagasListPage initialRagas={ragas} />
    </Layout>
  );
}
export const revalidate = 86400;
