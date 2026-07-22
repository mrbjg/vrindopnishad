import React from 'react';
import RagaDetailPage from '../../../../src/views/RagaDetailPage';
import Layout from '../../../../src/components/Layout';
import { getRagaBySlug, getAllRagas, ensureDataLoaded } from '../../../../src/lib/contentData';
import { notFound, permanentRedirect } from 'next/navigation';
import { Link } from '../../../../src/lib/router-compat';

export const revalidate = 604800; // 7 days Edge CDN cache

import { supabase } from '../../../../src/lib/supabase';

async function fetchRagaFromSupabaseBySlug(slug) {
  try {
    const decodedSlug = decodeURIComponent(slug).toLowerCase();
    const cleanRagaName = decodedSlug.replace(/^raag-/, '').replace(/^rag-/, '');
    
    // Find verses mentioning this raga in title or text
    const { data: verses, error } = await supabase
      .from('content')
      .select('*')
      .or(`title.ilike.%${cleanRagaName}%,hindi_text.ilike.%${cleanRagaName}%,sanskrit_text.ilike.%${cleanRagaName}%`);

    if (error || !verses || verses.length === 0) {
      return null;
    }

    const ragaName = decodedSlug.split('-').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ');

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

    return {
      name: ragaName,
      hinglishName: ragaName,
      slug: decodedSlug,
      verses: mappedVerses,
      imageUrl: null
    };
  } catch (err) {
    console.error('Failed to fetch raga from Supabase:', err);
    return null;
  }
}



export async function generateMetadata({ params }) {
  await ensureDataLoaded();
  const decodedSlug = decodeURIComponent(params.slug);
  let raga = getRagaBySlug(decodedSlug);
  if (!raga) {
    raga = await fetchRagaFromSupabaseBySlug(decodedSlug);
  }
  if (!raga) return {};

  const brand = "वृंदोपनिषद्";
  const mainPart = `${raga.name} आधारित पद`;
  let title = `${mainPart} | ${brand}`;
  if (title.length > 60) {
    title = mainPart.substring(0, 43) + `... | ${brand}`;
  }
  const description = `राग ${raga.name} में रचित दिव्य वाणी पदों एवं संकीर्तन का संग्रह। शास्त्रीय रागों में निबंध ब्रज रस के पद अर्थ सहित पढ़ें।`;

  return {
    title,
    description,
    alternates: {
      canonical: `https://path.vrindopnishad.in/hi/ragas/${raga.slug}`,
      languages: {
        'en': `https://path.vrindopnishad.in/ragas/${raga.slug}`,
        'hi': `https://path.vrindopnishad.in/hi/ragas/${raga.slug}`,
      }
    },
    openGraph: {
      title,
      description,
      url: `https://path.vrindopnishad.in/hi/ragas/${raga.slug}`,
      type: 'music.playlist',
    }
  };
}

export default async function HindiRagaRoute({ params }) {
  await ensureDataLoaded();
  const decodedSlug = decodeURIComponent(params.slug);
  let raga = getRagaBySlug(decodedSlug);
  if (!raga) {
    raga = await fetchRagaFromSupabaseBySlug(decodedSlug);
  }
  if (!raga) {
    notFound();
  }

  if (params.slug !== raga.slug) {
    permanentRedirect(`/hi/ragas/${raga.slug}`);
  }

  const listSchema = {
    "@context": "https://schema.org",
    "@type": "ItemList",
    "name": raga.name,
    "description": `राग ${raga.name} में रचित पदों की सूची`,
    "numberOfItems": raga.verses ? raga.verses.length : 0,
    "itemListElement": raga.verses ? raga.verses.slice(0, 10).map((v, idx) => ({
      "@type": "ListItem",
      "position": idx + 1,
      "url": `https://path.vrindopnishad.in/hi/lyrics/${v.slug || v.id}`
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
        "name": "राग",
        "item": "https://path.vrindopnishad.in/hi/ragas"
      },
      {
        "@type": "ListItem",
        "position": 3,
        "name": raga.name,
        "item": `https://path.vrindopnishad.in/hi/ragas/${raga.slug}`
      }
    ]
  };

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(listSchema) }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumbsSchema) }}
      />

      <div className="max-w-4xl mx-auto px-4 pt-4 mb-2 flex items-center gap-1.5 text-xs text-white/50 select-none">
        <Link href="/hi" className="hover:text-amber-400 transition-colors">मुख्यपृष्ठ</Link>
        <span>→</span>
        <Link href="/hi/ragas" className="hover:text-amber-400 transition-colors">राग</Link>
        <span>→</span>
        <span className="text-white/80 font-medium truncate">{raga.name}</span>
      </div>

      <Layout>
        <RagaDetailPage key={raga.slug || decodedSlug} initialRaga={raga} />
      </Layout>
    </>
  );
}

