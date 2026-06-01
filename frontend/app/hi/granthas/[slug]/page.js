import React from 'react';
import BookDetailPage from '../../../../src/views/BookDetailPage';
import Layout from '../../../../src/components/Layout';
import { getGranthaBySlug, getAllGranthas } from '../../../../src/lib/contentData';
import { notFound } from 'next/navigation';
import Link from 'next/link';

export async function generateStaticParams() {
  const books = getAllGranthas();
  return books.map(b => ({
    slug: encodeURIComponent(b.slug),
  }));
}

export async function generateMetadata({ params }) {
  const decodedSlug = decodeURIComponent(params.slug);
  const book = getGranthaBySlug(decodedSlug);
  if (!book) return {};

  const title = `ग्रन्थ ${book.name} — अर्थ, श्लोक, अनुवाद एवं विवेचन | Vrindopnishad`;
  const description = `रसिक संत ${book.author} द्वारा रचित ${book.name} के समस्त श्लोक, दोहे एवं पद हिंदी अनुवाद और व्याख्या के साथ पढ़ें।`;

  return {
    title,
    description,
    alternates: {
      canonical: `https://path.vrindopnishad.in/hi/granthas/${params.slug}`,
    },
    openGraph: {
      title,
      description,
      url: `https://path.vrindopnishad.in/hi/granthas/${params.slug}`,
      type: 'book',
    }
  };
}

export default function HindiBookRoute({ params }) {
  const decodedSlug = decodeURIComponent(params.slug);
  const book = getGranthaBySlug(decodedSlug);
  if (!book) {
    notFound();
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
        <BookDetailPage initialBook={book} />
      </Layout>
    </>
  );
}
export const revalidate = 86400;
