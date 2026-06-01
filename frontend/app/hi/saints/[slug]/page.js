import React from 'react';
import SaintDetailPage from '../../../../src/views/SaintDetailPage';
import Layout from '../../../../src/components/Layout';
import { getSaintBySlug, getAllSaints } from '../../../../src/lib/contentData';
import { notFound } from 'next/navigation';
import Link from 'next/link';

export async function generateStaticParams() {
  const saints = getAllSaints();
  return saints.map(s => ({
    slug: encodeURIComponent(s.slug),
  }));
}

export async function generateMetadata({ params }) {
  const decodedSlug = decodeURIComponent(params.slug);
  const saint = getSaintBySlug(decodedSlug);
  if (!saint) return {};
  
  const title = `संत ${saint.name} जीवनी एवं वाणी संग्रह | वृंदोपनिषद्`;
  const description = `महान रसिक संत ${saint.name} का जीवन चरित्र, आध्यात्मिक दर्शन, रचित ग्रन्थ और वाणी संग्रह। हिन्दी और ब्रजभाषा में व्याख्या सहित पढ़ें।`;

  return {
    title,
    description,
    alternates: {
      canonical: `https://path.vrindopnishad.in/hi/saints/${params.slug}`,
    },
    openGraph: {
      title,
      description,
      url: `https://path.vrindopnishad.in/hi/saints/${params.slug}`,
      type: 'profile',
    }
  };
}

export default function HindiSaintRoute({ params }) {
  const decodedSlug = decodeURIComponent(params.slug);
  const saint = getSaintBySlug(decodedSlug);
  if (!saint) {
    notFound();
  }

  const personSchema = {
    "@context": "https://schema.org",
    "@type": "Person",
    "name": saint.name,
    "alternateName": saint.hinglishName !== saint.name ? saint.hinglishName : undefined,
    "description": saint.biography || `ब्रज परंपरा के वैष्णव संत।`,
    "url": `https://path.vrindopnishad.in/hi/saints/${saint.slug}`,
    "knowsAbout": ["Vaishnavism", "Bhakti Yoga", "Braj Rasik Heritage", "Vrindavan"]
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
        dangerouslySetInnerHTML={{ __html: JSON.stringify(personSchema) }}
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
export const revalidate = 86400;
