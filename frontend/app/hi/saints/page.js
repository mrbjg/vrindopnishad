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
  const lightweightSaints = saints.map(s => ({
    id: s.id,
    name: s.name || '',
    hindiName: s.hindiName || s.name || '',
    slug: s.slug || '',
    period: s.period || ''
  }));

  return (
    <Layout>
      <SaintsListPage initialSaints={lightweightSaints} />
    </Layout>
  );
}
export const revalidate = 604800;
