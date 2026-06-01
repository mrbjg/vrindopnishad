import React from 'react';
import KnowledgeBasePage from '../../src/views/KnowledgeBasePage';
import KnowledgeBaseLayout from '../../src/components/KnowledgeBaseLayout';
import Layout from '../../src/components/Layout';

export const metadata = {
  title: 'Vedic Knowledge Base & Rasik Wiki | Vrindopnishad',
  description: 'A unified portal exploring Braj Bhakti, philosophy, saint biographies and devotee guides.',
  alternates: {
    canonical: 'https://path.vrindopnishad.in/knowledge-base',
  },
};

export default function KnowledgeBaseRoute() {
  return (
    <Layout>
      <KnowledgeBaseLayout>
        <KnowledgeBasePage />
      </KnowledgeBaseLayout>
    </Layout>
  );
}
export const revalidate = 86400;
