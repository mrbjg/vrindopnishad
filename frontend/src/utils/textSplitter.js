// Utility to dynamically split concatenated English translations from Hindi/Sanskrit verses.
// Some database items have their English translation appended to the end of the `hindi_text` field.

const englishVocab = new Set([
  'the', 'and', 'you', 'of', 'is', 'in', 'that', 'to', 'it', 'for', 'are', 'as', 'with', 
  'o', 'may', 'i', 'who', 'be', 'this', 'have', 'his', 'her', 'by', 'my', 'your', 'brother', 
  'not', 'never', 'lord', 'god', 'divine', 'couple', 'she', 'he', 'love', 'lotus', 'feet', 
  'glory', 'upon', 'within', 'reside', 'always', 'glorious', 'whose', 'remain', 'says', 
  'pray', 'prays', 'worships', 'tastes', 'taste'
]);

/**
 * Splits concatenated English translation from Hindi/Sanskrit verses.
 * 
 * @param {string} text - The raw text from the database (e.g. hindi_text)
 * @returns {{verse: string, translation: string}} The split verse and English translation
 */
export const splitVerseAndTranslation = (text) => {
  if (!text) return { verse: '', translation: '' };

  // 1. Pre-process CamelCase and citation boundaries to insert newlines
  // This cleans up instances where newlines were stripped during data migration.
  let cleaned = text;

  // CamelCase transitions (lowercase followed by uppercase, including unicode capitals)
  cleaned = cleaned.replace(/([a-z])([A-ZŚĀĪŪṚṄÑṬḌṆT])/g, '$1\n$2');

  // Digit followed by uppercase letter (e.g. 49Even -> 49\nEven)
  cleaned = cleaned.replace(/([0-9])([A-ZŚĀĪŪṚṄÑṬḌṆT])/g, '$1\n$2');

  // Any parenthesized/bracketed citation followed directly by a capital letter
  cleaned = cleaned.replace(/(\([^)]+\)|\[[^\]]+\])([A-ZŚĀĪŪṚṄÑṬḌṆT])/g, '$1\n$2');

  // 2. Count English words to verify if there is an English translation in this text
  const words = cleaned.match(/\b[a-zA-Z]+\b/g) || [];
  const englishCount = words.filter(w => englishVocab.has(w.toLowerCase())).length;

  // If there are very few English vocabulary words, it's likely just Romanized Hindi/Sanskrit, so don't split.
  if (englishCount < 5) {
    return { verse: text, translation: '' };
  }

  let splitIdx = -1;

  // 3. Search for common attribution patterns
  // Pattern 1: Hyphen followed by known authors/sources, up to an optional citation, followed by English start
  const pattern1 = /(-\s*(?:Shri|Swami|Rasik|Siddha|Bhagat|Sant|Goswami|Chaitanya|Bhatt|Haridas|Hit|Kripalu|Jagadguru|Braj Ke|Lalit|Ali|Kishori|Biharin|Dhruvdas|Nagaridas|Ganga|Gopal|Prabodhanand|Vrindavan|Radha|Charandas|Sahajo|Dayabai|Mira|Kabir|Surdas|Tulsidas|Raskhan|Roop|Sri|Srimad|Bhaktiras|Kavi|Rasika|Aacharya|Rani)[^-]+?(?:\([^)]+\)|\[[^\]]+\])?)\s*(?=[A-ZŚĀĪŪṚṄÑṬḌṆT])/i;
  const match1 = cleaned.match(pattern1);
  if (match1) {
    const attr = match1[1];
    splitIdx = cleaned.indexOf(attr) + attr.length;
  } else {
    // Pattern 2: Search for citation like [1], [2], (34), followed by English start
    const pattern2 = /((?:\([^)]+\)|\[[^\]]+\])?\s*-\s*(?:Shri|Swami|Rasik|Siddha|Bhagat|Sant|Goswami|Chaitanya|Bhatt|Haridas|Hit|Kripalu|Jagadguru|Braj Ke|Lalit|Ali|Kishori|Biharin|Dhruvdas|Nagaridas|Ganga|Gopal|Prabodhanand|Vrindavan|Radha|Charandas|Sahajo|Dayabai|Mira|Kabir|Surdas|Tulsidas|Raskhan|Roop|Sri|Srimad|Bhaktiras|Kavi|Rasika|Aacharya|Rani)[^-]+?(?:\([^)]+\)|\[[^\]]+\])?)\s*(?=[A-ZŚĀĪŪṚṄÑṬḌṆT])/i;
    const match2 = cleaned.match(pattern2);
    if (match2) {
      const attr = match2[1];
      splitIdx = cleaned.indexOf(attr) + attr.length;
    } else {
      // Pattern 3: Search for citation ending at the end of a verse, before english starts
      const pattern3 = /((?:\([^)]+\)|\[[^\]]+\]))\s*(?=[A-ZŚĀĪŪṚṄÑṬḌṆT])/;
      const match3 = cleaned.match(pattern3);
      if (match3) {
        const cit = match3[1];
        splitIdx = cleaned.indexOf(cit) + cit.length;
      } else {
        // Pattern 4: Fallback - Line splitting heuristic
        const lines = cleaned.split(/\r?\n/);
        let splitLineIdx = -1;
        for (let i = 0; i < lines.length; i++) {
          const line = lines[i].trim();
          if (!line) continue;

          const lineWords = line.match(/\b[a-zA-Z]+\b/g) || [];
          if (lineWords.length === 0) continue;

          const lineEngCount = lineWords.filter(w => englishVocab.has(w.toLowerCase())).length;
          
          // If a line is clearly English
          if (lineEngCount >= 3 || (lineWords.length >= 4 && lineEngCount / lineWords.length > 0.4)) {
            splitLineIdx = i;
            break;
          }
        }
        if (splitLineIdx !== -1 && splitLineIdx > 0) {
          const verseLines = lines.slice(0, splitLineIdx);
          const translationLines = lines.slice(splitLineIdx);
          return {
            verse: verseLines.join('\n').trim(),
            translation: translationLines.join('\n').trim()
          };
        }
      }
    }
  }

  if (splitIdx !== -1 && splitIdx < cleaned.length && splitIdx > 10) {
    return {
      verse: cleaned.substring(0, splitIdx).trim(),
      translation: cleaned.substring(splitIdx).trim()
    };
  }

  return { verse: text, translation: '' };
};
