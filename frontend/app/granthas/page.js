import React from 'react';
import BooksListPage from '../../src/views/BooksListPage';
import Layout from '../../src/components/Layout';
import { getAllGranthas } from '../../src/lib/contentData';

import { generatePageMetadata } from '../../src/lib/metadata';

export const metadata = generatePageMetadata({
  title: 'Sacred Granthas & Books | Vrindopnishad',
  description: 'Read and browse the sacred books, granthas and vanis written by the saints of Vrindavan.',
  path: '/granthas',
  keywords: ['Granthas', 'Vaishnava Books', 'Sacred Literature', 'Braj Granths']
});

export default function GranthasListRoute() {
  const books = getAllGranthas();

  return (
    <Layout>
      <BooksListPage initialBooks={books} />
    </Layout>
  );
}
export const revalidate = 86400;
