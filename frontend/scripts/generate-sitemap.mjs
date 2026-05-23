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
const FIREBASE_DB_URL = 'https://santvaanig-default-rtdb.asia-southeast1.firebasedatabase.app';
const DOMAIN = 'https://path.vrindopnishad.in';

// Consistent slug generation logic matching frontend/src/services/api.js
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

// Temperory removed as not required
// const CATEGORY_PAGES = [
//   { path: '/category/shloka', priority: '0.8', changefreq: 'weekly' },
//   { path: '/category/strotra', priority: '0.8', changefreq: 'weekly' },
//   { path: '/category/poem', priority: '0.8', changefreq: 'weekly' },
//   { path: '/category/sankirtan', priority: '0.8', changefreq: 'weekly' },
//   { path: '/category/saint', priority: '0.8', changefreq: 'weekly' },
//   { path: '/category/dham', priority: '0.8', changefreq: 'weekly' },
//   { path: '/category/literature', priority: '0.8', changefreq: 'weekly' },
// ];

async function generateSitemap() {
  console.log('--- 🚀 SEO Sitemap Generator ---');
  const today = new Date().toISOString().split('T')[0];
  let allContentItems = [];

  // 1. Fetch from Firebase RTDB (Primary source)
  try {
    console.log('📡 Fetching content from Firebase RTDB...');
    const response = await axios.get(`${FIREBASE_DB_URL}/public/content.json`, { timeout: 15000 });
    const rawData = response.data;

    if (rawData) {
      const items = Array.isArray(rawData)
        ? rawData.filter(Boolean)
        : Object.keys(rawData).map(key => ({ id: key, ...rawData[key] }));

      console.log(`✅ Found ${items.length} items in Firebase.`);
      allContentItems = [...allContentItems, ...items];
    }
  } catch (error) {
    console.warn('⚠️ Firebase fetch failed:', error.message);
  }

  // 2. Fetch from Supabase with pagination (1000 rows per page)
  if (SUPABASE_KEY) {
    try {
      console.log('📡 Fetching content from Supabase (paginated)...');
      const PAGE_SIZE = 1000;
      let offset = 0;
      let hasMore = true;

      while (hasMore) {
        const response = await axios.get(
          `${SUPABASE_URL}/rest/v1/content?select=title,id,slug,category&order=id&offset=${offset}&limit=${PAGE_SIZE}`,
          {
            headers: {
              'apikey': SUPABASE_KEY,
              'Authorization': `Bearer ${SUPABASE_KEY}`,
              'Prefer': 'count=exact'
            },
            timeout: 30000
          }
        );

        const items = response.data;
        if (items && items.length > 0) {
          items.forEach(item => {
            if (!allContentItems.some(existing => existing.id === item.id)) {
              allContentItems.push(item);
            }
          });
          console.log(`  📦 Fetched ${items.length} items (total: ${allContentItems.length})`);
          offset += PAGE_SIZE;
          hasMore = items.length === PAGE_SIZE;
        } else {
          hasMore = false;
        }
      }
      console.log(`✅ Total: ${allContentItems.length} items from Supabase.`);
    } catch (error) {
      console.warn('⚠️ Supabase fetch failed:', error.message);
    }
  }

  // 3. Extract unique categories dynamically case-insensitively and handle spaces/hyphens
  const categoriesSet = new Set();
  const uniqueCategories = [];
  allContentItems.forEach(item => {
    if (item.category) {
      const formatted = item.category.toString().toLowerCase().trim().replace(/\s+/g, '-');
      if (formatted && !categoriesSet.has(formatted)) {
        categoriesSet.add(formatted);
        uniqueCategories.push(formatted);
      }
    }
  });
  console.log(`📂 Found ${uniqueCategories.length} unique categories.`);

  // 4. Sanitize slug for XML-safe URLs
  const sanitizeSlug = (slug) => {
    if (!slug) return '';
    return slug.toString()
      .replace(/[\r\n\t]+/g, '')
      .replace(/["'<>&,;:!?()[\]{}]/g, '')
      .replace(/\s+/g, '-')
      .replace(/--+/g, '-')
      .replace(/^-+/, '').replace(/-+$/, '')
      .trim();
  };

  // 5. Generate XML — single-line <url> blocks to prevent whitespace corruption
  // CRITICAL: Deduplicate by slug to prevent Google from seeing duplicate URLs
  const seenSlugs = new Set();
  const contentUrls = allContentItems
    .map(item => {
      const rawSlug = item.slug || generateSlug(item.title);
      const slug = sanitizeSlug(rawSlug);
      if (!slug) return null;
      
      const normalizedSlug = slug.toLowerCase();
      // Skip duplicates
      if (seenSlugs.has(normalizedSlug)) return null;
      seenSlugs.add(normalizedSlug);
      
      // Percent-encode non-ASCII slugs using encodeURIComponent(decodeURIComponent(slug))
      const encodedSlug = encodeURIComponent(decodeURIComponent(slug));
      return `  <url><loc>${DOMAIN}/content/${encodedSlug}</loc><lastmod>${today}</lastmod><changefreq>daily</changefreq><priority>0.8</priority></url>`;
    })
    .filter(Boolean)
    .join('\n');
  console.log(`📊 Deduplicated: ${allContentItems.length} items → ${seenSlugs.size} unique URLs`);

  const staticUrls = SEO_PAGES.map(page =>
    `  <url><loc>${DOMAIN}${page.path}</loc><lastmod>${today}</lastmod><changefreq>${page.changefreq}</changefreq><priority>${page.priority}</priority></url>`
  ).join('\n');

  const catUrls = uniqueCategories.map(cat =>
    `  <url><loc>${DOMAIN}/category/${cat}</loc><lastmod>${today}</lastmod><changefreq>weekly</changefreq><priority>0.8</priority></url>`
  ).join('\n');

  const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${staticUrls}
${catUrls}
${contentUrls}
</urlset>`;

  try {
    // Write to public/ only (for local dev).
    // DO NOT write to build/ — on Vercel, a static build/sitemap.xml 
    // would take priority over the /api/sitemap serverless rewrite.
    if (!fs.existsSync('public')) {
      fs.mkdirSync('public');
    }

    fs.writeFileSync('public/sitemap.xml', sitemap);
    const totalUrls = SEO_PAGES.length + uniqueCategories.length + allContentItems.length;
    console.log(`✅ sitemap.xml generated in public/ with ${totalUrls} URLs`);

  } catch (err) {
    console.error('❌ Error writing sitemap file:', err.message);
  }
}

generateSitemap();
