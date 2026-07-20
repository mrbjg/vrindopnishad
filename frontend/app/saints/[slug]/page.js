import React from 'react';
import SaintDetailPage from '../../../src/views/SaintDetailPage';
import Layout from '../../../src/components/Layout';
import { getSaintBySlug, getAllSaints, ensureDataLoaded } from '../../../src/lib/contentData';
import { notFound, permanentRedirect } from 'next/navigation';
import { Link } from '../../../src/lib/router-compat';

export const dynamic = 'force-dynamic';

import { supabase } from '../../../src/lib/supabase';
import { getSaintMetadata } from '../../../src/utils/saintMetadata';

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
      biography: meta ? { text: meta.biographyEn } : { text: "Vaishnava saint of the Braj tradition." },
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

  const brand = "Vrindopnishad";
  const mainPart = `${saint.hinglishName} Biography`;
  let title = `${mainPart} | ${brand}`;
  if (title.length > 60) {
    title = mainPart.substring(0, 41) + `... | ${brand}`;
  }
  const description = `Read the biography, teachings, and complete verses (vani pad) of Shri ${saint.hinglishName}. Verified Vaishnava history and spiritual legacy.`;

  return {
    title,
    description,
    alternates: {
      canonical: `https://path.vrindopnishad.in/saints/${saint.slug}`,
      languages: {
        'en': `https://path.vrindopnishad.in/saints/${saint.slug}`,
        'hi': `https://path.vrindopnishad.in/hi/saints/${saint.slug}`,
      }
    },
    openGraph: {
      title,
      description,
      url: `https://path.vrindopnishad.in/saints/${saint.slug}`,
      type: 'profile',
    }
  };
}

export default async function SaintRoute({ params }) {
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
    permanentRedirect(`/saints/${saint.slug}`);
  }

  const profilePageSchema = {
    "@context": "https://schema.org",
    "@type": "ProfilePage",
    "mainEntity": {
      "@type": "Person",
      "name": saint.name,
      "alternateName": saint.hinglishName !== saint.name ? saint.hinglishName : undefined,
      "description": saint.biography || `Vaishnava saint of the Braj tradition.`,
      "url": `https://path.vrindopnishad.in/saints/${saint.slug}`,
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
        "name": "Home",
        "item": "https://path.vrindopnishad.in"
      },
      {
        "@type": "ListItem",
        "position": 2,
        "name": "Saints",
        "item": "https://path.vrindopnishad.in/saints"
      },
      {
        "@type": "ListItem",
        "position": 3,
        "name": saint.hinglishName,
        "item": `https://path.vrindopnishad.in/saints/${saint.slug}`
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
        <Link href="/" className="hover:text-amber-400 transition-colors">Home</Link>
        <span>→</span>
        <Link href="/saints" className="hover:text-amber-400 transition-colors">Saints</Link>
        <span>→</span>
        <span className="text-white/80 font-medium truncate">{saint.hinglishName}</span>
      </div>

      <Layout>
        <SaintDetailPage key={saint.slug || decodedSlug} initialSaint={saint} />
      </Layout>
    </>
  );
}

