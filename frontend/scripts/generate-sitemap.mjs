import fs from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

// Helper to manually load .env without dependencies
const loadEnv = (path) => {
  if (fs.existsSync(path)) {
    const content = fs.readFileSync(path, 'utf-8');
    content.split('\n').forEach(line => {
      const match = line.match(/^\s*([\w.-]+)\s*=\s*(.*)?\s*$/);
      if (match) {
        const key = match[1];
        let value = match[2] || '';
        if (value.startsWith('"') && value.endsWith('"')) value = value.slice(1, -1);
        if (value.startsWith("'") && value.endsWith("'")) value = value.slice(1, -1);
        process.env[key] = value;
      }
    });
  }
};

// Load .env
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
loadEnv(join(__dirname, '../.env'));

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
  const urlSet = new Set();
  const urls = [];

  // Helper to add unique URLs
  const addUrl = (loc, priority, freq) => {
    const fullLoc = loc.startsWith('http') ? loc : `${DOMAIN}${loc}`;
    if (!urlSet.has(fullLoc)) {
      urlSet.add(fullLoc);
      urls.push({ loc: fullLoc, priority, freq });
    }
  };

  // 1. Static SEO Pages
  SEO_PAGES.forEach(page => addUrl(page.path, page.priority, page.changefreq));

  // 2. Category Pages
  CATEGORY_PAGES.forEach(page => addUrl(page.path, page.priority, page.changefreq));

  // 3. Dynamic Content from Supabase
  if (SUPABASE_KEY) {
    try {
      console.log('Fetching dynamic content from Supabase...');
      const response = await fetch(`${SUPABASE_URL}/rest/v1/content?select=title,id`, {
          headers: {
              'apikey': SUPABASE_KEY,
              'Authorization': `Bearer ${SUPABASE_KEY}`
          }
      });
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const content = await response.json();
      if (content && content.length > 0) {
        console.log(`Found ${content.length} dynamic items.`);
        content.forEach(item => {
          const slug = generateSlug(item.title);
          const encodedSlug = slug ? slug.split('/').map(segment => encodeURIComponent(segment)).join('/') : item.id;
          if (encodedSlug) {
            addUrl(`/content/${encodedSlug}`, '0.8', 'daily');
          }
        });
      }
    } catch (error) {
      console.warn('Warning: Could not fetch dynamic content. Sitemap will include static pages only.');
      console.warn('Error detail:', error.message);
    }
  } else {
    console.log('SUPABASE_KEY not found. Skipping dynamic content.');
  }

  // Generate XML
  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls.map(u => `  <url>
    <loc>${u.loc}</loc>
    <lastmod>${today}</lastmod>
    <changefreq>${u.freq}</changefreq>
    <priority>${u.priority}</priority>
  </url>`).join('\n')}
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



