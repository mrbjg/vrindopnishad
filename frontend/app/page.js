import React from 'react';
import HomePage from '../src/views/HomePage';
import Layout from '../src/components/Layout';
import { getAllVerses, getAllSaints, getAllGranthas, getAllRagas, ensureDataLoaded } from '../src/lib/contentData';

export const metadata = {
  title: 'वृंदोपनिषद् पाठ - Braj Rasik Vani, Shlokas & Daily Chanting Sanctuary',
  description: 'Explore authentic Vedic Shlokas, Devotional Strotras, and Braj Rasik Vani with complete Hindi translations. Track your daily Chanting Malas and connect with Vrindavan wisdom.',
  alternates: {
    canonical: 'https://path.vrindopnishad.in',
  },
};

export default async function HomeRoute() {
  await ensureDataLoaded();
  const verses = getAllVerses();
  const saints = getAllSaints();
  const books = getAllGranthas();
  const ragas = getAllRagas();

  // Create lightweight versions of latest verses (only needs 6 items)
  const latestVerses = verses.slice(0, 6).map(v => ({
    id: v.id,
    slug: v.slug,
    category: v.category || 'poem',
    audio_url: v.audio_url || '',
    cleanTitle: v.cleanTitle || v.title || '',
    hindi_text: v.hindi_text ? v.hindi_text.substring(0, 150) + (v.hindi_text.length > 150 ? '...' : '') : '',
    english_translation: v.english_translation ? v.english_translation.substring(0, 150) + (v.english_translation.length > 150 ? '...' : '') : '',
    description: v.description ? v.description.substring(0, 150) + (v.description.length > 150 ? '...' : '') : '',
    isLightweight: true
  }));

  // Select Aaj Ka Pad
  const today = new Date();
  const hash = (today.getFullYear() * 37) + (today.getMonth() * 19) + today.getDate();
  const rawAajKaPad = verses[hash % verses.length];
  const aajKaPad = rawAajKaPad ? {
    id: rawAajKaPad.id,
    slug: rawAajKaPad.slug,
    category: rawAajKaPad.category || 'poem',
    audio_url: rawAajKaPad.audio_url || '',
    cleanTitle: rawAajKaPad.cleanTitle || rawAajKaPad.title || '',
    hindi_text: rawAajKaPad.hindi_text || '',
    sanskrit_text: rawAajKaPad.sanskrit_text || '',
    english_translation: rawAajKaPad.english_translation || '',
    description: rawAajKaPad.description || '',
    author: rawAajKaPad.author || ''
  } : null;

  // Compute category stats
  const categoryStats = { shloka: 0, strotra: 0, poem: 0, raga: ragas.length };
  verses.forEach(item => {
    const cat = item.category?.toLowerCase();
    if (categoryStats[cat] !== undefined) {
      categoryStats[cat]++;
    }
  });

  const websiteSchema = {
    "@context": "https://schema.org",
    "@type": "WebSite",
    "name": "Vrindopnishad",
    "url": "https://path.vrindopnishad.in",
    "potentialAction": {
      "@type": "SearchAction",
      "target": "https://path.vrindopnishad.in/lyrics?q={search_term_string}",
      "query-input": "required name=search_term_string"
    }
  };

  const orgSchema = {
    "@context": "https://schema.org",
    "@type": "Organization",
    "name": "Vrindopnishad",
    "url": "https://path.vrindopnishad.in",
    "logo": "https://path.vrindopnishad.in/official-logo-dark.svg",
    "sameAs": [
      "https://facebook.com/vrindopnishad",
      "https://instagram.com/vrindopnishad",
      "https://twitter.com/vrindopnishad"
    ]
  };

  // Create lightweight stubs for initial SSR rendering to keep HTML payload <50KB
  const lightweightSaints = saints.slice(0, 12).map(s => {
    const totalVerses = typeof s.verses === 'number' ? s.verses
      : (Array.isArray(s.verses) ? s.verses.length
      : (typeof s.verseIds === 'number' ? s.verseIds
      : (Array.isArray(s.verseIds) ? s.verseIds.length : (s.verseCount || s.count || 0))));
    return {
      id: s.id,
      name: s.name || '',
      hindiName: s.hindiName || s.name || '',
      hinglishName: s.hinglishName || s.name || '',
      slug: s.slug || '',
      period: s.period || '',
      verseCount: totalVerses,
      count: totalVerses,
      verses: totalVerses,
      verseIds: totalVerses
    };
  });

  const lightweightBooks = books.slice(0, 12).map(b => ({
    id: b.id,
    name: b.name || '',
    hindiName: b.hindiName || b.name || '',
    slug: b.slug || '',
    count: b.count || 0
  }));

  const lightweightRagas = ragas.slice(0, 12).map(r => ({
    name: typeof r === 'string' ? r : (r.name || ''),
    slug: typeof r === 'string' ? r : (r.slug || '')
  }));

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(websiteSchema) }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(orgSchema) }}
      />
      <Layout>
        <HomePage
          initialLatestVerses={latestVerses}
          initialAajKaPad={aajKaPad}
          initialCategoryStats={categoryStats}
          initialSaints={lightweightSaints}
          initialBooks={lightweightBooks}
          initialRagas={lightweightRagas}
        />
      </Layout>
    </>
  );
}
export const revalidate = 604800;
