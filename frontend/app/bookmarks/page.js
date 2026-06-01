import React from 'react';
import BookmarksPage from '../../src/views/BookmarksPage';
import Layout from '../../src/components/Layout';

export const metadata = {
  title: 'My Bookmarks | Vrindopnishad',
  description: 'Your saved verses, hymns, shlokas, and sacred scriptures.',
  alternates: {
    canonical: 'https://path.vrindopnishad.in/bookmarks',
  }
};

export default function BookmarksRoute() {
  return (
    <Layout>
      <BookmarksPage />
    </Layout>
  );
}
