import { transliterate } from './transliterate';

// Helper to generate URL-friendly slug
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

// Main function to parse and extract relationships from the content library
export function extractRelations(items) {
  if (!items || !items.length) {
    return { sants: [], books: [], ragas: [], biographies: [] };
  }

  const santsMap = {};
  const booksMap = {};
  const ragasMap = {};
  const biographies = [];

  // 1. Separate Biographies (category === 'saint')
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

  // 2. Process Content Items & Extract Relations
  items.forEach(item => {
    if (item.category?.toLowerCase() === 'saint') return; // Skip biography items themselves

    const title = item.title || '';
    let cleanTitle = title;
    let saintName = null;
    let bookName = null;
    let verseNum = null;

    // Check for " - " separator
    const parts = title.split(/\s+-\s+/);
    if (parts.length >= 2) {
      cleanTitle = parts[0].trim();
      const relationText = parts[1].trim();

      // Extract verse number, e.g. (14.41) or (10)
      const verseMatch = relationText.match(/\(([^)]+)\)$/);
      if (verseMatch) {
        verseNum = verseMatch[1].trim();
        const textWithoutVerse = relationText.replace(/\(([^)]+)\)$/, '').trim();
        
        // Split by comma for Saint and Book
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
        // No verse number
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

    // Fallback if saintName is still null but item.author is valid
    if (!saintName && item.author && item.author !== 'Braj Rasik Heritage') {
      saintName = item.author;
    }

    // Extract Raga
    let ragaName = null;
    const ragaRegex = /(राग\s+[^\s,;()-]+)/;
    const matchTitle = title.match(ragaRegex);
    const matchSanskrit = item.sanskrit_text?.match(ragaRegex);
    const matchHindi = item.hindi_text?.match(ragaRegex);
    
    if (matchTitle) ragaName = matchTitle[1];
    else if (matchSanskrit) ragaName = matchSanskrit[1];
    else if (matchHindi) ragaName = matchHindi[1];

    if (ragaName) {
      // Clean up Raga name (e.g. "राग परज" instead of "राग परज, त्रिताल")
      ragaName = ragaName.split(/[,]/)[0].trim();
    }

    // Enrich the item
    const enrichedItem = {
      ...item,
      cleanTitle,
      parsedSaint: saintName,
      parsedBook: bookName,
      parsedVerse: verseNum,
      parsedRaga: ragaName,
      slug: item.slug || slugify(transliterate(cleanTitle))
    };

    // Add to Sants Map
    if (saintName) {
      const cleanSantKey = saintName.replace(/जी की वाणी/g, '').replace(/जी/g, '').replace(/महाप्रभु/g, '').trim();
      const santSlug = slugify(transliterate(cleanSantKey));
      
      if (!santsMap[cleanSantKey]) {
        // Try to find matching biography
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

    // Add to Books Map
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

    // Add to Ragas Map
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

  // Convert Sets to Arrays and structure final response
  const sants = Object.values(santsMap).map(s => ({
    ...s,
    books: Array.from(s.books)
  })).sort((a, b) => b.verses.length - a.verses.length);

  const books = Object.values(booksMap).sort((a, b) => b.verses.length - a.verses.length);
  const ragas = Object.values(ragasMap).sort((a, b) => b.verses.length - a.verses.length);

  return { sants, books, ragas, biographies };
}
