import { getSitemapManifest } from '../../../src/lib/sitemapData.js';
import { STATIC_SEO_PAGES } from '../../../src/data/staticPagesData.js';
import { FESTIVALS_DATA } from '../../../src/data/festivalsData.js';
import { GLOSSARY_TERMS } from '../../../src/data/glossaryTerms.js';

export const dynamic = 'force-dynamic';

const CHUNK_SIZE = 3500; // 3500 items = 7000 URLs per sub-sitemap

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

function safeEncodeSlug(rawSlug) {
  if (!rawSlug) return '';
  try {
    return encodeURIComponent(decodeURIComponent(rawSlug));
  } catch (e) {
    return encodeURIComponent(rawSlug);
  }
}

export async function GET(request, { params }) {
  const manifest = getSitemapManifest();
  const sub = params?.sub || '';
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

    const staticSlugs = Object.keys(STATIC_SEO_PAGES || {});
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
    const allVerses = manifest.content || [];
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
      const slugVal = Array.isArray(v) ? v[0] : (v.slug || v.id?.toString() || '');
      const lastmodVal = Array.isArray(v) ? v[1] : (v.lastmod || v.updated_at || v.created_at);
      if (!slugVal) return;

      const slug = safeEncodeSlug(slugVal);
      const formattedDate = safeFormatDate(lastmodVal);

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
    const items = manifest.saints || [];
    items.forEach(s => {
      const slugVal = Array.isArray(s) ? s[0] : (s.slug || '');
      const lastmodVal = Array.isArray(s) ? s[1] : (s.lastmod || '2026-06-27');
      if (!slugVal) return;

      const slug = safeEncodeSlug(slugVal);
      const formattedDate = safeFormatDate(lastmodVal);

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
    const items = manifest.granthas || [];
    items.forEach(b => {
      const slugVal = Array.isArray(b) ? b[0] : (b.slug || '');
      const lastmodVal = Array.isArray(b) ? b[1] : (b.lastmod || '2026-06-27');
      if (!slugVal) return;

      const slug = safeEncodeSlug(slugVal);
      const formattedDate = safeFormatDate(lastmodVal);

      urlItems.push({
        loc: `${base}/granthas/${slug}`,
        changefreq: 'weekly',
        priority: '0.8',
        lastmod: formattedDate
      });
      urlItems.push({
        loc: `${base}/hi/granthas/${slug}`,
        changefreq: 'weekly',
        priority: '0.8',
        lastmod: formattedDate
      });
    });
  } else if (type === 'ragas') {
    const items = manifest.ragas || [];
    items.forEach(r => {
      const slugVal = Array.isArray(r) ? r[0] : (r.slug || '');
      const lastmodVal = Array.isArray(r) ? r[1] : (r.lastmod || '2026-06-27');
      if (!slugVal) return;

      const slug = safeEncodeSlug(slugVal);
      const formattedDate = safeFormatDate(lastmodVal);

      urlItems.push({
        loc: `${base}/ragas/${slug}`,
        changefreq: 'weekly',
        priority: '0.8',
        lastmod: formattedDate
      });
      urlItems.push({
        loc: `${base}/hi/ragas/${slug}`,
        changefreq: 'weekly',
        priority: '0.8',
        lastmod: formattedDate
      });
    });
  } else if (type === 'glossary') {
    const items = GLOSSARY_TERMS || [];
    items.forEach(t => {
      if (!t || !t.slug) return;
      const slug = safeEncodeSlug(t.slug);
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
    const slugs = Object.keys(FESTIVALS_DATA || {});
    slugs.forEach(slugRaw => {
      const slug = safeEncodeSlug(slugRaw);
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
  }

  const xmlUrls = urlItems.map(item => `  <url>
    <loc>${escapeXml(item.loc)}</loc>
    <lastmod>${escapeXml(item.lastmod)}</lastmod>
    <changefreq>${escapeXml(item.changefreq)}</changefreq>
    <priority>${escapeXml(item.priority)}</priority>
  </url>`).join('\n');

  if (urlItems.length === 0) {
    const emptyXml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
</urlset>`.trim();
    return new Response(emptyXml, {
      status: 200,
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'Cache-Control': 'public, max-age=86400, s-maxage=86400, stale-while-revalidate=604800'
      },
    });
  }

  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${xmlUrls}
</urlset>`.trim();

  return new Response(xml, {
    status: 200,
    headers: {
      'Content-Type': 'text/xml; charset=utf-8',
      'Cache-Control': 'public, max-age=86400, s-maxage=86400, stale-while-revalidate=604800'
    },
  });
}
