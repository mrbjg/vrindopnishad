import { 
  getAllVerses, 
  getAllSaints, 
  getAllGranthas, 
  getAllRagas, 
  getGlossaryTerms,
  ensureDataLoaded
} from '../../../src/lib/contentData';
import { STATIC_SEO_PAGES } from '../../../src/data/staticPagesData';
import { FESTIVALS_DATA } from '../../../src/data/festivalsData';

const NUM_CONTENT_CHUNKS = 15;
const CHUNK_SIZE = 3500; // 3500 verses = 7000 URLs per sub-sitemap (optimized for fast response & GSC limits)

export async function generateStaticParams() {
  const contentSubMaps = Array.from({ length: NUM_CONTENT_CHUNKS }, (_, i) => ({ sub: `content-${i + 1}.xml` }));
  return [
    { sub: 'pages.xml' },
    { sub: 'content.xml' },
    ...contentSubMaps,
    { sub: 'saints.xml' },
    { sub: 'granthas.xml' },
    { sub: 'ragas.xml' },
    { sub: 'glossary.xml' },
    { sub: 'festivals.xml' }
  ];
}

function escapeXml(str) {
  if (!str) return '';
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;');
}

function safeFormatDate(input, fallback = '2026-06-27') {
  if (!input) return fallback;
  try {
    const d = new Date(input);
    if (isNaN(d.getTime())) return fallback;
    return d.toISOString().split('T')[0];
  } catch (e) {
    return fallback;
  }
}

export async function GET(request, { params }) {
  await ensureDataLoaded();
  const sub = params.sub || '';
  const type = sub.replace('.xml', '');

  let urlItems = [];
  const base = 'https://path.vrindopnishad.in';

  if (type === 'pages') {
    const coreRoutes = [
      '',
      '/hi',
      '/lyrics',
      '/hi/lyrics',
      '/saints',
      '/hi/saints',
      '/granthas',
      '/hi/granthas',
      '/ragas',
      '/hi/ragas',
      '/knowledge-base',
      '/hi/knowledge-base'
    ];

    coreRoutes.forEach(route => {
      urlItems.push({
        loc: `${base}${route}`,
        changefreq: 'daily',
        priority: '1.0',
        lastmod: '2026-06-27'
      });
    });

    const staticSlugs = Object.keys(STATIC_SEO_PAGES);
    staticSlugs.forEach(slug => {
      urlItems.push({
        loc: `${base}/${slug}`,
        changefreq: 'weekly',
        priority: '0.7',
        lastmod: '2026-06-02'
      });
      urlItems.push({
        loc: `${base}/hi/${slug}`,
        changefreq: 'weekly',
        priority: '0.7',
        lastmod: '2026-06-02'
      });
    });
  } else if (type === 'content' || type.startsWith('content-')) {
    const allVerses = getAllVerses();
    let items = [];

    const match = type.match(/^content-(\d+)$/);
    if (match) {
      const pageNum = parseInt(match[1], 10);
      const startIndex = (pageNum - 1) * CHUNK_SIZE;
      items = allVerses.slice(startIndex, startIndex + CHUNK_SIZE);
    } else if (type === 'content') {
      items = allVerses.slice(0, CHUNK_SIZE);
    }

    items.forEach(v => {
      const rawSlug = v.slug || v.id?.toString() || '';
      if (!rawSlug) return;
      const slug = encodeURIComponent(rawSlug);
      const lastmodDate = v.updated_at || v.updatedAt || v.created_at || v.createdAt;
      const formattedDate = safeFormatDate(lastmodDate);

      urlItems.push({
        loc: `${base}/lyrics/${slug}`,
        changefreq: 'weekly',
        priority: '0.8',
        lastmod: formattedDate
      });
      urlItems.push({
        loc: `${base}/hi/lyrics/${slug}`,
        changefreq: 'weekly',
        priority: '0.8',
        lastmod: formattedDate
      });
    });
  } else if (type === 'saints') {
    const items = getAllSaints();
    items.forEach(s => {
      if (!s || !s.slug) return;
      const slug = encodeURIComponent(s.slug);
      const lastmodDate = s.rawItem?.updated_at || s.rawItem?.updatedAt;
      const formattedDate = safeFormatDate(lastmodDate);
      urlItems.push({
        loc: `${base}/saints/${slug}`,
        changefreq: 'weekly',
        priority: '0.9',
        lastmod: formattedDate
      });
      urlItems.push({
        loc: `${base}/hi/saints/${slug}`,
        changefreq: 'weekly',
        priority: '0.9',
        lastmod: formattedDate
      });
    });
  } else if (type === 'granthas') {
    const items = getAllGranthas();
    items.forEach(b => {
      if (!b || !b.slug) return;
      const slug = encodeURIComponent(b.slug);
      let lastmod = '2026-06-27';
      if (b.verses && Array.isArray(b.verses) && b.verses.length > 0) {
        const timestamps = b.verses
          .map(v => v?.updated_at || v?.updatedAt || v?.created_at || v?.createdAt)
          .filter(Boolean);
        if (timestamps.length > 0) {
          const validTimes = timestamps.map(t => new Date(t).getTime()).filter(t => !isNaN(t));
          if (validTimes.length > 0) {
            lastmod = safeFormatDate(Math.max(...validTimes));
          }
        }
      }
      urlItems.push({
        loc: `${base}/granthas/${slug}`,
        changefreq: 'weekly',
        priority: '0.8',
        lastmod
      });
      urlItems.push({
        loc: `${base}/hi/granthas/${slug}`,
        changefreq: 'weekly',
        priority: '0.8',
        lastmod
      });
    });
  } else if (type === 'ragas') {
    const items = getAllRagas();
    items.forEach(r => {
      if (!r || !r.slug) return;
      const slug = encodeURIComponent(r.slug);
      let lastmod = '2026-06-27';
      if (r.verses && Array.isArray(r.verses) && r.verses.length > 0) {
        const timestamps = r.verses
          .map(v => v?.updated_at || v?.updatedAt || v?.created_at || v?.createdAt)
          .filter(Boolean);
        if (timestamps.length > 0) {
          const validTimes = timestamps.map(t => new Date(t).getTime()).filter(t => !isNaN(t));
          if (validTimes.length > 0) {
            lastmod = safeFormatDate(Math.max(...validTimes));
          }
        }
      }
      urlItems.push({
        loc: `${base}/ragas/${slug}`,
        changefreq: 'weekly',
        priority: '0.8',
        lastmod
      });
      urlItems.push({
        loc: `${base}/hi/ragas/${slug}`,
        changefreq: 'weekly',
        priority: '0.8',
        lastmod
      });
    });
  } else if (type === 'glossary') {
    const items = getGlossaryTerms();
    items.forEach(t => {
      if (!t || !t.slug) return;
      const slug = encodeURIComponent(t.slug);
      urlItems.push({
        loc: `${base}/glossary/${slug}`,
        changefreq: 'monthly',
        priority: '0.6',
        lastmod: '2026-06-27'
      });
      urlItems.push({
        loc: `${base}/hi/glossary/${slug}`,
        changefreq: 'monthly',
        priority: '0.6',
        lastmod: '2026-06-27'
      });
    });
  } else if (type === 'festivals') {
    const slugs = Object.keys(FESTIVALS_DATA);
    slugs.forEach(slug => {
      urlItems.push({
        loc: `${base}/festivals/${slug}`,
        changefreq: 'weekly',
        priority: '0.8',
        lastmod: '2026-06-27'
      });
      urlItems.push({
        loc: `${base}/hi/festivals/${slug}`,
        changefreq: 'weekly',
        priority: '0.8',
        lastmod: '2026-06-27'
      });
    });
  } else {
    return new Response('Not Found', { status: 404 });
  }

  const xmlUrls = urlItems.map(item => `  <url>
    <loc>${escapeXml(item.loc)}</loc>
    <lastmod>${escapeXml(item.lastmod)}</lastmod>
    <changefreq>${escapeXml(item.changefreq)}</changefreq>
    <priority>${escapeXml(item.priority)}</priority>
  </url>`).join('\n');

  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${xmlUrls}
</urlset>`;

  return new Response(xml, {
    headers: {
      'Content-Type': 'application/xml; charset=utf-8',
      'Cache-Control': 'public, max-age=3600, s-maxage=86400, stale-while-revalidate=86400'
    },
  });
}
