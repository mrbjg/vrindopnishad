import fs from 'fs';
import axios from 'axios';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import glossaryTermsApi from '../api/glossaryTerms.js';
const { GLOSSARY_TERMS } = glossaryTermsApi;

// Load .env
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
dotenv.config({ path: join(__dirname, '../.env') });

const SUPABASE_URL = process.env.REACT_APP_SUPABASE_URL || 'https://tilimltxgeucefxzerqi.supabase.co';
const SUPABASE_KEY = process.env.REACT_APP_SUPABASE_ANON_KEY || '';
const FIREBASE_DB_URL = 'https://santvaanig-default-rtdb.asia-southeast1.firebasedatabase.app';
const DOMAIN = 'https://path.vrindopnishad.in';

// Devanagari to Hinglish Phonetic Map for SEO Slugs
const DevanagariToHinglishMap = {
  'अ': 'a', 'आ': 'aa', 'इ': 'i', 'ई': 'ee', 'उ': 'u', 'ऊ': 'oo', 'ऋ': 'ri',
  'ए': 'e', 'ऐ': 'ai', 'ओ': 'o', 'औ': 'au', 'अं': 'an', 'अः': 'ah',
  'क': 'ka', 'ख': 'kha', 'ग': 'ga', 'घ': 'gha', 'ङ': 'nga',
  'च': 'cha', 'छ': 'chha', 'ज': 'ja', 'झ': 'jha', 'ञ': 'nya',
  'ट': 'ta', 'ठ': 'tha', 'ड': 'da', 'ढ': 'dha', 'ण': 'na',
  'त': 'ta', 'थ': 'tha', 'द': 'da', 'ध': 'dha', 'न': 'na',
  'प': 'pa', 'फ': 'fa', 'ब': 'ba', 'भ': 'bha', 'म': 'ma',
  'य': 'ya', 'र': 'ra', 'ल': 'la', 'व': 'va', 'श': 'sha', 'ष': 'sha',
  'स': 'sa', 'ह': 'ha', 'ळ': 'la', 'क्ष': 'ksha', 'त्र': 'tra', 'ज्ञ': 'gya',
  'ा': 'a', 'ि': 'i', 'ी': 'ee', 'ु': 'u', 'ू': 'oo', 'ृ': 'ri',
  'े': 'e', 'ै': 'ai', 'ो': 'o', 'ौ': 'au', 'ं': 'n', 'ः': 'h', 'ँ': 'n',
  'ॅ': 'e', 'ॉ': 'o',
  'क़': 'qa', 'ख़': 'kha', 'ग़': 'gha', 'ज़': 'za', 'फ़': 'fa', 'ड़': 'da', 'ढ़': 'dha',
  '०': '0', '१': '1', '२': '2', '३': '3', '४': '4', '५': '5', '६': '6', '७': '7', '८': '8', '९': '9',
  '।': '.', '॥': '..'
};

const Consonants = new Set([
  'क', 'ख', 'ग', 'घ', 'ङ', 'च', 'छ', 'ज', 'झ', 'ञ',
  'ट', 'ठ', 'ड', 'ढ', 'ण', 'त', 'थ', 'द', 'ध', 'न',
  'प', 'फ', 'ब', 'भ', 'म', 'य', 'र', 'ल', 'व', 'श',
  'ष', 'स', 'ह', 'ळ', 'क्ष', 'त्र', 'ज्ञ',
  'क़', 'ख़', 'ग़', 'ज़', 'फ़', 'ड़', 'ढ़'
]);

const Matras = new Set([
  'ा', 'ि', 'ी', 'ु', 'ू', 'ृ', 'े', 'ै', 'ो', 'ौ', 'ं', 'ः', 'ँ', 'ॅ', 'ॉ'
]);

function transliterate(text) {
  if (!text) return "";
  let result = "";
  const chars = Array.from(text);
  
  for (let i = 0; i < chars.length; i++) {
    const char = chars[i];
    const nextChar = chars[i + 1] || "";
    
    const nuqtaCombo = char + nextChar;
    if (DevanagariToHinglishMap[nuqtaCombo] !== undefined) {
      result += DevanagariToHinglishMap[nuqtaCombo];
      i++;
      continue;
    }
    
    if (char === '्') {
      if (result.endsWith('a')) {
        result = result.substring(0, result.length - 1);
      }
      continue;
    }

    const mapped = DevanagariToHinglishMap[char];
    if (mapped !== undefined) {
      result += mapped;
      
      if (Consonants.has(char)) {
        const nextHasMatra = Matras.has(nextChar);
        const nextIsHalant = nextChar === '्';
        const nextIsWordBoundary = nextChar === ' ' || nextChar === '\n' || nextChar === '\t' || 
                                   nextChar === '।' || nextChar === '॥' || nextChar === ',' || 
                                   nextChar === '.' || nextChar === '?' || nextChar === '!' || 
                                   nextChar === '"' || nextChar === '\'' || nextChar === "";
        
        if (nextHasMatra || nextIsHalant || nextIsWordBoundary) {
          if (result.endsWith('a')) {
            result = result.substring(0, result.length - 1);
          }
        }
      }
    } else {
      result += char;
    }
  }

  return result
    .replace(/aa/g, 'a')
    .replace(/ee/g, 'i')
    .replace(/oo/g, 'u')
    .replace(/\s+/g, ' ')
    .trim();
}

const slugify = (text) => {
  if (!text) return '';
  return text
    .toString()
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '-')
    .replace(/[^a-z0-9-]/g, '')
    .replace(/--+/g, '-')
    .replace(/^-+/, '')
    .replace(/-+$/, '');
};

const generateSlug = (text) => {
  if (!text) return '';
  const transliterated = transliterate(text);
  return slugify(transliterated);
};

const sanitizeSlug = (slug) => {
  if (!slug) return '';
  return slug
    .toString()
    .replace(/[\r\n\t]+/g, '')
    .replace(/["'<>&,;:!?()[\]{}]/g, '')
    .replace(/\s+/g, '-')
    .replace(/--+/g, '-')
    .replace(/^-+/, '')
    .replace(/-+$/, '')
    .trim();
};

const escapeXmlUrl = (url) => {
  return url
    .replace(/&/g, '&amp;')
    .replace(/'/g, '&apos;')
    .replace(/"/g, '&quot;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');
};

// Dynamic relations extractor
function extractRelations(items) {
  if (!items || !items.length) {
    return { sants: [], books: [], ragas: [] };
  }

  const santsMap = {};
  const booksMap = {};
  const ragasMap = {};
  const biographies = [];

  // Pass 1: Gather biographies
  items.forEach(item => {
    if (item.category?.toLowerCase() === 'saint') {
      const title = item.title || '';
      const cleanName = title.replace(/\([^)]+\)/g, '').replace(/महाप्रभु/g, '').trim();
      const transliteratedName = transliterate(cleanName);
      biographies.push({
        name: cleanName,
        slug: item.slug || slugify(transliteratedName)
      });
    }
  });

  // Pass 2: Extract relations from verses
  items.forEach(item => {
    if (item.category?.toLowerCase() === 'saint') return;

    const title = item.title || '';
    let saintName = null;
    let bookName = null;

    const parts = title.split(/\s+-\s+/);
    if (parts.length >= 2) {
      const relationText = parts[1].trim();
      const verseMatch = relationText.match(/\(([^)]+)\)$/);
      const textWithoutVerse = verseMatch ? relationText.replace(/\(([^)]+)\)$/, '').trim() : relationText;
      const relParts = textWithoutVerse.split(/\s*,\s*/);
      
      if (relParts.length >= 2) {
        saintName = relParts[0].trim();
        bookName = relParts[1].trim();
      } else if (relParts.length === 1) {
        const val = relParts[0].trim();
        if (val.includes('वाणी') || val.includes('सागर') || val.includes('शतक') || val.includes('महिमामृत') || val.includes('दोहे') || val.includes('ग्रंथावली') || val.includes('पदावली') || val.includes('शत')) {
          bookName = val;
        } else {
          saintName = val;
        }
      }
    }

    if (!saintName && item.author && item.author !== 'Braj Rasik Heritage') {
      saintName = item.author;
    }

    // Extract Raga
    let ragaName = null;
    const ragaRegex = /(राग\s+[^\s,;()\-]+)/;
    const matchTitle = title.match(ragaRegex);
    const matchSanskrit = item.sanskrit_text?.match(ragaRegex);
    const matchHindi = item.hindi_text?.match(ragaRegex);
    
    if (matchTitle) ragaName = matchTitle[1];
    else if (matchSanskrit) ragaName = matchSanskrit[1];
    else if (matchHindi) ragaName = matchHindi[1];

    if (ragaName) {
      ragaName = ragaName.split(/[,]/)[0].trim();
    }

    if (saintName) {
      const cleanSantKey = saintName.replace(/जी की वाणी/g, '').replace(/जी/g, '').replace(/महाप्रभु/g, '').trim();
      const santSlug = slugify(transliterate(cleanSantKey));
      if (!santsMap[cleanSantKey]) {
        const matchedBio = biographies.find(bio => bio.name.includes(cleanSantKey) || cleanSantKey.includes(bio.name));
        santsMap[cleanSantKey] = {
          slug: matchedBio ? matchedBio.slug : santSlug
        };
      }
    }

    if (bookName) {
      const bookSlug = slugify(transliterate(bookName));
      if (!booksMap[bookName]) {
        booksMap[bookName] = { slug: bookSlug };
      }
    }

    if (ragaName) {
      const ragaSlug = slugify(transliterate(ragaName));
      if (!ragasMap[ragaName]) {
        ragasMap[ragaName] = { slug: ragaSlug };
      }
    }
  });

  return {
    sants: Object.values(santsMap),
    books: Object.values(booksMap),
    ragas: Object.values(ragasMap)
  };
}

const SEO_PAGES = [
  { path: '/', priority: '1.0', changefreq: 'daily' },
  { path: '/content', priority: '0.9', changefreq: 'daily' },
  { path: '/saints', priority: '0.9', changefreq: 'weekly' },
  { path: '/books', priority: '0.9', changefreq: 'weekly' },
  { path: '/ragas', priority: '0.9', changefreq: 'weekly' },
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
  { path: '/what-is-radha-snata', priority: '0.9', changefreq: 'weekly' },
  { path: '/nitya-vihar-vs-nikunj-vihar', priority: '0.9', changefreq: 'weekly' },
  { path: '/glossary', priority: '0.9', changefreq: 'weekly' },
  { path: '/places', priority: '0.9', changefreq: 'weekly' },
  { path: '/who-is-harirae-ji', priority: '0.9', changefreq: 'weekly' },
  { path: '/what-is-madhurya-and-sakhi-bhava', priority: '0.9', changefreq: 'weekly' },
  { path: '/radhavallabh-vs-gaudiya-sampradaya', priority: '0.9', changefreq: 'weekly' },
  { path: '/vrindavan-parikrama-guide', priority: '0.9', changefreq: 'weekly' },
  { path: '/history-of-radhavallabh-sampradaya', priority: '0.9', changefreq: 'weekly' },
  { path: '/major-rasik-saints-of-braj', priority: '0.9', changefreq: 'weekly' }
];

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
          `${SUPABASE_URL}/rest/v1/content?select=id,title,slug,category,author,hindi_text,sanskrit_text&order=id&offset=${offset}&limit=${PAGE_SIZE}`,
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

  // 3. Fallback: If both database fetches failed (e.g. sandboxed/offline), load from local backups
  if (allContentItems.length === 0) {
    console.log('⚠️ Both database fetches failed (offline/sandboxed). Loading from local backups...');
    try {
      const localFilePath = join(__dirname, '../../admin/data/brajrasik_hi_full.json');
      const localSaintsPath = join(__dirname, '../../admin/data/saints_formatted.json');
      
      if (fs.existsSync(localFilePath)) {
        console.log(`📡 Reading backup from ${localFilePath}...`);
        const fileContent = fs.readFileSync(localFilePath, 'utf8');
        const localData = JSON.parse(fileContent);
        console.log(`✅ Loaded ${localData.length} items from local backup.`);
        
        // Add id field if missing to keep database consistency
        const sanitizedData = localData.map((item, index) => ({
          id: item.id || `local-${index}`,
          ...item
        }));
        allContentItems = [...allContentItems, ...sanitizedData];
      }
      
      if (fs.existsSync(localSaintsPath)) {
        console.log(`📡 Reading saints backup from ${localSaintsPath}...`);
        const saintsContent = fs.readFileSync(localSaintsPath, 'utf8');
        const localSaints = JSON.parse(saintsContent);
        console.log(`✅ Loaded ${localSaints.length} saints from local backup.`);
        
        // Map category to 'saint' for relations extraction to identify them correctly
        const formattedSaints = localSaints.map((s, index) => ({
          id: s.id || `local-saint-${index}`,
          ...s,
          category: 'saint'
        }));
        allContentItems = [...allContentItems, ...formattedSaints];
      }
    } catch (fallbackError) {
      console.error('❌ Failed to load local backups:', fallbackError.message);
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

  // 4. Extract dynamic relations
  const { sants, books, ragas } = extractRelations(allContentItems);
  console.log(`👥 Extracted Relations: ${sants.length} Saints, ${books.length} Books, ${ragas.length} Ragas`);

  // 5. Generate XML — single-line <url> blocks to prevent whitespace corruption
  const staticUrls = SEO_PAGES.flatMap(page => [
    `  <url><loc>${DOMAIN}${page.path}</loc><lastmod>${today}</lastmod><changefreq>${page.changefreq}</changefreq><priority>${page.priority}</priority></url>`,
    `  <url><loc>${DOMAIN}/hi${page.path === '/' ? '' : page.path}</loc><lastmod>${today}</lastmod><changefreq>${page.changefreq}</changefreq><priority>${page.priority}</priority></url>`
  ]).join('\n');

  const catUrls = uniqueCategories.flatMap(cat => [
    `  <url><loc>${DOMAIN}/category/${cat}</loc><lastmod>${today}</lastmod><changefreq>weekly</changefreq><priority>0.8</priority></url>`,
    `  <url><loc>${DOMAIN}/hi/category/${cat}</loc><lastmod>${today}</lastmod><changefreq>weekly</changefreq><priority>0.8</priority></url>`
  ]).join('\n');

  const santUrls = sants.flatMap(s => {
    const escSlug = encodeURIComponent(decodeURIComponent(s.slug));
    return [
      `  <url><loc>${DOMAIN}/saint/${escSlug}</loc><lastmod>${today}</lastmod><changefreq>weekly</changefreq><priority>0.8</priority></url>`,
      `  <url><loc>${DOMAIN}/hi/saint/${escSlug}</loc><lastmod>${today}</lastmod><changefreq>weekly</changefreq><priority>0.8</priority></url>`
    ];
  }).join('\n');

  const bookUrls = books.flatMap(b => {
    const escSlug = encodeURIComponent(decodeURIComponent(b.slug));
    return [
      `  <url><loc>${DOMAIN}/book/${escSlug}</loc><lastmod>${today}</lastmod><changefreq>weekly</changefreq><priority>0.8</priority></url>`,
      `  <url><loc>${DOMAIN}/hi/book/${escSlug}</loc><lastmod>${today}</lastmod><changefreq>weekly</changefreq><priority>0.8</priority></url>`
    ];
  }).join('\n');

  const ragaUrls = ragas.flatMap(r => {
    const escSlug = encodeURIComponent(decodeURIComponent(r.slug));
    return [
      `  <url><loc>${DOMAIN}/raga/${escSlug}</loc><lastmod>${today}</lastmod><changefreq>weekly</changefreq><priority>0.8</priority></url>`,
      `  <url><loc>${DOMAIN}/hi/raga/${escSlug}</loc><lastmod>${today}</lastmod><changefreq>weekly</changefreq><priority>0.8</priority></url>`
    ];
  }).join('\n');

  const glossaryUrls = GLOSSARY_TERMS.flatMap(term => {
    const escSlug = encodeURIComponent(decodeURIComponent(term.slug));
    return [
      `  <url><loc>${DOMAIN}/glossary/${escSlug}</loc><lastmod>${today}</lastmod><changefreq>weekly</changefreq><priority>0.8</priority></url>`,
      `  <url><loc>${DOMAIN}/hi/glossary/${escSlug}</loc><lastmod>${today}</lastmod><changefreq>weekly</changefreq><priority>0.8</priority></url>`
    ];
  }).join('\n');

  const seenSlugs = new Set();
  const contentUrls = allContentItems
    .flatMap(item => {
      const rawSlug = item.slug || generateSlug(item.title);
      const slug = sanitizeSlug(rawSlug);
      if (!slug) return [];
      
      const normalizedSlug = slug.toLowerCase();
      if (seenSlugs.has(normalizedSlug)) return [];
      seenSlugs.add(normalizedSlug);
      
      const encodedSlug = encodeURIComponent(decodeURIComponent(slug));
      const defaultUrl = escapeXmlUrl(`${DOMAIN}/content/${encodedSlug}`);
      const hiUrl = escapeXmlUrl(`${DOMAIN}/hi/content/${encodedSlug}`);
      return [
        `  <url><loc>${defaultUrl}</loc><lastmod>${today}</lastmod><changefreq>daily</changefreq><priority>0.8</priority></url>`,
        `  <url><loc>${hiUrl}</loc><lastmod>${today}</lastmod><changefreq>daily</changefreq><priority>0.8</priority></url>`
      ];
    })
    .filter(Boolean)
    .join('\n');

  console.log(`📊 Deduplicated content: ${allContentItems.length} items → ${seenSlugs.size} unique URLs`);

  const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${staticUrls}
${catUrls}
${santUrls}
${bookUrls}
${ragaUrls}
${glossaryUrls}
${contentUrls}
</urlset>`;

  // If we are building on Vercel, do NOT output a static sitemap in the build folder
  // so that Vercel is forced to route /sitemap.xml to the dynamic serverless function /api/sitemap.
  if (process.env.VERCEL) {
    console.log('⚡ Vercel build environment detected. Deleting static build sitemaps to ensure dynamic sitemap rewrite routing is active.');
    try {
      const buildSitemapPath = join(__dirname, '../build/sitemap.xml');
      if (fs.existsSync(buildSitemapPath)) {
        fs.unlinkSync(buildSitemapPath);
        console.log('🗑️ Deleted build/sitemap.xml');
      }
      const publicSitemapPath = join(__dirname, '../public/sitemap.xml');
      if (fs.existsSync(publicSitemapPath)) {
        fs.unlinkSync(publicSitemapPath);
        console.log('🗑️ Deleted public/sitemap.xml');
      }
    } catch (e) {
      console.warn('⚠️ Non-critical failure cleaning build sitemaps:', e.message);
    }
  } else {
    try {
      if (!fs.existsSync('public')) {
        fs.mkdirSync('public');
      }

      fs.writeFileSync('public/sitemap.xml', sitemap);
      
      // Also write directly to build/ if it exists (useful for local production builds for static sites)
      if (fs.existsSync('build')) {
        fs.writeFileSync('build/sitemap.xml', sitemap);
        console.log('✅ sitemap.xml written to build/');
      }
      
      const totalUrls = SEO_PAGES.length * 2 + uniqueCategories.length * 2 + (sants.length + books.length + ragas.length + GLOSSARY_TERMS.length) * 2 + seenSlugs.size * 2;
      console.log(`✅ sitemap.xml generated in public/ with approx ${totalUrls} URLs`);

    } catch (err) {
      console.error('❌ Error writing sitemap file:', err.message);
    }
  }
}

generateSitemap();
