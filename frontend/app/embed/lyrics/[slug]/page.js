import React from 'react';
import { notFound } from 'next/navigation';
import { getVerseBySlug, ensureDataLoaded } from '../../../../src/lib/contentData';
import { supabase } from '../../../../src/lib/supabase';

export const revalidate = 604800; // Cache on CDN for fast iframe load times

async function fetchVerse(slug) {
  await ensureDataLoaded();
  const decodedSlug = decodeURIComponent(slug);
  let verse = getVerseBySlug(decodedSlug);
  if (!verse) {
    try {
      const { data } = await supabase
        .from('content')
        .select('id, title, sanskrit_text, hindi_text, english_translation, author, category, slug, audio_url')
        .or(`slug.eq.${decodedSlug},id.eq.${decodedSlug}`)
        .maybeSingle();
      if (data) verse = data;
    } catch (e) {}
  }
  return verse;
}

export async function generateMetadata({ params }) {
  const verse = await fetchVerse(params.slug);
  if (!verse) return {};
  return {
    title: `${verse.title} - Vrindopnishad Embed`,
    robots: {
      index: false,
      follow: true,
    },
  };
}

export default async function EmbedLyricPage({ params }) {
  const verse = await fetchVerse(params.slug);
  if (!verse) {
    notFound();
  }

  const cleanAuthor = verse.author ? verse.author.replace(/जी की वाणी/g, '').replace(/जी/g, '').trim() : 'Rasik Saint';
  const pageUrl = `https://path.vrindopnishad.in/lyrics/${verse.slug}`;

  // Truncate verse text for clean iframe snippet view
  const bodyText = verse.sanskrit_text || verse.hindi_text || verse.english_translation || '';
  const truncatedText = bodyText.length > 220 ? bodyText.slice(0, 220) + '...' : bodyText;

  return (
    <html lang="en" className="dark h-full bg-zinc-950 text-zinc-100 selection:bg-amber-500/30">
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <style>{`
          body {
            font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 0;
            background: #09090b;
            color: #f4f4f5;
          }
          .embed-card {
            border: 1px solid rgba(255, 255, 255, 0.12);
            border-radius: 12px;
            padding: 16px;
            background: linear-gradient(145deg, #18181b 0%, #09090b 100%);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            height: calc(100vh - 32px);
            box-sizing: border-box;
          }
          .tag {
            font-size: 10px;
            text-transform: uppercase;
            letter-spacing: 0.1em;
            color: #f59e0b;
            font-weight: 700;
          }
          .title {
            font-size: 16px;
            font-weight: 700;
            margin: 4px 0 2px 0;
            color: #ffffff;
            line-height: 1.3;
          }
          .author {
            font-size: 12px;
            color: #a1a1aa;
            margin-bottom: 12px;
          }
          .text-content {
            font-size: 13px;
            line-height: 1.6;
            color: #e4e4e7;
            white-space: pre-line;
            overflow: hidden;
            text-overflow: ellipsis;
            max-height: 110px;
          }
          .footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-top: 12px;
            padding-top: 10px;
            border-top: 1px solid rgba(255, 255, 255, 0.08);
          }
          .btn-cta {
            background: #d97706;
            color: #ffffff;
            font-size: 11px;
            font-weight: 600;
            padding: 6px 12px;
            border-radius: 9999px;
            text-decoration: none;
            transition: background 0.2s ease;
          }
          .btn-cta:hover {
            background: #b45309;
          }
          .brand {
            font-size: 11px;
            color: #71717a;
            text-decoration: none;
          }
          .brand:hover {
            color: #f59e0b;
          }
        `}</style>
      </head>
      <body>
        <div style={{ padding: '16px' }}>
          <div className="embed-card">
            <div>
              <span className="tag">Vrindopnishad Sanctuary</span>
              <h2 className="title">{verse.title}</h2>
              <div className="author">By {cleanAuthor}</div>
              <div className="text-content">{truncatedText}</div>
            </div>
            <div className="footer">
              <a href={pageUrl} target="_blank" rel="noopener noreferrer" className="brand">
                vrindopnishad.in
              </a>
              <a href={pageUrl} target="_blank" rel="noopener noreferrer" className="btn-cta">
                Read Full & Listen →
              </a>
            </div>
          </div>
        </div>
      </body>
    </html>
  );
}
