import React from 'react';
import KnowledgeBasePage from '../../src/views/KnowledgeBasePage';
import KnowledgeBaseLayout from '../../src/components/KnowledgeBaseLayout';
import Layout from '../../src/components/Layout';

import { generatePageMetadata } from '../../src/lib/metadata';

export const metadata = generatePageMetadata({
  title: 'Vedic Knowledge Base & Rasik Wiki | Vrindopnishad',
  description: 'A unified portal exploring Braj Bhakti, philosophy, saint biographies and devotee guides.',
  path: '/knowledge-base',
  keywords: ['Knowledge Base', 'Rasik Wiki', 'Braj Bhakti', 'Devotional Guide']
});

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
