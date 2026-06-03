const fs = require('fs');
const path = require('path');

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
  return slugify(transliterate(text));
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

function normalizeFuzzyText(text) {
  if (!text) return '';
  return text.toLowerCase()
    .replace(/[^a-z0-9]/g, '')
    .replace(/aa/g, 'a')
    .replace(/ee/g, 'i')
    .replace(/oo/g, 'u')
    .replace(/w/g, 'v')
    .replace(/th/g, 't')
    .replace(/dh/g, 'd')
    .replace(/bh/g, 'b')
    .replace(/sh/g, 's')
    .replace(/kh/g, 'k')
    .replace(/gh/g, 'g')
    .replace(/jh/g, 'j')
    .replace(/ph/g, 'p')
    .replace(/ch/g, 'c');
}

const cachePath = path.join(__dirname, '../data/processed_cache.json');
const cacheData = JSON.parse(fs.readFileSync(cachePath, 'utf8'));
const verses = cacheData.verses || [];

function getVerseBySlug(slug) {
  const decodedSlug = decodeURIComponent(slug).toLowerCase();
  const cleanSlug = sanitizeSlug(decodedSlug);
  
  // 1. Try exact match
  let matched = verses.find(item => 
    (item.slug && item.slug.toLowerCase() === decodedSlug) ||
    (item.slug && item.slug.toLowerCase() === cleanSlug) ||
    (item.id?.toString() === decodedSlug)
  );
  if (matched) return { method: 'exact', item: matched };

  // 2. If the slug contains non-ASCII (Devanagari) characters, transliterate and search
  if (/[^\x00-\x7F]/.test(decodedSlug)) {
    const cleanForTransliterate = decodedSlug.replace(/-/g, ' ');
    const transliteratedSlug = generateSlug(cleanForTransliterate);
    
    // 2a. Match transliterated slug against item slugs
    matched = verses.find(item => 
      (item.slug && item.slug.toLowerCase() === transliteratedSlug)
    );
    if (matched) return { method: 'devanagari-slug-transliterated', item: matched };
    
    // 2b. Match transliterated slug against transliterated item titles
    matched = verses.find(item => {
      if (!item.title) return false;
      const itemTitleTransliterated = generateSlug(item.title);
      return itemTitleTransliterated === transliteratedSlug;
    });
    if (matched) return { method: 'devanagari-title-transliterated', item: matched };
  }

  // 3. Try spelling-insensitive normalized fuzzy match
  const normDecoded = normalizeFuzzyText(decodedSlug);
  const normClean = normalizeFuzzyText(cleanSlug);
  
  if (normDecoded) {
    matched = verses.find(item => {
      if (!item.slug) return false;
      const normItem = normalizeFuzzyText(item.slug);
      return normItem === normDecoded || 
             normItem === normClean ||
             normItem.startsWith(normDecoded) || 
             normDecoded.startsWith(normItem) ||
             normItem.startsWith(normClean) ||
             normClean.startsWith(normItem) ||
             (normDecoded.length > 6 && (normItem.includes(normDecoded) || normDecoded.includes(normItem)));
    });
    if (matched) return { method: 'fuzzy', item: matched };
  }
  return null;
}

const testSlugs = [
  'sambhu-sur-dhyaavain-sada-ses-gun-gaavai-shri-hati-ji-radha-sudha-shatak',
  'किं-रे-धूर्त्त',
  'करू-मन-नंदनँदनको-ध्यान',
  'जब-सम्राट-अकबर-स्वामी-हरिदास-से-निधिवन-वृंदावन-में-मिले',
  'बिछुरन-मिलन-जहाँ-रहै-सुद्ध-प्रेम-नहिं-होइ',
  'ansbhuja-diyain-aavat-jamuna-teer-shri-roop-manjari',
  'janam-janam-jinke-sada-hum-chakar-shri-bhata-devacharya-yugal-shatak'
];

testSlugs.forEach(slug => {
  const result = getVerseBySlug(slug);
  if (result) {
    console.log(`Slug: ${slug} -> FOUND via ${result.method}. ID: ${result.item.id}, Title: ${result.item.title}`);
  } else {
    console.log(`Slug: ${slug} -> NOT FOUND`);
  }
});
