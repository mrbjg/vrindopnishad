import React from 'react';
import BooksListPage from '../../../src/views/BooksListPage';
import Layout from '../../../src/components/Layout';
import { getAllGranthas } from '../../../src/lib/contentData';

export const metadata = {
  title: 'प्रमुख ग्रन्थ एवं रस शास्त्र | Vrindopnishad',
  description: 'ब्रज रस के प्रमुख ग्रन्थों, वाणियों और शास्त्रों का संग्रह। रसिक संतों द्वारा रचित दिव्य ग्रन्थ और वाणी संग्रह।',
  alternates: {
    canonical: 'https://path.vrindopnishad.in/hi/granthas',
  },
};

export default function HindiGranthasListRoute() {
  const books = getAllGranthas();

  return (
    <Layout>
      <BooksListPage initialBooks={books} />
    </Layout>
  );
}
export const revalidate = 604800;
