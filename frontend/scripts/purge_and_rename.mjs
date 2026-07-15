#!/usr/bin/env node
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const dataDir = path.join(__dirname, '../data');
const dbPath = path.join(dataDir, 'vrindavaani_content.json');

// Devanagari to Hinglish transliteration helpers
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

function main() {
  if (!fs.existsSync(dbPath)) {
    console.error(`❌ DB file not found: ${dbPath}`);
    process.exit(1);
  }

  const data = JSON.parse(fs.readFileSync(dbPath, 'utf8'));
  console.log(`Loaded ${data.length} items from main DB.`);

  const seenSlugs = new Set();
  let updatedCount = 0;
  let collisionCount = 0;

  const cleanedData = data.map(item => {
    // 1. Purge references to BrajRasik.org
    item.reference_url = "";
    item.english_text = "";
    item.english_translation = "";
    item.description = "";

    // 2. Regenerate slug
    let baseSlug = generateSlug(item.title);
    if (!baseSlug) {
      baseSlug = `item-${item.id.substring(0, 8)}`;
    }
    
    // Ensure uniqueness
    let slug = baseSlug;
    let counter = 1;
    while (seenSlugs.has(slug)) {
      counter++;
      slug = `${baseSlug}-${counter}`;
      collisionCount++;
    }
    seenSlugs.add(slug);
    item.slug = slug;
    updatedCount++;

    return item;
  });

  console.log(`Processed ${updatedCount} items.`);
  console.log(`Encountered and resolved ${collisionCount} slug collisions.`);

  fs.writeFileSync(dbPath, JSON.stringify(cleanedData, null, 2), 'utf8');
  console.log(`✅ Saved purged database back to ${dbPath}`);
}

main();
