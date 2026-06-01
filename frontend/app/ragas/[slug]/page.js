import React from 'react';
import RagaDetailPage from '../../../src/views/RagaDetailPage';
import Layout from '../../../src/components/Layout';
import { getRagaBySlug, getAllRagas } from '../../../src/lib/contentData';
import { notFound } from 'next/navigation';
import Link from 'next/link';

export async function generateStaticParams() {
  const ragas = getAllRagas();
  return ragas.map(r => ({
    slug: encodeURIComponent(r.slug),
  }));
}

export async function generateMetadata({ params }) {
  const decodedSlug = decodeURIComponent(params.slug);
  const raga = getRagaBySlug(decodedSlug);
  if (!raga) return {};

  const title = `${raga.hinglishName} Devotional Songs | Vrindopnishad`;
  const description = `Read and listen to the sacred spiritual verses composed in ${raga.hinglishName} with translations. Complete listing.`;

  return {
    title,
    description,
    alternates: {
      canonical: `https://path.vrindopnishad.in/ragas/${params.slug}`,
    },
    openGraph: {
      title,
      description,
      url: `https://path.vrindopnishad.in/ragas/${params.slug}`,
      type: 'music.playlist',
    }
  };
}

export default function RagaRoute({ params }) {
  const decodedSlug = decodeURIComponent(params.slug);
  const raga = getRagaBySlug(decodedSlug);
  if (!raga) {
    notFound();
  }

  const listSchema = {
    "@context": "https://schema.org",
    "@type": "ItemList",
    "name": raga.name,
    "description": `List of songs composed in Raga ${raga.hinglishName}`,
    "numberOfItems": raga.verses ? raga.verses.length : 0,
    "itemListElement": raga.verses ? raga.verses.slice(0, 10).map((v, idx) => ({
      "@type": "ListItem",
      "position": idx + 1,
      "url": `https://path.vrindopnishad.in/content/${v.slug || v.id}`
    })) : []
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
        "name": "Ragas",
        "item": "https://path.vrindopnishad.in/ragas"
      },
      {
        "@type": "ListItem",
        "position": 3,
        "name": raga.hinglishName,
        "item": `https://path.vrindopnishad.in/ragas/${raga.slug}`
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
        <Link href="/" className="hover:text-amber-400 transition-colors">Home</Link>
        <span>→</span>
        <Link href="/ragas" className="hover:text-amber-400 transition-colors">Ragas</Link>
        <span>→</span>
        <span className="text-white/80 font-medium truncate">{raga.hinglishName}</span>
      </div>

      <Layout>
        <RagaDetailPage key={raga.slug || decodedSlug} initialRaga={raga} />
      </Layout>
    </>
  );
}
export const revalidate = 86400;
