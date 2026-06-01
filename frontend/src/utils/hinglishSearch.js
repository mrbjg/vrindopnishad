import { transliterate } from './transliterate';

const HINGLISH_MAP = {
  'radha': ['राधा', 'राधे', 'राधिका'],
  'radhe': ['राधे', 'राधा', 'राधिका'],
  'radhika': ['राधिका', 'राधा'],
  'krishna': ['कृष्ण', 'कृष्णा', 'श्री कृष्ण'],
  'krishn': ['कृष्ण', 'कृष्णा'],
  'shyam': ['श्याम', 'श्यामा', 'श्याम सुन्दर'],
  'shyama': ['श्यामा', 'श्याम'],
  'govind': ['गोविन्द', 'गोविंद'],
  'govinda': ['गोविन्द', 'गोविंद', 'गोविन्दा'],
  'gopal': ['गोपाल'],
  'kanha': ['कान्हा', 'कन्हैया'],
  'kanhaiya': ['कन्हैया', 'कान्हा'],
  'murli': ['मुरली', 'मुरलीधर'],
  'murlidhar': ['मुरलीधर'],
  'mohan': ['मोहन'],
  'giridhar': ['गिरिधर', 'गिरधर'],
  'banke': ['बांके', 'बाँके'],
  'bihari': ['बिहारी', 'विहारी'],
  'nand': ['नंद', 'नन्द'],
  'yashoda': ['यशोदा'],
  'balram': ['बलराम'],
  'sita': ['सीता'],
  'ram': ['राम', 'श्री राम'],
  'shri': ['श्री', 'श्रि'],
  'hanuman': ['हनुमान'],
  'ganesh': ['गणेश', 'गणेशा'],
  'shiv': ['शिव', 'शिवा'],
  'mahadev': ['महादेव'],
  'durga': ['दुर्गा'],
  'lakshmi': ['लक्ष्मी'],
  'saraswati': ['सरस्वती'],
  'meera': ['मीरा', 'मीराबाई'],
  'mira': ['मीरा', 'मीराबाई'],
  'surdas': ['सूरदास', 'सूर'],
  'sur': ['सूर', 'सूरदास'],
  'tulsidas': ['तुलसीदास'],
  'kabir': ['कबीर', 'कबीरदास'],
  'premanand': ['प्रेमानंद', 'प्रेमानन्द'],
  'vrindavan': ['वृंदावन', 'वृन्दावन', 'ब्रिंदावन'],
  'brindavan': ['वृंदावन', 'वृन्दावन', 'ब्रिंदावन'],
  'braj': ['ब्रज', 'व्रज'],
  'barsana': ['बरसाना', 'बरसाने'],
  'nandgaon': ['नंदगांव', 'नन्दगाँव'],
  'nandgaav': ['नंदगांव', 'नन्दगाँव'],
  'govardhan': ['गोवर्धन', 'गोवर्द्धन'],
  'mathura': ['मथुरा'],
  'gokul': ['गोकुल'],
  'yamuna': ['यमुना'],
  'kunj': ['कुंज', 'कुञ्ज'],
  'nikunj': ['निकुंज', 'निकुञ्ज'],
  'mandir': ['मंदिर', 'मन्दिर'],
  'dham': ['धाम'],
  'ghat': ['घाट'],
  'van': ['वन'],
  'bhajan': ['भजन', 'भजनी'],
  'shloka': ['श्लोक', 'श्लोकी'],
  'shlok': ['श्लोक'],
  'stotra': ['स्तोत्र', 'स्तोत्रम'],
  'strotra': ['स्तोत्र', 'स्त्रोत्र'],
  'mantra': ['मंत्र', 'मन्त्र'],
  'katha': ['कथा'],
  'kavita': ['कविता'],
  'poem': ['कविता', 'पद'],
  'pad': ['पद', 'पदों'],
  'doha': ['दोहा', 'दोहे'],
  'chaupai': ['चौपाई'],
  'aarti': ['आरती'],
  'arti': ['आरती'],
  'chalisa': ['चालीसा'],
  'stuti': ['स्तुति'],
  'vandana': ['वंदना', 'वन्दना'],
  'prarthana': ['प्रार्थना'],
  'kirtan': ['कीर्तन'],
  'sankirtan': ['संकीर्तन'],
  'bhakti': ['भक्ति'],
  'prem': ['प्रेम'],
  'ras': ['रस', 'रास'],
  'leela': ['लीला'],
  'lila': ['लीला'],
  'darshan': ['दर्शन'],
  'seva': ['सेवा'],
  'paath': ['पाठ'],
  'path': ['पाठ', 'पथ'],
  'gyan': ['ज्ञान'],
  'gian': ['ज्ञान'],
  'dhyan': ['ध्यान'],
  'moksha': ['मोक्ष'],
  'mukti': ['मुक्ति'],
  'karma': ['कर्म'],
  'dharma': ['धर्म'],
  'satya': ['सत्य'],
  'punya': ['पुण्य'],
  'rasik': ['रसिक'],
  'sant': ['संत', 'सन्त'],
  'guru': ['गुरु', 'गुरू'],
  'sadhu': ['साधु'],
  'vani': ['वाणी'],
  'vaani': ['वाणी'],
  'updesh': ['उपदेश'],
  'charitra': ['चरित्र'],
  'mahima': ['महिमा'],
  'sakhi': ['सखी', 'साखी'],
  'gopi': ['गोपी', 'गोपियों'],
  'pyar': ['प्यार', 'प्यारे', 'प्यारी'],
  'pyare': ['प्यारे', 'प्यार', 'प्यारी'],
  'sundar': ['सुंदर', 'सुन्दर'],
  'divya': ['दिव्य'],
  'pavitra': ['पवित्र'],
  'mangal': ['मंगल'],
  'param': ['परम'],
  'jai': ['जय', 'जै'],
  'jay': ['जय', 'जै'],
  'hare': ['हरे', 'हारे'],
  'hari': ['हरि', 'हरी'],
  'gita': ['गीता', 'गीत'],
  'geeta': ['गीता'],
  'veda': ['वेद', 'वेदों'],
  'ved': ['वेद', 'वेदों'],
  'upanishad': ['उपनिषद', 'उपनिषद्'],
  'puran': ['पुराण'],
  'purana': ['पुराण'],
  'ramayan': ['रामायण'],
  'mahabharat': ['महाभारत'],
  'bhagwat': ['भागवत', 'भगवत'],
  'bhagavat': ['भागवत', 'भगवत'],
};

export function normalizeForFuzzy(str) {
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

export function expandHinglishQuery(query) {
  if (!query || typeof query !== 'string') return [];

  const normalizedQuery = query.toLowerCase().trim();
  const words = normalizedQuery.split(/\s+/);
  const expandedTerms = new Set();

  expandedTerms.add(normalizedQuery);

  for (const word of words) {
    expandedTerms.add(word);

    const hindiVariants = HINGLISH_MAP[word];
    if (hindiVariants) {
      hindiVariants.forEach(v => expandedTerms.add(v));
    }

    for (const [key, variants] of Object.entries(HINGLISH_MAP)) {
      if (key.startsWith(word) && word.length >= 3) {
        variants.forEach(v => expandedTerms.add(v));
      }
    }
  }

  return Array.from(expandedTerms);
}

export function hinglishMatch(item, query) {
  if (!query || !item) return true;

  const originalQuery = query.trim().toLowerCase();
  
  // 1. Check if query contains Devanagari
  const isDevanagariQuery = /[\u0900-\u097F]/.test(originalQuery);
  
  // 2. Transliterate Devanagari query to Hinglish
  const queryHinglish = isDevanagariQuery ? transliterate(originalQuery) : originalQuery;
  const normalizedQuery = normalizeForFuzzy(queryHinglish);

  // 3. Extract first lines of text fields if present
  const sansFirstLine = item.sanskrit_text ? item.sanskrit_text.split(/[\n।॥]/).map(l => l.trim()).filter(Boolean)[0] || '' : '';
  const hindiFirstLine = item.hindi_text ? item.hindi_text.split(/[\n।॥]/).map(l => l.trim()).filter(Boolean)[0] || '' : '';

  // 4. Construct search indices
  const textDevanagari = [
    item.title,
    item.name,
    item.hindi_text,
    item.sanskrit_text,
    item.author,
    item.description,
    item.category,
    sansFirstLine,
    hindiFirstLine
  ].filter(Boolean).join(' ').toLowerCase();

  const textHinglish = [
    item.hinglishName,
    transliterate(item.title || ''),
    transliterate(item.name || ''),
    transliterate(item.author || ''),
    transliterate(item.description || ''),
    transliterate(sansFirstLine),
    transliterate(hindiFirstLine),
    item.english_translation,
    item.english_text,
    item.slug,
    ...(item.tags || [])
  ].filter(Boolean).join(' ').toLowerCase();

  // 5. Match Check
  // A. Direct Devanagari check (if query is Devanagari)
  if (isDevanagariQuery && textDevanagari.includes(originalQuery)) {
    return true;
  }

  // B. Standard Hinglish substring check
  if (textHinglish.includes(queryHinglish)) {
    return true;
  }

  // C. Fuzzy match check
  const normalizedIndex = normalizeForFuzzy(textHinglish);
  if (normalizedIndex.includes(normalizedQuery)) {
    return true;
  }

  // D. Map expand queries check
  const expanded = expandHinglishQuery(queryHinglish);
  const matchExpanded = expanded.some(term => {
    const termHing = transliterate(term);
    return textHinglish.includes(termHing) || normalizeForFuzzy(textHinglish).includes(normalizeForFuzzy(termHing));
  });

  return matchExpanded;
}

export function getSearchSuggestions(query) {
  if (!query || query.length < 2) return [];

  const normalizedQuery = query.toLowerCase().trim();
  const suggestions = [];

  for (const [hinglish, hindiArr] of Object.entries(HINGLISH_MAP)) {
    if (hinglish.startsWith(normalizedQuery) || normalizedQuery.startsWith(hinglish)) {
      suggestions.push({
        text: hinglish,
        hindi: hindiArr[0],
        label: `${hinglish} — ${hindiArr[0]}`
      });
    }
  }

  return suggestions.slice(0, 8);
}
