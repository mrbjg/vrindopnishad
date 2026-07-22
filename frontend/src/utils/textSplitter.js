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
 * Trims out any prose explanations, commentaries, or translations
 * that appear after the main verse attribution or verse body.
 * 
 * @param {string} text 
 * @returns {string} Clean verse text without explanations
 */
export const cleanVerseOnly = (text) => {
  if (!text) return '';

  let cleaned = text.trim();

  // Check for explicit prose commentary/translation headers like "भावार्थ:", "व्याख्या:", "Commentary:", "Explanation:"
  const headerMatch = cleaned.match(/(?:^|\n)\s*(?:भावार्थ|व्याख्या|विशेष|टीका|टिप्पणी|Commentary|Explanation|English Translation)\s*[:：]/i);
  if (headerMatch) {
    const headerIdx = cleaned.indexOf(headerMatch[0]);
    if (headerIdx > 10) {
      cleaned = cleaned.substring(0, headerIdx).trim();
    }
  }

  return cleaned;
};

/**
 * Splits concatenated English translation from Hindi/Sanskrit verses.
 * 
 * @param {string} text - The raw text from the database (e.g. hindi_text)
 * @returns {{verse: string, translation: string}} The split verse and English translation
 */
export const splitVerseAndTranslation = (text) => {
  if (!text) return { verse: '', translation: '' };

  // 1. Pre-process CamelCase and citation boundaries to insert newlines
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

  if (englishCount < 5) {
    return { verse: cleanVerseOnly(text), translation: '' };
  }

  let splitIdx = -1;

  // 3. Search for common attribution patterns
  const pattern1 = /(-\s*(?:Shri|Swami|Rasik|Siddha|Bhagat|Sant|Goswami|Chaitanya|Bhatt|Haridas|Hit|Kripalu|Jagadguru|Braj Ke|Lalit|Ali|Kishori|Biharin|Dhruvdas|Nagaridas|Ganga|Gopal|Prabodhanand|Vrindavan|Radha|Charandas|Sahajo|Dayabai|Mira|Kabir|Surdas|Tulsidas|Raskhan|Roop|Sri|Srimad|Bhaktiras|Kavi|Rasika|Aacharya|Rani)[^-]+?(?:\([^)]+\)|\[[^\]]+\])?)\s*(?=[A-ZŚĀĪŪṚṄÑṬḌṆT])/i;
  const match1 = cleaned.match(pattern1);
  if (match1) {
    const attr = match1[1];
    splitIdx = cleaned.indexOf(attr) + attr.length;
  } else {
    const pattern2 = /((?:\([^)]+\)|\[[^\]]+\])?\s*-\s*(?:Shri|Swami|Rasik|Siddha|Bhagat|Sant|Goswami|Chaitanya|Bhatt|Haridas|Hit|Kripalu|Jagadguru|Braj Ke|Lalit|Ali|Kishori|Biharin|Dhruvdas|Nagaridas|Ganga|Gopal|Prabodhanand|Vrindavan|Radha|Charandas|Sahajo|Dayabai|Mira|Kabir|Surdas|Tulsidas|Raskhan|Roop|Sri|Srimad|Bhaktiras|Kavi|Rasika|Aacharya|Rani)[^-]+?(?:\([^)]+\)|\[[^\]]+\])?)\s*(?=[A-ZŚĀĪŪṚṄÑṬḌṆT])/i;
    const match2 = cleaned.match(pattern2);
    if (match2) {
      const attr = match2[1];
      splitIdx = cleaned.indexOf(attr) + attr.length;
    } else {
      const pattern3 = /((?:\([^)]+\)|\[[^\]]+\]))\s*(?=[A-ZŚĀĪŪṚṄÑṬḌṆT])/;
      const match3 = cleaned.match(pattern3);
      if (match3) {
        const cit = match3[1];
        splitIdx = cleaned.indexOf(cit) + cit.length;
      } else {
        const lines = cleaned.split(/\r?\n/);
        let splitLineIdx = -1;
        for (let i = 0; i < lines.length; i++) {
          const line = lines[i].trim();
          if (!line) continue;

          const lineWords = line.match(/\b[a-zA-Z]+\b/g) || [];
          if (lineWords.length === 0) continue;

          const lineEngCount = lineWords.filter(w => englishVocab.has(w.toLowerCase())).length;
          
          if (lineEngCount >= 3 || (lineWords.length >= 4 && lineEngCount / lineWords.length > 0.4)) {
            splitLineIdx = i;
            break;
          }
        }
        if (splitLineIdx !== -1 && splitLineIdx > 0) {
          const verseLines = lines.slice(0, splitLineIdx);
          const translationLines = lines.slice(splitLineIdx);
          return {
            verse: cleanVerseOnly(verseLines.join('\n').trim()),
            translation: translationLines.join('\n').trim()
          };
        }
      }
    }
  }

  if (splitIdx !== -1 && splitIdx < cleaned.length && splitIdx > 10) {
    return {
      verse: cleanVerseOnly(cleaned.substring(0, splitIdx).trim()),
      translation: cleaned.substring(splitIdx).trim()
    };
  }

  return { verse: cleanVerseOnly(text), translation: '' };
};
