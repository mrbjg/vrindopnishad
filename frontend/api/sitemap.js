/**
 * Vercel Serverless Function: Dynamic Sitemap Generator
 * Fetches ALL content from Supabase (paginated) and generates XML.
 * Cached by Vercel CDN for 1 hour via s-maxage.
 */

const SUPABASE_URL = process.env.REACT_APP_SUPABASE_URL || 'https://tilimltxgeucefxzerqi.supabase.co';
const SUPABASE_KEY = process.env.REACT_APP_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpbGltbHR4Z2V1Y2VmeHplcnFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2MjQyNTQsImV4cCI6MjA4MzIwMDI1NH0.lwaCJyTRW6jNsfQJ32R_wAwp11yj6bvsJ4fzC0EX_00';
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

  // Paginated fetch from Supabase (1000 per page)
  try {
    const PAGE_SIZE = 1000;
    let offset = 0;
    let hasMore = true;

    while (hasMore) {
      const response = await fetch(
        `${SUPABASE_URL}/rest/v1/content?select=title,id,slug,category&order=id&offset=${offset}&limit=${PAGE_SIZE}`,
        {
          headers: {
            'apikey': SUPABASE_KEY,
            'Authorization': `Bearer ${SUPABASE_KEY}`
          }
        }
      );
      const items = await response.json();

      if (Array.isArray(items) && items.length > 0) {
        contentItems = contentItems.concat(items);
        offset += PAGE_SIZE;
        hasMore = items.length === PAGE_SIZE;
      } else {
        hasMore = false;
      }
    }
  } catch (e) {
    console.error('Supabase fetch failed:', e.message);
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
