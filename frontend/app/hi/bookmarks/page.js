import React from 'react';
import BookmarksPage from '../../../src/views/BookmarksPage';
import Layout from '../../../src/components/Layout';

export const metadata = {
  title: 'मेरी पाठ सूची (बुकमार्क) | Vrindopnishad',
  description: 'आपके सहेजे गए श्लोक, स्तोत्र, और पवित्र ग्रन्थ।',
  alternates: {
    canonical: 'https://path.vrindopnishad.in/hi/bookmarks',
  }
};

export default function HindiBookmarksRoute() {
  return (
    <Layout>
      <BookmarksPage />
    </Layout>
  );
}
