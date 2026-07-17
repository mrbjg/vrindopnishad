import React from 'react';
import BookDetailPage from '../../../../src/views/BookDetailPage';
import Layout from '../../../../src/components/Layout';
import { getGranthaBySlug, getAllGranthas, ensureDataLoaded } from '../../../../src/lib/contentData';
import { notFound, permanentRedirect } from 'next/navigation';
import { Link } from '../../../../src/lib/router-compat';

export async function generateStaticParams() {
  await ensureDataLoaded();
  const books = getAllGranthas();
  return books.map(book => ({
    slug: encodeURIComponent(book.slug),
  }));
}

import { supabase } from '../../../../src/lib/supabase';

const slugify = (text) => {
  if (!text) return '';
  return text.toString().toLowerCase().trim().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '').replace(/--+/g, '-');
};

async function fetchGranthaFromSupabaseBySlug(slug) {
  try {
    const decodedSlug = decodeURIComponent(slug).toLowerCase();
    
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
    console.error('Failed to fetch grantha from Supabase:', err);
    return null;
  }
}

export const dynamicParams = true;

export async function generateMetadata({ params }) {
  await ensureDataLoaded();
  const decodedSlug = decodeURIComponent(params.slug);
  let book = getGranthaBySlug(decodedSlug);
  if (!book) {
    book = await fetchGranthaFromSupabaseBySlug(decodedSlug);
  }
  if (!book) return {};

  const brand = "वृंदोपनिषद्";
  const mainPart = `ग्रन्थ ${book.name}`;
  let title = `${mainPart} | ${brand}`;
  if (title.length > 60) {
    title = mainPart.substring(0, 43) + `... | ${brand}`;
  }
  const description = `रसिक संत ${book.author} द्वारा रचित ${book.name} के समस्त श्लोक, दोहे एवं पद हिंदी अनुवाद और व्याख्या के साथ पढ़ें।`;

  return {
    title,
    description,
    alternates: {
      canonical: `https://path.vrindopnishad.in/hi/granthas/${book.slug}`,
      languages: {
        'en': `https://path.vrindopnishad.in/granthas/${book.slug}`,
        'hi': `https://path.vrindopnishad.in/hi/granthas/${book.slug}`,
      }
    },
    openGraph: {
      title,
      description,
      url: `https://path.vrindopnishad.in/hi/granthas/${book.slug}`,
      type: 'book',
    }
  };
}

export default async function HindiBookRoute({ params }) {
  await ensureDataLoaded();
  const decodedSlug = decodeURIComponent(params.slug);
  let book = getGranthaBySlug(decodedSlug);
  if (!book) {
    book = await fetchGranthaFromSupabaseBySlug(decodedSlug);
  }
  if (!book) {
    notFound();
  }

  if (decodeURIComponent(params.slug) !== decodeURIComponent(book.slug)) {
    permanentRedirect(`/hi/granthas/${book.slug}`);
  }

  const bookSchema = {
    "@context": "https://schema.org",
    "@type": "Book",
    "name": book.name,
    "author": {
      "@type": "Person",
      "name": book.author
    },
    "url": `https://path.vrindopnishad.in/hi/granthas/${book.slug}`,
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
        "name": "मुख्यपृष्ठ",
        "item": "https://path.vrindopnishad.in/hi"
      },
      {
        "@type": "ListItem",
        "position": 2,
        "name": "ग्रन्थ",
        "item": "https://path.vrindopnishad.in/hi/granthas"
      },
      {
        "@type": "ListItem",
        "position": 3,
        "name": book.name,
        "item": `https://path.vrindopnishad.in/hi/granthas/${book.slug}`
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
        <Link href="/hi" className="hover:text-amber-400 transition-colors">मुख्यपृष्ठ</Link>
        <span>→</span>
        <Link href="/hi/granthas" className="hover:text-amber-400 transition-colors">ग्रन्थ</Link>
        <span>→</span>
        <span className="text-white/80 font-medium truncate">{book.name}</span>
      </div>

      <Layout>
        <BookDetailPage key={book.slug || decodedSlug} initialBook={book} />
      </Layout>
    </>
  );
}
export const revalidate = 604800;
