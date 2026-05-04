/**
 * Vercel Serverless Function: Dynamic Sitemap Generator
 * 
 * This fetches ALL content from Firebase RTDB at request time and 
 * generates a fresh sitemap XML. Vercel CDN caches it via s-maxage.
 * 
 * WHY: Static sitemap.xml served by Vercel can conflict with SPA 
 * catch-all rewrites, causing Google Search Console "Couldn't fetch" errors.
 * A serverless function guarantees correct Content-Type and HTTP 200.
 */

const FIREBASE_DB_URL = 'https://santvaanig-default-rtdb.asia-southeast1.firebasedatabase.app';
const DOMAIN = 'https://path.vrindopnishad.in';

const generateSlug = (text) => {
  if (!text) return '';
  return text.toString().toLowerCase().trim()
    .replace(/\s+/g, '-')
    .replace(/[^\u0900-\u097F\w-]+/g, '')
    .replace(/--+/g, '-')
    .replace(/^-+/, '').replace(/-+$/, '');
};

const SEO_PAGES = [
  { path: '/', priority: '1.0', changefreq: 'daily' },
  { path: '/content', priority: '0.9', changefreq: 'daily' },
  { path: '/what-is-vrindopnishad', priority: '0.9', changefreq: 'weekly' },
  { path: '/meaning', priority: '0.9', changefreq: 'weekly' },
  { path: '/origin', priority: '0.9', changefreq: 'weekly' },
  { path: '/philosophy', priority: '0.9', changefreq: 'weekly' },
  { path: '/teachings', priority: '0.9', changefreq: 'weekly' },
  { path: '/importance', priority: '0.9', changefreq: 'weekly' },
  { path: '/devotion', priority: '0.9', changefreq: 'weekly' },
  { path: '/faq', priority: '0.9', changefreq: 'weekly' },
  { path: '/comparison-with-upanishads', priority: '0.9', changefreq: 'weekly' },
  { path: '/guide', priority: '0.9', changefreq: 'weekly' },
  { path: '/braj-rasik-heritage', priority: '0.9', changefreq: 'weekly' },
];

export default async function handler(req, res) {
  const today = new Date().toISOString().split('T')[0];
  let contentItems = [];

  // Fetch all content from Firebase RTDB (public REST endpoint)
  try {
    const response = await fetch(`${FIREBASE_DB_URL}/public/content.json`, {
      signal: AbortSignal.timeout(8000)
    });
    const rawData = await response.json();

    if (rawData) {
      contentItems = Array.isArray(rawData)
        ? rawData.filter(Boolean)
        : Object.keys(rawData).map(key => ({ id: key, ...rawData[key] }));
    }
  } catch (e) {
    console.error('Firebase fetch failed:', e.message);
  }

  // Extract unique categories
  const categories = [...new Set(contentItems.map(i => i.category).filter(Boolean))];

  // Build XML
  const staticUrls = SEO_PAGES.map(p => `
  <url>
    <loc>${DOMAIN}${p.path}</loc>
    <lastmod>${today}</lastmod>
    <changefreq>${p.changefreq}</changefreq>
    <priority>${p.priority}</priority>
  </url>`).join('');

  const catUrls = categories.map(cat => `
  <url>
    <loc>${DOMAIN}/category/${encodeURIComponent(cat.toLowerCase())}</loc>
    <lastmod>${today}</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.8</priority>
  </url>`).join('');

  const contentUrls = contentItems.map(item => {
    const slug = item.slug || generateSlug(item.title);
    return `
  <url>
    <loc>${DOMAIN}/content/${encodeURIComponent(slug)}</loc>
    <lastmod>${today}</lastmod>
    <changefreq>daily</changefreq>
    <priority>0.8</priority>
  </url>`;
  }).join('');

  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${staticUrls}
${catUrls}
${contentUrls}
</urlset>`;

  res.setHeader('Content-Type', 'application/xml; charset=utf-8');
  res.setHeader('Cache-Control', 'public, s-maxage=3600, stale-while-revalidate=86400');
  res.status(200).send(xml);
}
