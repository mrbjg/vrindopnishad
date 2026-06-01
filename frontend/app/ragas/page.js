import React from 'react';
import RagasListPage from '../../src/views/RagasListPage';
import Layout from '../../src/components/Layout';
import { getAllRagas } from '../../src/lib/contentData';

export const metadata = {
  title: 'Ragas & Devotional Songs | Vrindopnishad',
  description: 'Explore sacred songs and poetry categorized by classical Indian musical ragas.',
  alternates: {
    canonical: 'https://path.vrindopnishad.in/ragas',
  },
};

export default function RagasListRoute() {
  const ragas = getAllRagas();

  return (
    <Layout>
      <RagasListPage initialRagas={ragas} />
    </Layout>
  );
}
export const revalidate = 86400;
