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
  console.log('[build-sitemap-manifest] Generating sitemap_manifest.json...');
  
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

  let saintsList = [];
  if (fs.existsSync(saintsPath)) {
    const rawSaints = JSON.parse(fs.readFileSync(saintsPath, 'utf8'));
    saintsList = rawSaints.map(s => {
      const nameVal = s.name || s.title || '';
      const saintSlug = s.slug || generateSlug(nameVal);
      return [saintSlug, '2026-06-27'];
    }).filter(s => s[0]);
  }

  let granthas = [];
  let ragas = [];
  if (fs.existsSync(relationsPath)) {
    const rel = JSON.parse(fs.readFileSync(relationsPath, 'utf8'));
    if (rel.books) granthas = rel.books.map(b => [b.slug, '2026-06-27']).filter(b => b[0]);
    if (rel.ragas) ragas = rel.ragas.map(r => [r.slug, '2026-06-27']).filter(r => r[0]);
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
  console.log(`[build-sitemap-manifest] ✅ Saved sitemap_manifest.json (${sizeKB} KB)`);
  console.log(`  Verses: ${contentSlugs.length}, Saints: ${saintsList.length}, Granthas: ${granthas.length}, Ragas: ${ragas.length}`);
  
  return manifest;
}

if (process.argv[1] && process.argv[1].endsWith('build-sitemap-manifest.mjs')) {
  generateSitemapManifest();
}
