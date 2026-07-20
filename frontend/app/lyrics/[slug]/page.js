import React from 'react';
import { notFound, permanentRedirect } from 'next/navigation';
import Layout from '../../../src/components/Layout';
import ContentDetailPage from '../../../src/views/ContentDetailPage';
import { Link } from '../../../src/lib/router-compat';
import { 
  getVerseBySlug, 
  getAllVerses, 
  getAllSaints, 
  getAllGranthas, 
  getAllRagas, 
  ensureDataLoaded 
} from '../../../src/lib/contentData';
import { generatePageMetadata } from '../../../src/lib/metadata';
import { generateMusicCompositionSchema, generateBreadcrumbSchema } from '../../../src/lib/schemas';
import JsonLd from '../../../src/components/seo/JsonLd';
import Breadcrumbs from '../../../src/components/seo/Breadcrumbs';
import ShareButtons from '../../../src/components/seo/ShareButtons';
import FAQ from '../../../src/components/seo/FAQ';
import RelatedContent, { RelatedItem } from '../../../src/components/seo/RelatedContent';
import ReadingTime from '../../../src/components/seo/ReadingTime';
import LastUpdated from '../../../src/components/seo/LastUpdated';
import AuthorCard from '../../../src/components/seo/AuthorCard';
export const dynamic = 'force-dynamic';

import { supabase } from '../../../src/lib/supabase';

async function fetchVerseFromSupabaseBySlug(slug) {
  try {
    const { data, error } = await supabase
      .from('content')
      .select('*')
      .or(`slug.eq.${slug},id.eq.${slug}`)
      .maybeSingle();

    if (error || !data) return null;
    return {
      id: data.id,
      title: data.title,
      sanskrit_text: data.sanskrit_text || data.sanskritText || '',
      hindi_text: data.hindi_text || data.hindiText || '',
      english_text: data.english_text || data.englishText || '',
      english_translation: data.english_translation || data.englishTranslation || '',
      category: data.category || 'poem',
      description: data.description || '',
      content_text: data.content_text || data.contentText || '',
      tags: data.tags || [],
      status: (data.status || '').toLowerCase(),
      author: data.author || '',
      media_links: data.media_links || data.mediaLinks || [],
      audio_url: data.audio_url || data.audioUrl || '',
      image_urls: data.image_urls || data.imageUrls || [],
      video_urls: data.video_urls || data.videoUrls || [],
      slug: data.slug,
      created_at: data.created_at || data.createdAt,
      updated_at: data.updated_at || data.updatedAt
    };
  } catch (err) {
    console.error('Failed to fetch verse from Supabase:', err);
    return null;
  }
}


export async function generateMetadata({ params }) {
  await ensureDataLoaded();
  const decodedSlug = decodeURIComponent(params.slug);
  let verse = getVerseBySlug(decodedSlug);
  if (!verse) {
    verse = await fetchVerseFromSupabaseBySlug(decodedSlug);
  }
  if (!verse) return {};

  const cleanAuthor = verse.author ? verse.author.replace(/जी की वाणी/g, '').replace(/जी/g, '').trim() : 'Braj Rasik';

  return generatePageMetadata({
    title: `${verse.cleanTitle || verse.title} — Lyrics & Translation | ${cleanAuthor} | Vrindopnishad`,
    description: verse.description || `Read original text, Hinglish transliteration, and complete Hindi translation of ${verse.title} by ${cleanAuthor}.`,
    path: `/lyrics/${verse.slug}`,
    keywords: [verse.cleanTitle || verse.title, 'Lyrics', 'Bhajan Translation', cleanAuthor, 'Braj Bhasha Poetry'],
    type: 'music.song'
  });
}

export default async function LyricsDetailPage({ params }) {
  await ensureDataLoaded();
  const decodedSlug = decodeURIComponent(params.slug);
  let verse = getVerseBySlug(decodedSlug);
  if (!verse) {
    verse = await fetchVerseFromSupabaseBySlug(decodedSlug);
  }
  if (!verse) {
    notFound();
  }

  // Canonical redirection if slug mismatch
  if (params.slug !== verse.slug) {
    permanentRedirect(`/lyrics/${verse.slug}`);
  }

  const base = 'https://path.vrindopnishad.in';
  const pageUrl = `${base}/lyrics/${verse.slug}`;

  // Find related entities
  const saints = getAllSaints();
  const books = getAllGranthas();
  const ragas = getAllRagas();

  const currentAuthor = verse.author;
  let matchedSaint = null;
  if (currentAuthor) {
    const cleanAuthorKey = currentAuthor.replace(/जी की वाणी/g, '').replace(/जी/g, '').replace(/महाप्रभु/g, '').trim();
    matchedSaint = saints.find(s => {
      const sName = s.name || s.title || '';
      return sName.includes(cleanAuthorKey) || cleanAuthorKey.includes(sName);
    });
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

  // Build breadcrumbs
  const breadcrumbItems = [
    { name: 'Home', path: '/' },
    { name: 'Library', path: '/lyrics' }
  ];
  if (matchedBook) {
    breadcrumbItems.push({ name: matchedBook.name, path: `/granthas/${matchedBook.slug}` });
  }
  breadcrumbItems.push({ name: verse.cleanTitle || verse.title, path: `/lyrics/${verse.slug}` });

  // Schema structured data
  const compositionSchema = generateMusicCompositionSchema({
    title: verse.cleanTitle || verse.title,
    slug: verse.slug,
    hindi_text: verse.hindi_text,
    sanskrit_text: verse.sanskrit_text,
    english_translation: verse.english_translation,
    author: verse.author,
    raga: ragaName
  });

  // Dynamic FAQs
  const faqs = [
    {
      question: `Who is the composer/saint of "${verse.cleanTitle || verse.title}"?`,
      answer: `This pad was composed by the great saint ${verse.author || 'Team VrindaVaani'}.`
    }
  ];
  if (ragaName) {
    faqs.push({
      question: `In which musical raga is "${verse.cleanTitle || verse.title}" set?`,
      answer: `This song is set to classical Indian Raga ${ragaName}.`
    });
  }
  if (matchedBook) {
    faqs.push({
      question: `Which scripture or book contains this verse?`,
      answer: `It belongs to the grantha "${matchedBook.name}" written by ${matchedBook.author}.`
    });
  }

  // Cross-entity linking items
  const relatedItems = [];
  if (matchedSaint) {
    relatedItems.push({ name: matchedSaint.name, slug: matchedSaint.slug, type: 'saint' });
  }
  if (matchedBook) {
    relatedItems.push({ name: matchedBook.name, slug: matchedBook.slug, type: 'grantha' });
  }
  if (matchedRaga) {
    relatedItems.push({ name: matchedRaga.name, slug: matchedRaga.slug, type: 'raga' });
  }

  const allVerses = getAllVerses();
  const categoryVerses = allVerses.filter(item =>
    item.category === verse.category &&
    item.id?.toString() !== verse.id?.toString() &&
    item.category?.toLowerCase() !== 'saint'
  ).slice(0, 3);

  return (
    <>
      <JsonLd data={compositionSchema} />
      <Breadcrumbs items={breadcrumbItems} />
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
