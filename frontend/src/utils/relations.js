import { transliterate } from './transliterate';


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

let lastItemsRef = null;
let lastResult = null;
let globalRelationsCache = null;


export function extractRelations(items) {
  if (!items || !items.length) {
    return { sants: [], books: [], ragas: [], biographies: [] };
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
      
      biographies.push({
        id: item.id,
        slug: item.slug || slugify(transliteratedName),
        originalTitle: title,
        name: cleanName,
        hinglishName: transliteratedName,
        text: item.hindi_text || item.description || '',
        tags: item.tags || [],
        image: item.image_url || null,
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
          if (val.includes('वाणी') || val.includes('सागर') || val.includes('शतक') || val.includes('महिमामृत') || val.includes('दोहे') || val.includes('ग्रंथावली') || val.includes('पदावली') || val.includes('शत')) {
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
          if (val.includes('वाणी') || val.includes('सागर') || val.includes('शतक') || val.includes('महिमामृत') || val.includes('दोहे')) {
            bookName = val;
          } else {
            saintName = val;
          }
        }
      }
    }

    
    if (!saintName && item.author && item.author !== 'Braj Rasik Heritage') {
      saintName = item.author;
    }

    
    let ragaName = null;
    const ragaRegex = /(राग\s+[^\s,;()-]+)/;
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
      const santSlug = slugify(transliterate(cleanSantKey));
      
      if (!santsMap[cleanSantKey]) {
        
        const matchedBio = biographies.find(bio => 
          bio.name.includes(cleanSantKey) || cleanSantKey.includes(bio.name)
        );

        santsMap[cleanSantKey] = {
          name: saintName,
          cleanName: cleanSantKey,
          slug: santSlug,
          hinglishName: transliterate(saintName),
          verses: [],
          books: new Set(),
          biography: matchedBio || null
        };
      }
      santsMap[cleanSantKey].verses.push(enrichedItem);
      if (bookName) santsMap[cleanSantKey].books.add(bookName);
    }

    
    if (bookName) {
      const bookSlug = slugify(transliterate(bookName));
      if (!booksMap[bookName]) {
        booksMap[bookName] = {
          name: bookName,
          slug: bookSlug,
          hinglishName: transliterate(bookName),
          author: saintName || 'Unknown',
          authorSlug: saintName ? slugify(transliterate(saintName.replace(/जी/g, '').trim())) : null,
          verses: []
        };
      }
      booksMap[bookName].verses.push(enrichedItem);
    }

    
    if (ragaName) {
      const ragaSlug = slugify(transliterate(ragaName));
      if (!ragasMap[ragaName]) {
        ragasMap[ragaName] = {
          name: ragaName,
          slug: ragaSlug,
          hinglishName: transliterate(ragaName),
          verses: []
        };
      }
      ragasMap[ragaName].verses.push(enrichedItem);
    }
  });

  
  const sants = Object.values(santsMap).map(s => ({
    ...s,
    books: Array.from(s.books)
  })).sort((a, b) => b.verses.length - a.verses.length);

  const books = Object.values(booksMap).sort((a, b) => b.verses.length - a.verses.length);
  const ragas = Object.values(ragasMap).sort((a, b) => b.verses.length - a.verses.length);

  const result = { sants, books, ragas, biographies };
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
