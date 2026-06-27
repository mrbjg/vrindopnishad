import { getAllVerses, ensureDataLoaded } from '../../src/lib/contentData';

export async function GET() {
  await ensureDataLoaded();
  const verses = getAllVerses();
  
  // Sort by date, newest first
  const sorted = [...verses].sort((a, b) => {
    const dateA = new Date(a.updated_at || a.updatedAt || a.created_at || a.createdAt || '2026-06-27').getTime();
    const dateB = new Date(b.updated_at || b.updatedAt || b.created_at || b.createdAt || '2026-06-27').getTime();
    return dateB - dateA;
  }).slice(0, 50);

  const base = 'https://path.vrindopnishad.in';
  
  const itemsXml = sorted.map(v => {
    const slug = encodeURIComponent(v.slug || v.id?.toString() || '');
    const title = v.title || 'Sacred Devotional Pad';
    const link = `${base}/content/${slug}`;
    const description = v.description || v.hindi_text?.substring(0, 200) || 'Sacred Vaishnava literature and devotional poetry.';
    const pubDate = new Date(v.updated_at || v.updatedAt || v.created_at || v.createdAt || '2026-06-27').toUTCString();
    const author = v.author || 'Braj Rasik Heritage';
    const category = v.category || 'poem';

    return `    <item>
      <title><![CDATA[${title}]]></title>
      <link>${link}</link>
      <guid isPermaLink="true">${link}</guid>
      <description><![CDATA[${description}]]></description>
      <pubDate>${pubDate}</pubDate>
      <author>${author}</author>
      <category>${category}</category>
    </item>`;
  }).join('\n');

  const xml = `<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>Vrindopnishad RSS Feed</title>
    <link>${base}</link>
    <description>Latest sacred verses, shlokas, and devotional literature of Vrindavan and Braj Rasik heritage.</description>
    <language>en-us</language>
    <lastBuildDate>${new Date().toUTCString()}</lastBuildDate>
    <atom:link href="${base}/rss.xml" rel="self" type="application/rss+xml" />
${itemsXml}
  </channel>
</rss>`;

  return new Response(xml, {
    headers: {
      'Content-Type': 'application/xml; charset=utf-8',
      'Cache-Control': 'public, max-age=3600, s-maxage=18000',
    },
  });
}
