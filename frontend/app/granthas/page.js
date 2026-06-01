import React from 'react';
import BooksListPage from '../../src/views/BooksListPage';
import Layout from '../../src/components/Layout';
import { getAllGranthas } from '../../src/lib/contentData';

export const metadata = {
  title: 'Sacred Granthas & Books | Vrindopnishad',
  description: 'Read and browse the sacred books, granthas and vanis written by the saints of Vrindavan.',
  alternates: {
    canonical: 'https://path.vrindopnishad.in/granthas',
  },
};

export default function GranthasListRoute() {
  const books = getAllGranthas();

  return (
    <Layout>
      <BooksListPage initialBooks={books} />
    </Layout>
  );
}
export const revalidate = 86400;
