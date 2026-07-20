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

function normalizeForFuzzy(str) {
  if (!str) return '';
  return str
    .toLowerCase()
    .replace(/v/g, 'b')
    .replace(/sh/g, 's')
    .replace(/oo/g, 'u')
    .replace(/ee/g, 'i')
    .replace(/aa/g, 'a')
    .replace(/kh/g, 'k')
    .replace(/gh/g, 'g')
    .replace(/ch/g, 'c')
    .replace(/jh/g, 'j')
    .replace(/th/g, 't')
    .replace(/dh/g, 'd')
    .replace(/ph/g, 'f')
    .replace(/bh/g, 'b')
    .replace(/(.)\1+/g, '$1') // Remove double characters
    .replace(/[^a-z0-9]/g, '') // Keep alphanumeric only
    .trim();
}

function loadLocalJSONFallback() {
  const appDirectory = process.cwd();

  let contentPath = path.join(appDirectory, 'data/vrindavaani_content.json');
  if (!fs.existsSync(contentPath)) {
    contentPath = path.join(appDirectory, 'frontend/data/vrindavaani_content.json');
  }
  if (!fs.existsSync(contentPath)) {
    contentPath = path.join(appDirectory, 'public/data/content_backup.json');
  }
  if (!fs.existsSync(contentPath)) {
    contentPath = path.join(appDirectory, 'frontend/public/data/content_backup.json');
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
          if (slug.length > 100) {
            slug = slug.substring(0, 100).replace(/-+$/, '');
          }
        }
        const title = item.title || '';
        let cleanTitle = title;
        const realParts = title.split(/\s+-\s+/);
        if (realParts.length >= 2) {
          cleanTitle = realParts[0].trim();
        }
        const normalizedTags = !item.tags ? [] : Array.isArray(item.tags) ? item.tags : String(item.tags).split(',').map(t => t.trim()).filter(Boolean);

        // Pre-compute search fields
        const sansFirstLine = item.sanskrit_text ? item.sanskrit_text.split(/[\n।॥]/).map(l => l.trim()).filter(Boolean)[0] || '' : '';
        const hindiFirstLine = item.hindi_text ? item.hindi_text.split(/[\n।॥]/).map(l => l.trim()).filter(Boolean)[0] || '' : '';

        const _textDevanagari = [
          title,
          item.name,
          item.hindi_text,
          item.sanskrit_text,
          item.author,
          item.description,
          cleanCategory,
          sansFirstLine,
          hindiFirstLine
        ].filter(Boolean).join(' ').toLowerCase();

        const _textHinglish = [
          item.hinglishName,
          transliterate(title),
          transliterate(item.name || ''),
          transliterate(item.author || ''),
          transliterate(item.description || ''),
          transliterate(sansFirstLine),
          transliterate(hindiFirstLine),
          item.english_translation,
          item.english_text,
          slug,
          ...(normalizedTags)
        ].filter(Boolean).join(' ').toLowerCase();

        const _normalizedHinglish = normalizeForFuzzy(_textHinglish);

        return {
          id: item.id || `local-${idx}`,
          ...item,
          tags: normalizedTags,
          category: cleanCategory,
          cleanTitle: cleanTitle,
          slug: slug,
          _textDevanagari,
          _textHinglish,
          _normalizedHinglish
        };
      });
    }

    let rawSaints = [];
    if (fs.existsSync(saintsPath)) {
      const rawSaintsData = fs.readFileSync(saintsPath, 'utf8');
      rawSaints = JSON.parse(rawSaintsData).map((saint, idx) => {
        const nameVal = saint.name || saint.title || '';
        const bioText = saint.biography || saint.hindi_text || saint.description || '';
        const saintSlug = saint.slug || generateSlug(nameVal);
        const hinglishSaintName = saint.hinglishName || transliterate(nameVal);

        const _textDevanagari = [
          nameVal,
          bioText,
          saint.author,
          saint.description,
          'saint'
        ].filter(Boolean).join(' ').toLowerCase();

        const _textHinglish = [
          hinglishSaintName,
          transliterate(nameVal),
          transliterate(bioText),
          transliterate(saint.description || ''),
          saintSlug
        ].filter(Boolean).join(' ').toLowerCase();

        const _normalizedHinglish = normalizeForFuzzy(_textHinglish);

        return {
          id: saint.id || `saint-local-${idx}`,
          ...saint,
          name: nameVal,
          hinglishName: hinglishSaintName,
          biography: bioText,
          category: 'saint',
          slug: saintSlug,
          _textDevanagari,
          _textHinglish,
          _normalizedHinglish
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

  // Try to load prebuilt processed cache synchronously to bypass slow relation building
  try {
    const cacheFile = getProcessedCacheFilePath();
    if (fs.existsSync(cacheFile)) {
      const rawCache = fs.readFileSync(cacheFile, 'utf8');
      const cachePayload = JSON.parse(rawCache);
      if (cachePayload.isFullyCompiled) {
        const verses = cachePayload.verses || [];
        const saintsRaw = cachePayload.saintsRaw || [];
        const data = {
          items: [...verses, ...saintsRaw],
          verses: verses,
          saints: cachePayload.saints || [],
          books: cachePayload.books || [],
          ragas: cachePayload.ragas || []
        };
        localFallbackCache = data;
        contentCache = data;
        if (typeof global !== 'undefined') {
          global.localFallbackCache = data;
          global.contentCache = data;
        }
        return data;
      }
    }
  } catch (e) {
    console.warn("[DataCache] Synchronous cache load failed, falling back:", e);
  }

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

    // Helper: strip a verse to lightweight card fields only
    const toLightweight = (v) => ({
      id: v.id,
      title: v.title,
      slug: v.slug,
      category: v.category,
      author: v.author,
      cleanTitle: v.cleanTitle,
      sanskrit_text: (v.sanskrit_text || '').substring(0, 100),
      tags: v.tags,
      audio_url: v.audio_url ? true : undefined,
      image_urls: v.image_urls?.length ? true : undefined,
      video_urls: v.video_urls?.length ? true : undefined,
    });

    // Split and write category-specific index files (lightweight, ~2MB each)
    const categories = ['shloka', 'strotra', 'poem', 'saint', 'dham'];
    categories.forEach(cat => {
      const indexFile = path.join(dataDir, `content_index_${cat}.json`);
      if (force || !fs.existsSync(indexFile)) {
        const catVerses = verses.filter(v => {
          const itemCat = classifyItemCategory(v);
          return itemCat === cat;
        });
        const lightweightVerses = catVerses.map(toLightweight);
        console.log(`[DataCache] Saving lightweight index [${cat}] (${lightweightVerses.length} items) to: ${indexFile}...`);
        try {
          fs.writeFileSync(indexFile, JSON.stringify(lightweightVerses), 'utf8');
        } catch (err) {
          console.warn(`[DataCache] Index write failed for ${cat}:`, err);
        }
      }
    });

    // Write a smaller backup for the home screen (latest 100 items)
    const homeFile = path.join(dataDir, 'content_backup_home.json');
    if (force || !fs.existsSync(homeFile)) {
      console.log(`[DataCache] Saving home screen backup (first 100 items) to: ${homeFile}...`);
      const homeVerses = verses.slice(0, 100).map(toLightweight);
      try {
        fs.writeFileSync(homeFile, JSON.stringify(homeVerses), 'utf8');
      } catch (err) {
        console.warn("[DataCache] Home backup write failed:", err);
      }
    }

    // Pre-compute and save relations
    const relationsFile = path.join(dataDir, 'relations_backup.json');
    if (force || !fs.existsSync(relationsFile)) {
      console.log(`[DataCache] Pre-computing and saving relations backup to: ${relationsFile}...`);
      const relations = extractRelations(verses);
      try {
        fs.writeFileSync(relationsFile, JSON.stringify(relations), 'utf8');
      } catch (err) {
        console.warn("[DataCache] Relations backup write failed:", err);
      }
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

        if (fs.existsSync(cacheFile)) {
          try {
            const stat = fs.statSync(cacheFile);
            const now = Date.now();
            const age = now - stat.mtimeMs;
            const isDev = process.env.NODE_ENV === 'development';
            const ttl = isDev ? CACHE_TTL_DEV : CACHE_TTL_PROD;

            const rawCache = fs.readFileSync(cacheFile, 'utf8');
            const cachePayload = JSON.parse(rawCache);

            if (cachePayload.isFullyCompiled) {
              console.log(`[DataCache] Loading pre-compiled cache from file: ${cacheFile} (Age: ${Math.round(age / 1000)}s)...`);
              const startTime = Date.now();
              const verses = cachePayload.verses || [];
              const saintsRaw = cachePayload.saintsRaw || [];
              contentCache = {
                items: [...verses, ...saintsRaw],
                verses: verses,
                saints: cachePayload.saints || [],
                books: cachePayload.books || [],
                ragas: cachePayload.ragas || []
              };
              console.log(`[DataCache] Successfully loaded pre-compiled cache in ${Date.now() - startTime}ms.`);
              if (typeof global !== 'undefined') global.contentCache = contentCache;
              return contentCache;
            }
          } catch (readErr) {
            console.warn("[DataCache] Precompiled cache load failed, rebuilding:", readErr.message || readErr);
          }
        }

        console.log("[DataCache] Rebuilding data graph from scratch...");
        const startTime = Date.now();
        const localData = loadLocalJSONFallback();
        
        contentCache = localData;
        writeBackupFile(localData.verses, true);
        console.log(`[DataCache] Falling back to local data. Cache built in ${Date.now() - startTime}ms.`);

        try {
          console.log(`[DataCache] Saving fully compiled cache fallback to: ${cacheFile}...`);
          const cachePayload = {
            verses: contentCache.verses,
            saintsRaw: contentCache.items.filter(item => item.category === 'saint'),
            saints: contentCache.saints,
            books: contentCache.books,
            ragas: contentCache.ragas,
            isFullyCompiled: true
          };
          fs.writeFileSync(cacheFile, JSON.stringify(cachePayload), 'utf8');
        } catch (writeErr) {
          console.warn("[DataCache] Could not write processed cache file:", writeErr);
        }

        if (typeof global !== 'undefined') global.contentCache = contentCache;
        return contentCache;
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

const VALID_RAGAS = new Set([
  'कल्याण', 'कल्यान', 'केदार', 'केदारो', 'केदारौ', 'नट', 'सारंग', 'बिलावल', 'विलावल', 'काफी', 'काफ़ी', 'काफ़ी', 
  'ललित', 'भैरव', 'भैरवी', 'भैरो', 'भैरों', 'भैरौं', 'भैंरु', 'सोरठ', 'सोरठा', 'सोरठि', 'मल्हार', 'मलार', 'मलहार', 
  'आसावरी', 'असावरी', 'आसावारी', 'हिंडोल', 'हिंडोरा', 'विभास', 'बिभास', 'परज', 'खमाच', 'खमाज', 'खमांच', 'खम्माच', 'खम्माज', 
  'बिहाग', 'विहाग', 'बिहागरो', 'बिहागरौ', 'विहागरो', 'विहागरौ', 'विहगरौ', 'यमन', 'ईमन', 'टोड़ी', 'तोड़ी', 'टोडी', 
  'धनाश्री', 'कान्हरा', 'कान्हरो', 'कान्हरौ', 'कान्हरौं', 'कानरा', 'कानरौ', 'कानहरौ', 'कानहारौं', 'कन्हारो', 'जयजयवन्ती', 
  'जयजयवंती', 'जैजैवंती', 'जैजैवन्ती', 'बागेश्री', 'देश', 'देस', 'पीलू', 'वृंदावनी', 'रामकली', 'रामग्री', 'देवगंधार', 
  'देवगन्धार', 'सुहा', 'सुहाई', 'जैतश्री', 'जयतिश्री', 'मांड', 'माँड़', 'मारू', 'मालकौंस', 'मालकोंस', 'मालकोश', 'मालकोस', 
  'मालकौस', 'श्री', 'अड़ाना', 'अड़ानो', 'अडानो', 'सिंधुरा', 'जौनपुरी', 'गूजरी', 'गोंड', 'गोड', 'गौड', 'गौड़', 'गौरी', 
  'गोरी', 'गौर', 'कामोद', 'जंगला', 'झंझोटी', 'झँझोटी', 'झंझौटी', 'झिंझोटी', 'दरबारी', 'तिलककामोद', 'बहार', 'भीमपलासी', 
  'भूपाल', 'भूपली', 'भुपाली', 'मेघ', 'हमीर', 'प्रभाती', 'अलहिया', 'अहीर', 'कलावती', 'कलिंगडा', 'कलिंगड़ा', 'कालंगड़ा', 
  'कालिंगड़ा', 'कालिंगडा', 'खंजनाक्षी', 'खट', 'खाट', 'खिमटासिंधुका', 'गंधार', 'गन्धार', 'चर्चरी', 'चैती', 'ज़िला', 
  'जिला', 'जै', 'तेतालौ', 'टेटलौ', 'धमाल', 'ध्रुपद', 'नाइकी', 'नायकी', 'नारायणी', 'पंचम', 'पटदीप', 'पूरबी', 'पूरवी', 
  'पूरिया', 'पूर्वी', 'बरवा', 'बसंत', 'बसन्त', 'वसंत', 'वसन्त', 'भाल', 'मरवा', 'मालव', 'मुलतानी', 'मुल्तानी', 'योगिया', 
  'ललित', 'लावनी', 'शहानौ', 'श्यामकल्याण', 'हमीर', 'हल्हैया'
]);

function extractCleanRaga(textSanskrit, textHindi, title) {
  const testExtract = (text) => {
    if (!text) return null;
    const lines = text.split('\n').map(l => l.trim()).filter(Boolean).slice(0, 3);
    for (const line of lines) {
      const lineRegex = /^[([]?\s*(राग\s+[^\s,;()\]\-]+)/;
      const match = line.match(lineRegex);
      if (match) return match[1];
    }
    return null;
  };

  const titleRegex = /(?:-\s*|,\s*|\s+)(राग\s+[^\s,;()\-]+)/;
  const cleanTitle = title || '';
  const titleMatch = cleanTitle.match(titleRegex);
  let candidate = null;
  if (titleMatch) {
    candidate = titleMatch[1];
  } else {
    candidate = testExtract(textSanskrit) || testExtract(textHindi);
  }

  if (candidate) {
    const rawRaga = candidate.split(/[,]/)[0].trim();
    const nameWithoutPrefix = rawRaga.replace(/^राग\s+/, '').trim();
    if (VALID_RAGAS.has(nameWithoutPrefix)) {
      return rawRaga;
    }
  }
  return null;
}

function buildRelations(items) {
  const santsMap = {};
  const booksMap = {};
  const ragasMap = {};
  const biographies = [];

  items.forEach(item => {
    if (item.category?.toLowerCase() === 'saint') {
      const nameVal = item.name || item.title || '';
      const cleanName = nameVal.replace(/\([^)]+\)/g, '').replace(/महाप्रभु/g, '').trim();
      const saintSlug = getNormalizedSaintSlug(cleanName);
      biographies.push({
        name: cleanName,
        slug: saintSlug,
        text: item.biography || item.hindi_text || item.description || '',
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

    if (!saintName && item.author && item.author !== 'Team VrindaVaani') {
      saintName = item.author;
    }

    if (saintName && /^[0-9\s\(\)\-\.#]+$/.test(saintName)) {
      saintName = null;
    }

    const ragaName = extractCleanRaga(item.sanskrit_text, item.hindi_text, title);

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
    saints: Object.values(santsMap)
      .filter(s => !/^[0-9\s\(\)\-\.#]+$/.test(s.name) && s.name.trim() !== "")
      .map(s => ({ ...s, books: Array.from(s.books) })),
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

  // Try sri/shri/shree transliteration variants
  const sriVariants = [
    decodedSlug.replace(/\bsri-/g, 'shri-'),
    decodedSlug.replace(/\bshri-/g, 'sri-'),
    decodedSlug.replace(/\bshree-/g, 'shri-'),
    decodedSlug.replace(/\bsri-/g, 'shree-'),
    decodedSlug.replace(/\bshri-/g, 'shree-'),
    decodedSlug.replace(/\bshree-/g, 'sri-'),
  ];
  for (const variant of sriVariants) {
    matched = saints.find(s => s.slug.toLowerCase() === variant);
    if (matched) return matched;
  }

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
