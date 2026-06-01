

const SUPABASE_URL = process.env.REACT_APP_SUPABASE_URL || 'https://tilimltxgeucefxzerqi.supabase.co';
const SUPABASE_KEY = process.env.REACT_APP_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpbGltbHR4Z2V1Y2VmeHplcnFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2MjQyNTQsImV4cCI6MjA4MzIwMDI1NH0.lwaCJyTRW6jNsfQJ32R_wAwp11yj6bvsJ4fzC0EX_00';
const DOMAIN = 'https://path.vrindopnishad.in';
const { GLOSSARY_TERMS } = require('./glossaryTerms');


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


function extractRelations(items) {
  if (!items || !items.length) {
    return { sants: [], books: [], ragas: [] };
  }

  const santsMap = {};
  const booksMap = {};
  const ragasMap = {};
  const biographies = [];

  
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
  { path: '/major-rasik-saints-of-braj', priority: '0.9', changefreq: 'weekly' },
  { path: '/about', priority: '0.8', changefreq: 'monthly' },
  { path: '/editorial-policy', priority: '0.8', changefreq: 'monthly' },
  { path: '/sources', priority: '0.8', changefreq: 'monthly' },
  { path: '/contact', priority: '0.8', changefreq: 'monthly' },
  { path: '/search', priority: '0.7', changefreq: 'weekly' },
  { path: '/granthas', priority: '0.9', changefreq: 'weekly' }
];

export default async function handler(req, res) {
  const today = new Date().toISOString().split('T')[0];
  let contentItems = [];

  
  try {
    const PAGE_SIZE = 1000;
    let offset = 0;
    let hasMore = true;

    while (hasMore) {
      const response = await fetch(
        `${SUPABASE_URL}/rest/v1/content?select=id,title,slug,category,author,hindi_text,sanskrit_text&order=id&offset=${offset}&limit=${PAGE_SIZE}`,
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

  if (contentItems.length === 0) {
    console.log('⚠️ Both database fetches failed (offline/sandboxed). Loading from local backups...');
    try {
      const fs = require('fs');
      const path = require('path');
      let localFilePath = path.join(process.cwd(), 'data/brajrasik_hi_full.json');
      let localSaintsPath = path.join(process.cwd(), 'data/saints_formatted.json');
      
      if (!fs.existsSync(localFilePath)) {
        localFilePath = path.join(process.cwd(), 'frontend/data/brajrasik_hi_full.json');
        localSaintsPath = path.join(process.cwd(), 'frontend/data/saints_formatted.json');
      }
      if (!fs.existsSync(localFilePath)) {
        localFilePath = path.join(process.cwd(), 'admin/data/brajrasik_hi_full.json');
        localSaintsPath = path.join(process.cwd(), 'admin/data/saints_formatted.json');
      }

      if (fs.existsSync(localFilePath)) {
        console.log(`📡 Reading backup from ${localFilePath}...`);
        const fileContent = fs.readFileSync(localFilePath, 'utf8');
        const localData = JSON.parse(fileContent);
        console.log(`✅ Loaded ${localData.length} items from local backup.`);
        
        const sanitizedData = localData.map((item, index) => ({
          id: item.id || `local-${index}`,
          ...item
        }));
        contentItems = contentItems.concat(sanitizedData);
      }
      
      if (fs.existsSync(localSaintsPath)) {
        console.log(`📡 Reading saints backup from ${localSaintsPath}...`);
        const saintsContent = fs.readFileSync(localSaintsPath, 'utf8');
        const localSaints = JSON.parse(saintsContent);
        console.log(`✅ Loaded ${localSaints.length} saints from local backup.`);
        
        const formattedSaints = localSaints.map((s, index) => ({
          id: s.id || `local-saint-${index}`,
          ...s,
          category: 'saint'
        }));
        contentItems = contentItems.concat(formattedSaints);
      }
    } catch (fallbackError) {
      console.error('❌ Failed to load local backups in sitemap handler:', fallbackError.message);
    }
  }

  
  const categoriesSet = new Set();
  const categories = [];
  contentItems.forEach(i => {
    if (i.category) {
      const formatted = i.category.toString().toLowerCase().trim().replace(/\s+/g, '-');
      if (formatted && !categoriesSet.has(formatted)) {
        categoriesSet.add(formatted);
        categories.push(formatted);
      }
    }
  });

  
  const { sants, books, ragas } = extractRelations(contentItems);

  
  const staticUrls = SEO_PAGES.flatMap(p => {
    const enPath = p.path;
    const hiPath = '/hi' + (p.path === '/' ? '' : p.path);
    return [
      `  <url>\n    <loc>${DOMAIN}${enPath}</loc>\n    <xhtml:link rel="alternate" hreflang="en" href="${DOMAIN}${enPath}"/>\n    <xhtml:link rel="alternate" hreflang="hi" href="${DOMAIN}${hiPath}"/>\n    <xhtml:link rel="alternate" hreflang="x-default" href="${DOMAIN}${enPath}"/>\n    <lastmod>${today}</lastmod><changefreq>${p.changefreq}</changefreq><priority>${p.priority}</priority>\n  </url>`,
      `  <url>\n    <loc>${DOMAIN}${hiPath}</loc>\n    <xhtml:link rel="alternate" hreflang="en" href="${DOMAIN}${enPath}"/>\n    <xhtml:link rel="alternate" hreflang="hi" href="${DOMAIN}${hiPath}"/>\n    <xhtml:link rel="alternate" hreflang="x-default" href="${DOMAIN}${enPath}"/>\n    <lastmod>${today}</lastmod><changefreq>${p.changefreq}</changefreq><priority>${p.priority}</priority>\n  </url>`
    ];
  }).join('\n');

  const catUrls = categories.flatMap(cat => [
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
    const enUrl = escapeXmlUrl(`${DOMAIN}/glossary/${escSlug}`);
    const hiUrl = escapeXmlUrl(`${DOMAIN}/hi/glossary/${escSlug}`);
    return [
      `  <url>\n    <loc>${enUrl}</loc>\n    <xhtml:link rel="alternate" hreflang="en" href="${enUrl}"/>\n    <xhtml:link rel="alternate" hreflang="hi" href="${hiUrl}"/>\n    <xhtml:link rel="alternate" hreflang="x-default" href="${enUrl}"/>\n    <lastmod>${today}</lastmod><changefreq>weekly</changefreq><priority>0.8</priority>\n  </url>`,
      `  <url>\n    <loc>${hiUrl}</loc>\n    <xhtml:link rel="alternate" hreflang="en" href="${enUrl}"/>\n    <xhtml:link rel="alternate" hreflang="hi" href="${hiUrl}"/>\n    <xhtml:link rel="alternate" hreflang="x-default" href="${enUrl}"/>\n    <lastmod>${today}</lastmod><changefreq>weekly</changefreq><priority>0.8</priority>\n  </url>`
    ];
  }).join('\n');

  const seenSlugs = new Set();
  const contentUrls = contentItems
    .flatMap(item => {
      const rawSlug = item.slug || generateSlug(item.title);
      const slug = sanitizeSlug(rawSlug);
      if (!slug) return [];
      
      const normalizedSlug = slug.toLowerCase();
      if (seenSlugs.has(normalizedSlug)) return [];
      seenSlugs.add(normalizedSlug);
      
      const encodedSlug = encodeURIComponent(decodeURIComponent(slug));
      const enUrl = escapeXmlUrl(`${DOMAIN}/content/${encodedSlug}`);
      const hiUrl = escapeXmlUrl(`${DOMAIN}/hi/content/${encodedSlug}`);
      return [
        `  <url>\n    <loc>${enUrl}</loc>\n    <xhtml:link rel="alternate" hreflang="en" href="${enUrl}"/>\n    <xhtml:link rel="alternate" hreflang="hi" href="${hiUrl}"/>\n    <xhtml:link rel="alternate" hreflang="x-default" href="${enUrl}"/>\n    <lastmod>${today}</lastmod><changefreq>daily</changefreq><priority>0.8</priority>\n  </url>`,
        `  <url>\n    <loc>${hiUrl}</loc>\n    <xhtml:link rel="alternate" hreflang="en" href="${enUrl}"/>\n    <xhtml:link rel="alternate" hreflang="hi" href="${hiUrl}"/>\n    <xhtml:link rel="alternate" hreflang="x-default" href="${enUrl}"/>\n    <lastmod>${today}</lastmod><changefreq>daily</changefreq><priority>0.8</priority>\n  </url>`
      ];
    })
    .filter(Boolean)
    .join('\n');

  const sub = req.query.sub;
  let xml = '';

  if (!sub) {
    xml = `<?xml version="1.0" encoding="UTF-8"?>
<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <sitemap>
    <loc>${DOMAIN}/sitemaps/content.xml</loc>
    <lastmod>${today}</lastmod>
  </sitemap>
  <sitemap>
    <loc>${DOMAIN}/sitemaps/saints.xml</loc>
    <lastmod>${today}</lastmod>
  </sitemap>
  <sitemap>
    <loc>${DOMAIN}/sitemaps/granthas.xml</loc>
    <lastmod>${today}</lastmod>
  </sitemap>
  <sitemap>
    <loc>${DOMAIN}/sitemaps/teachings.xml</loc>
    <lastmod>${today}</lastmod>
  </sitemap>
</sitemapindex>`;
    res.setHeader('Content-Type', 'application/xml; charset=utf-8');
    res.setHeader('Cache-Control', 'public, s-maxage=3600, stale-while-revalidate=86400');
    res.status(200).send(xml);
    return;
  }

  let urls = '';
  if (sub === 'saints') {
    urls = santUrls;
  } else if (sub === 'granthas') {
    urls = `${bookUrls}\n${ragaUrls}\n${catUrls}`;
  } else if (sub === 'teachings') {
    urls = `${staticUrls}\n${glossaryUrls}`;
  } else if (sub === 'content') {
    urls = contentUrls;
  } else {
    res.status(404).send('Sitemap not found');
    return;
  }

  xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:xhtml="http://www.w3.org/1999/xhtml">
${urls}
</urlset>`;

  res.setHeader('Content-Type', 'application/xml; charset=utf-8');
  res.setHeader('Cache-Control', 'public, s-maxage=3600, stale-while-revalidate=86400');
  res.status(200).send(xml);
}
