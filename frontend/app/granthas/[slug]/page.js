import React from 'react';
import BookDetailPage from '../../../src/views/BookDetailPage';
import Layout from '../../../src/components/Layout';
import { getGranthaBySlug, getAllGranthas, getVerseBySlug, ensureDataLoaded } from '../../../src/lib/contentData';
import { notFound, permanentRedirect } from 'next/navigation';
import { Link } from '../../../src/lib/router-compat';

export const revalidate = false; // Serve statically with 0 ISR Writes on Vercel

import { supabase } from '../../../src/lib/supabase';

const slugify = (text) => {
  if (!text) return '';
  return text.toString().toLowerCase().trim().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '').replace(/--+/g, '-');
};

async function fetchGranthaFromSupabaseBySlug(slug) {
  try {
    const decodedSlug = decodeURIComponent(slug).toLowerCase();
    
    // 1. Try reading local book shard or backup file
    try {
      const shardPath = path.join(process.cwd(), 'public/data/books', `${decodedSlug}.json`);
      if (fs.existsSync(shardPath)) {
        const shardData = JSON.parse(fs.readFileSync(shardPath, 'utf8'));
        if (shardData) return shardData;
      }
    } catch (e) { }

    // 2. Query Supabase as last resort with safe exception handling
    const { data: verses, error } = await supabase
      .from('content')
      .select('*')
      .ilike('slug', `%${decodedSlug}%`);

    if (error || !verses || verses.length === 0) {
      return null;
    }

    const titleWords = decodedSlug.split('-').map(w => w.charAt(0).toUpperCase() + w.slice(1));
    const bookName = titleWords.join(' ');

    let authorName = 'Braj Rasik';
    const authorCounts = {};
    let maxCount = 0;
    
    verses.forEach(v => {
      const auth = v.author || '';
      if (auth) {
        authorCounts[auth] = (authorCounts[auth] || 0) + 1;
        if (authorCounts[auth] > maxCount) {
          maxCount = authorCounts[auth];
          authorName = auth;
        }
      }
    });

    authorName = authorName.replace(/जी की वाणी/g, '').replace(/जी/g, '').trim();

    const mappedVerses = verses.map(v => ({
      id: v.id,
      title: v.title,
      sanskrit_text: v.sanskrit_text || v.sanskritText || '',
      hindi_text: v.hindi_text || v.hindiText || '',
      english_text: v.english_text || v.englishText || '',
      english_translation: v.english_translation || v.englishTranslation || '',
      category: v.category || 'poem',
      description: v.description || '',
      content_text: v.content_text || v.contentText || '',
      tags: v.tags || [],
      status: (v.status || '').toLowerCase(),
      author: v.author || '',
      media_links: v.media_links || v.mediaLinks || [],
      audio_url: v.audio_url || v.audioUrl || '',
      image_urls: v.image_urls || v.imageUrls || [],
      video_urls: v.video_urls || v.videoUrls || [],
      slug: v.slug,
      created_at: v.created_at || v.createdAt,
      updated_at: v.updated_at || v.updatedAt
    }));

    return {
      name: bookName,
      slug: decodedSlug,
      author: authorName,
      authorSlug: slugify(authorName),
      verses: mappedVerses,
      imageUrl: null
    };
  } catch (err) {
    console.warn('Supabase fetch failed or quota exceeded:', err?.message || err);
    return null;
  }
}



export async function generateMetadata({ params }) {
  await ensureDataLoaded();
  const decodedSlug = decodeURIComponent(params.slug);
  let book = getGranthaBySlug(decodedSlug);
  if (!book) {
    book = await fetchGranthaFromSupabaseBySlug(decodedSlug);
  }
  if (!book) return {};

  const brand = "Vrindopnishad";
  const mainPart = `${book.name} Scripture`;
  let title = `${mainPart} | ${brand}`;
  if (title.length > 60) {
    title = mainPart.substring(0, 41) + `... | ${brand}`;
  }
  const description = `Read the sacred verses, chapters, and translation of the classic scripture ${book.name} written by ${book.author}. Complete verse list.`;

  return {
    title,
    description,
    alternates: {
      canonical: `https://path.vrindopnishad.in/granthas/${book.slug}`,
      languages: {
        'en': `https://path.vrindopnishad.in/granthas/${book.slug}`,
        'hi': `https://path.vrindopnishad.in/hi/granthas/${book.slug}`,
      }
    },
    openGraph: {
      title,
      description,
      url: `https://path.vrindopnishad.in/granthas/${book.slug}`,
      type: 'book',
    }
  };
}

export default async function BookRoute({ params }) {
  await ensureDataLoaded();
  const decodedSlug = decodeURIComponent(params.slug);
  let book = getGranthaBySlug(decodedSlug);
  if (!book) {
    book = await fetchGranthaFromSupabaseBySlug(decodedSlug);
  }
  if (!book) {
    const verse = getVerseBySlug(decodedSlug);
    if (verse) {
      permanentRedirect(`/lyrics/${verse.slug || decodedSlug}`);
    }
    notFound();
  }

  if (params.slug !== book.slug) {
    permanentRedirect(`/granthas/${book.slug}`);
  }

  const bookSchema = {
    "@context": "https://schema.org",
    "@type": "Book",
    "name": book.name,
    "author": {
      "@type": "Person",
      "name": book.author
    },
    "url": `https://path.vrindopnishad.in/granthas/${book.slug}`,
    "workExample": book.verses ? book.verses.slice(0, 10).map(v => ({
      "@type": "CreativeWork",
      "name": v.title,
      "text": v.sanskrit_text || v.hindi_text
    })) : []
  };

  const breadcrumbsSchema = {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    "itemListElement": [
      {
        "@type": "ListItem",
        "position": 1,
        "name": "Home",
        "item": "https://path.vrindopnishad.in"
      },
      {
        "@type": "ListItem",
        "position": 2,
        "name": "Granthas",
        "item": "https://path.vrindopnishad.in/granthas"
      },
      {
        "@type": "ListItem",
        "position": 3,
        "name": book.name,
        "item": `https://path.vrindopnishad.in/granthas/${book.slug}`
      }
    ]
  };

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(bookSchema) }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumbsSchema) }}
      />

      <div className="max-w-4xl mx-auto px-4 pt-4 mb-2 flex items-center gap-1.5 text-xs text-white/50 select-none">
        <Link href="/" className="hover:text-amber-400 transition-colors">Home</Link>
        <span>→</span>
        <Link href="/granthas" className="hover:text-amber-400 transition-colors">Granthas</Link>
        <span>→</span>
        <span className="text-white/80 font-medium truncate">{book.name}</span>
      </div>

      <Layout>
        <BookDetailPage key={book.slug || decodedSlug} initialBook={book} />
      </Layout>
    </>
  );
}

