#!/usr/bin/env node
/**
 * add_citations.mjs
 * Fetches the BrajRasik.org content sitemap, extracts all article URLs,
 * and maps them to our local JSON database records by slug to provide official citations.
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const dataDir = path.join(__dirname, '../data');
const publicDataDir = path.join(__dirname, '../public/data');

const dbPath = path.join(dataDir, 'vrindavaani_content.json');
const saintsPath = path.join(dataDir, 'saints_formatted.json');

// Devanagari to Hinglish transliteration helpers (to generate slugs for fallback)
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
        const nextIsWordBoundary = nextChar === ' ' || nextChar === '\n' || nextChar === '\t' ||
          nextChar === '।' || nextChar === '॥' || nextChar === ',' ||
          nextChar === '.' || nextChar === '?' || nextChar === '!' ||
          nextChar === '\"' || nextChar === '\'' || nextChar === '';
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
  return text.toString().toLowerCase().trim()
    .replace(/\s+/g, '-')
    .replace(/[^a-z0-9-]/g, '')
    .replace(/--+/g, '-')
    .replace(/^-+/, '')
    .replace(/-+$/, '');
}

function generateSlug(text) {
  return slugify(transliterate(text));
}

function classifyItemCategory(item) {
  if (!item) return 'poem';
  const rawCat = (item.category || '').toLowerCase().trim();

  if (rawCat === 'saint' || rawCat === 'dham') {
    return rawCat;
  }

  if (rawCat === 'strotra' || rawCat === 'strotras' || rawCat === 'stotra' || rawCat === 'stotras') {
    return 'strotra';
  }
  if (rawCat === 'poem' || rawCat === 'poems' || rawCat === 'poetry') {
    return 'poem';
  }

  const title = (item.title || '').toLowerCase();
  const sanskrit = (item.sanskrit_text || '').toLowerCase();

  if (
    title.includes('स्तोत्र') || title.includes('strotra') || title.includes('stotra') ||
    title.includes('शतक') || title.includes('shatak') ||
    title.includes('अष्टक') || title.includes('ashtak') ||
    title.includes('महिमामृत') || title.includes('mahimamrit') ||
    title.includes('सुधानिधि') || title.includes('sudhanidhi') ||
    title.includes('सहस्रनाम') || title.includes('sahasranam') ||
    sanskrit.includes('स्तोत्र') || sanskrit.includes('strotra') || sanskrit.includes('stotra')
  ) {
    return 'strotra';
  }

  const hasSanskritText = sanskrit.trim().length > 10 &&
    (sanskrit.includes('॥') || sanskrit.includes('।') || sanskrit.includes('ॐ') || !/[a-z]{5,}/.test(sanskrit));

  const isScriptureBook = title.includes('gita') || title.includes('गीता') ||
    title.includes('upnishad') || title.includes('उपनिषद') ||
    title.includes('samhita') || title.includes('संहिता') ||
    title.includes('purana') || title.includes('पुराण') ||
    title.includes('shloka') || title.includes('श्लोक');

  if (isScriptureBook || hasSanskritText || rawCat === 'shloka' || rawCat === 'shlokas') {
    return 'shloka';
  }

  return 'poem';
}

async function addCitations() {
  console.log('🔄 Fetching sitemap from BrajRasik.org...');
  try {
    const res = await fetch('https://www.brajrasik.org/sitemaps/content.xml');
    if (!res.ok) {
      throw new Error(`HTTP error! status: ${res.status}`);
    }
    const sitemapXml = await res.text();
    
    // Parse URLs and build a map: slug -> english_url
    const locRegex = /<loc>(.*?)<\/loc>/g;
    const urlMap = {};
    let match;
    while ((match = locRegex.exec(sitemapXml)) !== null) {
      const url = match[1].trim();
      const parts = url.split('/');
      const slug = parts[parts.length - 1].toLowerCase().trim();
      
      // Clean up to standard English URL base
      let cleanUrl = url;
      if (url.includes('/hi/')) {
        cleanUrl = url.replace('/hi/articles/', '/articles/');
      }
      urlMap[slug] = cleanUrl;
    }
    console.log(`✅ Loaded ${Object.keys(urlMap).length} unique slugs from sitemap.`);

    // Load main local DB
    if (!fs.existsSync(dbPath)) {
      console.error(`❌ Database file not found at: ${dbPath}`);
      process.exit(1);
    }
    const data = JSON.parse(fs.readFileSync(dbPath, 'utf8'));
    console.log(`Loaded ${data.length} items from main DB.`);

    let matchedCount = 0;
    const updatedData = data.map(item => {
      const slug = item.slug ? item.slug.trim().toLowerCase() : generateSlug(item.title);
      let referenceUrl = "";
      if (urlMap[slug]) {
        referenceUrl = urlMap[slug];
        matchedCount++;
      }
      return {
        ...item,
        reference_url: referenceUrl
      };
    });

    console.log(`✅ Reference URLs added successfully. Matched: ${matchedCount} / ${data.length}`);

    // Save to main DB
    fs.writeFileSync(dbPath, JSON.stringify(updatedData, null, 2), 'utf8');
    console.log(`💾 Saved updated DB to: ${dbPath}`);

    // Save to backup file
    const backupPath = path.join(publicDataDir, 'content_backup.json');
    fs.writeFileSync(backupPath, JSON.stringify(updatedData, null, 2), 'utf8');
    console.log(`💾 Saved updated backup to: ${backupPath}`);

    // Split category backup files
    const categories = ['shloka', 'strotra', 'poem', 'dham'];
    categories.forEach(cat => {
      const catFile = path.join(publicDataDir, `content_backup_${cat}.json`);
      const catVerses = updatedData.filter(v => classifyItemCategory(v) === cat);
      fs.writeFileSync(catFile, JSON.stringify(catVerses, null, 2), 'utf8');
      console.log(`💾 Saved updated split (${cat}) with ${catVerses.length} items to: ${catFile}`);
    });

    console.log('🎉 Citation mapping complete!');
  } catch (err) {
    console.error('❌ Citation addition failed:', err.message);
  }
}

addCitations();
