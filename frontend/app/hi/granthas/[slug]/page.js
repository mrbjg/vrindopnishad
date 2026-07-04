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

export const dynamicParams = true;

export async function generateMetadata({ params }) {
  await ensureDataLoaded();
  const decodedSlug = decodeURIComponent(params.slug);
  const book = getGranthaBySlug(decodedSlug);
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
  const book = getGranthaBySlug(decodedSlug);
  if (!book) {
    notFound();
  }

  if (params.slug !== book.slug) {
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
