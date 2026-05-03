import fs from 'fs';
import axios from 'axios';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

// Load .env
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
dotenv.config({ path: join(__dirname, '../.env') });

const SUPABASE_URL = process.env.REACT_APP_SUPABASE_URL || 'https://tilimltxgeucefxzerqi.supabase.co';
const SUPABASE_KEY = process.env.REACT_APP_SUPABASE_ANON_KEY || '';
const DOMAIN = 'https://path.vrindopnishad.in';

const generateSlug = (text) => {
  if (!text) return '';
  return text
    .toString()
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '-')
    .replace(/[^\u0900-\u097F\w-]+/g, '')
    .replace(/--+/g, '-')
    .replace(/^-+/, '')
    .replace(/-+$/, '');
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

const CATEGORY_PAGES = [
  { path: '/category/shloka', priority: '0.8', changefreq: 'weekly' },
  { path: '/category/strotra', priority: '0.8', changefreq: 'weekly' },
  { path: '/category/poem', priority: '0.8', changefreq: 'weekly' },
  { path: '/category/sankirtan', priority: '0.8', changefreq: 'weekly' },
  { path: '/category/saint', priority: '0.8', changefreq: 'weekly' },
  { path: '/category/dham', priority: '0.8', changefreq: 'weekly' },
  { path: '/category/literature', priority: '0.8', changefreq: 'weekly' },
];

async function generateSitemap() {
  console.log('--- SEO Sitemap Generator ---');
  const today = new Date().toISOString().split('T')[0];
  let contentUrls = '';

  if (SUPABASE_KEY) {
    try {
      console.log('Fetching dynamic content from Supabase...');
      const response = await axios.get(`${SUPABASE_URL}/rest/v1/content?select=title,id`, {
        headers: {
          'apikey': SUPABASE_KEY,
          'Authorization': `Bearer ${SUPABASE_KEY}`
        },
        timeout: 10000
      });

      const content = response.data;
      if (content && content.length > 0) {
        console.log(`Found ${content.length} dynamic items.`);
        contentUrls = content.map(item => {
          const slug = generateSlug(item.title);
          const encodedSlug = slug ? slug.split('/').map(segment => encodeURIComponent(segment)).join('/') : item.id;
          return `
  <url>
    <loc>${DOMAIN}/content/${encodedSlug}</loc>
    <lastmod>${today}</lastmod>
    <changefreq>daily</changefreq>
    <priority>0.8</priority>
  </url>`;
        }).join('');
      }
    } catch (error) {
      console.warn('Warning: Could not fetch dynamic content. Sitemap will include static pages only.');
      console.warn('Error detail:', error.message);
    }
  } else {
    console.log('SUPABASE_KEY not found. Skipping dynamic content.');
  }

  const staticUrls = SEO_PAGES.map(page => `
  <url>
    <loc>${DOMAIN}${page.path === '/' ? '/' : page.path}</loc>
    <lastmod>${today}</lastmod>
    <changefreq>${page.changefreq}</changefreq>
    <priority>${page.priority}</priority>
  </url>`).join('');

  const catUrls = CATEGORY_PAGES.map(page => `
  <url>
    <loc>${DOMAIN}${page.path}</loc>
    <lastmod>${today}</lastmod>
    <changefreq>${page.changefreq}</changefreq>
    <priority>${page.priority}</priority>
  </url>`).join('');

  const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${staticUrls}
${catUrls}
${contentUrls}
</urlset>`;

  try {
    // Ensure public folder exists
    if (!fs.existsSync('public')) {
      fs.mkdirSync('public');
    }
    fs.writeFileSync('public/sitemap.xml', xml);
    console.log(`✅ sitemap.xml generated in public/ (${urls.length} unique URLs)`);

    if (fs.existsSync('build')) {
      fs.writeFileSync('build/sitemap.xml', xml);
      console.log('✅ sitemap.xml copied to build/');
    }
  } catch (err) {
    console.error('Error writing sitemap file:', err.message);
  }
}

generateSitemap();
