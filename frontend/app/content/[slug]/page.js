import React from 'react';
import ContentDetailPage from '../../../src/views/ContentDetailPage';
import Layout from '../../../src/components/Layout';
import { getVerseBySlug, getAllVerses, getAllSaints, getAllGranthas, getAllRagas, ensureDataLoaded } from '../../../src/lib/contentData';
import { notFound, permanentRedirect } from 'next/navigation';
import { Link } from '../../../src/lib/router-compat';

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

  const cleanSaint = parsedSaintName ? parsedSaintName.replace(/जी की वाणी/g, '').replace(/जी/g, '').replace(/महाप्रभु/g, '').trim() : "Vaishnava Saint";
  const cleanGranth = parsedGranthName ? parsedGranthName.trim() : "Vrindopnishad Granth";
  
  const formattedPad = padNumber
    .replace(/पद्/g, 'Pad')
    .replace(/पद/g, 'Pad')
    .replace(/श्लोक/g, 'Shloka')
    .replace(/१/g, '1').replace(/२/g, '2').replace(/३/g, '3').replace(/४/g, '4')
    .replace(/५/g, '5').replace(/६/g, '6').replace(/७/g, '7').replace(/८/g, '8')
    .replace(/९/g, '9').replace(/०/g, '0');

  const title = `${cleanGranth} — ${formattedPad} | ${cleanSaint} | Vrindopnishad`;
  const description = `Read and explore ${verse.title} by ${cleanSaint} from the grantha ${cleanGranth}. Completely free online access with meaning, translation, and commentary. Available in Hindi, Sanskrit, Braj Bhasha, and English transliteration.`;

  return {
    title,
    description,
    alternates: {
      canonical: `https://path.vrindopnishad.in/content/${verse.slug}`,
      languages: {
        'en': `https://path.vrindopnishad.in/content/${verse.slug}`,
        'hi': `https://path.vrindopnishad.in/hi/content/${verse.slug}`,
      }
    },
    openGraph: {
      title,
      description,
      url: `https://path.vrindopnishad.in/content/${verse.slug}`,
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

export default async function VerseRoute({ params }) {
  await ensureDataLoaded();
  const decodedSlug = decodeURIComponent(params.slug);
  const verse = getVerseBySlug(decodedSlug);
  if (!verse) {
    notFound();
  }

  if (params.slug !== verse.slug) {
    permanentRedirect(`/content/${verse.slug}`);
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
      "name": verse.author || "Braj Rasik Heritage"
    },
    "publisher": {
      "@type": "Organization",
      "name": "Vrindopnishad",
      "logo": {
        "@type": "ImageObject",
        "url": "https://path.vrindopnishad.in/official-logo-dark.svg"
      }
    }
  };

  const breadcrumbsElements = [
    { name: "Home", url: "https://path.vrindopnishad.in" }
  ];
  if (matchedBook) {
    breadcrumbsElements.push({ name: matchedBook.name, url: `https://path.vrindopnishad.in/granthas/${matchedBook.slug}` });
  } else {
    breadcrumbsElements.push({ name: "Library", url: "https://path.vrindopnishad.in/content" });
  }
  breadcrumbsElements.push({ name: verse.title, url: `https://path.vrindopnishad.in/content/${verse.slug}` });

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
        <Link href="/" className="hover:text-amber-400 transition-colors">Home</Link>
        <span>→</span>
        {matchedBook ? (
          <>
            <Link href={`/granthas/${matchedBook.slug}`} className="hover:text-amber-400 transition-colors">{matchedBook.name}</Link>
            <span>→</span>
          </>
        ) : (
          <>
            <Link href="/content" className="hover:text-amber-400 transition-colors">Library</Link>
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
