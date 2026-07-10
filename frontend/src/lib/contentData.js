import fs from 'fs';
import path from 'path';
import { SAINT_METADATA, getSaintMetadata } from '../data/saintMetadata';
import { GLOSSARY_TERMS } from '../data/glossaryTerms';
import { listAllContent } from './dataconnect';
import { dataConnect } from '../firebase';
import { extractRelations } from '../utils/relations';

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

let contentCache = typeof global !== 'undefined' ? (global.contentCache || null) : null;
let localFallbackCache = typeof global !== 'undefined' ? (global.localFallbackCache || null) : null;
let initializationPromise = typeof global !== 'undefined' ? (global.initializationPromise || null) : null;

async function fetchAllFromDataConnect() {
  console.log("[DataConnect] Blocked: fetchAllFromDataConnect has been disabled.");
  return [];
}

function loadLocalJSONFallback() {
  const appDirectory = process.cwd();

  // Try loading full backup first to ensure we have the complete 10k+ items even when quota is exceeded
  let contentPath = path.join(appDirectory, 'public/data/content_backup.json');
  if (!fs.existsSync(contentPath)) {
    contentPath = path.join(appDirectory, 'frontend/public/data/content_backup.json');
  }

  // Fall back to smaller initial dataset if full backup is missing
  if (!fs.existsSync(contentPath)) {
    contentPath = path.join(appDirectory, 'data/brajrasik_hi_full.json');
  }
  if (!fs.existsSync(contentPath)) {
    contentPath = path.join(appDirectory, 'frontend/data/brajrasik_hi_full.json');
  }

  let saintsPath = path.join(appDirectory, 'data/saints_formatted.json');
  if (!fs.existsSync(saintsPath)) {
    saintsPath = path.join(appDirectory, 'frontend/data/saints_formatted.json');
  }

  try {
    let allContentItems = [];
    if (fs.existsSync(contentPath)) {
      const rawContent = fs.readFileSync(contentPath, 'utf8');
      const parsedContent = JSON.parse(rawContent);
      const totalItems = parsedContent.length;

      for (let i = 0; i < totalItems; i += 500) {
        const end = Math.min(i + 500, totalItems);
        console.log(`[DataCache] Initializing memory cache... Loaded ${end} / ${totalItems} items`);
      }

      allContentItems = parsedContent.map((item, idx) => {
        const cleanCategory = classifyItemCategory(item);
        let slug = item.slug;
        if (!slug || slug.startsWith('untitled')) {
          slug = generateSlug(item.title);
        } else {
          slug = slugify(slug);
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
      rawSaints = JSON.parse(rawSaintsData).map((saint, idx) => {
        const nameVal = saint.name || saint.title || '';
        return {
          id: saint.id || `saint-local-${idx}`,
          ...saint,
          name: nameVal,
          hinglishName: saint.hinglishName || transliterate(nameVal),
          biography: saint.biography || saint.hindi_text || saint.description || '',
          category: 'saint',
          slug: saint.slug || generateSlug(nameVal)
        };
      });
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
  if (localFallbackCache) return localFallbackCache;
  const data = loadLocalJSONFallback();
  localFallbackCache = data;
  if (typeof global !== 'undefined') {
    global.localFallbackCache = data;
  }
  return data;
}

const CACHE_TTL_DEV = 15 * 60 * 1000; // 15 minutes in development
const CACHE_TTL_PROD = 24 * 60 * 60 * 1000; // 24 hours in production

function getProcessedCacheFilePath() {
  const appDirectory = process.cwd();
  let cacheDir = path.join(appDirectory, 'data');
  if (!fs.existsSync(cacheDir)) {
    cacheDir = path.join(appDirectory, 'frontend/data');
  }
  if (!fs.existsSync(cacheDir)) {
    try {
      fs.mkdirSync(cacheDir, { recursive: true });
    } catch (e) { }
  }
  return path.join(cacheDir, 'processed_cache.json');
}

function writeBackupFile(verses, force = false) {
  if (!verses || verses.length === 0) return;
  try {
    const appDirectory = process.cwd();
    let dataDir = path.join(appDirectory, 'public/data');
    if (!fs.existsSync(dataDir)) {
      dataDir = path.join(appDirectory, 'frontend/public/data');
    }
    if (!fs.existsSync(dataDir)) {
      try {
        fs.mkdirSync(dataDir, { recursive: true });
      } catch (e) { }
    }

    const backupFile = path.join(dataDir, 'content_backup.json');
    const writeFull = force || !fs.existsSync(backupFile);
    if (writeFull) {
      console.log(`[DataCache] Saving backup data file to: ${backupFile}...`);
      fs.writeFile(backupFile, JSON.stringify(verses), 'utf8', (err) => {
        if (err) console.warn("[DataCache] Async backup write failed:", err);
      });
    }

    // Split and write category-specific files
    const categories = ['shloka', 'strotra', 'poem', 'saint', 'dham'];
    categories.forEach(cat => {
      const catFile = path.join(dataDir, `content_backup_${cat}.json`);
      if (force || !fs.existsSync(catFile)) {
        const catVerses = verses.filter(v => {
          const itemCat = classifyItemCategory(v);
          return itemCat === cat;
        });
        console.log(`[DataCache] Saving category backup [${cat}] to: ${catFile}...`);
        fs.writeFile(catFile, JSON.stringify(catVerses), 'utf8', (err) => {
          if (err) console.warn(`[DataCache] Async backup write failed for ${cat}:`, err);
        });
      }
    });

    // Pre-compute and save relations
    const relationsFile = path.join(dataDir, 'relations_backup.json');
    if (force || !fs.existsSync(relationsFile)) {
      console.log(`[DataCache] Pre-computing and saving relations backup to: ${relationsFile}...`);
      const relations = extractRelations(verses);
      fs.writeFile(relationsFile, JSON.stringify(relations), 'utf8', (err) => {
        if (err) console.warn("[DataCache] Async relations backup write failed:", err);
      });
    }

  } catch (err) {
    console.warn("[DataCache] Could not start content backup write:", err);
  }
}

export async function ensureDataLoaded() {
  if (typeof global !== 'undefined' && global.contentCache) {
    contentCache = global.contentCache;
    return contentCache;
  }
  if (contentCache) return contentCache;
  if (typeof global !== 'undefined' && global.initializationPromise) {
    initializationPromise = global.initializationPromise;
    return initializationPromise;
  }
  if (initializationPromise) return initializationPromise;

  initializationPromise = (async () => {
    console.log("[DataCache] Initializing memory cache...");

    if (typeof window === 'undefined') {
      try {
        const cacheFile = getProcessedCacheFilePath();
        let loadedFromCache = false;

        if (fs.existsSync(cacheFile)) {
          try {
            const stat = fs.statSync(cacheFile);
            const now = Date.now();
            const age = now - stat.mtimeMs;
            const isDev = process.env.NODE_ENV === 'development';
            const ttl = isDev ? CACHE_TTL_DEV : CACHE_TTL_PROD;

            const rawCache = fs.readFileSync(cacheFile, 'utf8');
            const cachePayload = JSON.parse(rawCache);
            const verses = cachePayload.verses || [];

            // Check if this cache is fallback (contains only ~643 local items instead of all 8073 items)
            const isFallback = verses.length < 1000;
            const isFresh = age < ttl;

            if (!isFallback && (isFresh || !isDev)) {
              console.log(`[DataCache] Loading flat processed cache from file: ${cacheFile} (Age: ${Math.round(age / 1000)}s)...`);
              const startTime = Date.now();

              if (!cachePayload.saintsRaw && cachePayload.saints) {
                console.log("[DataCache] Old nested cache structure detected. Upgrading to flat cache format...");
                throw new Error("Old cache format forcing rebuild.");
              }

              const rawVerses = cachePayload.verses || [];
              const verses = rawVerses.map((item, idx) => {
                let slug = item.slug;
                if (!slug || slug.startsWith('untitled')) {
                  slug = generateSlug(item.title);
                } else {
                  slug = slugify(slug);
                }
                if (slug && slug.length > 100) {
                  slug = slug.substring(0, 100).replace(/-+$/, '');
                }
                return {
                  ...item,
                  slug: slug
                };
              });
              const saintsRaw = cachePayload.saintsRaw || [];
              const combined = [...verses, ...saintsRaw];

              const totalItems = combined.length;
              for (let i = 0; i < totalItems; i += 500) {
                const end = Math.min(i + 500, totalItems);
                console.log(`[DataCache] Initializing memory cache... Loaded ${end} / ${totalItems} items`);
              }

              const relations = buildRelations(combined);

              contentCache = {
                items: combined,
                verses: verses,
                saints: relations.saints,
                books: relations.books,
                ragas: relations.ragas
              };

              loadedFromCache = true;
              console.log(`[DataCache] Successfully loaded and mapped flat cache in ${Date.now() - startTime}ms.`);
              writeBackupFile(contentCache.verses, false);
              if (typeof global !== 'undefined') global.contentCache = contentCache;
              return contentCache;
            } else {
              console.log(`[DataCache] Processed cache is stale (Age: ${Math.round(age / 1000)}s, TTL: ${ttl / 1000}s). Rebuilding...`);
            }
          } catch (readErr) {
            console.warn("[DataCache] Cache loading bypassed or failed, rebuilding:", readErr.message || readErr);
          }
        }

        console.log("[DataCache] Rebuilding data graph from scratch...");
        const startTime = Date.now();
        const localData = loadLocalJSONFallback();
        let remoteItems = await fetchAllFromDataConnect();

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
          const totalItems = combined.length;
          for (let i = 0; i < totalItems; i += 500) {
            const end = Math.min(i + 500, totalItems);
            console.log(`[DataCache] Initializing memory cache... Loaded ${end} / ${totalItems} items`);
          }
          const relations = buildRelations(combined);

          contentCache = {
            items: combined,
            verses: remoteItems,
            saints: relations.saints,
            books: relations.books,
            ragas: relations.ragas
          };

          try {
            console.log(`[DataCache] Saving flat cache layout to: ${cacheFile}...`);
            const cachePayload = {
              verses: remoteItems,
              saintsRaw: rawSaints
            };
            fs.writeFileSync(cacheFile, JSON.stringify(cachePayload), 'utf8');
            writeBackupFile(remoteItems, true); // Force update backup when cache is completely rebuilt
          } catch (writeErr) {
            console.warn("[DataCache] Could not write processed cache file:", writeErr);
          }

          console.log(`[DataCache] Cache built from scratch in ${Date.now() - startTime}ms.`);
          if (typeof global !== 'undefined') global.contentCache = contentCache;
          return contentCache;
        } else {
          contentCache = localData;
          writeBackupFile(localData.verses, true);
          console.log(`[DataCache] Falling back to local data. Cache built in ${Date.now() - startTime}ms.`);
          if (typeof global !== 'undefined') global.contentCache = contentCache;
          return contentCache;
        }
      } catch (err) {
        console.warn("[DataCache] Load failed, falling back to local dataset:", err);
      }
    }

    const localData = loadLocalJSONFallback();
    contentCache = localData;
    if (typeof global !== 'undefined') global.contentCache = contentCache;
    return contentCache;
  })();

  if (typeof global !== 'undefined') global.initializationPromise = initializationPromise;
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
      slug: (item.slug && !item.slug.startsWith('untitled')) ? item.slug : slugify(transliterate(cleanTitle))
    };

    const lightweightItem = {
      id: enrichedItem.id,
      slug: enrichedItem.slug,
      category: enrichedItem.category || 'poem',
      audio_url: enrichedItem.audio_url || '',
      cleanTitle: enrichedItem.cleanTitle || '',
      hindi_text: enrichedItem.hindi_text ? enrichedItem.hindi_text.substring(0, 150) + (enrichedItem.hindi_text.length > 150 ? '...' : '') : '',
      english_translation: enrichedItem.english_translation ? enrichedItem.english_translation.substring(0, 150) + (enrichedItem.english_translation.length > 150 ? '...' : '') : '',
      description: enrichedItem.description ? enrichedItem.description.substring(0, 150) + (enrichedItem.description.length > 150 ? '...' : '') : '',
      isLightweight: true
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
      santsMap[santSlug].verses.push(lightweightItem);
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
          hinglishName: transliterate(normalizedBName),
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
      booksMap[bookSlug].verses.push(lightweightItem);
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
      ragasMap[ragaName].verses.push(lightweightItem);
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
      hinglishName: 'Seva Kunj Literature',
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
  const { verses } = loadRawData(false);
  return verses;
}

export function getAllVersesLightweight() {
  const { verses } = loadRawData(false);
  return verses.map(v => ({
    id: v.id,
    slug: v.slug,
    category: v.category || 'poem',
    audio_url: v.audio_url || '',
    title: v.title || '',
    author: v.author || '',
    hindi_text: v.hindi_text ? v.hindi_text.substring(0, 200) + (v.hindi_text.length > 200 ? '...' : '') : '',
    sanskrit_text: v.sanskrit_text ? v.sanskrit_text.substring(0, 200) + (v.sanskrit_text.length > 200 ? '...' : '') : '',
    english_translation: v.english_translation ? v.english_translation.substring(0, 200) + (v.english_translation.length > 200 ? '...' : '') : '',
    description: v.description ? v.description.substring(0, 200) + (v.description.length > 200 ? '...' : '') : ''
  }));
}

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

export function getVerseBySlug(slug) {
  const { verses } = loadRawData(false);
  const decodedSlug = decodeURIComponent(slug).toLowerCase();
  const cleanSlug = sanitizeSlug(decodedSlug);

  const decodedClean = decodedSlug.replace(/-+$/, '');
  const cleanSlugClean = cleanSlug.replace(/-+$/, '');

  // 1. Try exact match
  let matched = verses.find(item => {
    const itemSlug = (item.slug || '').toLowerCase();
    const itemSlugClean = itemSlug.replace(/-+$/, '');
    return itemSlugClean === decodedClean ||
      itemSlugClean === cleanSlugClean ||
      (item.id?.toString() === decodedSlug);
  });
  if (matched) return matched;

  // 2. Transliterate search slug if it contains Devanagari
  let searchSlug = decodedSlug;
  if (/[^\x00-\x7F]/.test(decodedSlug)) {
    const cleanForTransliterate = decodedSlug.replace(/-/g, ' ');
    searchSlug = generateSlug(cleanForTransliterate);

    // 2a. Match transliterated slug exactly
    matched = verses.find(item => {
      const itemSlug = (item.slug || '').toLowerCase();
      const itemSlugClean = itemSlug.replace(/-+$/, '');
      const searchSlugClean = searchSlug.replace(/-+$/, '');
      return itemSlugClean === searchSlugClean;
    });
    if (matched) return matched;

    // 2b. Match transliterated slug against transliterated item titles
    matched = verses.find(item => {
      if (!item.title) return false;
      const itemTitleTransliterated = generateSlug(item.title);
      return itemTitleTransliterated === searchSlug;
    });
    if (matched) return matched;
  }

  // 3. Try spelling-insensitive normalized fuzzy match
  const normDecoded = normalizeFuzzyText(searchSlug);
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
        (normDecoded.length > 5 && (normItem.includes(normDecoded) || normDecoded.includes(normItem)));
    });
    if (matched) return matched;

    // 3b. Try fuzzy match on transliterated title
    matched = verses.find(item => {
      if (!item.title) return false;
      const normTitle = normalizeFuzzyText(generateSlug(item.title));
      return normTitle === normDecoded ||
        normTitle.startsWith(normDecoded) ||
        normDecoded.startsWith(normTitle) ||
        (normDecoded.length > 5 && (normTitle.includes(normDecoded) || normDecoded.includes(normTitle)));
    });
    if (matched) return matched;
  }

  // 4. Try consonantal skeleton match for Devanagari transliteration differences
  const skeleton = (str) => str.toLowerCase().replace(/[^a-z0-9]/g, '').replace(/[aeiouy]/g, '');
  const decodedSkeleton = skeleton(searchSlug);

  if (decodedSkeleton && decodedSkeleton.length > 3) {
    matched = verses.find(item => {
      if (!item.slug) return false;
      const itemSkeleton = skeleton(item.slug);
      return itemSkeleton === decodedSkeleton ||
        itemSkeleton.startsWith(decodedSkeleton) ||
        decodedSkeleton.startsWith(itemSkeleton) ||
        (decodedSkeleton.length > 5 && (itemSkeleton.includes(decodedSkeleton) || decodedSkeleton.includes(itemSkeleton)));
    });
    if (matched) return matched;
  }

  return null;
}

export function getAllSaints() {
  const { saints } = loadRawData(false);
  return saints;
}

export function getSaintBySlug(slug) {
  const { saints } = loadRawData(false);
  const decodedSlug = decodeURIComponent(slug).toLowerCase();

  let matched = saints.find(s => s.slug.toLowerCase() === decodedSlug);
  if (matched) return matched;

  // Try using getNormalizedSaintSlug directly
  const normSaintSlug = getNormalizedSaintSlug(decodedSlug);
  matched = saints.find(s => s.slug.toLowerCase() === normSaintSlug);
  if (matched) return matched;

  // Transliterate if Devanagari
  let searchSlug = decodedSlug;
  if (/[^\x00-\x7F]/.test(decodedSlug)) {
    const cleanForTransliterate = decodedSlug.replace(/-/g, ' ');
    searchSlug = generateSlug(cleanForTransliterate);
    matched = saints.find(s => s.slug.toLowerCase() === searchSlug || s.slug.toLowerCase() === searchSlug.replace(/-maharaj$/, ''));
    if (matched) return matched;

    const normSearchSaintSlug = getNormalizedSaintSlug(searchSlug);
    matched = saints.find(s => s.slug.toLowerCase() === normSearchSaintSlug);
    if (matched) return matched;
  }

  const cleanSlug = searchSlug.replace(/-maharaj$/, '');

  // Try spelling-insensitive normalized match
  const normDecoded = normalizeFuzzyText(searchSlug);
  const normClean = normalizeFuzzyText(cleanSlug);

  if (normDecoded) {
    matched = saints.find(s => {
      const normItem = normalizeFuzzyText(s.slug);
      return normItem === normDecoded ||
        normItem === normClean ||
        normItem.startsWith(normDecoded) ||
        normDecoded.startsWith(normItem) ||
        normItem.includes(normClean) ||
        normClean.includes(normItem);
    });
    if (matched) return matched;
  }

  // Try consonantal skeleton match fallback
  const skeleton = (str) => str.toLowerCase().replace(/[^a-z0-9]/g, '').replace(/[aeiouy]/g, '');
  const decodedSkeleton = skeleton(searchSlug);
  const cleanSkeleton = skeleton(cleanSlug);
  if (decodedSkeleton && decodedSkeleton.length > 3) {
    matched = saints.find(s => {
      const itemSkeleton = skeleton(s.slug);
      return itemSkeleton === decodedSkeleton ||
        itemSkeleton === cleanSkeleton ||
        itemSkeleton.startsWith(decodedSkeleton) ||
        decodedSkeleton.startsWith(itemSkeleton) ||
        itemSkeleton.includes(cleanSkeleton) ||
        cleanSkeleton.includes(itemSkeleton);
    });
    if (matched) return matched;
  }

  return null;
}

export function getAllGranthas() {
  const { books } = loadRawData(false);
  return books;
}

export function getGranthaBySlug(slug) {
  const { books } = loadRawData(false);
  const decodedSlug = decodeURIComponent(slug).toLowerCase();

  // 1. Try exact match
  let matched = books.find(b => b.slug.toLowerCase() === decodedSlug);
  if (matched) return matched;

  // Transliterate if Devanagari
  let searchSlug = decodedSlug;
  if (/[^\x00-\x7F]/.test(decodedSlug)) {
    const cleanForTransliterate = decodedSlug.replace(/-/g, ' ');
    searchSlug = generateSlug(cleanForTransliterate);
    matched = books.find(b => b.slug.toLowerCase() === searchSlug);
    if (matched) return matched;
  }

  // 2. Try spelling-insensitive normalized match
  const normDecoded = normalizeFuzzyText(searchSlug);
  if (normDecoded) {
    matched = books.find(b => {
      if (!b.slug) return false;
      const normItem = normalizeFuzzyText(b.slug);
      return normItem === normDecoded ||
        normItem.startsWith(normDecoded) ||
        normDecoded.startsWith(normItem) ||
        (normDecoded.length > 5 && (normItem.includes(normDecoded) || normDecoded.includes(normItem)));
    });
    if (matched) return matched;
  }

  // Try consonantal skeleton match fallback
  const skeleton = (str) => str.toLowerCase().replace(/[^a-z0-9]/g, '').replace(/[aeiouy]/g, '');
  const decodedSkeleton = skeleton(searchSlug);
  if (decodedSkeleton && decodedSkeleton.length > 3) {
    matched = books.find(b => {
      if (!b.slug) return false;
      const itemSkeleton = skeleton(b.slug);
      return itemSkeleton === decodedSkeleton ||
        itemSkeleton.startsWith(decodedSkeleton) ||
        decodedSkeleton.startsWith(itemSkeleton) ||
        (decodedSkeleton.length > 5 && (itemSkeleton.includes(decodedSkeleton) || decodedSkeleton.includes(itemSkeleton)));
    });
    if (matched) return matched;
  }

  return null;
}

export function getAllRagas() {
  const { ragas } = loadRawData(false);
  return ragas;
}

export function getRagaBySlug(slug) {
  const { ragas } = loadRawData(false);
  const decodedSlug = decodeURIComponent(slug).toLowerCase();

  // 1. Try exact match
  let matched = ragas.find(r => r.slug.toLowerCase() === decodedSlug);
  if (matched) return matched;

  // Transliterate if Devanagari
  let searchSlug = decodedSlug;
  if (/[^\x00-\x7F]/.test(decodedSlug)) {
    const cleanForTransliterate = decodedSlug.replace(/-/g, ' ');
    searchSlug = generateSlug(cleanForTransliterate);
    matched = ragas.find(r => r.slug.toLowerCase() === searchSlug);
    if (matched) return matched;
  }

  // 2. Try spelling-insensitive normalized match
  const normDecoded = normalizeFuzzyText(searchSlug);
  if (normDecoded) {
    matched = ragas.find(r => {
      if (!r.slug) return false;
      const normItem = normalizeFuzzyText(r.slug);
      return normItem === normDecoded ||
        normItem.startsWith(normDecoded) ||
        normDecoded.startsWith(normItem) ||
        (normDecoded.length > 5 && (normItem.includes(normDecoded) || normDecoded.includes(normItem)));
    });
    if (matched) return matched;
  }
  return null;
}

export function getGlossaryTerms() {
  return GLOSSARY_TERMS;
}

export function getGlossaryTermBySlug(slug) {
  const decodedSlug = decodeURIComponent(slug).toLowerCase();
  let matched = GLOSSARY_TERMS.find(term => term.slug.toLowerCase() === decodedSlug);
  if (matched) return matched;

  // Transliterate if Devanagari
  let searchSlug = decodedSlug;
  if (/[^\x00-\x7F]/.test(decodedSlug)) {
    const cleanForTransliterate = decodedSlug.replace(/-/g, ' ');
    searchSlug = generateSlug(cleanForTransliterate);
    matched = GLOSSARY_TERMS.find(term => term.slug.toLowerCase() === searchSlug);
    if (matched) return matched;
  }

  // Fuzzy match
  const normDecoded = normalizeFuzzyText(searchSlug);
  if (normDecoded) {
    matched = GLOSSARY_TERMS.find(term => {
      const normTerm = normalizeFuzzyText(term.slug);
      return normTerm === normDecoded ||
        normTerm.startsWith(normDecoded) ||
        normDecoded.startsWith(normTerm);
    });
    if (matched) return matched;
  }
  return null;
}
