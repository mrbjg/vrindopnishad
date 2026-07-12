import React from 'react';
import SaintDetailPage from '../../../../src/views/SaintDetailPage';
import Layout from '../../../../src/components/Layout';
import { getSaintBySlug, getAllSaints, ensureDataLoaded } from '../../../../src/lib/contentData';
import { notFound, permanentRedirect } from 'next/navigation';
import { Link } from '../../../../src/lib/router-compat';

export async function generateStaticParams() {
  await ensureDataLoaded();
  const saints = getAllSaints().slice(0, 50);
  return saints.map(saint => ({
    slug: encodeURIComponent(saint.slug),
  }));
}

import { supabase } from '../../../../src/lib/supabase';
import { getSaintMetadata } from '../../../../src/utils/saintMetadata';

async function fetchSaintFromSupabaseBySlug(slug) {
  try {
    const decodedSlug = decodeURIComponent(slug).toLowerCase();
    
    // Find any verse by this author/slug in Supabase
    const { data: verses, error } = await supabase
      .from('content')
      .select('*')
      .ilike('slug', `%${decodedSlug}%`);

    if (error || !verses || verses.length === 0) {
      return null;
    }

    // Find the most common author name in the results
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
      bestAuthor = decodedSlug.split('-').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ');
    }

    const cleanName = bestAuthor.replace(/जी की वाणी/g, '').replace(/जी/g, '').trim();

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

    const meta = getSaintMetadata(slug);

    return {
      name: cleanName,
      hinglishName: cleanName,
      slug: decodedSlug,
      verses: mappedVerses,
      books: Array.from(new Set(verses.map(v => v.category).filter(Boolean))),
      biography: meta ? { text: meta.biographyHi || meta.biographyEn } : { text: "ब्रज परंपरा के वैष्णव संत।" },
      imageUrl: null
    };
  } catch (err) {
    console.error('Failed to fetch saint from Supabase:', err);
    return null;
  }
}

export const dynamicParams = true;

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

  if (params.slug !== saint.slug) {
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
export const revalidate = 604800;
