import React from 'react';
import RagasListPage from '../../../src/views/RagasListPage';
import Layout from '../../../src/components/Layout';
import { getAllRagas } from '../../../src/lib/contentData';

export const metadata = {
  title: 'रागों के अनुसार वाणी पद | Vrindopnishad',
  description: 'शास्त्रीय रागों में निबंध ब्रज रस के पदों का वर्गीकरण। भारतीय शास्त्रीय रागों में आबद्ध दिव्य भजन एवं वाणी।',
  alternates: {
    canonical: 'https://path.vrindopnishad.in/hi/ragas',
  },
};

export default function HindiRagasListRoute() {
  const ragas = getAllRagas();

  return (
    <Layout>
      <RagasListPage initialRagas={ragas} />
    </Layout>
  );
}
export const revalidate = 604800;
