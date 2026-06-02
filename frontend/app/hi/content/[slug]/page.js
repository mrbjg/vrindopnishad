import React from 'react';
import ContentDetailPage from '../../../../src/views/ContentDetailPage';
import Layout from '../../../../src/components/Layout';
import { getVerseBySlug, getAllVerses, getAllSaints, getAllGranthas, getAllRagas, ensureDataLoaded } from '../../../../src/lib/contentData';
import { notFound } from 'next/navigation';
import Link from 'next/link';

export async function generateStaticParams() {
  // Return empty array to generate pages on-demand (ISR/SSR).
  // This reduces Vercel compilation time from 15+ minutes to under 1 minute.
  return [];
}

export async function generateMetadata({ params }) {
  await ensureDataLoaded();
  const decodedSlug = decodeURIComponent(params.slug);
  const verse = getVerseBySlug(decodedSlug);
  if (!verse) return {};

  const cleanTitle = verse.title || "";
  const brand = "वृंदोपनिषद्";
  let title = `${cleanTitle} | ${brand}`;
  if (title.length > 60) {
    title = cleanTitle.substring(0, 43) + `... | ${brand}`;
  }
  const textSummary = verse.hindi_text || verse.english_translation || verse.description || '';
  const description = textSummary.substring(0, 155) + (textSummary.length > 155 ? '...' : '');

  return {
    title,
    description,
    alternates: {
      canonical: `https://path.vrindopnishad.in/hi/content/${params.slug}`,
    },
    openGraph: {
      title,
      description,
      url: `https://path.vrindopnishad.in/hi/content/${params.slug}`,
      type: 'article',
      images: [
        {
          url: 'https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png',
          width: 800,
          height: 600,
          alt: cleanTitle,
        }
      ]
    },
    twitter: {
      card: 'summary_large_image',
      title,
      description,
      images: ['https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png'],
    }
  };
}

export default async function HindiVerseRoute({ params }) {
  await ensureDataLoaded();
  const decodedSlug = decodeURIComponent(params.slug);
  const verse = getVerseBySlug(decodedSlug);
  if (!verse) {
    notFound();
  }

  const allVerses = getAllVerses();
  const saints = getAllSaints();
  const books = getAllGranthas();
  const ragas = getAllRagas();

  const currentAuthor = verse.author;
  let matchedSaint = null;
  if (currentAuthor) {
    const cleanAuthorKey = currentAuthor.replace(/जी की वाणी/g, '').replace(/जी/g, '').replace(/महाप्रभु/g, '').trim();
    matchedSaint = saints.find(s => s.name.includes(cleanAuthorKey) || cleanAuthorKey.includes(s.name));
  }

  let bookName = null;
  const cleanTitle = verse.title || "";
  const titleParts = cleanTitle.split(/\s+-\s+/);
  if (titleParts.length >= 2) {
    const relationText = titleParts[1].trim();
    const verseMatch = relationText.match(/\(([^)]+)\)$/);
    const textWithoutVerse = verseMatch ? relationText.replace(/\(([^)]+)\)$/, '').trim() : relationText;
    const relParts = textWithoutVerse.split(/\s*,\s*/);
    if (relParts.length >= 2) {
      bookName = relParts[1].trim();
    } else if (relParts.length === 1) {
      const val = relParts[0].trim();
      if (val.includes('वाणी') || val.includes('सागर') || val.includes('शतक') || val.includes('महिमामृत') || val.includes('दोहे') || val.includes('केलिमाल') || val.includes('चौरासी')) {
        bookName = val;
      }
    }
  }
  const matchedBook = bookName ? books.find(b => b.name === bookName) : null;

  let ragaName = null;
  const ragaRegex = /(राग\s+[^\s,;()-]+)/;
  const matchTitle = cleanTitle.match(ragaRegex);
  const matchSanskrit = verse.sanskrit_text?.match(ragaRegex);
  const matchHindi = verse.hindi_text?.match(ragaRegex);
  if (matchTitle) ragaName = matchTitle[1];
  else if (matchSanskrit) ragaName = matchSanskrit[1];
  else if (matchHindi) ragaName = matchHindi[1];
  if (ragaName) ragaName = ragaName.split(/[,]/)[0].trim();

  const matchedRaga = ragaName ? ragas.find(r => r.name === ragaName) : null;

  const categoryVerses = allVerses.filter(item => 
    item.category === verse.category && 
    item.id?.toString() !== verse.id?.toString() &&
    item.category?.toLowerCase() !== 'saint'
  ).slice(0, 3);

  
  const articleSchema = {
    "@context": "https://schema.org",
    "@type": "Article",
    "headline": verse.title,
    "description": verse.description || verse.hindi_text || verse.english_translation,
    "articleBody": `${verse.sanskrit_text || ''}\n${verse.hindi_text || ''}\n${verse.english_translation || ''}`,
    "inLanguage": "hi",
    "author": {
      "@type": "Person",
      "name": verse.author || "ब्रज रसिक धरोहर"
    },
    "publisher": {
      "@type": "Organization",
      "name": "वृंदोपनिषद्",
      "logo": {
        "@type": "ImageObject",
        "url": "https://path.vrindopnishad.in/official-logo-dark.svg"
      }
    }
  };

  const breadcrumbsElements = [
    { name: "मुख्यपृष्ठ", url: "https://path.vrindopnishad.in/hi" }
  ];
  if (matchedBook) {
    breadcrumbsElements.push({ name: matchedBook.name, url: `https://path.vrindopnishad.in/hi/granthas/${matchedBook.slug}` });
  } else {
    breadcrumbsElements.push({ name: "पुस्तकालय", url: "https://path.vrindopnishad.in/hi/content" });
  }
  breadcrumbsElements.push({ name: verse.title, url: `https://path.vrindopnishad.in/hi/content/${verse.slug}` });

  const breadcrumbsSchema = {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    "itemListElement": breadcrumbsElements.map((el, idx) => ({
      "@type": "ListItem",
      "position": idx + 1,
      "name": el.name,
      "item": el.url
    }))
  };

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(articleSchema) }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumbsSchema) }}
      />
      
      
      <div className="max-w-6xl mx-auto px-4 pt-4 mb-2 flex items-center gap-1.5 text-xs text-white/50 select-none">
        <Link href="/hi" className="hover:text-amber-400 transition-colors">मुख्यपृष्ठ</Link>
        <span>→</span>
        {matchedBook ? (
          <>
            <Link href={`/hi/granthas/${matchedBook.slug}`} className="hover:text-amber-400 transition-colors">{matchedBook.name}</Link>
            <span>→</span>
          </>
        ) : (
          <>
            <Link href="/hi/content" className="hover:text-amber-400 transition-colors">पुस्तकालय</Link>
            <span>→</span>
          </>
        )}
        <span className="text-white/80 font-medium truncate max-w-[200px]">{verse.title}</span>
      </div>

      <Layout>
        <ContentDetailPage
          key={verse.id || decodedSlug}
          initialContent={verse}
          initialRelatedSaint={matchedSaint}
          initialRelatedBook={matchedBook}
          initialRelatedRaga={matchedRaga}
          initialRelatedVerses={categoryVerses}
        />
      </Layout>
    </>
  );
}
export const revalidate = 86400;
