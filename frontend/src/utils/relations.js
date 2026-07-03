import { transliterate } from './transliterate.js';

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

let lastItemsRef = null;
let lastResult = null;
let globalRelationsCache = null;

export function extractRelations(items) {
  if (!items || !items.length) {
    return { sants: [], books: [], ragas: [] };
  }

  if (items === lastItemsRef && lastResult) {
    return lastResult;
  }

  if (lastItemsRef && items.length === lastItemsRef.length && items.length > 0) {
    if (items[0] === lastItemsRef[0] && items[items.length - 1] === lastItemsRef[lastItemsRef.length - 1]) {
      lastItemsRef = items; 
      return lastResult;
    }
  }

  const cacheKey = 'sv_extracted_relations_cache';
  if (typeof window !== 'undefined') {
    try {
      if (!globalRelationsCache) {
        const localCached = localStorage.getItem(cacheKey);
        if (localCached) {
          globalRelationsCache = JSON.parse(localCached);
        }
      }
      if (globalRelationsCache) {
        if (
          globalRelationsCache.itemsLength === items.length &&
          globalRelationsCache.firstId === items[0]?.id &&
          globalRelationsCache.lastId === items[items.length - 1]?.id
        ) {
          lastItemsRef = items;
          lastResult = globalRelationsCache.data;
          return globalRelationsCache.data;
        }
      }
    } catch (e) {
      console.warn('Failed to parse persistent relations cache:', e);
    }
  }

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
        id: item.id,
        slug: saintSlug,
        originalTitle: title,
        name: cleanName,
        hinglishName: transliteratedName,
        text: item.hindi_text || item.description || '',
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
          books: new Set(),
          biography: matchedBio || null
        };
      }
      santsMap[santSlug].verseIds.push(item.id);
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
          verseIds: []
        };
      } else {
        if (saintName && booksMap[bookSlug].author === 'Unknown') {
          booksMap[bookSlug].author = saintName;
          booksMap[bookSlug].authorSlug = getNormalizedSaintSlug(saintName);
        }
      }
      booksMap[bookSlug].verseIds.push(item.id);
    }

    if (ragaName) {
      const ragaSlug = slugify(transliterate(ragaName));
      if (!ragasMap[ragaName]) {
        ragasMap[ragaName] = {
          name: ragaName,
          slug: ragaSlug,
          hinglishName: transliterate(ragaName),
          verseIds: []
        };
      }
      ragasMap[ragaName].verseIds.push(item.id);
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

  const result = { sants, books, ragas };
  lastItemsRef = items;
  lastResult = result;

  if (typeof window !== 'undefined') {
    try {
      const cacheData = {
        itemsLength: items.length,
        firstId: items[0]?.id,
        lastId: items[items.length - 1]?.id,
        data: result
      };
      globalRelationsCache = cacheData;
      localStorage.setItem('sv_extracted_relations_cache', JSON.stringify(cacheData));
    } catch (e) {}
  }

  return result;
}

