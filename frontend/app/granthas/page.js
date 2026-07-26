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
    hinglishName: b.hinglishName || b.name || '',
    cleanName: b.cleanName || b.name || '',
    slug: b.slug || '',
    author: b.author || '',
    count: b.count || (b.verseIds ? b.verseIds.length : 0),
    verses: [],
    verseIds: b.verseIds ? b.verseIds.slice(0, 10) : []
  }));

  return (
    <Layout>
      <BooksListPage initialBooks={lightweightBooks} />
    </Layout>
  );
}
export const revalidate = false;
