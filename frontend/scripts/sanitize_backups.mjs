import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Helper transliteration (duplicate of transliterate.js for self-containment)
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
        if (nextHasMatra || nextIsHalant) {
          if (result.endsWith('a')) {
            result = result.substring(0, result.length - 1);
          }
        } else if (nextIsWordBoundary) {
          if (result.endsWith('a')) {
            result = result.substring(0, result.length - 1);
          }
        }
      }
    } else {
      result += char;
    }
  }
  return result;
}

// Paths
const sitemapPath = '/Users/sakhi/.gemini/antigravity-ide/brain/a8bc031e-410f-4ff9-9e87-10e8d6dd4c48/.system_generated/steps/577/content.md';
const dataDir = path.join(__dirname, '../public/data');

// 1. Read sitemap
console.log("Reading sitemap...");
const sitemapContent = fs.readFileSync(sitemapPath, 'utf8');
const locRegex = /<loc>(https:\/\/www\.vrindopnishad\.org\/(?:hi\/)?articles\/[^\/]+\/([^<]+))<\/loc>/g;
const copyrightedSlugs = new Set();
let match;
while ((match = locRegex.exec(sitemapContent)) !== null) {
  copyrightedSlugs.add(match[2].trim().toLowerCase());
}
console.log(`Loaded ${copyrightedSlugs.size} copyrighted slugs.`);

// Helper function to sanitize a file
function sanitizeFile(filePath) {
  if (!fs.existsSync(filePath)) {
    console.log(`File not found: ${filePath}`);
    return null;
  }
  
  console.log(`Sanitizing file: ${filePath}...`);
  const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  let count = 0;
  
  const sanitized = data.map(item => {
    count++;
    const basePoetry = item.sanskrit_text || item.hindi_text || "";
    const cleanTransliteration = basePoetry ? transliterate(basePoetry) : "";
    
    return {
      ...item,
      description: "",
      sanskrit_text: basePoetry,
      english_translation: cleanTransliteration,
      english_text: cleanTransliteration,
      hindi_text: ""
    };
  });
  
  console.log(`Sanitized ${count} / ${data.length} items in ${path.basename(filePath)}.`);
  fs.writeFileSync(filePath, JSON.stringify(sanitized, null, 2), 'utf8');
  return sanitized;
}

// 2. Sanitize main content_backup.json
sanitizeFile(path.join(dataDir, 'content_backup.json'));

// 3. Sanitize category backups
const categories = ['shloka', 'strotra', 'poem', 'saint', 'dham'];
categories.forEach(cat => {
  sanitizeFile(path.join(dataDir, `content_backup_${cat}.json`));
});

// 4. Sanitize relations_backup.json
const relationsFile = path.join(dataDir, 'relations_backup.json');
if (fs.existsSync(relationsFile)) {
  console.log(`Sanitizing relations file: ${relationsFile}...`);
  const relations = JSON.parse(fs.readFileSync(relationsFile, 'utf8'));
  let relCount = 0;
  
  const sanitizeVerseList = (verses) => {
    if (!Array.isArray(verses)) return;
    verses.forEach(v => {
      relCount++;
      v.description = "";
      v.hindi_text = "";
      // Clean transliteration for lightweight item (title transliterated or first line if available)
      v.english_translation = v.cleanTitle ? transliterate(v.cleanTitle) : "";
    });
  };
  
  // Sanitize verses inside sants
  if (Array.isArray(relations.sants)) {
    relations.sants.forEach(saint => {
      sanitizeVerseList(saint.verses);
    });
  }
  
  // Sanitize verses inside books
  if (Array.isArray(relations.books)) {
    relations.books.forEach(book => {
      sanitizeVerseList(book.verses);
    });
  }
  
  // Sanitize verses inside ragas
  if (Array.isArray(relations.ragas)) {
    relations.ragas.forEach(raga => {
      sanitizeVerseList(raga.verses);
    });
  }
  
  console.log(`Sanitized ${relCount} relation items in relations_backup.json.`);
  fs.writeFileSync(relationsFile, JSON.stringify(relations, null, 2), 'utf8');
}

console.log("All backup files are completely sanitized and safe.");
