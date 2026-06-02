import fs from 'fs';
import path from 'path';
import { SAINT_METADATA, getSaintMetadata } from '../data/saintMetadata';
import { GLOSSARY_TERMS } from '../data/glossaryTerms';
import { listAllContent } from './dataconnect';
import { dataConnect } from '../firebase';

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

let contentCache = null;
let initializationPromise = null;

async function fetchAllFromDataConnect() {
  try {
    console.log("[DataConnect] Fetching all content items from Firebase Data Connect (limit 25000)...");
    const result = await listAllContent(dataConnect, { limit: 25000 });
    if (result && result.data && result.data.contents) {
      console.log(`[DataConnect] Successfully fetched ${result.data.contents.length} items.`);
      return result.data.contents.map(item => {
        let slug = item.slug;
        if (!slug || /[^\x00-\x7F]/.test(slug)) {
          slug = generateSlug(item.title || slug);
        }
        if (slug.length > 100) {
          slug = slug.substring(0, 100).replace(/-+$/, '');
        }
        return {
          id: item.id,
          title: item.title,
          sanskrit_text: item.sanskritText || '',
          hindi_text: item.hindiText || '',
          english_text: item.englishText || '',
          english_translation: item.englishTranslation || '',
          category: item.category,
          description: item.description || '',
          content_text: item.contentText || '',
          tags: item.tags || [],
          status: (item.status || 'PUBLISHED').toLowerCase(),
          author: item.author || '',
          media_links: item.mediaLinks || [],
          audio_url: item.audioUrl || '',
          image_urls: item.imageUrls || [],
          video_urls: item.videoUrls || [],
          slug: slug,
          created_at: item.createdAt,
          updated_at: item.updatedAt
        };
      });
    }
  } catch (error) {
    console.error("[DataConnect] Query failed:", error);
  }
  return [];
}

function loadLocalJSONFallback() {
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
      allContentItems = JSON.parse(rawContent).map((item, idx) => {
        const cleanCategory = classifyItemCategory(item);
        let slug = item.slug;
        if (!slug || /[^\x00-\x7F]/.test(slug)) {
          slug = generateSlug(item.title || slug);
        }
        if (slug.length > 100) {
          slug = slug.substring(0, 100).replace(/-+$/, '');
        }
        return {
          id: item.id || `local-${idx}`,
          ...item,
          category: cleanCategory,
          slug: slug
        };
      });
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

    return {
      items: combined,
      verses: allContentItems,
      saints: relations.saints,
      books: relations.books,
      ragas: relations.ragas
    };
  } catch (error) {
    console.error("Failed to load local JSON files:", error);
    return { items: [], verses: [], saints: [], books: [], ragas: [] };
  }
}

export function loadRawData() {
  if (contentCache) return contentCache;
  return loadLocalJSONFallback();
}

export async function ensureDataLoaded() {
  if (contentCache) return contentCache;
  if (initializationPromise) return initializationPromise;

  initializationPromise = (async () => {
    console.log("[DataCache] Initializing memory cache...");
    const localData = loadLocalJSONFallback();
    
    if (typeof window === 'undefined') {
      try {
        const remoteItems = await fetchAllFromDataConnect();
        if (remoteItems && remoteItems.length > 0) {
          const appDirectory = process.cwd();
          let saintsPath = path.join(appDirectory, 'data/saints_formatted.json');
          if (!fs.existsSync(saintsPath)) {
            saintsPath = path.join(appDirectory, 'frontend/data/saints_formatted.json');
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

          const combined = [...remoteItems, ...rawSaints];
          const relations = buildRelations(combined);

          contentCache = {
            items: combined,
            verses: remoteItems,
            saints: relations.saints,
            books: relations.books,
            ragas: relations.ragas
          };
          console.log(`[DataCache] Cache successfully initialized with ${remoteItems.length} database items!`);
          return contentCache;
        }
      } catch (err) {
        console.warn("[DataCache] Remote load failed, falling back to local dataset:", err);
      }
    }
    
    contentCache = localData;
    console.log(`[DataCache] Cache initialized with local fallback of ${localData.verses.length} items.`);
    return contentCache;
  })();

  return initializationPromise;
}

export function getNormalizedSaintSlug(name) {
  if (!name) return '';
  const clean = name.toLowerCase();
  if (clean.includes('haridas') || clean.includes('हरिदास')) return 'swami-haridas';
  if (clean.includes('harivansh') || clean.includes('हरिवंश')) return 'hit-harivansh';
  if (clean.includes('vyas') || clean.includes('व्यास')) return 'hariram-vyas';
  if (clean.includes('dhruv') || clean.includes('ध्रुव')) return 'dhruvdas';
  if (clean.includes('premanand') || clean.includes('प्रेमानंद')) return 'premanand-ji-maharaj';
  return slugify(transliterate(name));
}

export function getNormalizedBookSlug(name) {
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

export function getNormalizedBookName(name) {
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

export function parseAuthorField(authorStr) {
  if (!authorStr || authorStr === 'Braj Rasik Heritage') {
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
      const saintSlug = getNormalizedSaintSlug(cleanName);
      biographies.push({
        name: cleanName,
        slug: saintSlug,
        text: item.hindi_text || item.description || '',
        imageUrl: item.image_url || null,
        rawItem: item
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

    const parts = title.split(/\s+-\_\s+/); // Handle any variation
    const realParts = title.split(/\s+-\s+/);
    if (realParts.length >= 2) {
      cleanTitle = realParts[0].trim();
      const relationText = realParts[1].trim();
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

    const enrichedItem = {
      ...item,
      cleanTitle,
      parsedSaint: saintName,
      parsedBook: bookName,
      parsedVerse: verseNum,
      parsedRaga: ragaName,
      slug: item.slug || slugify(transliterate(cleanTitle))
    };

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
          name: matchedBio ? matchedBio.name : cleanSantKey,
          hinglishName: transliterate(matchedBio ? matchedBio.name : cleanSantKey),
          slug: santSlug,
          biography: matchedBio ? matchedBio.text : '',
          metadata: getSaintMetadata(santSlug),
          imageUrl: matchedBio ? matchedBio.imageUrl : null,
          verses: [],
          books: new Set(),
          rawItem: matchedBio ? matchedBio.rawItem : null
        };
      }
      santsMap[santSlug].verses.push(enrichedItem);
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
          author: saintName || 'Unknown Rasik',
          authorSlug: saintName ? getNormalizedSaintSlug(saintName) : null,
          verses: [],
          imageUrl: item.image_url || null
        };
      } else {
        if (!booksMap[bookSlug].imageUrl && item.image_url) {
          booksMap[bookSlug].imageUrl = item.image_url;
        }
        if (saintName && booksMap[bookSlug].author === 'Unknown Rasik') {
          booksMap[bookSlug].author = saintName;
          booksMap[bookSlug].authorSlug = getNormalizedSaintSlug(saintName);
        }
      }
      booksMap[bookSlug].verses.push(enrichedItem);
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
      ragasMap[ragaName].verses.push(enrichedItem);
    }
  });

  const sevaKunjSlug = 'seva-kunj-texts';
  const sevaKunjVerses = [];
  
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
      let enriched = item;
      for (const b of Object.values(booksMap)) {
        const found = b.verses.find(v => v.id === item.id);
        if (found) {
          enriched = found;
          break;
        }
      }
      if (!sevaKunjVerses.some(v => v.id === enriched.id)) {
        sevaKunjVerses.push(enriched);
      }
    }
  });

  if (sevaKunjVerses.length > 0) {
    booksMap[sevaKunjSlug] = {
      name: 'सेवा कुंज साहित्य',
      slug: sevaKunjSlug,
      author: 'रसिक संत / Rasik Saints',
      authorSlug: 'hit-harivansh',
      verses: sevaKunjVerses,
      imageUrl: '/assets/images/sewakunj.jpg'
    };
  }

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
