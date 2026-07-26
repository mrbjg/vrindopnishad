#!/usr/bin/env node
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const dataDir = path.join(__dirname, '../data');
const publicDataDir = path.join(__dirname, '../public/data');
const dbPath = path.join(dataDir, 'vrindavaani_content.json');
const saintsPath = path.join(dataDir, 'saints_formatted.json');
const relationsPath = path.join(publicDataDir, 'relations_backup.json');

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
const Consonants = new Set(['क', 'ख', 'ग', 'घ', 'ङ', 'च', 'छ', 'ज', 'झ', 'ञ', 'ट', 'ठ', 'ड', 'ढ', 'ण', 'त', 'थ', 'द', 'ध', 'न', 'प', 'फ', 'ब', 'भ', 'म', 'य', 'र', 'ल', 'व', 'श', 'ष', 'स', 'ह', 'ळ', 'क्ष', 'त्र', 'ज्ञ', 'क़', 'ख़', 'ग़', 'ज़', 'फ़', 'ड़', 'ढ़']);
const Matras = new Set(['ा', 'ि', 'ी', 'ु', 'ू', 'ृ', 'े', 'ै', 'ो', 'ौ', 'ं', 'ः', 'ँ', 'ॅ', 'ॉ']);

function transliterate(text) {
  if (!text) return '';
  let result = '';
  const chars = Array.from(text);
  for (let i = 0; i < chars.length; i++) {
    const char = chars[i];
    const nextChar = chars[i + 1] || '';
    const nuqtaCombo = char + nextChar;
    if (DevanagariToHinglishMap[nuqtaCombo] !== undefined) {
      result += DevanagariToHinglishMap[nuqtaCombo];
      i++;
      continue;
    }
    if (char === '्') {
      if (result.endsWith('a')) result = result.substring(0, result.length - 1);
      continue;
    }
    const mapped = DevanagariToHinglishMap[char];
    if (mapped !== undefined) {
      result += mapped;
      if (Consonants.has(char)) {
        const nextHasMatra = Matras.has(nextChar);
        const nextIsHalant = nextChar === '्';
        const nextIsWordBoundary = nextChar === ' ' || nextChar === '\n' || nextChar === '\t' || nextChar === '।' || nextChar === '॥' || nextChar === ',' || nextChar === '.' || nextChar === '?' || nextChar === '!' || nextChar === '"' || nextChar === '\'' || nextChar === '';
        if (nextHasMatra || nextIsHalant || nextIsWordBoundary) {
          if (result.endsWith('a')) result = result.substring(0, result.length - 1);
        }
      }
    } else {
      result += char;
    }
  }
  return result.replace(/aa/g, 'a').replace(/ee/g, 'i').replace(/oo/g, 'u').replace(/\s+/g, ' ').trim();
}

function slugify(text) {
  if (!text) return '';
  return text.toString().toLowerCase().trim().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '').replace(/--+/g, '-').replace(/^-+/, '').replace(/-+$/, '');
}

function generateSlug(text) {
  return slugify(transliterate(text));
}

function safeDate(input) {
  if (!input) return '2026-06-27';
  try {
    const d = new Date(input);
    if (isNaN(d.getTime())) return '2026-06-27';
    return d.toISOString().split('T')[0];
  } catch (e) {
    return '2026-06-27';
  }
}

export function generateSitemapManifest() {
  console.log('[build-sitemap-manifest] Generating complete sitemap_manifest.json...');
  
  let rawContent = [];
  if (fs.existsSync(dbPath)) {
    rawContent = JSON.parse(fs.readFileSync(dbPath, 'utf8'));
  }
  
  const contentSlugs = [];
  const seenContent = new Set();

  for (const item of rawContent) {
    const cat = (item.category || '').toLowerCase();
    if (cat === 'saint') continue;
    let slug = item.slug;
    if (!slug || slug.startsWith('untitled')) {
      slug = generateSlug(item.title);
    }
    if (!slug) slug = item.id;
    if (!slug || seenContent.has(slug)) continue;
    seenContent.add(slug);
    const lastmod = safeDate(item.updated_at || item.updatedAt || item.created_at || item.createdAt);
    contentSlugs.push([slug, lastmod]);
  }

  const saintsSet = new Set();
  const saintsList = [];

  // Load from saints_formatted.json
  if (fs.existsSync(saintsPath)) {
    const rawSaints = JSON.parse(fs.readFileSync(saintsPath, 'utf8'));
    rawSaints.forEach(s => {
      const nameVal = s.name || s.title || '';
      const saintSlug = s.slug || generateSlug(nameVal);
      if (saintSlug && !saintsSet.has(saintSlug)) {
        saintsSet.add(saintSlug);
        saintsList.push([saintSlug, '2026-06-27']);
      }
    });
  }

  let granthas = [];
  let ragas = [];

  const summaryPath = path.join(dataDir, 'relations_summary.json');
  const relPath = fs.existsSync(relationsPath) ? relationsPath : (fs.existsSync(summaryPath) ? summaryPath : null);

  if (relPath) {
    const rel = JSON.parse(fs.readFileSync(relPath, 'utf8'));
    if (rel.sants && Array.isArray(rel.sants)) {
      rel.sants.forEach(s => {
        if (s.slug && !saintsSet.has(s.slug)) {
          saintsSet.add(s.slug);
          saintsList.push([s.slug, '2026-06-27']);
        }
      });
    }
    if (rel.books && Array.isArray(rel.books)) {
      const granthaSet = new Set();
      granthas = rel.books.map(b => {
        if (!b.slug || granthaSet.has(b.slug)) return null;
        granthaSet.add(b.slug);
        return [b.slug, '2026-06-27'];
      }).filter(Boolean);
    }
    if (rel.ragas && Array.isArray(rel.ragas)) {
      const ragaSet = new Set();
      ragas = rel.ragas.map(r => {
        if (!r.slug || ragaSet.has(r.slug)) return null;
        ragaSet.add(r.slug);
        return [r.slug, '2026-06-27'];
      }).filter(Boolean);
    }
  }

  const manifest = {
    content: contentSlugs,
    saints: saintsList,
    granthas: granthas,
    ragas: ragas
  };

  if (!fs.existsSync(dataDir)) {
    fs.mkdirSync(dataDir, { recursive: true });
  }
  if (!fs.existsSync(publicDataDir)) {
    fs.mkdirSync(publicDataDir, { recursive: true });
  }

  const manifestPath = path.join(dataDir, 'sitemap_manifest.json');
  fs.writeFileSync(manifestPath, JSON.stringify(manifest), 'utf8');

  const publicManifestPath = path.join(publicDataDir, 'sitemap_manifest.json');
  fs.writeFileSync(publicManifestPath, JSON.stringify(manifest), 'utf8');

  const sizeKB = (fs.statSync(manifestPath).size / 1024).toFixed(1);
  console.log(`[build-sitemap-manifest] ✅ Saved complete sitemap_manifest.json (${sizeKB} KB)`);
  console.log(`  Verses: ${contentSlugs.length}, Saints: ${saintsList.length}, Granthas: ${granthas.length}, Ragas: ${ragas.length}`);

  // --- Generate Static XML Sitemap Files for Google Search Console ---
  const publicSitemapsDir = path.join(__dirname, '../public/sitemaps');
  if (!fs.existsSync(publicSitemapsDir)) {
    fs.mkdirSync(publicSitemapsDir, { recursive: true });
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

  function safeEncodeSlug(rawSlug) {
    if (!rawSlug) return '';
    try {
      return encodeURIComponent(decodeURIComponent(rawSlug));
    } catch (e) {
      return encodeURIComponent(rawSlug);
    }
  }

  const base = 'https://path.vrindopnishad.in';
  const today = new Date().toISOString().split('T')[0];

  function buildUrlSet(items) {
    const urls = items.map(item => `  <url>
    <loc>${escapeXml(item.loc)}</loc>
    <lastmod>${escapeXml(item.lastmod || today)}</lastmod>
    <changefreq>${escapeXml(item.changefreq || 'weekly')}</changefreq>
    <priority>${escapeXml(item.priority || '0.8')}</priority>
  </url>`).join('\n');

    return `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls}
</urlset>`.trim();
  }

  // 1. Pages sitemap
  const pagesItems = [
    { loc: `${base}`, priority: '1.0', changefreq: 'daily', lastmod: today },
    { loc: `${base}/hi`, priority: '1.0', changefreq: 'daily', lastmod: today },
    { loc: `${base}/lyrics`, priority: '0.9', changefreq: 'daily', lastmod: today },
    { loc: `${base}/hi/lyrics`, priority: '0.9', changefreq: 'daily', lastmod: today },
    { loc: `${base}/saints`, priority: '0.9', changefreq: 'daily', lastmod: today },
    { loc: `${base}/hi/saints`, priority: '0.9', changefreq: 'daily', lastmod: today },
    { loc: `${base}/granthas`, priority: '0.9', changefreq: 'daily', lastmod: today },
    { loc: `${base}/hi/granthas`, priority: '0.9', changefreq: 'daily', lastmod: today },
    { loc: `${base}/ragas`, priority: '0.8', changefreq: 'daily', lastmod: today },
    { loc: `${base}/hi/ragas`, priority: '0.8', changefreq: 'daily', lastmod: today },
    { loc: `${base}/knowledge-base`, priority: '0.8', changefreq: 'weekly', lastmod: today },
    { loc: `${base}/hi/knowledge-base`, priority: '0.8', changefreq: 'weekly', lastmod: today }
  ];
  fs.writeFileSync(path.join(publicSitemapsDir, 'pages.xml'), buildUrlSet(pagesItems), 'utf8');

  // 2. Saints sitemap
  const saintItems = [];
  saintsList.forEach(s => {
    const slug = safeEncodeSlug(Array.isArray(s) ? s[0] : s.slug);
    const date = Array.isArray(s) ? s[1] : s.lastmod;
    if (!slug) return;
    saintItems.push({ loc: `${base}/saints/${slug}`, priority: '0.9', lastmod: date });
    saintItems.push({ loc: `${base}/hi/saints/${slug}`, priority: '0.9', lastmod: date });
  });
  fs.writeFileSync(path.join(publicSitemapsDir, 'saints.xml'), buildUrlSet(saintItems), 'utf8');

  // 3. Granthas sitemap
  const granthaItems = [];
  granthas.forEach(b => {
    const slug = safeEncodeSlug(Array.isArray(b) ? b[0] : b.slug);
    const date = Array.isArray(b) ? b[1] : b.lastmod;
    if (!slug) return;
    granthaItems.push({ loc: `${base}/granthas/${slug}`, priority: '0.8', lastmod: date });
    granthaItems.push({ loc: `${base}/hi/granthas/${slug}`, priority: '0.8', lastmod: date });
  });
  fs.writeFileSync(path.join(publicSitemapsDir, 'granthas.xml'), buildUrlSet(granthaItems), 'utf8');

  // 4. Ragas sitemap
  const ragaItems = [];
  ragas.forEach(r => {
    const slug = safeEncodeSlug(Array.isArray(r) ? r[0] : r.slug);
    const date = Array.isArray(r) ? r[1] : r.lastmod;
    if (!slug) return;
    ragaItems.push({ loc: `${base}/ragas/${slug}`, priority: '0.8', lastmod: date });
    ragaItems.push({ loc: `${base}/hi/ragas/${slug}`, priority: '0.8', lastmod: date });
  });
  fs.writeFileSync(path.join(publicSitemapsDir, 'ragas.xml'), buildUrlSet(ragaItems), 'utf8');

  // 5. Content sitemaps (chunked)
  const CHUNK_SIZE = 3500;
  const totalChunks = Math.max(1, Math.ceil(contentSlugs.length / CHUNK_SIZE));
  const sitemapListForIndex = [];

  sitemapListForIndex.push(`${base}/sitemaps/pages.xml`);

  for (let c = 0; c < totalChunks; c++) {
    const chunkSlugs = contentSlugs.slice(c * CHUNK_SIZE, (c + 1) * CHUNK_SIZE);
    const cItems = [];
    chunkSlugs.forEach(v => {
      const slug = safeEncodeSlug(Array.isArray(v) ? v[0] : v.slug);
      const date = Array.isArray(v) ? v[1] : v.lastmod;
      if (!slug) return;
      cItems.push({ loc: `${base}/lyrics/${slug}`, priority: '0.8', lastmod: date });
      cItems.push({ loc: `${base}/hi/lyrics/${slug}`, priority: '0.8', lastmod: date });
    });
    const fileName = `content-${c + 1}.xml`;
    const xmlContent = buildUrlSet(cItems);
    fs.writeFileSync(path.join(publicSitemapsDir, fileName), xmlContent, 'utf8');
    sitemapListForIndex.push(`${base}/sitemaps/${fileName}`);

    // Create legacy content.xml alias for content-1.xml so GSC's old /sitemaps/content.xml entry succeeds 100%
    if (c === 0) {
      fs.writeFileSync(path.join(publicSitemapsDir, 'content.xml'), xmlContent, 'utf8');
      sitemapListForIndex.push(`${base}/sitemaps/content.xml`);
    }
  }

  sitemapListForIndex.push(`${base}/sitemaps/saints.xml`);
  sitemapListForIndex.push(`${base}/sitemaps/granthas.xml`);
  sitemapListForIndex.push(`${base}/sitemaps/ragas.xml`);

  // 6. Master sitemap.xml index file
  const indexSitemaps = sitemapListForIndex.map(url => `  <sitemap>
    <loc>${escapeXml(url)}</loc>
    <lastmod>${today}</lastmod>
  </sitemap>`).join('\n');

  const masterSitemapXml = `<?xml version="1.0" encoding="UTF-8"?>
<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${indexSitemaps}
</sitemapindex>`.trim();

  const publicSitemapXmlPath = path.join(__dirname, '../public/sitemap.xml');
  fs.writeFileSync(publicSitemapXmlPath, masterSitemapXml, 'utf8');

  console.log(`[build-sitemap-manifest] ✅ Successfully generated static XML sitemaps in public/sitemaps/ & public/sitemap.xml!`);

  return manifest;
}

if (process.argv[1] && process.argv[1].endsWith('build-sitemap-manifest.mjs')) {
  generateSitemapManifest();
}
