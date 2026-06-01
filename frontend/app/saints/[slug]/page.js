import React from 'react';
import SaintDetailPage from '../../../src/views/SaintDetailPage';
import Layout from '../../../src/components/Layout';
import { getSaintBySlug, getAllSaints } from '../../../src/lib/contentData';
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
  
  const title = `${saint.hinglishName} Biography & Collected Verses | Vrindopnishad`;
  const description = `Read the biography, teachings, and complete verses (vani pad) of Shri ${saint.hinglishName}. Verified Vaishnava history and spiritual legacy.`;

  return {
    title,
    description,
    alternates: {
      canonical: `https://path.vrindopnishad.in/saints/${params.slug}`,
    },
    openGraph: {
      title,
      description,
      url: `https://path.vrindopnishad.in/saints/${params.slug}`,
      type: 'profile',
    }
  };
}

export default function SaintRoute({ params }) {
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
    "description": saint.biography || `Vaishnava saint of the Braj tradition.`,
    "url": `https://path.vrindopnishad.in/saints/${saint.slug}`,
    "knowsAbout": ["Vaishnavism", "Bhakti Yoga", "Braj Rasik Heritage", "Vrindavan"]
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
        dangerouslySetInnerHTML={{ __html: JSON.stringify(personSchema) }}
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
export const revalidate = 86400;
