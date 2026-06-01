import React from 'react';
import SaintsListPage from '../../src/views/SaintsListPage';
import Layout from '../../src/components/Layout';
import { getAllSaints } from '../../src/lib/contentData';

export const metadata = {
  title: 'Rasik Saints of Vrindavan & Braj | Vrindopnishad',
  description: 'Explore the holy lives, lineages, histories, and collection of spiritual vanis of the great Rasik Saints of Vrindavan.',
  alternates: {
    canonical: 'https://path.vrindopnishad.in/saints',
  },
};

export default function SaintsListRoute() {
  const saints = getAllSaints();

  return (
    <Layout>
      <SaintsListPage initialSaints={saints} />
    </Layout>
  );
}
export const revalidate = 86400;
