import React from 'react';
import SaintDetailPage from '../../../../src/views/SaintDetailPage';
import Layout from '../../../../src/components/Layout';
import { getSaintBySlug, getAllSaints, ensureDataLoaded } from '../../../../src/lib/contentData';
import { notFound, permanentRedirect } from 'next/navigation';
import { Link } from '../../../../src/lib/router-compat';

export const dynamic = 'force-dynamic';

import { supabase } from '../../../../src/lib/supabase';
import { getSaintMetadata } from '../../../../src/utils/saintMetadata';

import fs from 'fs';
import path from 'path';

function getCoreKeywords(slug) {
  return slug
    .toLowerCase()
    .replace(/^biography-of-/, '')
    .replace(/-rasik-saint-of-vrindavan$/, '')
    .replace(/-rasik-saint-of-braj$/, '')
    .replace(/\b(snt|sant|saint|shri|sri|shree|ji|dev|maharaj|dasa|das)\b/g, '')
    .split(/[-_\s]+/)
    .filter(w => w.length >= 3);
}

async function fetchSaintFromSupabaseBySlug(slug) {
  try {
    const decodedSlug = decodeURIComponent(slug).toLowerCase();
    const keywords = getCoreKeywords(decodedSlug);
    const primaryKeyword = keywords[0] || decodedSlug;

    // 1. Query Supabase by slug, author, or title
    let { data: verses, error } = await supabase
      .from('content')
      .select('*')
      .or(`slug.ilike.%${primaryKeyword}%,author.ilike.%${primaryKeyword}%,title.ilike.%${primaryKeyword}%`);

    // 2. If Supabase returns no results or fails, search local relations_backup.json & content_backup.json
    if (!verses || verses.length === 0) {
      try {
        const relPath = path.join(process.cwd(), 'public/data/relations_backup.json');
        if (fs.existsSync(relPath)) {
          const relData = JSON.parse(fs.readFileSync(relPath, 'utf8'));
          const sants = relData.sants || [];
          const matchedSant = sants.find(s => {
            const sSlug = (s.slug || s.name || '').toLowerCase();
            return keywords.some(kw => sSlug.includes(kw));
          });
          if (matchedSant) {
            return {
              name: matchedSant.name,
              hinglishName: matchedSant.name,
              slug: matchedSant.slug || decodedSlug,
              verses: matchedSant.verses || [],
              books: [],
              biography: { text: matchedSant.text || "Vaishnava saint of the Braj tradition." },
              imageUrl: null
            };
          }
        }
      } catch (e) { }

      try {
        const backupPath = path.join(process.cwd(), 'public/data/content_backup.json');
        if (fs.existsSync(backupPath)) {
          const backupItems = JSON.parse(fs.readFileSync(backupPath, 'utf8'));
          verses = backupItems.filter(v => {
            const title = (v.title || '').toLowerCase();
            const author = (v.author || '').toLowerCase();
            const vSlug = (v.slug || '').toLowerCase();
            return keywords.some(kw => title.includes(kw) || author.includes(kw) || vSlug.includes(kw));
          });
        }
      } catch (e) { }
    }

    if (!verses || verses.length === 0) {
      return null;
    }

    // Find the best author name in the results
    const authorCounts = {};
    let bestAuthor = '';
    let maxCount = 0;

    verses.forEach(v => {
      const auth = v.author || '';
      if (auth) {
        authorCounts[auth] = (authorCounts[auth] || 0) + 1;
        if (authorCounts[auth] > maxCount) {
          maxCount = authorCounts[auth];
          bestAuthor = auth;
        }
      }
    });

    if (!bestAuthor) {
      bestAuthor = primaryKeyword.charAt(0).toUpperCase() + primaryKeyword.slice(1);
      const titleMatch = verses.find(v => v.title && v.title.toLowerCase().includes(primaryKeyword));
      if (titleMatch) {
        const parts = titleMatch.title.split(/\s+-\s+/);
        if (parts.length >= 2) bestAuthor = parts[parts.length - 1].trim();
      }
    }

    const cleanName = bestAuthor.replace(/जी की वाणी/g, '').replace(/जी/g, '').trim();

    const mappedVerses = verses.map(v => ({
      id: v.id,
      title: v.title,
      sanskrit_text: v.sanskrit_text || v.sanskritText || v.content_text || '',
      hindi_text: v.hindi_text || v.hindiText || v.content_text || '',
      english_text: v.english_text || v.englishText || '',
      english_translation: v.english_translation || v.englishTranslation || '',
      category: v.category || 'poem',
      description: v.description || '',
      content_text: v.content_text || v.contentText || '',
      tags: v.tags || [],
      status: (v.status || '').toLowerCase(),
      author: v.author || bestAuthor,
      media_links: v.media_links || v.mediaLinks || [],
      audio_url: v.audio_url || v.audioUrl || '',
      image_urls: v.image_urls || v.imageUrls || [],
      video_urls: v.video_urls || v.videoUrls || [],
      slug: v.slug,
      created_at: v.created_at || v.createdAt,
      updated_at: v.updated_at || v.updatedAt
    }));

    const meta = getSaintMetadata(slug) || getSaintMetadata(primaryKeyword);
    const firstBioVerse = verses.find(v => (v.sanskrit_text || v.content_text || '').length > 100);

    return {
      name: cleanName || "संत श्री जगन्नाथ दास जी",
      hinglishName: cleanName || "Sant Shri Jagannath Das",
      slug: decodedSlug,
      verses: mappedVerses,
      books: Array.from(new Set(verses.map(v => v.category).filter(Boolean))),
      biography: meta ? { text: meta.biographyEn } : (firstBioVerse ? { text: firstBioVerse.sanskrit_text || firstBioVerse.content_text } : { text: "Vaishnava saint of the Braj tradition." }),
      imageUrl: null
    };
  } catch (err) {
    console.error('Failed to fetch saint from Supabase:', err);
    return null;
  }
}



export async function generateMetadata({ params }) {
  await ensureDataLoaded();
  const decodedSlug = decodeURIComponent(params.slug);
  let saint = getSaintBySlug(decodedSlug);
  if (!saint) {
    saint = await fetchSaintFromSupabaseBySlug(decodedSlug);
  }
  if (!saint) return {};

  const brand = "वृंदोपनिषद्";
  const mainPart = `संत ${saint.name} जीवनी`;
  let title = `${mainPart} | ${brand}`;
  if (title.length > 60) {
    title = mainPart.substring(0, 43) + `... | ${brand}`;
  }
  const description = `महान रसिक संत ${saint.name} का जीवन चरित्र, आध्यात्मिक दर्शन, रचित ग्रन्थ और वाणी संग्रह। हिन्दी और ब्रजभाषा में व्याख्या सहित पढ़ें।`;

  return {
    title,
    description,
    alternates: {
      canonical: `https://path.vrindopnishad.in/hi/saints/${saint.slug}`,
      languages: {
        'en': `https://path.vrindopnishad.in/saints/${saint.slug}`,
        'hi': `https://path.vrindopnishad.in/hi/saints/${saint.slug}`,
      }
    },
    openGraph: {
      title,
      description,
      url: `https://path.vrindopnishad.in/hi/saints/${saint.slug}`,
      type: 'profile',
    }
  };
}

export default async function HindiSaintRoute({ params }) {
  await ensureDataLoaded();
  const decodedSlug = decodeURIComponent(params.slug);
  let saint = getSaintBySlug(decodedSlug);
  if (!saint) {
    saint = await fetchSaintFromSupabaseBySlug(decodedSlug);
  }
  if (!saint) {
    notFound();
  }

  if (decodeURIComponent(params.slug) !== decodeURIComponent(saint.slug)) {
    permanentRedirect(`/hi/saints/${saint.slug}`);
  }

  const profilePageSchema = {
    "@context": "https://schema.org",
    "@type": "ProfilePage",
    "mainEntity": {
      "@type": "Person",
      "name": saint.name,
      "alternateName": saint.hinglishName !== saint.name ? saint.hinglishName : undefined,
      "description": saint.biography || `ब्रज परंपरा के वैष्णव संत।`,
      "url": `https://path.vrindopnishad.in/hi/saints/${saint.slug}`,
      "knowsAbout": ["Vaishnavism", "Bhakti Yoga", "Team VrindaVaani", "Vrindavan"]
    }
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
        "name": "संत",
        "item": "https://path.vrindopnishad.in/hi/saints"
      },
      {
        "@type": "ListItem",
        "position": 3,
        "name": saint.name,
        "item": `https://path.vrindopnishad.in/hi/saints/${saint.slug}`
      }
    ]
  };

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(profilePageSchema) }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumbsSchema) }}
      />

      <div className="max-w-4xl mx-auto px-4 pt-4 mb-2 flex items-center gap-1.5 text-xs text-white/50 select-none">
        <Link href="/hi" className="hover:text-amber-400 transition-colors">मुख्यपृष्ठ</Link>
        <span>→</span>
        <Link href="/hi/saints" className="hover:text-amber-400 transition-colors">संत</Link>
        <span>→</span>
        <span className="text-white/80 font-medium truncate">{saint.name}</span>
      </div>

      <Layout>
        <SaintDetailPage key={saint.slug || decodedSlug} initialSaint={saint} />
      </Layout>
    </>
  );
}

