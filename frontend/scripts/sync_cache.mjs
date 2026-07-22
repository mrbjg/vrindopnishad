#!/usr/bin/env node
/**
 * sync_cache.mjs
 * Regenerates processed_cache.json, public/data backups, category splits,
 * and relations_backup.json from vrindavaani_content.json + saints_formatted.json
 * Run this after ANY modification to the main database file.
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { generateSitemapManifest } from './build-sitemap-manifest.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const dataDir = path.join(__dirname, '../data');
const dbPath = path.join(dataDir, 'vrindavaani_content.json');
const saintsPath = path.join(dataDir, 'saints_formatted.json');
const cachePath = path.join(dataDir, 'processed_cache.json');
const publicDataDir = path.join(__dirname, '../public/data');

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

function getNormalizedSaintSlug(name) {
  if (!name) return '';
  const clean = name.toLowerCase();
  if (clean.includes('haridas') || clean.includes('हरिदास')) return 'swami-haridas';
  if (clean.includes('harivansh') || clean.includes('हरिवंश')) return 'hit-harivansh';
  if (clean.includes('vyas') || clean.includes('व्यास')) return 'hariram-vyas';
  if (clean.includes('dhruv') || clean.includes('ध्रुव')) return 'dhruvdas';
  if (clean.includes('premanand') || clean.includes('प्रेमानंद')) return 'premanand-ji-maharaj';
  return slugify(transliterate(name));
}

function getNormalizedBookSlug(name) {
  if (!name) return '';
  const clean = name.toLowerCase();
  if (
    clean.includes('सुधानिधि') ||
    clean.includes('sudhanidhi') ||
    clean.includes('sudha-nidhi') ||
    clean.includes('sudha_nidhi') ||
    (clean.includes('सुधा') && clean.includes('निधि')) ||
    (clean.includes('sudha') && clean.includes('nidhi'))
  ) return 'radha-sudha-nidhi';
  if (clean.includes('चौरासी') || clean.includes('चतुरासी') || clean.includes('chaurasi') || clean.includes('chaturasi')) return 'hit-chaurasi';
  if (clean.includes('केलिमाल') || clean.includes('केलीमाल') || clean.includes('kelimal')) return 'kelimal';
  if (clean.includes('सिद्धान्त के पद') || clean.includes('सिद्धांत के पद') || clean.includes('सिद्धान्त की पद') || clean.includes('siddhanta-pada') || clean.includes('siddhant-pada')) return 'siddhanta-pada';
  if (clean.includes('बयालीस लीला') || clean.includes('ब्यालीस लीला') || clean.includes('bayalees') || clean.includes('byalees')) return 'bayalees-leela';
  if (clean.includes('व्यास वाणी') || clean.includes('vyas-vani') || clean.includes('vyas vani')) return 'vyas-vani';
  if (clean.includes('seva-kunj-texts') || clean.includes('seva-kunj') || clean.includes('सेवा कुंज') || clean.includes('सेवा कुञ्ज')) return 'seva-kunj-texts';
  return slugify(transliterate(name));
}

function getNormalizedBookName(name) {
  if (!name) return '';
  const clean = name.toLowerCase();
  if (
    clean.includes('सुधानिधि') ||
    clean.includes('sudhanidhi') ||
    clean.includes('sudha-nidhi') ||
    (clean.includes('सुधा') && clean.includes('निधि')) ||
    (clean.includes('sudha') && clean.includes('nidhi'))
  ) return 'श्री राधा सुधा निधि';
  if (clean.includes('चौरासी') || clean.includes('चतुरासी') || clean.includes('chaurasi')) return 'श्री हित चौरासी';
  if (clean.includes('केलिमाल') || clean.includes('केलीमाल') || clean.includes('kelimal')) return 'केलिमाल';
  if (clean.includes('सिद्धान्त के पद') || clean.includes('सिद्धांत के पद') || clean.includes('सिद्धान्त की पद')) return 'सिद्धान्त के पद';
  if (clean.includes('बयालीस लीला') || clean.includes('ब्यालीस लीला')) return 'बयालीस लीला';
  if (clean.includes('व्यास वाणी')) return 'व्यास वाणी';
  if (clean.includes('seva-kunj-texts') || clean.includes('seva-kunj') || clean.includes('सेवा कुंज') || clean.includes('सेवा कुञ्ज')) return 'सेवा कुंज साहित्य';
  return name;
}

function parseAuthorField(authorStr) {
  if (!authorStr || authorStr === 'Team VrindaVaani') {
    return { saintName: null, bookName: null, verseNum: null };
  }

  let saintName = null;
  let bookName = null;
  let verseNum = null;

  const verseMatch = authorStr.match(/\(([^)]+)\)$/);
  let cleanAuthor = authorStr;
  if (verseMatch) {
    verseNum = verseMatch[1].trim();
    cleanAuthor = authorStr.replace(/\s*\([^)]+\)\s*$/, '').trim();
  }

  const parts = cleanAuthor.split(/\s*,\s*|\s{2,}/);
  if (parts.length >= 2) {
    saintName = parts[0].trim();
    bookName = parts[1].trim();
  } else {
    saintName = parts[0].trim();
  }

  return { saintName, bookName, verseNum };
}

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
      const nameVal = item.name || item.title || '';
      const cleanName = nameVal.replace(/\([^)]+\)/g, '').replace(/महाप्रभु/g, '').trim();
      const transliteratedName = transliterate(cleanName);
      const saintSlug = getNormalizedSaintSlug(cleanName);

      biographies.push({
        id: item.id,
        slug: saintSlug,
        originalTitle: nameVal,
        name: cleanName,
        hinglishName: transliteratedName,
        text: item.biography || item.hindi_text || item.description || '',
        tags: item.tags || [],
        image: item.image_url || null
      });
    }
  });

  items.forEach(item => {
    if (item.category?.toLowerCase() === 'saint') return;

    const title = item.title || '';
    let cleanTitle = title;
    let saintName = null;
    let bookName = null;
    let verseNum = null;

    const parts = title.split(/\s+-\s+/);
    if (parts.length >= 2) {
      cleanTitle = parts[0].trim();
      const relationText = parts[1].trim();
      const verseMatch = relationText.match(/\(([^)]+)\)$/);
      if (verseMatch) {
        verseNum = verseMatch[1].trim();
        const textWithoutVerse = relationText.replace(/\(([^)]+)\)$/, '').trim();
        const relParts = textWithoutVerse.split(/\s*,\s*/);
        if (relParts.length >= 2) {
          saintName = relParts[0].trim();
          bookName = relParts[1].trim();
        } else if (relParts.length === 1) {
          const val = relParts[0].trim();
          if (val.includes('वाणी') || val.includes('सागर') || val.includes('शतक') || val.includes('महिमामृत') || val.includes('दोहे') || val.includes('ग्रंथावली') || val.includes('पदावली') || val.includes('शत') || val.includes('केलिमाल') || val.includes('चौरासी') || val.includes('सुधानिधि')) {
            bookName = val;
          } else {
            saintName = val;
          }
        }
      } else {
        const relParts = relationText.split(/\s*,\s*/);
        if (relParts.length >= 2) {
          saintName = relParts[0].trim();
          bookName = relParts[1].trim();
        } else if (relParts.length === 1) {
          const val = relParts[0].trim();
          if (val.includes('वाणी') || val.includes('सागर') || val.includes('शतक') || val.includes('महिमामृत') || val.includes('दोहे') || val.includes('केलिमाल') || val.includes('चौरासी') || val.includes('सुधानिधि')) {
            bookName = val;
          } else {
            saintName = val;
          }
        }
      }
    }

    if (!saintName && item.author) {
      const parsedAuthor = parseAuthorField(item.author);
      saintName = parsedAuthor.saintName;
      bookName = parsedAuthor.bookName || bookName;
      verseNum = parsedAuthor.verseNum || verseNum;
    }

    if (!saintName && item.author && item.author !== 'Team VrindaVaani') {
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
      const santSlug = getNormalizedSaintSlug(cleanSantKey);

      if (!santsMap[santSlug]) {
        const matchedBio = biographies.find(bio =>
          bio.name.includes(cleanSantKey) || cleanSantKey.includes(bio.name) ||
          (cleanSantKey.includes('हरिदास') && bio.name.includes('हरिदास')) ||
          (cleanSantKey.includes('हरिवंश') && bio.name.includes('हरिवंश'))
        );

        santsMap[santSlug] = {
          name: matchedBio ? matchedBio.name : saintName,
          cleanName: cleanSantKey,
          slug: santSlug,
          hinglishName: transliterate(matchedBio ? matchedBio.name : saintName),
          verseIds: [],
          verses: [],
          books: new Set(),
          biography: matchedBio || null
        };
      }
      santsMap[santSlug].verseIds.push(item.id);
      const finalTitle = cleanTitle || item.title || item.name || 'पद';
      const verseObj = {
        id: item.id,
        title: item.title || finalTitle,
        slug: (item.slug && !item.slug.startsWith('untitled')) ? item.slug : generateSlug(finalTitle),
        category: item.category || classifyItemCategory(item),
        author: item.author || saintName || '',
        cleanTitle: finalTitle,
        tags: item.tags || [],
        sanskrit_text: item.sanskrit_text || '',
        hindi_text: item.hindi_text || '',
        audio_url: item.audio_url || ''
      };
      santsMap[santSlug].verses.push(verseObj);
      if (bookName) {
        const normalizedBName = getNormalizedBookName(bookName);
        santsMap[santSlug].books.add(normalizedBName);
      }
    }

    if (bookName) {
      const bookSlug = getNormalizedBookSlug(bookName);
      const normalizedBName = getNormalizedBookName(bookName);
      if (!booksMap[bookSlug]) {
        booksMap[bookSlug] = {
          name: normalizedBName,
          slug: bookSlug,
          hinglishName: transliterate(normalizedBName),
          author: saintName || 'Unknown',
          authorSlug: saintName ? getNormalizedSaintSlug(saintName) : null,
          verseIds: [],
          verses: []
        };
      } else {
        if (saintName && booksMap[bookSlug].author === 'Unknown') {
          booksMap[bookSlug].author = saintName;
          booksMap[bookSlug].authorSlug = getNormalizedSaintSlug(saintName);
        }
      }
      booksMap[bookSlug].verseIds.push(item.id);
      const finalTitle = cleanTitle || item.title || item.name || 'पद';
      booksMap[bookSlug].verses.push({
        id: item.id,
        title: item.title || finalTitle,
        slug: (item.slug && !item.slug.startsWith('untitled')) ? item.slug : generateSlug(finalTitle),
        category: item.category || classifyItemCategory(item),
        author: item.author || saintName || '',
        cleanTitle: finalTitle,
        tags: item.tags || [],
        sanskrit_text: item.sanskrit_text || '',
        hindi_text: item.hindi_text || '',
        audio_url: item.audio_url || ''
      });
    }

    if (ragaName) {
      const ragaSlug = slugify(transliterate(ragaName));
      if (!ragasMap[ragaName]) {
        ragasMap[ragaName] = {
          name: ragaName,
          slug: ragaSlug,
          hinglishName: transliterate(ragaName),
          verseIds: [],
          verses: []
        };
      }
      ragasMap[ragaName].verseIds.push(item.id);
      const finalTitle = cleanTitle || item.title || item.name || 'पद';
      ragasMap[ragaName].verses.push({
        id: item.id,
        title: item.title || finalTitle,
        slug: (item.slug && !item.slug.startsWith('untitled')) ? item.slug : generateSlug(finalTitle),
        category: item.category || classifyItemCategory(item),
        author: item.author || saintName || '',
        cleanTitle: finalTitle,
        tags: item.tags || [],
        sanskrit_text: item.sanskrit_text || '',
        hindi_text: item.hindi_text || '',
        audio_url: item.audio_url || ''
      });
    }
  });

  const sevaKunjSlug = 'seva-kunj-texts';
  const sevaKunjVerseIds = [];

  items.forEach(item => {
    if (item.category?.toLowerCase() === 'saint') return;
    const textToScan = [
      item.title,
      item.author,
      item.hindi_text,
      item.sanskrit_text,
      item.english_translation,
      item.description
    ].filter(Boolean).join(' ').toLowerCase();

    const isSevaKunj = textToScan.includes('सेवा कुंज') ||
      textToScan.includes('सेवाकुंज') ||
      textToScan.includes('seva kunj') ||
      textToScan.includes('sewakunj') ||
      textToScan.includes('seva-kunj') ||
      textToScan.includes('सेवा सुख') ||
      (item.tags && item.tags.some(t => t.toLowerCase().includes('seva') || t.toLowerCase().includes('kunj')));

    if (isSevaKunj) {
      if (!sevaKunjVerseIds.includes(item.id)) {
        sevaKunjVerseIds.push(item.id);
      }
    }
  });

  if (sevaKunjVerseIds.length > 0) {
    booksMap[sevaKunjSlug] = {
      name: 'सेवा कुंज साहित्य',
      slug: sevaKunjSlug,
      hinglishName: 'Seva Kunj Texts',
      author: 'रसिक संत / Rasik Saints',
      authorSlug: 'hit-harivansh',
      verseIds: sevaKunjVerseIds
    };
  }

  const sants = Object.values(santsMap).map(s => ({
    ...s,
    books: Array.from(s.books)
  })).sort((a, b) => b.verseIds.length - a.verseIds.length);

  const books = Object.values(booksMap).sort((a, b) => b.verseIds.length - a.verseIds.length);
  const ragas = Object.values(ragasMap).sort((a, b) => b.verseIds.length - a.verseIds.length);

  return { sants, books, ragas };
}

console.log('[sync_cache] Reading main database from vrindavaani_content.json...');
const rawData = JSON.parse(fs.readFileSync(dbPath, 'utf8'));
const data = rawData.map(item => {
  const normalizedTags = !item.tags ? [] : Array.isArray(item.tags) ? item.tags : String(item.tags).split(',').map(t => t.trim()).filter(Boolean);
  return {
    ...item,
    tags: normalizedTags
  };
});

let saints = [];
if (fs.existsSync(saintsPath)) {
  saints = JSON.parse(fs.readFileSync(saintsPath, 'utf8')).map((s, i) => ({
    id: s.id || `saint-local-${i}`,
    ...s,
    category: 'saint',
    slug: s.slug || ''
  }));
}

// 1. Regenerate processed_cache.json
console.log('[sync_cache] Generating processed_cache.json...');
const cachePayload = { isFullyCompiled: true, verses: data, saintsRaw: saints };
fs.writeFileSync(cachePath, JSON.stringify(cachePayload), 'utf8');
const cacheSizeMB = (fs.statSync(cachePath).size / (1024 * 1024)).toFixed(1);
console.log(`[sync_cache] Saved processed_cache.json (${cacheSizeMB} MB)`);

// 2. Ensure public/data folder exists
if (!fs.existsSync(publicDataDir)) {
  fs.mkdirSync(publicDataDir, { recursive: true });
}

// 3. Rebuild public/data/content_backup.json
console.log('[sync_cache] Generating public/data/content_backup.json...');
const backupFile = path.join(publicDataDir, 'content_backup.json');
fs.writeFileSync(backupFile, JSON.stringify(data, null, 2), 'utf8');
console.log(`[sync_cache] Saved public/data/content_backup.json`);

// 4. Split and write category-specific files
const categories = ['shloka', 'strotra', 'poem', 'saint', 'dham'];
categories.forEach(cat => {
  const catFile = path.join(publicDataDir, `content_backup_${cat}.json`);
  let catVerses = [];
  if (cat === 'saint') {
    catVerses = saints;
  } else {
    catVerses = data.filter(v => classifyItemCategory(v) === cat);
  }
  fs.writeFileSync(catFile, JSON.stringify(catVerses, null, 2), 'utf8');
  console.log(`[sync_cache] Saved public/data/content_backup_${cat}.json with ${catVerses.length} items`);
});

// 5. Pre-compute and save relations backup
console.log('[sync_cache] Extracting relations and generating relations_backup.json...');
const relations = extractRelations([...data, ...saints]);
const clientRelations = {
  sants: relations.sants.map(s => ({
    name: s.name,
    slug: s.slug,
    hinglishName: s.hinglishName,
    verseIds: s.verseIds,
    verses: (s.verses || []).map(v => ({
      id: v.id,
      title: v.title || v.cleanTitle || '',
      cleanTitle: v.cleanTitle || '',
      slug: v.slug || '',
      category: v.category || 'poem'
    })),
    books: s.books
  })),
  books: relations.books.map(b => ({
    name: b.name,
    slug: b.slug,
    hinglishName: b.hinglishName,
    author: b.author,
    authorSlug: b.authorSlug,
    verseIds: b.verseIds,
    verses: (b.verses || []).map(v => ({
      id: v.id,
      title: v.title || v.cleanTitle || '',
      cleanTitle: v.cleanTitle || '',
      slug: v.slug || '',
      category: v.category || 'poem'
    }))
  })),
  ragas: relations.ragas.map(r => ({
    name: r.name,
    slug: r.slug,
    hinglishName: r.hinglishName,
    verseIds: r.verseIds,
    verses: (r.verses || []).map(v => ({
      id: v.id,
      title: v.title || v.cleanTitle || '',
      cleanTitle: v.cleanTitle || '',
      slug: v.slug || '',
      category: v.category || 'poem'
    }))
  })),
  biographies: relations.sants.map(s => ({
    id: s.biography?.id || null,
    slug: s.slug,
    originalTitle: s.biography?.originalTitle || s.name,
    name: s.name,
    hinglishName: s.hinglishName,
    text: s.biography?.text || '',
    tags: s.biography?.tags || [],
    image: s.biography?.image || null
  }))
};

const relationsFile = path.join(publicDataDir, 'relations_backup.json');
fs.writeFileSync(relationsFile, JSON.stringify(clientRelations, null, 2), 'utf8');
console.log(`[sync_cache] Saved relations_backup.json`);

// 6. Write individual per-book static shards
console.log('[sync_cache] Generating per-book static JSON shards...');
const publicBooksDir = path.join(publicDataDir, 'books');
if (!fs.existsSync(publicBooksDir)) {
  fs.mkdirSync(publicBooksDir, { recursive: true });
}

relations.books.forEach(b => {
  if (!b.slug) return;
  const bookFile = path.join(publicBooksDir, `${b.slug}.json`);
  const bookData = {
    name: b.name,
    slug: b.slug,
    hinglishName: b.hinglishName,
    author: b.author,
    authorSlug: b.authorSlug,
    verseIds: b.verseIds,
    verses: b.verses || []
  };
  fs.writeFileSync(bookFile, JSON.stringify(bookData, null, 2), 'utf8');
});
console.log(`[sync_cache] Saved ${relations.books.length} individual book shards in public/data/books/`);

// 7. Write individual per-saint static shards
console.log('[sync_cache] Generating per-saint static JSON shards...');
const publicSaintsDir = path.join(publicDataDir, 'saints');
if (!fs.existsSync(publicSaintsDir)) {
  fs.mkdirSync(publicSaintsDir, { recursive: true });
}

relations.sants.forEach(s => {
  if (!s.slug) return;
  const saintFile = path.join(publicSaintsDir, `${s.slug}.json`);
  const saintData = {
    name: s.name,
    slug: s.slug,
    hinglishName: s.hinglishName,
    cleanName: s.cleanName,
    books: s.books,
    verseIds: s.verseIds,
    verses: s.verses || [],
    biography: s.biography || null
  };
  fs.writeFileSync(saintFile, JSON.stringify(saintData, null, 2), 'utf8');
});
console.log(`[sync_cache] Saved ${relations.sants.length} individual saint shards in public/data/saints/`);

// 8. Generate sitemap manifest
generateSitemapManifest();

console.log(`[sync_cache] ✅ All local cache files, public backups, and book/saint shards successfully updated and in sync!`);
