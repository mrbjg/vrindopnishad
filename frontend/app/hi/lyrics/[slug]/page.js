import React from 'react';
import { notFound, permanentRedirect } from 'next/navigation';
import Layout from '../../../../src/components/Layout';
import ContentDetailPage from '../../../../src/views/ContentDetailPage';
import { Link } from '../../../../src/lib/router-compat';
import { 
  getVerseBySlug, 
  getAllVerses, 
  getAllSaints, 
  getAllGranthas, 
  getAllRagas, 
  ensureDataLoaded 
} from '../../../../src/lib/contentData';
import { generatePageMetadata } from '../../../../src/lib/metadata';
import { generateMusicCompositionSchema } from '../../../../src/lib/schemas';
import JsonLd from '../../../../src/components/seo/JsonLd';
import Breadcrumbs from '../../../../src/components/seo/Breadcrumbs';
import ShareButtons from '../../../../src/components/seo/ShareButtons';
import FAQ from '../../../../src/components/seo/FAQ';
import RelatedContent, { RelatedItem } from '../../../../src/components/seo/RelatedContent';
import ReadingTime from '../../../../src/components/seo/ReadingTime';
import LastUpdated from '../../../../src/components/seo/LastUpdated';
import AuthorCard from '../../../../src/components/seo/AuthorCard';
export const revalidate = 604800; // 7 days edge CDN cache to eliminate serverless CPU duration spikes

import { supabase } from '../../../../src/lib/supabase';

import fs from 'fs';
import path from 'path';

function getUntruncatedServerText(slug, id, sanskrit, hindi, title) {
  const isTruncated = (str) => {
    if (!str) return true;
    const trimmed = str.trim();
    if (trimmed.length <= 120) return true;
    if (trimmed.length <= 350 && !/[॥।.\!\?\n\”\"']/.test(trimmed.slice(-3))) return true;
    return false;
  };

  let fullSanskrit = sanskrit || '';
  let fullHindi = hindi || '';

  // Fast path: if already untruncated, return immediately with 0 disk read
  if (!isTruncated(fullSanskrit) && !isTruncated(fullHindi) && fullSanskrit.length >= 300) {
    return { sanskrit: fullSanskrit, hindi: fullHindi };
  }

  // Try reading relations_backup.json from global memory or disk
  try {
    if (!global.serverRelationsCache) {
      const relPath = path.join(process.cwd(), 'public/data/relations_backup.json');
      if (fs.existsSync(relPath)) {
        global.serverRelationsCache = JSON.parse(fs.readFileSync(relPath, 'utf8'));
      }
    }

    if (serverRelationsCache) {
      const allRelItems = [
        ...(serverRelationsCache.sants || []),
        ...(serverRelationsCache.biographies || []),
        ...(serverRelationsCache.books || []),
        ...(serverRelationsCache.ragas || [])
      ];
      const targetSlug = (slug || '').replace(/^-+|-+$/g, '');
      const targetId = (id || '').toString();

      const foundRel = allRelItems.find(x =>
        (x.id && targetId && x.id.toString() === targetId) ||
        (x.slug && targetSlug && x.slug.replace(/^-+|-+$/g, '') === targetSlug) ||
        (x.originalTitle && title && x.originalTitle.trim() === title.trim())
      );

      if (foundRel && foundRel.text && foundRel.text.length > fullSanskrit.length) {
        fullSanskrit = foundRel.text;
        if (!fullHindi || fullHindi.length < foundRel.text.length) fullHindi = foundRel.text;
      }
    }
  } catch (e) { }

  // Try reading content_backup.json from disk if text is still short (< 300 chars) or truncated
  if (isTruncated(fullSanskrit) || isTruncated(fullHindi) || fullSanskrit.length < 300) {
    try {
      if (!serverBackupCache) {
        const backupPath = path.join(process.cwd(), 'public/data/content_backup.json');
        if (fs.existsSync(backupPath)) {
          serverBackupCache = JSON.parse(fs.readFileSync(backupPath, 'utf8'));
        }
      }

      if (serverBackupCache && serverBackupCache.length > 0) {
        const targetSlug = (slug || '').replace(/^-+|-+$/g, '');
        const targetId = (id || '').toString();

        const foundBackup = serverBackupCache.find(x =>
          (x.id && targetId && x.id.toString() === targetId) ||
          (x.slug && targetSlug && x.slug.replace(/^-+|-+$/g, '') === targetSlug) ||
          (x.title && title && x.title.trim() === title.trim())
        );

        if (foundBackup) {
          const sText = foundBackup.sanskrit_text || foundBackup.content_text || '';
          const hText = foundBackup.hindi_text || '';

          if (sText && sText.length > fullSanskrit.length) {
            fullSanskrit = sText;
          }
          if (hText && hText.length > fullHindi.length) {
            fullHindi = hText;
          }
        }
      }
    } catch (e) { }
  }

  return { sanskrit: fullSanskrit, hindi: fullHindi };
}

async function fetchVerseFromSupabaseBySlug(slug) {
  try {
    const { data, error } = await supabase
      .from('content')
      .select('*')
      .or(`slug.eq.${slug},id.eq.${slug}`)
      .maybeSingle();

    if (error || !data) return null;

    let sanskrit = data.sanskrit_text || data.sanskritText || '';
    let hindi = data.hindi_text || data.hindiText || '';

    const local = getVerseBySlug(slug) || getVerseBySlug(data.slug || '');
    if (local) {
      if (local.sanskrit_text && local.sanskrit_text.length > sanskrit.length) {
        sanskrit = local.sanskrit_text;
      }
      if (local.hindi_text && local.hindi_text.length > hindi.length) {
        hindi = local.hindi_text;
      }
    }

    if (data.content_text && data.content_text.length > (sanskrit.length + hindi.length + 30)) {
      const parts = data.content_text.split('\n\n');
      if (parts.length >= 2) {
        sanskrit = parts[0];
        hindi = parts.slice(1).join('\n\n');
      } else {
        sanskrit = data.content_text;
      }
    }

    const full = getUntruncatedServerText(slug, data.id, sanskrit, hindi, data.title);
    sanskrit = full.sanskrit;
    hindi = full.hindi;

    return {
      id: data.id,
      title: data.title,
      sanskrit_text: sanskrit,
      hindi_text: hindi,
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

  const cleanAuthor = verse.author ? verse.author.replace(/जी की वाणी/g, '').replace(/जी/g, '').trim() : 'वैष्णव संत';

  return generatePageMetadata({
    title: `${verse.cleanTitle || verse.title} — मूल पाठ और व्याख्या | ${cleanAuthor} | वृंदोपनिषद्`,
    description: verse.description || `संत ${cleanAuthor} द्वारा रचित पद/भजन ${verse.title}। मूल देवनागरी पाठ, हिंदी अनुवाद, व्याख्या और श्रवण ऑडियो।`,
    path: `/hi/lyrics/${verse.slug}`,
    keywords: [verse.cleanTitle || verse.title, 'भजन', 'पद अनुवाद', cleanAuthor, 'ब्रजभाषा काव्य'],
    type: 'music.song'
  });
}

export default async function HindiLyricsDetailPage({ params }) {
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
  if (decodeURIComponent(params.slug) !== decodeURIComponent(verse.slug)) {
    permanentRedirect(`/hi/lyrics/${verse.slug}`);
  }

  const base = 'https://path.vrindopnishad.in';
  const pageUrl = `${base}/hi/lyrics/${verse.slug}`;

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
    { name: 'मुख्यपृष्ठ', path: '/hi' },
    { name: 'पुस्तकालय', path: '/hi/lyrics' }
  ];
  if (matchedBook) {
    breadcrumbItems.push({ name: matchedBook.name, path: `/hi/granthas/${matchedBook.slug}` });
  }
  breadcrumbItems.push({ name: verse.cleanTitle || verse.title, path: `/hi/lyrics/${verse.slug}` });

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
      question: `"${verse.cleanTitle || verse.title}" के रचयिता संत कौन हैं?`,
      answer: `इस पद की रचना महान रसिक संत ${verse.author || 'ब्रज रसिक धरोहर'} द्वारा की गई है।`
    }
  ];
  if (ragaName) {
    faqs.push({
      question: `"${verse.cleanTitle || verse.title}" किस शास्त्रीय राग में निबद्ध है?`,
      answer: `यह पद शास्त्रीय राग ${ragaName} में निबद्ध है।`
    });
  }
  if (matchedBook) {
    faqs.push({
      question: `यह पद किस ग्रन्थ से लिया गया है?`,
      answer: `यह पद ${matchedBook.author} द्वारा रचित ग्रन्थ "${matchedBook.name}" के अंतर्गत संकलित है।`
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
