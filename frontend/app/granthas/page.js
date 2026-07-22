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
  const lightweightBooks = books.map(b => ({
    id: b.id,
    name: b.name || '',
    hindiName: b.hindiName || b.name || '',
    slug: b.slug || '',
    count: b.count || 0
  }));

  return (
    <Layout>
      <BooksListPage initialBooks={lightweightBooks} />
    </Layout>
  );
}
export const revalidate = 604800;
