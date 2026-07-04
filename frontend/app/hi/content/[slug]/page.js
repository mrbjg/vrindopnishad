import React from 'react';
import ContentDetailPage from '../../../../src/views/ContentDetailPage';
import Layout from '../../../../src/components/Layout';
import { getVerseBySlug, getAllVerses, getAllSaints, getAllGranthas, getAllRagas, ensureDataLoaded, getSaintBySlug, getGranthaBySlug } from '../../../../src/lib/contentData';
import { notFound, permanentRedirect } from 'next/navigation';
import { Link } from '../../../../src/lib/router-compat';

export async function generateStaticParams() {
  await ensureDataLoaded();
  const verses = getAllVerses().slice(0, 200);
  return verses.map(verse => ({
    slug: encodeURIComponent(verse.slug),
  }));
}

export const dynamicParams = true;

export async function generateMetadata({ params }) {
  await ensureDataLoaded();
  const decodedSlug = decodeURIComponent(params.slug);
  const verse = getVerseBySlug(decodedSlug);
  if (!verse) return {};

  let parsedSaintName = "";
  let parsedGranthName = "";
  let padNumber = "";
  
  const titleVal = verse.title || "";
  const tParts = titleVal.split(/\s+-\s+/);
  if (tParts.length >= 2) {
    padNumber = tParts[0].trim();
    const relText = tParts[1].trim();
    const bracketMatch = relText.match(/\(([^)]+)\)$/);
    const bracketContent = bracketMatch ? bracketMatch[1].trim() : "";
    const cleanRelText = bracketMatch ? relText.replace(/\(([^)]+)\)$/, '').trim() : relText;
    const relSplit = cleanRelText.split(/\s*,\s*/);
    
    if (relSplit.length >= 2) {
      parsedSaintName = relSplit[0].trim();
      parsedGranthName = relSplit[1].trim();
    } else if (relSplit.length === 1) {
      const val = relSplit[0].trim();
      if (val.includes('वाणी') || val.includes('सागर') || val.includes('शतक') || val.includes('महिमामृत') || val.includes('दोहे') || val.includes('ग्रंथावली') || val.includes('पदावली') || val.includes('शत') || val.includes('केलिमाल') || val.includes('चौरासी')) {
        parsedGranthName = val;
      } else {
        parsedSaintName = val;
      }
    }
    if (!parsedGranthName && bracketContent) {
      parsedGranthName = bracketContent.replace(/\d+/g, '').replace(/[१२३४५६७८९०]+/g, '').trim();
    }
  } else {
    padNumber = titleVal;
  }

  if (!parsedSaintName) {
    parsedSaintName = verse.author && verse.author !== 'Braj Rasik Heritage' ? verse.author : '';
  }

  const cleanSaint = parsedSaintName ? parsedSaintName.replace(/जी की वाणी/g, '').replace(/जी/g, '').replace(/महाप्रभु/g, '').trim() : "वैष्णव संत";
  const cleanGranth = parsedGranthName ? parsedGranthName.trim() : "वृंदोपनिषद् ग्रन्थ";

  const title = `${cleanGranth} — ${padNumber} | ${cleanSaint} | वृंदोपनिषद्`;
  const description = `पवित्र वैष्णव संत ${cleanSaint} द्वारा रचित पद/श्लोक ${verse.title} (ग्रन्थ: ${cleanGranth})। मूल पाठ, हिंदी भावार्थ, अंग्रेजी अनुवाद और रोमन व्याख्या सहित निःशुल्क पढ़ें।`;

  return {
    title,
    description,
    alternates: {
      canonical: `https://path.vrindopnishad.in/hi/content/${verse.slug}`,
      languages: {
        'en': `https://path.vrindopnishad.in/content/${verse.slug}`,
        'hi': `https://path.vrindopnishad.in/hi/content/${verse.slug}`,
      }
    },
    openGraph: {
      title,
      description,
      url: `https://path.vrindopnishad.in/hi/content/${verse.slug}`,
      type: 'article',
      images: [
        {
          url: 'https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png',
          width: 800,
          height: 600,
          alt: cleanSaint,
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
    const saint = getSaintBySlug(decodedSlug);
    if (saint) {
      permanentRedirect(`/hi/saints/${saint.slug}`);
    }
    const book = getGranthaBySlug(decodedSlug);
    if (book) {
      permanentRedirect(`/hi/granthas/${book.slug}`);
    }
    notFound();
  }

  if (verse.category === 'poem' || verse.category === 'lyrics') {
    permanentRedirect(`/hi/lyrics/${verse.slug}`);
  }

  if (params.slug !== verse.slug) {
    permanentRedirect(`/hi/content/${verse.slug}`);
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
export const revalidate = 604800;
