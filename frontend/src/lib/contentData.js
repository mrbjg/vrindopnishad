import fs from 'fs';
import path from 'path';
import { SAINT_METADATA, getSaintMetadata } from '../data/saintMetadata';
import { GLOSSARY_TERMS } from '../data/glossaryTerms';

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

export function transliterate(text) {
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

export const slugify = (text) => {
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

export const generateSlug = (text) => {
  return slugify(transliterate(text));
};

export const sanitizeSlug = (slug) => {
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

let contentCache = null;

function loadRawData() {
  if (contentCache) return contentCache;

  const appDirectory = process.cwd();
  
  
  let contentPath = path.join(appDirectory, 'data/brajrasik_hi_full.json');
  let saintsPath = path.join(appDirectory, 'data/saints_formatted.json');

  if (!fs.existsSync(contentPath)) {
    contentPath = path.join(appDirectory, 'frontend/data/brajrasik_hi_full.json');
    saintsPath = path.join(appDirectory, 'frontend/data/saints_formatted.json');
  }

  try {
    let allContentItems = [];
    if (fs.existsSync(contentPath)) {
      const rawContent = fs.readFileSync(contentPath, 'utf8');
      allContentItems = JSON.parse(rawContent).map((item, idx) => ({
        id: item.id || `local-${idx}`,
        ...item,
        slug: item.slug || generateSlug(item.title)
      }));
    }

    let rawSaints = [];
    if (fs.existsSync(saintsPath)) {
      const rawSaintsData = fs.readFileSync(saintsPath, 'utf8');
      rawSaints = JSON.parse(rawSaintsData).map((saint, idx) => ({
        id: saint.id || `saint-local-${idx}`,
        ...saint,
        category: 'saint',
        slug: saint.slug || generateSlug(saint.title)
      }));
    }

    
    const combined = [...allContentItems, ...rawSaints];
    const relations = buildRelations(combined);

    contentCache = {
      items: combined,
      verses: allContentItems,
      saints: relations.saints,
      books: relations.books,
      ragas: relations.ragas
    };

    return contentCache;
  } catch (error) {
    console.error("Failed to load local JSON files:", error);
    return { items: [], verses: [], saints: [], books: [], ragas: [] };
  }
}

function buildRelations(items) {
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
        slug: item.slug || slugify(transliteratedName),
        text: item.hindi_text || item.description || '',
        imageUrl: item.image_url || null,
        rawItem: item
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
        if (val.includes('वाणी') || val.includes('सागर') || val.includes('शतक') || val.includes('महिमामृत') || val.includes('दोहे') || val.includes('ग्रंथावली') || val.includes('पदावली') || val.includes('शत') || val.includes('केलिमाल') || val.includes('चौरासी')) {
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
        const finalSlug = matchedBio ? matchedBio.slug : santSlug;
        santsMap[cleanSantKey] = {
          name: cleanSantKey,
          hinglishName: transliterate(cleanSantKey),
          slug: finalSlug,
          biography: matchedBio ? matchedBio.text : '',
          metadata: getSaintMetadata(finalSlug),
          imageUrl: matchedBio ? matchedBio.imageUrl : null,
          verses: [],
          books: new Set(),
          rawItem: matchedBio ? matchedBio.rawItem : null
        };
      }
      santsMap[cleanSantKey].verses.push(item);
      if (bookName) santsMap[cleanSantKey].books.add(bookName);
    }

    if (bookName) {
      const bookSlug = slugify(transliterate(bookName));
      if (!booksMap[bookName]) {
        booksMap[bookName] = {
          name: bookName,
          slug: bookSlug,
          author: saintName || 'Unknown Rasik',
          verses: [],
          imageUrl: item.image_url || null
        };
      } else if (!booksMap[bookName].imageUrl && item.image_url) {
        booksMap[bookName].imageUrl = item.image_url;
      }
      booksMap[bookName].verses.push(item);
    }

    if (ragaName) {
      const ragaSlug = slugify(transliterate(ragaName));
      if (!ragasMap[ragaName]) {
        ragasMap[ragaName] = {
          name: ragaName,
          hinglishName: transliterate(ragaName),
          slug: ragaSlug,
          verses: [],
          imageUrl: item.image_url || null
        };
      } else if (!ragasMap[ragaName].imageUrl && item.image_url) {
        ragasMap[ragaName].imageUrl = item.image_url;
      }
      ragasMap[ragaName].verses.push(item);
    }
  });

  
  return {
    saints: Object.values(santsMap).map(s => ({ ...s, books: Array.from(s.books) })),
    books: Object.values(booksMap),
    ragas: Object.values(ragasMap)
  };
}

export function getAllVerses() {
  const { verses } = loadRawData();
  return verses;
}

export function getVerseBySlug(slug) {
  const { verses } = loadRawData();
  const decodedSlug = decodeURIComponent(slug).toLowerCase();
  const cleanSlug = sanitizeSlug(decodedSlug);
  return verses.find(item => 
    (item.slug && item.slug.toLowerCase() === decodedSlug) ||
    (item.slug && item.slug.toLowerCase() === cleanSlug) ||
    (item.id?.toString() === decodedSlug)
  ) || null;
}

export function getAllSaints() {
  const { saints } = loadRawData();
  return saints;
}

export function getSaintBySlug(slug) {
  const { saints } = loadRawData();
  const decodedSlug = decodeURIComponent(slug).toLowerCase();
  
  let matched = saints.find(s => s.slug.toLowerCase() === decodedSlug);
  
  if (!matched) {
    const cleanSlug = decodedSlug.replace(/-maharaj$/, '');
    matched = saints.find(s => s.slug.toLowerCase().includes(cleanSlug) || cleanSlug.includes(s.slug.toLowerCase()));
  }
  return matched || null;
}

export function getAllGranthas() {
  const { books } = loadRawData();
  return books;
}

export function getGranthaBySlug(slug) {
  const { books } = loadRawData();
  const decodedSlug = decodeURIComponent(slug).toLowerCase();
  return books.find(b => b.slug.toLowerCase() === decodedSlug) || null;
}

export function getAllRagas() {
  const { ragas } = loadRawData();
  return ragas;
}

export function getRagaBySlug(slug) {
  const { ragas } = loadRawData();
  const decodedSlug = decodeURIComponent(slug).toLowerCase();
  return ragas.find(r => r.slug.toLowerCase() === decodedSlug) || null;
}

export function getGlossaryTerms() {
  return GLOSSARY_TERMS;
}

export function getGlossaryTermBySlug(slug) {
  const decodedSlug = decodeURIComponent(slug).toLowerCase();
  return GLOSSARY_TERMS.find(term => term.slug.toLowerCase() === decodedSlug) || null;
}
