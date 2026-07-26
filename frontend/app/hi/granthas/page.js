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
