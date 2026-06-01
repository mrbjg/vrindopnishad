import React from 'react';
import KnowledgeBasePage from '../../../src/views/KnowledgeBasePage';
import KnowledgeBaseLayout from '../../../src/components/KnowledgeBaseLayout';
import Layout from '../../../src/components/Layout';

export const metadata = {
  title: 'वैदिक ज्ञान कोष और रसिक विकी | Vrindopnishad',
  description: 'ब्रज रस के दार्शनिक सिद्धांतों, रसिक आचार्यों के इतिहास और शब्दकोश का संग्रह।',
  alternates: {
    canonical: 'https://path.vrindopnishad.in/hi/knowledge-base',
  },
};

export default function HindiKnowledgeBaseRoute() {
  return (
    <Layout>
      <KnowledgeBaseLayout>
        <KnowledgeBasePage />
      </KnowledgeBaseLayout>
    </Layout>
  );
}
export const revalidate = 86400;
