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

  return (
    <Layout>
      <SaintsListPage initialSaints={saints} />
    </Layout>
  );
}
export const revalidate = 604800;
