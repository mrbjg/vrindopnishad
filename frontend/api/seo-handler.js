

import fs from 'fs';
import path from 'path';

import { getSaintMetadata } from './saintMetadata.js';
import { GLOSSARY_TERMS } from './glossaryTerms.js';

const SUPABASE_URL = process.env.REACT_APP_SUPABASE_URL || 'https://tilimltxgeucefxzerqi.supabase.co';
const SUPABASE_KEY = process.env.REACT_APP_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpbGltbHR4Z2V1Y2VmeHplcnFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2MjQyNTQsImV4cCI6MjA4MzIwMDI1NH0.lwaCJyTRW6jNsfQJ32R_wAwp11yj6bvsJ4fzC0EX_00';
const DOMAIN = 'https://path.vrindopnishad.in';


let globalCache = {
  items: null,
  relations: null
};
const CACHE_TTL = 300000;


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

const slugify = (text) => {
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

const generateSlug = (text) => {
  return slugify(transliterate(text));
};

const sanitizeSlug = (slug) => {
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

function escapeHtml(str) {
  if (!str) return '';
  return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&apos;');
}

function getBreadcrumbsHtml(isHi, items) {
  const arrow = '<span style="color: #a8a29e; margin: 0 8px;">&rarr;</span>';
  const listItems = items.map((item, idx) => {
    const isLast = idx === items.length - 1;
    if (isLast) {
      return `<span style="color: #78716c; font-weight: 500;">${escapeHtml(item.name)}</span>`;
    }
    return `<a href="${item.url}" style="color: #f2a60d; text-decoration: none; font-weight: 500;">${escapeHtml(item.name)}</a>`;
  });
  return `<nav aria-label="Breadcrumb" style="font-size: 0.85rem; color: #a8a29e; margin-bottom: 24px; font-family: sans-serif;">
    ${listItems.join(arrow)}
  </nav>`;
}

// Dynamic relations extractor
function extractRelations(items) {
  if (!items || !items.length) {
    return { sants: [], books: [], ragas: [] };
  }

  const santsMap = {};
  const booksMap = {};
  const ragasMap = {};
  const biographies = [];

  // Pass 1: Gather biographies
  items.forEach(item => {
    if (item.category?.toLowerCase() === 'saint') {
      const title = item.title || '';
      const cleanName = title.replace(/\([^)]+\)/g, '').replace(/महाप्रभु/g, '').trim();
      const transliteratedName = transliterate(cleanName);
      biographies.push({
        name: cleanName,
        slug: item.slug || slugify(transliteratedName),
        text: item.hindi_text || item.description || '',
        imageUrl: item.image_url || null
      });
    }
  });

  // Pass 2: Extract relations from verses
  items.forEach(item => {
    if (item.category?.toLowerCase() === 'saint') return;

    const title = item.title || '';
    let saintName = null;
    let bookName = null;

    const parts = title.split(/\s+-\s+/);
    if (parts.length >= 2) {
      const relationText = parts[1].trim();
      const verseMatch = relationText.match(/\(([^)]+)\)$/);
      const textWithoutVerse = verseMatch ? relationText.replace(/\(([^)]+)\)$/, '').trim() : relationText;
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
    }

    if (!saintName && item.author && item.author !== 'Braj Rasik Heritage') {
      saintName = item.author;
    }

    // Extract Raga
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
      const santSlug = slugify(transliterate(cleanSantKey));
      if (!santsMap[cleanSantKey]) {
        const matchedBio = biographies.find(bio => bio.name.includes(cleanSantKey) || cleanSantKey.includes(bio.name));
        santsMap[cleanSantKey] = {
          name: cleanSantKey,
          hinglishName: transliterate(cleanSantKey),
          slug: matchedBio ? matchedBio.slug : santSlug,
          biography: matchedBio ? { text: matchedBio.text, rawItem: matchedBio } : null,
          imageUrl: matchedBio ? matchedBio.imageUrl : null,
          verses: [],
          books: new Set()
        };
      }
      santsMap[cleanSantKey].verses.push(item);
      if (bookName) santsMap[cleanSantKey].books.add(bookName);
    }

    if (bookName) {
      const bookSlug = slugify(transliterate(bookName));
      if (!booksMap[bookName]) {
        booksMap[bookName] = {
          name: bookName,
          slug: bookSlug,
          author: saintName || 'Unknown Rasik',
          verses: [],
          imageUrl: item.image_url || null
        };
      } else if (!booksMap[bookName].imageUrl && item.image_url) {
        booksMap[bookName].imageUrl = item.image_url;
      }
      booksMap[bookName].verses.push(item);
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
      ragasMap[ragaName].verses.push(item);
    }
  });

  return {
    sants: Object.values(santsMap).map(s => ({ ...s, books: Array.from(s.books) })),
    books: Object.values(booksMap),
    ragas: Object.values(ragasMap)
  };
}

// Static SEO pages registry containing their exact semantic titles, description metadata, and HTML text payloads
const STATIC_SEO_PAGES = {
  'what-is-vrindopnishad': {
    en: {
      title: 'What is Vrindopnishad? — Definition & Core Concept | Vrindopnishad',
      description: 'Discover the definition and vision of Vrindopnishad. Learn how this sacred digital platform preserves Sanskrit shlokas and teachings of Vrindavan saints.',
      body: '<h1>What is Vrindopnishad?</h1><p>Vrindopnishad is a pioneering digital platform dedicated to the preservation, curation, and dissemination of authentic spiritual knowledge rooted in the Vedic tradition. The name itself is a beautiful synthesis of two profound Sanskrit concepts: "Vrinda" (वृंदा), referring to the sacred groves of Vrindavan and the divine play of Lord Krishna, and "Upanishad" (उपनिषद्), meaning the "sitting near" or the transmission of sacred, esoteric knowledge from teacher to disciple. Together, Vrindopnishad represents a modern digital ashram where seekers from across the world can access the timeless wisdom of Indias spiritual heritage.</p><p>In an era where digital noise often drowns out contemplative depth, Vrindopnishad stands as a refuge — a carefully curated space where one can immerse oneself in sacred Sanskrit shlokas, devotional strotras, heartfelt Hindi poetry, and the profound teachings of the great saints who walked the sacred soil of Vrindavan, Barsana, Nandgaon, and Govardhan. The platform serves as a bridge between ancient wisdom and contemporary seekers, making age-old spiritual texts accessible without compromising their sanctity or depth.</p><p>The platform hosts an extensive and ever-growing collection of spiritual content organized into several key categories. The content library includes sacred verses (shlokas) from the Vedas, Upanishads, and Bhagavad Gita, each presented with original Sanskrit text, Hindi transliteration, and English commentary. Beyond scriptural texts, the platform features devotional hymns (strotras) — powerful prayers and invocations that have been chanted for centuries in temples across India.</p>'
    },
    hi: {
      title: 'वृंदोपनिषद् क्या है? — परिभाषा एवं मूल अवधारणा | Vrindopnishad',
      description: 'वृंदोपनिषद् के बारे में जानें। समझें कि यह पवित्र डिजिटल मंच क्या है, इसका दृष्टिकोण और यह किस प्रकार आधुनिक तकनीक को परंपरा से जोड़ता है।',
      body: '<h1>वृंदोपनिषद् क्या है?</h1><p>वृंदोपनिषद् (वृंदोपनिषद्) वैदिक और वैष्णव परंपरा से जुड़े प्रामाणिक आध्यात्मिक ज्ञान के संरक्षण, संपादन और प्रसार के लिए समर्पित एक अग्रणी डिजिटल मंच है। इसका नाम दो अति महत्वपूर्ण संस्कृत शब्दों के योग से बना है: "वृंदा" (वृंदावन की पवित्र तुलसी कुंज और लीला भूमि) और "उपनिषद" (गुरु के निकट बैठकर प्राप्त किया जाने वाला गोपनीय दिव्य ज्ञान)। इस प्रकार वृंदोपनिषद् एक आधुनिक डिजिटल आश्रम का प्रतिनिधित्व करता है जहाँ वैश्विक जिज्ञासु प्राचीन आध्यात्मिक धरोहर से सीधे जुड़ सकते हैं।</p><p>आज के डिजिटल युग में जहाँ चारों ओर अशांति और कोलाहल है, वृंदोपनिषद् एक आध्यात्मिक आश्रय के रूप में खड़ा है। यह एक ऐसा स्थान है जहाँ आप संस्कृत श्लोकों, स्तोत्रों, हिंदी भक्ति कविताओं और ब्रज के महान रसिक संतों की शिक्षाओं में पूरी तरह से डूब सकते हैं। यह मंच प्राचीन ज्ञान को उसकी शुद्धता और गहराई के साथ आधुनिक तकनीक के माध्यम से सहज रूप में उपलब्ध कराता है।</p><p>इस मंच पर वेदों, उपनिषदों और श्रीमद्भगवद्गीता के श्लोकों का विस्तृत संग्रह है, जिसमें मूल पाठ, उच्चारण निर्देश, हिंदी अनुवाद और व्याख्याएँ शामिल हैं। इसके अतिरिक्त ब्रज के संतों जैसे स्वामी हरिदास, हित हरिवंश और वर्तमान संतों के पदों एवं भजनों को भी यहाँ संरक्षित किया गया है।</p>'
    }
  },
  'meaning': {
    en: {
      title: 'Meaning of Vrindopnishad — Etymology & Spiritual Significance',
      description: 'Explore the profound meaning of Vrindopnishad. Understand the Sanskrit etymology, spiritual symbolism, and deeper significance behind this sacred name.',
      body: '<h1>Meaning of Vrindopnishad (वृंदोपनिषद्)</h1><p>The word "Vrindopnishad" (वृंदोपनिषद्) is a Sanskrit compound formed by uniting two rich terms. "Vrinda" (वृंदा) means a cluster of sacred Tulsi plants — the earthly manifestation of goddess Vrinda Devi. In Vrindavan\'s devotional literature, Vrinda is intimately connected with the divine pastoral landscape where Lord Krishna enacted his transcendent plays (leelas). The forest of Vrindavan itself takes its name from these sacred groves.</p><p>"Upanishad" (उपनिषद्) derives from three Sanskrit roots: "upa" (near), "ni" (down), and "sad" (to sit) — painting a picture of a student sitting near a teacher to receive sacred knowledge. The Upanishads are the culminating wisdom texts of the Vedic corpus, dealing with the ultimate nature of reality (Brahman), the self (Atman), and liberation (Moksha).</p><p>When merged into "Vrindopnishad," the compound suggests "the sacred, esoteric knowledge that flows from Vrindavan" — spiritual wisdom from the most sacred landscape in Vaishnava devotion. This is not academic knowledge but transformative wisdom received in a state of devotional surrender. It bridges the jnana (knowledge) tradition represented by the Upanishads with the bhakti (devotion) tradition centered in Vrindavan. This synthesis reflects a profound theological insight: the highest knowledge and deepest devotion are complementary paths leading to the same transcendent reality.</p>'
    },
    hi: {
      title: 'वृंदोपनिषद् शब्द का अर्थ — संस्कृत व्युत्पत्ति एवं महत्व',
      description: 'वृंदोपनिषद् शब्द का गहरा अर्थ समझें। संस्कृत व्याकरण के अनुसार इसकी संधि, व्युत्पत्ति और आध्यात्मिक संदेश की विस्तृत विवेचना।',
      body: '<h1>वृंदोपनिषद् का अर्थ</h1><p>"वृंदोपनिषद्" (वृंद + उपनिषद्) एक अत्यंत सुंदर और प्रतीकात्मक संस्कृत शब्द है, जिसकी संरचना दो मूलभूत विचारों से हुई है। "वृंदा" का अर्थ है तुलसी के पवित्र पौधे और वृंदावन की वह अलौकिक भूमि जहाँ श्री राधा कृष्ण ने अपनी नित्य रास लीलाएँ संपादित की थीं। ब्रज की भक्ति परंपरा में वृंदा देवी को इस दिव्य वन की अधिष्ठात्री देवी माना गया है, जो लीला के लिए संपूर्ण वातावरण तैयार करती हैं।</p><p>"उपनिषद्" का अर्थ है गुरु के पास निष्ठापूर्वक बैठना (उप + नि + सद्) ताकि उस गोपनीय आध्यात्मिक ज्ञान को ग्रहण किया जा सके जो अंधकार को मिटाता है। उपनिषद सनातन धर्म के सबसे बड़े दार्शनिक ग्रन्थ हैं जो आत्मा, परमात्मा और मोक्ष की चर्चा करते हैं।</p><p>जब हम इन दोनों को जोड़कर "वृंदोपनिषद्" बनाते हैं, तो इसका अर्थ होता है — "वृंदावन की रस-भूमि से प्रकट होने वाला परम गोपनीय और मधुर ज्ञान।" यह ज्ञान शुष्क तर्क या केवल बौद्धिक विमर्श नहीं है, बल्कि यह प्रेम, समर्पण और रसानुभूति से परिपूर्ण ज्ञान है। यह हमें सिखाता है कि सत्य केवल जानने की वस्तु नहीं है, बल्कि वह अनुभव और आत्मीय संबंध की वस्तु है।</p>'
    }
  },
  'origin': {
    en: {
      title: 'Origin & History of Vrindopnishad — Roots of Braj Devotion',
      description: 'Trace the origin and scriptural history of the teachings found in Vrindopnishad. Learn how these sacred texts have been preserved over generations.',
      body: '<h1>Origin & History of Vrindopnishad</h1><p>The origin of Vrindopnishad is inseparable from the sacred geography of Vrindavan, the ancient forest town on the banks of the Yamuna river. Vrindavan is understood in Hindu theology as the eternal abode of Radha and Krishna, a transcendent realm that manifests on earth. For over five thousand years, this landscape has been the epicenter of Bhakti (devotional) spirituality, attracting saints, poets, and philosophers.</p><p>The literary traditions that Vrindopnishad preserves have their roots in this unique spiritual ecosystem. From the 16th century onwards, when the Six Goswamis of Vrindavan — disciples of Sri Chaitanna Mahaprabhu — systematized the theology of Radha-Krishna worship, Vrindavan became a powerhouse of spiritual literature. The Goswamis composed hundreds of texts in Sanskrit, covering everything from abstruse philosophy to intimate devotional poetry. This literary explosion laid the foundation for the traditions that Vrindopnishad now digitally preserves.</p><p>For centuries, the spiritual literature of Vrindavan was transmitted primarily through oral tradition — from guru to shishya (teacher to student). Devotional songs were learned by heart and sung in temple gatherings. While this organic transmission ensured the vitality of the tradition, it also made it vulnerable to loss. Vrindopnishad was born from the recognition that digital technology offers an unprecedented opportunity to preserve, organize, and share this endangered heritage, collecting manuscripts from ashrams and temples.</p>'
    },
    hi: {
      title: 'वृंदोपनिषद् का इतिहास और उत्पत्ति — ब्रज भक्ति परंपरा',
      description: 'वृंदोपनिषद् की ऐतिहासिक और आध्यात्मिक उत्पत्ति के विषय में जानें। वृंदावन और ब्रज के संतों की गौरवशाली परंपरा का इतिहास।',
      body: '<h1>उत्पत्ति एवं इतिहास</h1><p>वृंदोपनिषद् की उत्पत्ति ब्रजमंडल की पावन भूमि और वहाँ प्रवाहित होने वाली भक्ति रस की धारा से जुड़ी है। वृंदावन केवल एक भौगोलिक स्थान नहीं है, बल्कि इसे भगवान का शाश्वत निवास स्थल माना गया है। 16वीं शताब्दी में श्री चैतन्य महाप्रभु के वृंदावन आगमन के बाद उनके शिष्यों (षड्-गोस्वामी) ने यहाँ बैठकर शास्त्रों का अनुसंधान किया और वैष्णव दर्शन की स्थापना की।</p><p>इसके बाद के समय में ब्रज के प्रमुख रसिक संतों जैसे स्वामी हरिदास, हित हरिवंश महाप्रभु, नारायण भट्ट और हरिराम व्यास ने अद्भुत काव्य ग्रंथों की रचना की। इन संतों ने संस्कृत के साथ-साथ स्थानीय ब्रजभाषा में भी अमूल्य पदों की रचना की। सदियों तक यह ज्ञान मौखिक परंपरा (गुरु-शिष्य परंपरा) और भोजपत्र या ताड़ के पत्तों पर लिखी पांडुलिपियों के रूप में जीवित रहा।</p><p>समय के साथ कई पांडुलिपियाँ नष्ट होने लगीं और मौखिक पाठ करने वाले संतों की संख्या भी घटने लगी। इसी संकट को देखते हुए वृंदोपनिषद् परियोजना की शुरुआत की गई ताकि वृंदावन की प्राचीन मंदिरों और आश्रमों में सुरक्षित इस महान वाणी साहित्य को डिजिटल रूप में सहेजकर पूरी दुनिया के लिए सुलभ बनाया जा सके।</p>'
    }
  },
  'philosophy': {
    en: {
      title: 'Philosophy of Vrindopnishad — Achintya Bheda Abheda & Bhakti',
      description: 'Dive deep into the theological philosophy of Vrindopnishad. Explore concepts of divine love (Raganuga Bhakti) and relationships of the self.',
      body: '<h1>Theological Philosophy of Vrindopnishad</h1><p>The core philosophy of Vrindopnishad is based on Achintya Bheda Abheda (inconceivable simultaneous oneness and difference) and Raganuga Bhakti (spontaneous, passionate devotion). It posits that the supreme truth is personal and aesthetic (Raso Vai Sah), manifesting as the Divine Couple Shri Radha Krishna in the eternal forest of Nitya Vrindavan. The soul (jiva) is eternally connected to the Divine yet distinct, serving as a particle of spiritual energy.</p><p>Unlike paths of dry intellect or rigorous asceticism, Vrindopnishad emphasizes that the highest attainment is not silent merging into the formless Brahman, but entering the eternal, selfless loving service (Prema Seva) of the Divine Couple. This philosophy values human emotion, teaching that our capacity to love is not something to be destroyed, but rather redirected towards its original, divine source. By doing so, the soul is freed from material attachments and awakens to its true spiritual identity.</p><p>This philosophical approach is reflected in every design choice on the platform — from the contemplative visual aesthetics to the audio narration features that allow users to listen to verses being chanted in their traditional melodic patterns. The interface is designed to evoke the infinite cosmos of Vedic cosmology, creating a digital threshold that transitions the user from the mundane world to a space of reverence.</p>'
    },
    hi: {
      title: 'वृंदोपनिषद् का दर्शन — अचिन्त्य भेदाभेद एवं भक्ति मार्ग',
      description: 'वृंदोपनिषद् के दार्शनिक सिद्धांतों का परिचय। जीव, ब्रह्म और भक्ति के संबंधों की व्याख्या, और वैष्णव आचार्यों का दृष्टिकोण।',
      body: '<h1>आध्यात्मिक दर्शन</h1><p>वृंदोपनिषद् का दर्शन वैष्णव वेदांत के सबसे मधुर और गंभीर रूप \'अचिन्त्य भेदाभेद\' तथा \'रागानुगा भक्ति\' पर आधारित है। यह दर्शन स्वीकार करता है कि परमात्मा और आत्मा के बीच एक ऐसा संबंध है जो एक ही समय पर एकता (अभेद) और भिन्नता (भेद) दोनों को दर्शाता है। यह संबंध मानव की तर्कशक्ति से परे है, इसलिए इसे अचिन्त्य कहा गया है।</p><p>यहाँ परमात्मा को केवल एक न्यायकर्ता या सृष्टि के नियंता के रूप में नहीं, बल्कि परम रसमय सत्ता \'श्री राधा कृष्ण\' के रूप में देखा जाता है। जीव का परम उद्देश्य मुक्ति (मोक्ष) पाना नहीं है, बल्कि भगवान की दिव्य प्रेम और सेवा (प्रेमा भक्ति) का रसास्वादन करना है। यह भक्ति भय या नियमों से परे होकर हृदय के स्वाभाविक अनुराग से उत्पन्न होती है।</p><p>इस दार्शनिक पृष्ठभूमि में सांसारिक कामनाओं को दबाने के बजाय उन्हें भगवान की सेवा में लगाकर पवित्र करने का निर्देश दिया गया है। जब मन और इंद्रियाँ भगवान के नाम, रूप, और लीला के श्रवण और कीर्तन में लग जाती हैं, तो मनुष्य स्वतः ही माया के बंधनों से मुक्त हो जाता है।</p>'
    }
  },
  'teachings': {
    en: {
      title: 'Teachings of Vrindopnishad — Wisdom from Rasik Saints',
      description: 'Discover the core teachings and spiritual guidelines of Vrindopnishad. Practical wisdom and guidance for daily devotion and inner peace.',
      body: '<h1>Core Teachings of Braj Rasik Tradition</h1><p>The teachings preserved in Vrindopnishad offer a practical, heart-centered roadmap for spiritual awakening in the modern world. Unlike paths based on dry philosophical speculation or rigorous physical asceticism, the Rasik saints of Vrindavan emphasize that the highest goal of human life is to cultivate unconditional, selfless divine love (Prema) and enter into the eternal service (Seva) of the Divine Couple, Shri Radha and Shri Krishna, in the sacred bower of Nikunj. Below are the six fundamental teachings that form the core of this devotional path:</p><h2>1. The Power of Nama Japa & Kirtan</h2><p>The foremost practice recommended by all Rasik acharyas is the constant chanting and singing of the holy names of God (Nama Japa and Kirtan). In this current age of distraction (Kali Yuga), formal sacrifices, complex yoga postures, and silent meditation are difficult to perform successfully due to mental agitation. The holy name is understood to be non-different from the Lord Himself. Chanting the name of "Radha" or the Hare Krishna mahamantra acts as a powerful purifying agent, clearing the heart of negative emotions, stabilizing the mind, and gradually awakening the soul\'s innate spiritual love.</p><h2>2. Humility, Tolerance & Respect (Trina-dapi Suni-chena)</h2><p>A seeker cannot progress on the path of devotion without cultivating genuine humility. Following the instructions of Sri Chaitanya Mahaprabhu, a devotee should consider themselves lower than a blade of grass (trina-dapi suni-chena), be more tolerant than a tree, offer all respect to others without desiring any honor in return, and constantly chant the holy names. True humility means recognizing that every living entity is a part of the divine family, which naturally leads to compassion, non-violence, and the reduction of egotistical pride.</p><h2>3. The Association of Saintly Persons (Sadhu Sanga)</h2><p>The company we keep has a profound impact on our consciousness. <em>Sadhu Sanga</em>—associating with saintly, selfless individuals who are dedicated to the spiritual path—is described as the catalyst for spiritual growth. Just as a mirror reflects whatever is placed before it, our minds absorb the desires and qualities of those we associate with. Being in the presence of advanced devotees naturally elevates our thoughts, inspires us to practice daily sadhana, and helps resolve doubts that arise on our spiritual journey.</p><h2>4. Daily Study of Saintly Literature (Vani Swadhyaya)</h2><p>Reciting and studying the written teachings of the saints (Vani Swadhyaya) is considered a form of direct satsang. The compositions of Swami Haridas, Hit Harivansh, and other Rasik saints are not mere poetry; they are direct records of their spiritual realizations. When we read their words daily, we are tuning our minds to their frequency. Vrindopnishad encourages seekers to make the reading of the daily verse a regular part of their morning routine to establish a peaceful, meditative anchor for the rest of the day.</p><h2>5. Spontaneous Love over Rigid Rituals (Raganuga Bhakti)</h2><p>Braj devotion is characterized by its emphasis on <em>Raganuga Bhakti</em>—devotion that follows the spontaneous, intense love felt by the eternal residents of Vrindavan. While initial stages of devotion may rely on rules and regulations (Vaidhi Bhakti) to build discipline, the ultimate goal is to transition into a state of natural, unforced attraction to the Divine. Here, worship is not performed out of fear of punishment or desire for material rewards, but out of pure affection and a desire to bring happiness to the Divine Couple.</p><h2>6. Deep Reverence for Braj Dham & Braj Raj</h2><p>The physical landscape of Vrindavan, Govardhan, and Barsana is not considered ordinary material land, but the earthly manifestation of the spiritual world. The dust of this land (Braj Raj) is highly venerated because it has been touched by the feet of Shri Radha, Krishna, and countless saints. Walking through the Dham, performing the circumambulation (Parikrama), and maintaining an attitude of reverence toward the sacred environment are essential aspects of the practice, helping the seeker connect with the divine energy that permeates the region.</p>'
    },
    hi: {
      title: 'वृंदोपनिषद् की मुख्य शिक्षाएँ — जीवन बदलने वाले उपदेश',
      description: 'ब्रज के रसिक आचार्यों और संतों के मुख्य उपदेश। मन की शुद्धि, दैनिक साधना और आध्यात्मिक जीवन जीने के व्यावहारिक नियम।',
      body: '<h1>ब्रज रसिक परंपरा की मुख्य शिक्षाएँ</h1><p>वृंदोपनिषद् में संरक्षित संतों की शिक्षाएँ आधुनिक जीवन के कोलाहल और तनाव के बीच आंतरिक शांति, शुद्धि और दिव्य आनंद प्राप्त करने का एक अत्यंत सरल व व्यावहारिक मार्ग प्रशस्त करती हैं। शुष्क बौद्धिक तर्कों या अत्यंत कठिन शारीरिक तपस्या के विपरीत, ब्रज के रसिक आचार्य यह सिखाते हैं कि मानव जीवन का चरम लक्ष्य हृदय में निस्वार्थ दिव्य प्रेम (प्रेमा भक्ति) को जाग्रत करना और वृंदावन निकुंज के अंतर्गत युगल सरकार (श्री राधा कृष्ण) की नित्य सेवा में लीन होना है। इस भक्ति मार्ग के छह मुख्य स्तंभ निम्नलिखित हैं:</p><h2>१. नाम जप एवं संकीर्तन की शक्ति</h2><p>सभी रसिक आचार्यों द्वारा बताई गई साधनाओं में सर्वोपरि साधना है — भगवान के पवित्र नामों का निरंतर जप और कीर्तन। कलयुग के इस अशांत वातावरण में जटिल यज्ञ, कठिन योग और एकांत ध्यान लगाना अत्यंत कठिन है क्योंकि मन सदैव चंचल रहता है। ऐसी स्थिति में भगवान का नाम ही साक्षात् भगवान का स्वरूप है। "राधा" नाम या हरे कृष्ण महामंत्र का श्रद्धापूर्वक जप करने से चित्त के समस्त विकार दूर होते हैं, मानसिक शांति मिलती है और आत्मा का ईश्वर के प्रति सहज प्रेम जाग्रत होता है।</p><h2>२. परम विनम्रता, सहनशीलता एवं सर्व-आदर (दीनता)</h2><p>भक्ति मार्ग में प्रगति तब तक संभव नहीं है जब तक हृदय में सच्ची दीनता और विनम्रता न हो। चैतन्य महाप्रभु के उपदेशों के अनुसार, साधक को स्वयं को तिनके से भी अधिक छोटा (तृणादपि सुनीचेन) समझना चाहिए, वृक्ष के समान सहनशील होना चाहिए, स्वयं के लिए किसी मान-सम्मान की इच्छा न रखते हुए दूसरों को आदर देना चाहिए और निरंतर हरिनाम का संकीर्तन करना चाहिए। जब हम प्रत्येक जीव में ईश्वर का अंश देखने लगते हैं, तो हमारे भीतर स्वतः ही करुणा और अहिंसा का भाव आ जाता है।</p><h2>३. संतों की संगति (साधु संग)</h2><p>हम जिन लोगों के बीच रहते हैं, उनके विचारों का हमारे अवचेतन मन पर गहरा प्रभाव पड़ता है। <em>साधु संग</em> अर्थात उन निस्वार्थ भक्तों की संगति करना जो ईश्वर के मार्ग पर आगे बढ़ चुके हैं, हमारी आध्यात्मिक उन्नति को तीव्र कर देता है। जैसे दर्पण अपने सामने रखी वस्तु को प्रतिबिंबित करता है, वैसे ही हमारा मन भी संतों के दिव्य विचारों और गुणों को ग्रहण करने लगता है। सत्संग से हमारे संशय दूर होते हैं और साधना के प्रति निष्ठा दृढ़ होती है।</p><h2>४. वाणी साहित्य का दैनिक स्वाध्याय (वाणी पाठ)</h2><p>संतों के लिखे पदों और वाणियों का नित्य पाठ करना भी साक्षात् सत्संग का ही रूप माना जाता है। स्वामी हरिदास, हित हरिवंश और अन्य महान संतों की रचनाएँ कोई साधारण काव्य नहीं हैं, बल्कि उनके प्रत्यक्ष आध्यात्मिक अनुभवों के दिव्य शब्दचित्र हैं। प्रतिदिन इनके पाठ से हमारा मन संतों के भाव से जुड़ता है। वृंदोपनिषद् साधकों को प्रेरित करता है कि वे प्रतिदिन एक श्लोक या पद का पाठ अवश्य करें ताकि पूरा दिन सकारात्मक और शांतिमय बना रहे।</p><h2>५. विधि-विधानों से ऊपर प्रेम (रागानुगा भक्ति)</h2><p>ब्रज की भक्ति की सबसे बड़ी विशेषता है — <em>रागानुगा भक्ति</em>। इसका अर्थ है वह भक्ति जो नियमों के डर या किसी सांसारिक लालच से नहीं, बल्कि भगवान के प्रति स्वाभाविक आकर्षण और स्नेह से उत्पन्न होती है। यद्यपि प्रारंभिक अवस्था में अनुशासन बनाने के लिए नियमों (वैधी भक्ति) की आवश्यकता होती है, परंतु अंतिम लक्ष्य भगवान को अपने प्रियतम, मित्र या बालक के रूप में मानकर उनसे निःस्वार्थ प्रेम करना है।</p><h2>६. ब्रज धाम और ब्रज रज के प्रति श्रद्धा</h2><p>वृंदावन, गोवर्धन और बरसाना की भूमि को सामान्य भौतिक भूमि नहीं, बल्कि गोलोक धाम का भूतल पर साक्षात् स्वरूप माना गया है। यहाँ की धूलि (ब्रज रज) को संतों ने सिर पर धारण किया है क्योंकि इस रज में श्री राधा कृष्ण के चरणों की दिव्य छाप है। धाम का आदर करना, यमुना जी की वंदना करना, और ब्रज के पर्यावरण को स्वच्छ व पवित्र रखना भी इस साधना का एक महत्वपूर्ण अंग है, जो साधक को यहाँ की दिव्य ऊर्जा से जोड़ता है।</p>'
    }
  },
  'importance': {
    en: {
      title: 'Importance of Vrindopnishad in Modern Times — Spiritual Value',
      description: 'Why is Vrindopnishad relevant today? Read about the critical importance of preserving scriptural wisdom in the digital age.',
      body: '<h1>Importance of Vrindopnishad Today</h1><p>In our modern fast-paced world, the message of Vrindopnishad serves as a stabilizing, peaceful anchor. It provides the digital age with accessible, authenticated translations of spiritual literature, ensuring that the legacy of the saints remains a living guide for humanity. The stress and anxiety of contemporary life are often the results of a spiritual vacuum; Vrindopnishad aims to fill this void with the cooling nectar of divine wisdom.</p><p>The preservation of these texts is also of immense cultural and historical importance. As traditional lifestyles change, there is a real danger that the unique literary and linguistic heritage of the Braj region could be lost. By digitizing these works, Vrindopnishad ensures their survival for future generations, making them available to scholars, devotees, and general seekers worldwide.</p><p>Furthermore, the platform demonstrates that technology can be a powerful tool for spiritual elevation when used with the right intention. By creating a dedicated, aesthetic space for sacred literature, Vrindopnishad helps users transform their screen time into a source of peace, clarity, and inner growth, rather than distraction and comparison.</p>'
    },
    hi: {
      title: 'आधुनिक युग में वृंदोपनिषद् का महत्व — क्यों आवश्यक है यह मंच',
      description: 'आज के विज्ञान और तकनीक के युग में आध्यात्मिक ग्रंथों की प्रासंगिकता। मानसिक शांति और जीवन की सार्थकता पाने में इसकी भूमिका।',
      body: '<h1>आधुनिक समाज में महत्व</h1><p>आज की 21वीं सदी में, जहाँ तकनीक और भौतिक साधनों की प्रचुरता है, वहीं मनुष्य के भीतर अशांति, तनाव और एक खालीपन भी बढ़ा है। ऐसी परिस्थिति में वृंदोपनिषद् का महत्व अत्यंत प्रासंगिक हो जाता है। यह मंच आधुनिक मानव को उसकी व्यस्त जीवनशैली के बीच सीधे अध्यात्म से जुड़ने का अवसर देता है।</p><p>वृंदावन की रसिक परंपरा का यह साहित्य हमें सिखाता है कि जीवन का अंतिम लक्ष्य केवल धन कमाना या बाहरी सफलता पाना नहीं है, बल्कि हृदय में प्रेम और आनंद को जाग्रत करना है। यह साहित्य हमें मानसिक तनाव से मुक्ति देकर सकारात्मक ऊर्जा से भर देता है।</p><p>सांस्कृतिक रूप से भी यह मंच अमूल्य योगदान दे रहा है। वैश्वीकरण के इस दौर में हमारी क्षेत्रीय भाषाएँ और प्राचीन ग्रंथ लुप्त होने की कगार पर हैं। वृंदोपनिषद् इन दुर्लभ वाणियों और श्लोकों को सहेजकर आने वाली पीढ़ियों के लिए एक सुरक्षित भंडार तैयार कर रहा है, ताकि हमारी ज्ञान परंपरा अखंड बनी रहे।</p>'
    }
  },
  'devotion': {
    en: {
      title: 'Devotional Significance (Bhakti Marg) of Vrindopnishad',
      description: 'Explore the path of devotion (Bhakti) on Vrindopnishad. Learn how reciting shlokas and contemplation can evoke divine consciousness.',
      body: '<h1>The Path of Devotion (Bhakti Marg)</h1><p>Bhakti, or pure devotion, is the heart of the Vrindopnishad collection. Unlike paths based on austere meditation or intellectual speculation, Bhakti values love and emotional relationship with the Divine. It emphasizes that the supreme Lord is not an impersonal force but a loving person who responds to the sincere calls of His devotees. The path is accessible to all, requiring no special qualifications other than sincerity.</p><p>Vrindopnishad focuses specifically on Raganuga Bhakti, which is the path of spontaneous loving service following in the footsteps of the eternal residents of Vrindavan. This form of devotion is characterized by its sweetness (madhurya) and its focus on the pastimes of Radha and Krishna. It teaches the devotee to serve the divine couple with the same intimate love and affection that one would feel for a beloved friend, child, or master.</p><p>The reciting of shlokas, singing of kirtans, and contemplation of the saints\' lives are all practical methods to cultivate this devotional mood. Through these practices, the heart is purified, the mind is anchored in divine thoughts, and the seeker experiences a profound inner joy that transcends material circumstances. Bhakti is not a passive belief but a dynamic, active expression of love.</p>'
    },
    hi: {
      title: 'भक्ति मार्ग का महत्व — वृंदोपनिषद् भक्ति दर्शन',
      description: 'भक्ति क्या है और इसका मार्ग ज्ञान मार्ग से कैसे भिन्न है? प्रेम लक्षणा भक्ति और भगवान के प्रति पूर्ण समर्पण का मार्ग।',
      body: '<h1>भक्ति मार्ग का रहस्य</h1><p>भक्ति मार्ग वृंदोपनिषद् की रीढ़ है। श्रीमद्भागवत और अन्य वैष्णव ग्रंथों के अनुसार, भक्ति का मार्ग सबसे सुगम और आनंदमयी है। ज्ञान मार्ग में जहाँ बुद्धि और कड़े नियमों की आवश्यकता होती है, वहीं भक्ति मार्ग में केवल सरल और निष्कपट हृदय की आवश्यकता होती है।</p><p>भक्ति का अर्थ है भगवान से एक गहरा, व्यक्तिगत और प्रेमपूर्ण संबंध स्थापित करना। ब्रज की परंपरा \'माधुर्य भाव\' की भक्ति का उपदेश देती है, जहाँ भगवान को परम ऐश्वर्यशाली स्वामी मानकर डरने के बजाय, उन्हें अपने अति प्रिय सखा, पुत्र या प्रियतम के रूप में पूजा जाता है। यह प्रेम भगवान और भक्त के बीच की दूरी को मिटा देता है।</p><p>श्लोकों का सस्वर पाठ करना, नाम संकीर्तन करना और संतों के चरित्र का स्मरण करना भक्ति मार्ग के मुख्य अंग हैं। यह साधना मन के विकारों को धोकर उसे भगवान के प्रेम में लीन कर देती है। भक्ति केवल एक क्रिया नहीं है, यह एक स्थिति है जहाँ भक्त अपने पूरे अस्तित्व को भगवान के चरणों में समर्पित कर देता है और परम शांति का अनुभव करता है।</p>'
    }
  },
  'faq': {
    en: {
      title: 'FAQ — Frequently Asked Questions about Vrindopnishad',
      description: 'Find answers to common questions about Vrindopnishad, Vaishnavism, spiritual practice, and the authenticity of our texts.',
      body: '<h1>Frequently Asked Questions</h1><h3>What is Vrindopnishad?</h3><p>Vrindopnishad is a sacred digital platform dedicated to preserving and sharing authentic spiritual and Vedic knowledge. It hosts Sanskrit shlokas, strotras, poetry, and saint teachings.</p><h3>Are the texts authentic?</h3><p>Yes, all texts are compiled from authorized Vaishnava publications, verified against established scholarly editions, and cross-checked by Sanskrit scholars in Vrindavan.</p><h3>Is this platform associated with a specific sect?</h3><p>While deeply rooted in the Gaudiya Vaishnava and Radhavallabhi traditions of Vrindavan, Vrindopnishad welcomes seekers of all backgrounds and maintains scholarly objectivity.</p><h3>How can I practice daily?</h3><p>You can read the Verse of the Day, contemplate its meaning, listen to audio chanting, and use the Japa counter to chant the holy names of God daily.</p>'
    },
    hi: {
      title: 'प्रश्नोत्तर — वृंदोपनिषद् सामान्य प्रश्न और उत्तर',
      description: 'वृंदोपनिषद् से संबंधित मुख्य प्रश्नों के समाधान। श्लोकों की प्रामाणिकता, नाम जप और साधना के विषय में अक्सर पूछे जाने वाले प्रश्न।',
      body: '<h1>अक्सर पूछे जाने वाले प्रश्न</h1><h3>वृंदोपनिषद् क्या है?</h3><p>वृंदोपनिषद् एक डिजिटल आध्यात्मिक मंच है जो वेदों, उपनिषदों और वृंदावन के संतों की शिक्षाओं को संरक्षित करके उन्हें जन-साधारण तक पहुँचाने का कार्य कर रहा है।</p><h3>यहाँ संकलित श्लोक कितने प्रामाणिक हैं?</h3><p>सभी पाठ और श्लोक प्रामाणिक वैष्णव ग्रन्थों और वृंदावन की मूल पांडुलिपियों से लिए गए हैं। इनकी प्रामाणिकता की जाँच संस्कृत के विद्वानों द्वारा की गई है।</p><h3>क्या यह किसी विशेष संप्रदाय से जुड़ा है?</h3><p>यह मंच ब्रज की वैष्णव परंपरा (गौड़ीय, राधावल्लभ, हरिदासी संप्रदाय आदि) से प्रेरित है, परंतु यहाँ संकलित ज्ञान सार्वभौमिक है और सभी पृष्ठभूमि के साधकों का स्वागत करता है।</p><h3>मैं अपनी दैनिक साधना कैसे शुरू करूँ?</h3><p>आप प्रतिदिन \'आज का श्लोक\' पढ़ सकते हैं, उसके अर्थ का चिंतन कर सकते हैं और नाम जप काउंटर का उपयोग करके प्रतिदिन भगवान के नाम का स्मरण कर सकते हैं।</p>'
    }
  },
  'nitya-vihar-vs-nikunj-vihar': {
    en: {
      title: 'Nitya Vihar vs Nikunj Vihar — Differences & Spiritual Meaning',
      description: 'Learn the difference between Nitya Vihar and Nikunj Vihar in Vrindavan theology. Explore the teachings of Swami Haridas and Hit Harivansh.',
      body: '<h1>Nitya Vihar vs Nikunj Vihar</h1><p>In the spiritual traditions of Vrindavan, particularly within the Haridasi Sampradaya (founded by Swami Haridas) and the Radhavallabh Sampradaya (founded by Goswami Hit Harivansh Mahaprabhu), the terms <strong>Nitya Vihar</strong> (नित्य विहार) and <strong>Nikunj Vihar</strong> (निकुंज विहार) represent the pinnacle of devotional aesthetics (Rasa). While closely related, they highlight distinct aspects of the divine relationship between Shri Radha and Shri Krishna.</p><p><strong>Nitya Vihar</strong> refers to the eternal, continuous, and timeless nature of the love-play. It has no beginning, no end, and no element of physical or emotional separation (viraha). It is always occurring in the present moment. <strong>Nikunj Vihar</strong> refers to the spatial setting and physical expression of this play. "Nikunj" means the secluded bowers or dynamic, lush green groves of Vrindavan where the most confidential pastimes unfold in privacy.</p><p>Though often used together as "Nitya Nikunj Vihar," theological scholars and saints distinguish them as state vs. setting. Nitya Vihar is the state of constant union and mutual fascination between the divine lovers. Nikunj Vihar represents the aesthetic atmosphere, the forest alcoves decorated by nature, and the intimate service (Seva) performed by the Sahacharis. Swami Haridas placed ultimate emphasis on worshiping the couple specifically as they reside together eternally in the Nikunj.</p>'
    },
    hi: {
      title: 'नित्य विहार बनाम निकुंज विहार — अंतर और आध्यात्मिक महत्व',
      description: 'वृंदावन दर्शन में नित्य विहार और निकुंज विहार के बीच दार्शनिक अंतर समझें। स्वामी हरिदास और हित हरिवंश महाप्रभु की शिक्षाओं का अध्ययन करें।',
      body: '<h1>नित्य विहार बनाम निकुंज विहार</h1><p>वृंदावन की रसिक परंपराओं (हरिदासी और राधावल्लभ संप्रदाय) में <strong>नित्य विहार</strong> (नित्य विहार) और <strong>निकुंज विहार</strong> (निकुंज विहार) दिव्य रस साधना के दो महत्वपूर्ण स्तंभ हैं।</p><p><strong>नित्य विहार</strong> का अर्थ है श्री राधा कृष्ण की लीला का वह रूप जो देश, काल और परिस्थिति से परे पूरी तरह से नित्य, शाश्वत और अखंड है। इसमें किसी प्रकार का वियोग (विरह) नहीं होता, यह सदा एक समान रूप से प्रवाहित होने वाला दिव्य आनंद है।</p><p><strong>निकुंज विहार</strong> उस दिव्य क्रीड़ा के स्थान (स्थल) और अंतरंगता को दर्शाता है। "निकुंज" का अर्थ है वृंदावन के अत्यंत सघन, एकांत और लताओं से घिरे कुंज जहाँ श्री राधा कृष्ण सखियों के मध्य परम गोपनीय रूप से विहार करते हैं। जहाँ नित्य विहार लीला की शाश्वतता को प्रकट करता है, वहीं निकुंज विहार उसके रसमय वातावरण और एकांत सौंदर्य को रेखांकित करता है।</p>'
    }
  },
  'glossary': {
    en: {
      title: 'Braj Rasik Glossary — Vrindavan Spiritual & Theological Terms',
      description: 'Explore the comprehensive Braj Rasik Glossary of spiritual, theological, and devotional terms from Vrindavan, including etymology, Hindi, and English definitions.',
      body: '<h1>Braj Rasik Glossary & Spiritual Encyclopedia</h1><p>A comprehensive dictionary of key theological terms, devotional sentiments, and philosophical concepts from the rasik traditions of Vrindavan.</p><h3>1. Braj Ras (ब्रज रस)</h3><p>The sweet, transcendental mellow of divine love experienced in Vrindavan, centering on absolute selflessness.</p><h3>2. Nitya Vihar (नित्य विहार)</h3><p>The eternal, continuous love-play of Shri Radha and Krishna without any element of physical or emotional separation.</p><h3>3. Nikunj (निकुंज)</h3><p>Secluded forest bowers and climbing groves where the most confidential pastimes of the Divine Couple unfold in privacy.</p><h3>4. Manjari Bhava (मंजरी भाव)</h3><p>The highly confidential mood of spiritual practice where the devotee serves as a loving maidservant of Srimati Radharani.</p><h3>5. Sakhi Bhava (सखी भाव)</h3><p>The devotional sentiment of serving as an intimate friend and companion to Shri Radha and Krishna.</p><h3>6. Bhajan (भजन)</h3><p>Spiritual chanting, singing of devotional hymns, or absorbing the mind in silent contemplation and worship of the Divine Couple.</p><h3>7. Asta Sakhi (अष्ट सखी)</h3><p>The eight principal sakhis (female companions) of Srimati Radharani in Nikunj: Lalita, Vishakha, Chitra, Champakalata, Tungavidya, Indulekha, Rangadevi, and Sudevi.</p><h3>8. Kirtan (संकीर्तन)</h3><p>Congregational or individual singing and chanting of the holy names, attributes, and pastimes of Radha and Krishna.</p><h3>9. Lila (लीला)</h3><p>The transcendental, divine play or pastimes of Radha and Krishna, free from material karma.</p><h3>10. Seva (सेवा)</h3><p>Selfless devotional service performed with love for the satisfaction of the Guru, Vaishnavas, and Radha-Krishna.</p><h3>11. Bhakti (भक्ति)</h3><p>Active loving devotion and surrender to the Supreme Lord as both the practice and the goal.</p><h3>12. Prema (प्रेम)</h3><p>The highest stage of pure, unalloyed, and unconditional love for God, completely free from personal desires.</p><h3>13. Saranagati (शरणागति)</h3><p>Unconditional surrender to the refuge of the Divine Couple, characterized by complete faith and humility.</p><h3>14. Sadhana (साधना)</h3><p>Spiritual practice or discipline undertaken to achieve purification of the heart and realization of Bhakti.</p><h3>15. Braj Bhasha (ब्रजभाषा)</h3><p>The sweet western dialect of Hindi spoken in the Braj region, used by Rasik saints to compose their poetry.</p>'
    },
    hi: {
      title: 'ब्रज रसिक शब्दावली — वृंदावन के आध्यात्मिक एवं दार्शनिक शब्द',
      description: 'वृंदावन की रसिक परंपरा के प्रमुख आध्यात्मिक, दार्शनिक और भक्तिमय शब्दों की विस्तृत सूची। अर्थ, व्युत्पत्ति और हिंदी व्याख्या।',
      body: '<h1>ब्रज रसिक शब्दावली (Spiritual Encyclopedia)</h1><p>वृंदावन की रसिक उपासना और वाणी साहित्य में प्रयुक्त होने वाले प्रमुख शब्दों की सरल व्याख्या:</p><h3>१. ब्रज रस</h3><p>वृंदावन के निकुंजों में आस्वादन किया जाने वाला वह दिव्य प्रेम रस जो संपूर्ण निस्वार्थता पर आधारित है।</p><h3>२. नित्य विहार</h3><p>श्री राधा कृष्ण की वह लीला जो नित्य है, जिसमें विरह का कोई स्थान नहीं है, और जो निरंतर चल रही है।</p><h3>३. निकुंज</h3><p>वृंदावन के एकांत लता-कुंज जहाँ युगल सरकार (राधा कृष्ण) अपनी अंतरंग लीलाएँ संपादित करते हैं।</p><h3>४. मंजरी भाव</h3><p>वह साधना भाव जिसमें साधक अपने को श्री राधा की अंतरंग दासी मानकर केवल उनके सुख के लिए सेवा करता है।</p><h3>५. सखी भाव</h3><p>वह भाव जिसमें साधक स्वयं को श्री राधा कृष्ण की सखी मानकर उनकी लीलाओं में सहयोग करता है।</p><h3>६. भजन</h3><p>नाम जप, ध्यान या भगवान के लीला चिंतन में मन को लगाने की आध्यात्मिक साधना।</p><h3>७. अष्ट सखी</h3><p>श्री राधा जी की आठ प्रमुख अंतरंग सखियाँ: ललिता, विशाखा, चित्रा, चम्पकलता, तुंगविद्या, इन्दुलेखा, रंगदेवी और सुदेवी।</p><h3>८. संकीर्तन</h3><p>भगवान के नाम, रूप और गुणों का सामूहिक या व्यक्तिगत रूप से सस्वर गायन।</p><h3>९. लीला</h3><p>भगवान की वह दिव्य क्रीड़ा जो कर्म बंधन से मुक्त और विशुद्ध आनंद रूप होती है।</p><h3>१०. सेवा</h3><p>गुरु, वैष्णव और भगवान की प्रसन्नता के लिए किया जाने वाला निस्वार्थ प्रेमपूर्ण कार्य।</p><h3>११. भक्ति</h3><p>परमात्मा के प्रति प्रेम और अनन्य समर्पण का भाव।</p><h3>१२. प्रेम</h3><p>कामनाओं से रहित भगवान के प्रति सर्वोच्च, निस्वार्थ और अखंड अनुराग।</p><h3>१३. शरणागति</h3><p>भगवान के चरणों में स्वयं को पूर्ण रूप से समर्पित कर देने की स्थिति।</p><h3>१४. साधना</h3><p>हृदय की शुद्धि और ईश्वरीय प्रेम की प्राप्ति के लिए किया जाने वाला दैनिक अभ्यास।</p><h3>१५. ब्रजभाषा</h3><p>ब्रजमंडल की मीठी बोली जिसमें संतों ने अपने समस्त पदों और वाणियों की रचना की है।</p>'
    }
  },
  'places': {
    en: {
      title: 'Braj Dham Sacred Places — Guide to Holy Sites of Vrindavan',
      description: 'A comprehensive spiritual guide to the holy places, sacred lakes, and mystical groves of Braj Dham and Vrindavan, with historical and saintly connections.',
      body: '<h1>Sacred Places of Braj Dham</h1><p>A virtual pilgrimage guide to the holy sites and groves of Vrindavan:</p><h3>1. Nidhivan (निधिवन)</h3><p>The ancient forest grove where Swami Haridas performed bhajan, manifested Bankey Bihari Ji, and witnessed Nitya Vihar. It is believed that Radha and Krishna perform Ras Lila here nightly.</p><h3>2. Seva Kunj (सेवा कुंज)</h3><p>Also known as Nikunjavana, the sacred bower associated with Hit Harivansh Mahaprabhu where Krishna massages the feet of Shri Radha and performs intimate seva.</p><h3>3. Radha Kund (राधा कुण्ड)</h3><p>The most sacred lake in the universe, representing the liquid form of Srimati Radharani\'s pure love. Rediscovered by Sri Chaitanya Mahaprabhu.</p><h3>4. Govardhan Hill (गोवर्धन पर्वत)</h3><p>The holy hill lifted by Lord Krishna to protect the residents of Braj, circumambulated by thousands of devotees daily.</p><h3>5. Keshi Ghat (केशी घाट)</h3><p>The primary bathing ghat in Vrindavan where Krishna killed the Keshi demon, famous for its Yamuna Aarti.</p><h3>6. Kusum Sarovar (कुसुम सरोवर)</h3><p>The historical sandstone lake where Gopis collected flowers, a key stop on the Govardhan Parikrama.</p><h3>7. Mansi Ganga (मानसी गंगा)</h3><p>The sacred lake in Govardhan town manifested from Krishna\'s mind to please Nanda Baba.</p><h3>8. Prem Mandir (प्रेम मंदिर)</h3><p>The stunning modern temple of divine love built entirely of Italian Carrara marble.</p><h3>9. Radha Raman Temple (राधा रमण मंदिर)</h3><p>The historic temple containing the self-manifested deity of Radha Raman Ji from a Saligram Shila.</p><h3>10. Bankey Bihari Temple (बांके बिहारी मंदिर)</h3><p>The popular temple of Bankey Bihari Ji manifested by Swami Haridas in Nidhivan.</p><h3>11. Radha Vallabh Temple (राधावल्लभ मंदिर)</h3><p>The center of Radhavallabh sampradaya established by Hit Harivansh, celebrating the supremacy of Shri Radha.</p><h3>12. Kaliya Dah (कालिया दह)</h3><p>The spot on Yamuna river where Lord Krishna leaped from a Kadamba tree to conquer Kaliya serpent.</p>'
    },
    hi: {
      title: 'ब्रज धाम दर्शन — वृंदावन के पावन तीर्थ स्थल मार्गदर्शिका',
      description: 'ब्रजमंडल के मुख्य तीर्थों, पवित्र सरोवरों और रहस्यों से भरे वनों की विस्तृत जानकारी। इतिहास, कथा और संतों से जुड़ाव।',
      body: '<h1>ब्रज धाम के प्रमुख पावन स्थल</h1><p>ब्रजमंडल के पावन स्थलों और वनों का आध्यात्मिक परिचय:</p><h3>१. निधिवन</h3><p>वह प्राचीन पवित्र वन जहाँ स्वामी हरिदास जी ने तपस्या की और बांके बिहारी जी को प्रकट किया। यहाँ आज भी नित्य रास होने की लोक मान्यता है।</p><h3>२. सेवा कुंज</h3><p>हित हरिवंश महाप्रभु से संबंधित वह दिव्य निकुंज जहाँ भगवान श्यामसुंदर श्री राधा जी के चरणों की सेवा करते हैं।</p><h3>३. श्री राधा कुण्ड</h3><p>वैष्णव संप्रदाय में सर्वोच्च तीर्थ माना जाने वाला वह सरोवर जो स्वयं श्री राधा जी द्वारा निर्मित है और उनके साक्षात् प्रेम का प्रतीक है।</p><h3>४. गोवर्धन पर्वत</h3><p>भगवान श्रीकृष्ण द्वारा उठाया गया वह पावन पर्वत जिसका पूजन और परिक्रमा भक्त श्रद्धापूर्वक करते हैं।</p><h3>५. केशी घाट</h3><p>वृंदावन का सबसे प्रमुख घाट जहाँ भगवान कृष्ण ने केशी दैत्य का वध किया था, जहाँ प्रतिदिन यमुना आरती होती है।</p><h3>६. कुसुम सरोवर</h3><p>गोवर्धन परिक्रमा मार्ग पर स्थित ऐतिहासिक सरोवर जहाँ गोपियाँ पुष्प संकलन करती थीं।</p><h3>७. मानसी गंगा</h3><p>गोवर्धन के केंद्र में स्थित सरोवर जिसे भगवान कृष्ण ने नंदबाबा के स्नान हेतु अपने मन से प्रकट किया था।</p><h3>८. प्रेम मंदिर</h3><p>सफेद इतालवी संगमरमर से निर्मित भव्य मंदिर जो युगल सरकार की दिव्य लीलाओं को दर्शाता है।</p><h3>९. राधा रमण मंदिर</h3><p>वह ऐतिहासिक मंदिर जहाँ शालिग्राम शिला से प्रकट श्री राधा रमण देव जी की सेवा होती है।</p><h3>१०. बांके बिहारी मंदिर</h3><p>स्वामी हरिदास जी की साधना से प्रकट बांके बिहारी जी का अति प्रसिद्ध मंदिर।</p><h3>११. राधावल्लभ मंदिर</h3><p>हित हरिवंश महाप्रभु द्वारा स्थापित वह मंदिर जहाँ श्री राधा जी के सिंहासन और मुकुट की पूजा होती है।</p><h3>१२. कालिया दह</h3><p>यमुना जी का वह घाट जहाँ कदम्ब वृक्ष से कूदकर भगवान कृष्ण ने कालिया नाग का दमन किया था।</p>'
    }
  },
  'comparison-with-upanishads': {
    en: {
      title: 'Comparison of Vrindopnishad with Classical Upanishads',
      description: 'How does Vrindopnishad compare to principal Vedic Upanishads? Read a detailed comparative study of theology and methods.',
      body: '<h1>Comparison with Classical Upanishads</h1><p>While the classical Vedic Upanishads (such as the Chandogya, Brihadaranyaka, and Isha) focus primarily on the formless aspect of truth (Nirguna Brahman) and absolute liberation (Moksha), Vrindopnishad synthesizes this intellectual peak with the ultimate depth of Bhakti (loving devotion). It shows that the absolute truth is not a cold, qualityless state of consciousness, but the supreme person who possesses infinite qualities and is the ocean of relationship (Raso Vai Sah).</p><p>In classical Upanishads, the method is often negation (Neti Neti) and quiet meditation to realize the identity of the individual soul with the supreme soul. In Vrindopnishad, the method is celebration and relationship — chanting the names, singing the pastimes, and serving the divine couple Radha Krishna. The individual soul does not merge into the divine, but retains its distinct spiritual identity in order to experience the bliss of eternal service.</p><p>Thus, Vrindopnishad does not reject the classical Upanishads but rather fulfills them. It takes the high philosophical conclusions of the Upanishads and bathes them in the sweet, relational nectar of Vrindavan devotion, presenting a complete, integrated path that satisfies both the intellect and the heart.</p>'
    },
    hi: {
      title: 'पारंपरिक उपनिषदों से तुलना — वृंदोपनिषद् दार्शनिक तुलना',
      description: 'वैदिक उपनिषदों और वृंदावन की रसिक विचारधारा के बीच दार्शनिक अंतर और समानताएँ। ब्रह्म, आत्मा और प्रेम दर्शन की तुलना।',
      body: '<h1>वैदिक उपनिषदों से तुलना</h1><p>पारंपरिक वैदिक उपनिषद (जैसे ईश, कठ, केन आदि) मुख्य रूप से ज्ञान मार्ग पर आधारित हैं। वे निराकार ब्रह्म की प्राप्ति और सांसारिक बंधनों से मुक्त होकर मोक्ष (मुक्ति) पाने को जीवन का परम ध्येय घोषित करते हैं। वहीं, वृंदोपनिषद् इस ज्ञान को आगे बढ़ाते हुए भगवान के साकार और मधुर रूप \'श्री राधा कृष्ण\' की उपासना पर बल देता है।</p><p>पारंपरिक उपनिषदों की साधना पद्धति में जगत को मिथ्या मानकर \'नेति नेति\' (यह नहीं, वह नहीं) का आश्रय लिया जाता है और मौन ध्यान किया जाता है। इसके विपरीत, वृंदोपनिषद् में संसार को भगवान की लीला का विस्तार मानकर भगवान के नामों, गुणों और रूप का उत्सव मनाया जाता है। यहाँ भक्त भगवान में लीन होना नहीं चाहता, बल्कि सेवक बनकर उनके प्रेम का रसास्वादन करना चाहता है।</p><p>संक्षेप में, पारंपरिक उपनिषद यदि ज्ञान का शिखर हैं, तो वृंदोपनिषद् उस शिखर पर बहने वाला प्रेम रस का झरना है। यह बुद्धि की गहराई को हृदय के भाव से जोड़कर एक पूर्ण जीवन दर्शन प्रस्तुत करता है।</p>'
    }
  },
  'guide': {
    en: {
      title: 'Complete Guide to Vrindopnishad — Seeker\'s Manual',
      description: 'A step-by-step seeker\'s guide to utilizing Vrindopnishad for daily paath, meditation, Japa chanting, and spiritual growth.',
      body: '<h1>Seeker\'s Practice Guide</h1><p>To make the most of the Vrindopnishad platform, we recommend establishing a consistent daily practice. Begin your morning by accessing the Verse of the Day. Read the Sanskrit text aloud if possible, as the sound vibration has a purifying effect on the mind. Spend a few minutes reading the Hindi and English translations, focusing on how the message applies to your daily life.</p><p>Next, use the digital Japa counter to chant your daily rounds of the holy names. Find a quiet spot, sit comfortably with a straight posture, and focus your full attention on the sound of the mantra. Try to avoid distractions and quiet the mind, letting the sound vibration wash over you. This practice builds focus, reduces stress, and cultivates inner peace.</p><p>Throughout the day, try to remember the teachings of the saints. Perform your daily duties as an offering to the divine, maintaining an attitude of gratitude and humility. In the evening, you can return to the platform to read a biography of a saint or listen to a temple kirtan. By making these practices a part of your daily routine, you will experience a steady growth in your spiritual awareness and emotional well-being.</p>'
    },
    hi: {
      title: 'साधना मार्गदर्शिका — वृंदोपनिषद् का दैनिक उपयोग कैसे करें',
      description: 'दैनिक स्वाध्याय, नाम जप और ध्यान के लिए एक पूर्ण व्यावहारिक मार्गदर्शिका। आध्यात्मिक विकास के लिए सरल कदम।',
      body: '<h1>साधना मार्गदर्शिका</h1><p>वृंदोपनिषद् मंच का अधिकतम लाभ उठाने के लिए हम एक नियमित दैनिक दिनचर्या बनाने की सलाह देते हैं। अपने सुबह के समय को शांत और आध्यात्मिक वातावरण में बिताने का प्रयास करें।</p><p>1. **दैनिक स्वाध्याय:** प्रतिदिन सुबह उठकर सबसे पहले मंच पर दिए गए \'दैनिक श्लोक\' या पद का पाठ करें। संस्कृत शब्दों के सही उच्चारण का अभ्यास करें और उसके बाद उसके अनुवाद और व्याख्या को ध्यानपूर्वक पढ़ें।</p><p>2. **नाम जप साधना:** दिन में कम से कम 10 से 15 मिनट के लिए नाम जप काउंटर का उपयोग करें। एक शांत स्थान पर बैठकर भगवान के नाम का उच्चारण करें और अपना पूरा ध्यान उस ध्वनि पर केंद्रित करें। यह मानसिक विकारों को शांत करने की सबसे शक्तिशाली औषधि है।</p><p>3. **संतों का स्मरण:** संध्या के समय संतों की जीवनियाँ (संत चरित्र) पढ़ें। उनके जीवन की कठिनाइयाँ और उनकी निष्कपट भक्ति हमें कठिन समय में भी धैर्य और विश्वास बनाए रखने की शक्ति देती है।</p>'
    }
  },
  'braj-rasik-heritage': {
    en: {
      title: 'Braj Rasik Heritage — The Devotional Legacy of Vrindavan',
      description: 'Discover the rich spiritual legacy of the Braj region and Vaishnava Rasik saints. Explore their contributions to kirtan, literature, and art.',
      body: '<h1>Braj Rasik Heritage</h1><p>Braj Rasik Heritage is the spiritual repository of divine songs, literature, poetry, and theology compiled by the rasik saints of Vrindavan. This heritage centers on absolute selflessness, sweet aesthetic devotion, and ecstatic communion with Shri Radha Krishna. It includes the teachings of Swami Haridas, Hit Harivansh Mahaprabhu, Swami Hariram Vyas, Surdas, and Sri Chaitanya\'s followers.</p><p>This heritage is unique in its emphasis on Madhurya Rasa (the mood of sweet, intimate love) over Aishwarya Rasa (the mood of awe and reverence). It teaches that God is not a distant ruler to be feared, but a beloved friend and partner in a relationship of pure love. The saints expressed this philosophy through beautiful poetry in the Braj Bhasha language, which is celebrated for its musicality and emotional depth.</p><p>By preserving and sharing this heritage, Vrindopnishad aims to keep this living spiritual tradition alive for future generations. The songs and teachings are not just historical artifacts, but active invitations to experience the same divine love that the saints felt. Exploring this heritage is a journey into the very heart of devotion, offering a path to absolute inner fulfillment.</p>'
    },
    hi: {
      title: 'ब्रज रसिक विरासत — वृंदावन की अलौकिक प्रेम परंपरा',
      description: 'ब्रज के रसिक संतों की अनमोल आध्यात्मिक धरोहर। उनके काव्य, संगीत और दर्शन का संपूर्ण परिचय और वैष्णव समाज में योगदान।',
      body: '<h1>ब्रज रसिक विरासत</h1><p>ब्रज रसिक विरासत उन महान संतों के जीवन, उनके भजनों, काव्यों और दार्शनिक सिद्धांतों का दिव्य संकलन है जिन्होंने ब्रज की पावन भूमि को अपनी लीला स्थली बनाया। इस विरासत का मूल उद्देश्य भगवान श्री राधा कृष्ण के प्रति पूर्ण और निस्वार्थ प्रेम (माधुर्य भाव) का प्रचार करना है।</p><p>इस परंपरा में स्वामी हरिदास, हित हरिवंश महाप्रभु, नारायण भट्ट और हरिराम व्यास जैसे आचार्यों का स्थान प्रमुख है। इन संतों ने ब्रजभाषा में मधुर पदों की रचना की जिन्हें आज भी वृंदावन के मंदिरों में गाया जाता है। यह परंपरा सिखाती है कि भगवान को पाने के लिए किसी कठिन तपस्या की आवश्यकता नहीं है, केवल सरल और निश्छल प्रेम ही उन्हें वश में कर सकता है।</p><p>वृंदोपनिषद् इस विरासत को डिजिटल युग में जीवित रखने के लिए प्रतिबद्ध है। यह केवल एक संग्रह नहीं है, बल्कि एक जीवित अनुभव है जो हमें सिखाता है कि किस प्रकार हम अपने हृदय को एक निर्मल कुंज बनाकर उसमें परमात्मा का स्वागत कर सकते हैं।</p>'
    }
  },
  'what-is-radha-snata': {
    en: {
      title: 'What is Radha Snata? — Morning Pastimes & Spiritual Meaning',
      description: 'Understand the concept of Radha Snata (Radha-snata-vibhusita) in Braj Rasik heritage. Explore its role in Asta-kaliya-lila and morning devotional meditations.',
      body: '<h1>What is Radha Snata?</h1><p>In the esoteric Vaishnava tradition of Vrindavan, particularly within the lineage of the Braj Rasik saints, <strong>Radha Snata</strong> (often referred to in Sanskrit verses as <em>Radha Snata-Vibhusita</em> — Srimati Radharani after completing Her divine morning bath and ornamentation) is not merely a physical action but a deep object of spiritual meditation (Smarana).</p><p>According to the Rasik scriptures, every moment of the Divine Couple, Shri Radha and Shri Krishna, is eternal, taking place in the spiritual realm of Nitya Vrindavan. The daily pastimes are structured into eight distinct periods of the day, known as the Asta-kaliya-lila. The morning pastime, occurring in the second period (Dvitiya-Yama, typically between 6:00 AM and 8:20 AM), is when Shri Radha returns to Her home in Yavat, takes Her sacred morning bath, is adorned with divine jewelry and clothing, and prepares delicious foods for Shri Krishna.</p><p>During the morning hours, the Gopis and Manjaris (intimate maidservants) assist Srimati Radharani in Her bathing ritual. Srimati Radharani is bathed with pure, scented waters infused with saffron, sandalwood paste, and fragrant flowers. Following the bath, the sakhis dress Her in brilliant blue garments (nilambari) and decorate Her with exquisite ornaments. Rasik devotees meditate on this form of Radha Snata-Vibhusita to cultivate the mood of a maidservant (Manjari Bhava), desiring only to assist in the pleasure of the Divine Couple.</p>'
    },
    hi: {
      title: 'राधा स्नात क्या है? — सुबह की लीलाएँ एवं आध्यात्मिक महत्व',
      description: 'ब्रज रसिक विरासत में राधा स्नात (राधा-स्नात-विभूषिता) की अवधारणा को समझें। अष्टकाली लीला और प्रातःकालीन भक्ति ध्यान में इसकी भूमिका का अध्ययन करें।',
      body: '<h1>राधा स्नात क्या है?</h1><p>वृंदावन की रसिक वैष्णव परंपरा में, <strong>राधा स्नात</strong> (संस्कृत श्लोकों में <em>राधा स्नात-विभूषिता</em> — दिव्य प्रातःकालीन स्नान और श्रृंगार के बाद श्री राधा) केवल एक शारीरिक क्रिया नहीं है, बल्कि यह मानसिक साधना और गहन भक्ति ध्यान (स्मरण) का एक महत्वपूर्ण विषय है।</p><p>रसिक शास्त्रों के अनुसार, श्री राधा कृष्ण की नित्य लीलाएँ आठ पहरों में विभाजित हैं, जिन्हें <strong>अष्टकालीन लीला</strong> कहा जाता है। प्रातःकाल की लीला (द्वितीय याम, लगभग सुबह 6:00 से 8:20 बजे) में श्री राधा अपने गृह यावट लौटती हैं, जहाँ सखियाँ और मंजरी दासियाँ उन्हें सुगंधित जल, केसर और चंदन से स्नान कराती हैं। स्नान के पश्चात उन्हें नील वस्त्र (नीलाम्बरी) पहनाया जाता है और दिव्य आभूषणों तथा सोलह श्रृंगार से सुसज्जित किया जाता है। रसिक साधक इस स्वरूप का ध्यान करते हैं ताकि वे सखी भाव या मंजरी भाव में प्रतिष्ठित होकर युगल सरकार की सेवा कर सकें।</p>'
    }
  },
  'who-is-harirae-ji': {
    en: {
      title: 'Who is Harirae Ji? — Biography, Teachings & Varta Literature',
      description: 'Discover the life and spiritual contributions of Shri Harirae Ji Mahaprabhu, the prominent acharya of Pushtimarg and writer of historical Varta literature.',
      body: '<h1>Shri Harirae Ji Mahaprabhu</h1><p>Shri Harirae Ji Mahaprabhu (1612–1715 AD) was one of the most prominent acharyas in the disciplic lineage of Shri Vallabhacharya, within the Pushtimarg (path of grace) tradition. Born in Gokul, he was blessed with deep spiritual insight from childhood. He is celebrated for his absolute dedication to the service of Lord Shrinathji and is considered an embodiment of the spiritual mood of service (Bhava).</p><p>Shri Harirae Ji is historically famous for compiling and commenting on the **Varta Literature**—specifically the *Chaurasi Vaishnavan Ki Varta* (Chronicles of 84 Vaishnavas) and *Do Sau Vaishnavan Ki Varta* (Chronicles of 252 Vaishnavas). These texts form the bedrock of historical Vaishnava biography in India, detailing the lives, struggles, and devotional realizations of Vallabhacharya’s and Vitthalnath’s disciples.</p><p>Beyond Vartas, he wrote the *Siksha Patra* (letters of instruction)—41 letters containing detailed instructions on daily sadhana, mental control, and Vaishnava behavior. His Sanskrit commentary on Vallabhacharya’s work, *Siddhanta Muktavali*, remains a canonical guide for understanding the philosophy of Shuddhadvaita (pure non-dualism).</p>'
    },
    hi: {
      title: 'श्री हरिराय जी महाप्रभु कौन हैं? — जीवनी, शिक्षाएँ एवं वार्ता साहित्य',
      description: 'पुष्टिमार्ग के महान आचार्य और वार्ता साहित्य के लेखक श्री हरिराय जी महाप्रभु के जीवन और आध्यात्मिक योगदान के बारे में विस्तार से जानें।',
      body: '<h1>श्री हरिराय जी महाप्रभु</h1><p>श्री हरिराय जी महाप्रभु (1612-1715 ई.) पुष्टिमार्ग सम्प्रदाय (वल्लभ संप्रदाय) के अंतर्गत श्री वल्लभाचार्य जी की शिष्य परंपरा में एक महान आचार्य थे। गोकुल में जन्मे हरिराय जी बचपन से ही उच्च कोटि के भगवद-भक्त थे और वे श्रीनाथजी की निकुंज सेवा के प्रति पूर्ण समर्पित थे। उन्हें पुष्टिमार्गीय साधना में \'भाव रूप\' माना जाता है।</p><p>वे मुख्य रूप से <strong>वार्ता साहित्य</strong> (जैसे *चौरासी वैष्णवन की वार्ता* और *दो सौ बावन वैष्णवन की वार्ता*) के संपादन और टीका के लिए इतिहास में प्रसिद्ध हैं। यह वार्ता साहित्य भारत में वैष्णव भक्तों के जीवन चरित्र और उनके भक्ति अनुभवों का आधार ग्रन्थ है, जो प्रारंभिक ब्रजभाषा गद्य में लिखा गया है।</p><p>इसके अतिरिक्त उन्होंने *शिक्षा पत्र* की रचना की, जिसमें ४१ पत्र हैं जो साधक के लिए दैनिक साधना, मन पर नियंत्रण और वैष्णवोचित आचरण के महत्वपूर्ण नियमों को सरल भाषा में समझाते हैं।</p>'
    }
  },
  'what-is-madhurya-and-sakhi-bhava': {
    en: {
      title: 'What is Madhurya Bhava & Sakhi Bhava? — Sentiments of Divine Love',
      description: 'Understand the deep spiritual sentiments of Madhurya Bhava (conjugal love) and Sakhi Bhava (friendship/maidservant mood) in Vrindavan Vaishnavism.',
      body: '<h1>Madhurya Bhava & Sakhi Bhava</h1><p><strong>Madhurya Bhava</strong> represents the conjugal or romantic relationship sentiment between the soul and God. Regarded as the highest and sweetest of the five primary devotional relationships (Rasas) in Vaishnavism, it transcends the awe and reverence of majestic worship, replacing it with absolute intimacy, mutual surrender, and complete selflessness.</p><p>In this mood, Lord Krishna is not approached as the almighty creator or king, but as the supreme beloved (Shyamasundar). Srimati Radharani is the ideal embodiment of Madhurya Bhava, where every action is performed solely for the sensory and spiritual pleasure of the Divine Couple.</p><p><strong>Sakhi Bhava</strong> is the mood of serving as an intimate friend or female companion (Sakhi) to Shri Radha and Krishna. Sakhis (like Lalita and Vishakha) coordinate the pastimes, decorate the arbors, and directly share in the blissful sport of the Divine Couple. An even more confidential aspect is **Manjari Bhava** (the mood of maidservants), championed by the Gaudiya tradition. Manjaris are young assistant sakhis who serve Srimati Radharani exclusively. They do not seek direct association with Krishna; rather, their ultimate joy lies in assisting Radha in Her union, representing the highest peak of selflessness.</p>'
    },
    hi: {
      title: 'माधुर्य भाव और सखी भाव क्या है? — दिव्य प्रेम दर्शन एवं अंतर',
      description: 'वृंदावन दर्शन के दिव्य भावों: माधुर्य भाव (प्रियतम भाव) और सखी/मंजरी भाव (दासी/सहेली भाव) के गहरे आध्यात्मिक रहस्यों को समझें।',
      body: '<h1>माधुर्य भाव एवं सखी भाव</h1><p><strong>माधुर्य भाव</strong> आत्मा और परमात्मा के बीच के मधुर प्रियतम संबंध (पति-पत्नी या प्रेमी-प्रेमिका) का प्रतीक है। वैष्णव भक्ति शास्त्रों में इसे पाँच मुख्य रसों में सबसे उत्तम और मधुर माना गया है, जहाँ ईश्वर के प्रति भय या ऐश्वर्य को भूलकर भक्त पूर्ण अंतरंगता और निस्वार्थ प्रेम में डूब जाता है।</p><p>इस भाव में भगवान कृष्ण को सृष्टि के नियामक के रूप में नहीं, बल्कि मन को मोहने वाले श्यामसुंदर के रूप में भजा जाता है। श्री राधा जी इस भाव की आदर्श प्रतिमूर्ति हैं, जहाँ प्रत्येक लीला केवल प्रियतम के सुख के लिए होती है।</p><p><strong>सखी एवं मंजरी भाव</strong> में साधक स्वयं को सखी या सहचरी मानकर श्री राधा कृष्ण की लीलाओं में सेवा करता है। गौड़ीय परंपरा में <strong>मंजरी भाव</strong> को अत्यंत गोपनीय माना गया है, जहाँ साधिका श्री राधारानी की दासी बनकर उनकी प्रसन्नता के लिए कुंजों की सेवा करती है और स्वयं कृष्ण से मिलन की आकांक्षा नहीं रखती, जो निस्वार्थता की पराकाष्ठा है।</p>'
    }
  },
  'radhavallabh-vs-gaudiya-sampradaya': {
    en: {
      title: 'Radha Vallabh vs Gaudiya Sampradaya — Philosophy, Founders & Differences',
      description: 'Understand the key philosophical differences between Radha Vallabh and Gaudiya Sampradaya. Compare Hit Harivansh and Chaitanya Mahaprabhu\'s teachings.',
      body: '<h1>Radhavallabh vs Gaudiya Sampradaya</h1><p>The <strong>Gaudiya Sampradaya</strong> traces its modern renaissance to <strong>Sri Chaitanya Mahaprabhu</strong> (1486–1534 AD) in Bengal. Chaitanya Mahaprabhu instructed the Six Goswamis to establish the Achintya-Bheda-Abheda philosophy. The <strong>Radhavallabh Sampradaya</strong> was established by <strong>Goswami Hit Harivansh Mahaprabhu</strong> (1502–1552 AD). He manifested the deity of Shri Radhavallabh Lal Ji in Vrindavan, centering the entire tradition on spontaneous love rather than conventional Vedic rituals.</p><p>In Gaudiya theology, Shri Radha is established as the <em>Hladini Shakti</em> (pleasure-giving energy) of Lord Krishna, who is the ultimate energetic source (Shaktiman). In the Radhavallabh tradition, the theology is radically <strong>Radha-centric</strong>. Shri Radha is not merely the potency; She is the supreme, sovereign ruler of Vrindavan. Lord Krishna is considered Her absolute servant, dedicated solely to Her pleasure.</p><p>Gaudiya Vaishnavism champions <strong>Manjari Bhava</strong>, where devotees meditate on serving under the principal sakhis as tiny maidservants. The pastimes involve both union and separation (viraha/vipralambha). Radhavallabh sadhana revolves around <strong>Sahachari Bhava</strong> and is focused exclusively on <strong>Nitya Vihar</strong>—continuous, uninterrupted union in the bowers of Nikunj. There is absolutely no place for separation (viraha) in this sentiment.</p>'
    },
    hi: {
      title: 'राधावल्लभ बनाम गौड़ीय संप्रदाय — दर्शन, आचार्य एवं अंतर',
      description: 'राधावल्लभ और गौड़ीय संप्रदाय के बीच प्रमुख दार्शनिक अंतर समझें। हित हरिवंश महाप्रभु और चैतन्य महाप्रभु के सिद्धांतों का तुलनात्मक अध्ययन।',
      body: '<h1>राधावल्लभ बनाम गौड़ीय संप्रदाय</h1><p>गौड़ीय सम्प्रदाय का प्राकट्य 16वीं शताब्दी में <strong>श्रीमन् महाप्रभु चैतन्य देव</strong> (1486–1534 ई.) के बंगाल से आगमन के साथ हुआ। इन्होंने अचिन्त्य-भेदाभेद दर्शन की स्थापना की। वहीं, <strong>राधावल्लभ सम्प्रदाय</strong> की स्थापना <strong>गोस्वामी हित हरिवंश महाप्रभु</strong> (1502–1552 ई.) द्वारा की गई, जिन्होंने मदन टेर पर श्री राधावल्लभ लाल जी को विराजमान किया।</p><p>गौड़ीय दर्शन में श्री राधा को भगवान कृष्ण की \'ह्लादिनी शक्ति\' (आनंददायिनी शक्ति) माना जाता है, जहाँ कृष्ण परम पुरुष हैं। इसके विपरीत, राधावल्लभ सम्प्रदाय में श्री राधा ही सर्वोपरि सत्ता हैं और कृष्ण भी उनके अधीन रहकर उनकी प्रसन्नता के लिए लीला विलास करते हैं (राधा चरण प्रधान)।</p><p>गौड़ीय मत में <strong>मंजरी भाव</strong> प्रमुख है जिसमें मिलन के साथ-साथ वियोग (विरह) का भाव भी रस की पुष्टि के लिए आवश्यक है। राधावल्लभ मत में <strong>सहचरी भाव</strong> प्रमुख है जहाँ केवल <strong>नित्य विहार</strong> (अखंड मिलन) की उपासना होती है और विरह का सर्वथा निषेध है।</p>'
    }
  },
  'vrindavan-parikrama-guide': {
    en: {
      title: 'Vrindavan Parikrama Guide — Route, Holy Ghats & Spiritual Rules',
      description: 'Complete guide to the sacred Vrindavan Parikrama circumambulation (~10km). Learn about the route, starting points, holy temples, and spiritual rules.',
      body: '<h1>Vrindavan Parikrama Guide</h1><p>Performing the Parikrama (circumambulation) is a practice of physical and mental submission to the divine. Devotees believe that circling the holy town of Vrindavan cleanses accumulated karma and grants entrance into the eternal arbors of Nikunj. The total distance is approximately **10 Kilometers (6 miles)** and takes between **2.5 to 4 hours** at a normal walking pace.</p><p>While the Parikrama can be started at any point, most pilgrims prefer to begin at the banks of the Yamuna River (such as **Keshi Ghat**), the historical **Madan Mohan Temple**, or near **ISKCON temple**. Key landmarks include Keshi Ghat, Madan Mohan Temple on the red-sandstone hill, Kaliya Dah where Krishna subdued Kaliya serpent, and Imli Tala where Chaitanya Mahaprabhu sat in deep ecstasy under the sacred tamarind tree.</p><p>Spiritual etiquette suggests walking barefoot to touch the sacred dust (Braj Raj) directly, constantly chanting the names of Radha and Krishna, and showing respect to sadhus, cowherds, and the sacred cows along the path.</p>'
    },
    hi: {
      title: 'वृंदावन परिक्रमा मार्गदर्शिका — मार्ग, प्रमुख घाट एवं महत्व',
      description: 'वृंदावन की पवित्र परिक्रमा (लगभग 10 किमी) का संपूर्ण विवरण। परिक्रमा का समय, प्रारंभ बिंदु, मुख्य घाट और दर्शन स्थल।',
      body: '<h1>वृंदावन परिक्रमा मार्गदर्शिका</h1><p>वृंदावन की पावन पंचकोसीय परिक्रमा (लगभग १० किलोमीटर) ब्रजमंडल का एक अत्यंत महत्वपूर्ण साधना अंग है। मान्यता है कि परिक्रमा लगाने से अनंत पापों का नाश होता है और साधक को गोलोक धाम की प्राप्ति होती है। इसे पूरा करने में लगभग २.५ से ४ घंटे का समय लगता है।</p><p>श्रद्धालु मुख्य रूप से इस्कॉन मंदिर के पास से, केशी घाट से या मदन मोहन जी के मंदिर से परिक्रमा प्रारंभ करते हैं। इसके मुख्य पड़ावों में यमुना नदी का केशी घाट, काली दह (काली नाग दमन स्थल), इमली तला (चैतन्य महाप्रभु की साधना स्थली) आदि तीर्थ आते हैं।</p><p>परिक्रमा के समय नंगे पैर चलना सर्वश्रेष्ठ माना जाता है ताकि पवित्र रज का सीधे स्पर्श हो। यात्रा के समय मुख से निरंतर राधे-राधे या हरे कृष्ण महामंत्र का नाम जप करना चाहिए और मार्ग में पड़ने वाले गौवंश व संतों की सेवा करनी चाहिए।</p>'
    }
  },
  'history-of-radhavallabh-sampradaya': {
    en: {
      title: 'History of Radha Vallabh Sampradaya — Founder, Philosophy & Temples',
      description: 'An in-depth historical and theological guide to the Radhavallabh Sampradaya of Vrindavan, founded by Shri Hit Harivansh Mahaprabhu. Learn about Sahachari Bhava and Radha Dasya.',
      body: '<h1>History of Radha Vallabh Sampradaya</h1><p>The Radha Vallabh Sampradaya was established in the 16th century by <strong>Shri Hit Harivansh Mahaprabhu</strong> (1502–1552 AD), who is worshiped as the incarnation of Lord Krishna\'s divine flute. He brought the deity of Shri Radhavallabh Lal Ji to Vrindavan and installed Him at Madan Ter in 1534 AD.</p><p>The central philosophy of the sampradaya is <strong>Radha Dasya</strong>, which holds Srimati Radharani as the supreme controller of Vrindavan. Lord Krishna is considered Her servant, dedicated entirely to Her pleasure. Practitioners cultivate <strong>Sahachari Bhava</strong>, identifying as companions who witness and serve the eternal couple in the secluded bowers (Nikunj) of Vrindavan. The tradition focuses exclusively on <strong>Nitya Vihar</strong>, which represents continuous, uninterrupted union devoid of physical or emotional separation.</p><p>Canonical literature includes the <em>Hit Chaurasi</em> (84 Braj Bhasha verses) and <em>Radha Sudha Nidhi</em> (270 Sanskrit verses), which outline the aesthetics of devotion and disciplic teachings.</p>'
    },
    hi: {
      title: 'राधावल्लभ संप्रदाय का इतिहास — संस्थापक, दर्शन एवं मुख्य मंदिर',
      description: 'राधावल्लभ संप्रदाय के इतिहास, संस्थापक श्री हित हरिवंश महाप्रभु, सहचरी भाव दर्शन और वृंदावन के मुख्य मंदिरों का विस्तृत विवरण।',
      body: '<h1>राधावल्लभ संप्रदाय का इतिहास</h1><p>राधावल्लभ संप्रदाय की स्थापना 16वीं शताब्दी में <strong>श्री हित हरिवंश महाप्रभु</strong> (1502–1552 ईस्वी) द्वारा की गई थी, जिन्हें भगवान कृष्ण की मुरली का अवतार माना जाता है। उन्होंने संवत 1591 (1534 ईस्वी) में श्री राधावल्लभ लाल जी के विग्रह को वृंदावन के मदन टेर पर प्रतिष्ठित किया।</p><p>इस संप्रदाय का मुख्य दर्शन <strong>राधा दास्य</strong> है, जहाँ श्री राधा रानी को ही सर्वोपरि आराध्या माना जाता है और श्री कृष्ण उनके अधीन रहकर सेवा करते हैं। साधक <strong>सहचरी भाव</strong> की उपासना करते हैं, जिसमें वे सखी बनकर निकुंज की नित्य लीलाओं में युगल की सेवा करते हैं। इसमें केवल <strong>नित्य विहार</strong> (अखंड मिलन) का स्थान है, वियोग का कोई स्थान नहीं है।</p><p>मुख्य ग्रंथों में हित हरिवंश महाप्रभु जी रचित <em>हित चौरासी</em> (ब्रजभाषा) और <em>राधासुधानिधि</em> (संस्कृत) शामिल हैं, जो इस उपासना पद्धति के सैद्धांतिक आधार हैं।</p>'
    }
  },
  'major-rasik-saints-of-braj': {
    en: {
      title: 'Major Rasik Saints of Braj — Lineages, Biographies & Contributions',
      description: 'A comprehensive guide and disciplic map of the prominent Rasik saints of Vrindavan, including Swami Haridas, Hit Harivansh, Hariram Vyas, and Dhruvdas.',
      body: '<h1>Major Rasik Saints of Braj</h1><p>Vrindavan\'s spiritual heritage is shaped by the <strong>Rasik saints</strong>, who lived in constant contemplation of the intimate pastimes of Radha and Krishna. They expressed their realizations through poetry and classical music, rejecting dry ritualism.</p><p>The foundation of this tradition rests on the <strong>Haritrayi</strong> (the triad of saints): <strong>Swami Haridas</strong>, who manifested Bankey Bihari Ji in Nidhivan; <strong>Shri Hit Harivansh Mahaprabhu</strong>, who founded the Radhavallabh lineage; and <strong>Shri Hariram Vyas</strong> of Vyas Ghera. In the 17th century, <strong>Shri Dhruvdas</strong> compiled the disciplic histories in his monumental <em>Bayalees Leela</em>. Today, this lineage continues through contemporary saints like <strong>Shri Premanand Ji Maharaj</strong>.</p>'
    },
    hi: {
      title: 'ब्रज के प्रमुख रसिक संत — जीवनी, गुरु परंपरा एवं साहित्यिक योगदान',
      description: 'वृंदावन के महान रसिक संतों — स्वामी हरिदास, श्री हित हरिवंश, हरीराम व्यास, ध्रुवदास आदि का जीवन चरित्र एवं गुरु परंपरा इतिहास।',
      body: '<h1>ब्रज के प्रमुख रसिक संत</h1><p>वृंदावन की आध्यात्मिक विरासत यहाँ के <strong>रसिक संतों</strong> द्वारा रची गई है, जो युगल सरकार की निकुंज लीलाओं में मग्न रहते थे। उन्होंने कर्मकांडों और शुष्क ज्ञान को छोड़कर केवल प्रेम मार्ग को अपनाया।</p><p>इस परंपरा के मूल आधार <strong>हरित्रयी</strong> कहे जाने वाले तीन संत हैं: <strong>स्वामी हरिदास जी</strong> (निधिवन में बिहारी जी को प्रकट करने वाले), <strong>श्री हित हरिवंश महाप्रभु</strong> (राधावल्लभ संप्रदाय के प्रवर्तक), और व्यास घेरा के <strong>श्री हरिराम व्यास जी</strong>। 17वीं शताब्दी में <strong>श्री ध्रुवदास जी</strong> ने <em>बयालीस लीला</em> की रचना कर इस परंपरा के सिद्धांतों को लिपिबद्ध किया। वर्तमान समय में पूज्य <strong>श्री प्रेमानंद जी महाराज</strong> इस रसमय धारा का प्रचार कर रहे हैं।</p>'
    }
  },
  'about': {
    en: {
      title: 'About Vrindopnishad — Archiving Sacred Braj Literature',
      description: 'Learn about the mission, vision, and team behind Vrindopnishad. We digitally preserve ancient Sanskrit shlokas and teachings of Vrindavan rasik saints.',
      body: '<h1>About Vrindopnishad Project</h1><p>The Vrindopnishad Project is a scholarly digital archiving and publication platform dedicated to preserving the rich devotional literature of the Braj region. We collect, cross-reference, and publish the original verses (Sanskrit shlokas, Braj Bhasha poetry) from manuscript collections and printed publications, translating them into Hindi and English with detailed annotations and audio chanting. Our mission is to make these sacred works universally accessible without financial barriers, operating under the guidance of manuscript editors and traditional scholars.</p>'
    },
    hi: {
      title: 'परियोजना परिचय (About) — वृंदोपनिषद् ग्रंथालय संरक्षण',
      description: 'वृंदोपनिषद् परियोजना के बारे में जानें। हमारा उद्देश्य प्राचीन पांडुलिपियों, भजनों और संस्कृत श्लोकों का डिजिटल संरक्षण और निःशुल्क प्रकाशन करना है।',
      body: '<h1>परियोजना परिचय (About Us)</h1><p>वृंदोपनिषद् परियोजना एक डिजिटल आध्यात्मिक पुस्तकालय है जो ब्रजमंडल के प्राचीन और दुर्लभ वाणी साहित्य के संरक्षण के लिए समर्पित है। हमारा प्रमुख उद्देश्य मध्यकालीन रसिक संतों (जैसे स्वामी हरिदास, श्री हित हरिवंश, ध्रुवदास आदि) की रचनाओं और संस्कृत ग्रंथों को पांडुलिपियों व प्रामाणिक संस्करणों से संकलित करना है। इन्हें हम मूल पाठ, रोमन लिप्यंतरण, हिंदी अनुवाद और विस्तृत व्याख्या के साथ उपलब्ध कराते हैं। यह संपूर्ण सेवा संस्कृत विद्वानों और manuscript आचार्यों के मार्गदर्शन में संचालित है तथा सभी के लिए पूर्णतः निःशुल्क उपलब्ध है।</p>'
    }
  },
  'editorial-policy': {
    en: {
      title: 'Editorial & Verification Policy — Vrindopnishad',
      description: 'Read the editorial standards of Vrindopnishad. Learn how we verify Sanskrit shlokas, Braj Bhasha poetry, and translations for scriptural accuracy.',
      body: '<h1>Editorial & Verification Policy</h1><p>Every text published on Vrindopnishad undergoes a meticulous verification process. We crosscheck all Devanagari texts against multiple printed editions from established publishers (like Gita Press, Gorakhpur and Radhavallabh Temple Publications) to correct typographical errors. Translations are reviewed by traditional scholars to ensure fidelity to historical commentaries, and transliterations conform strictly to standard Roman IAST guidelines. We encourage readers to report any discrepancies for immediate review and correction.</p>'
    },
    hi: {
      title: 'सम्पादन एवं सत्यापन नीति (Editorial Policy) — वृंदोपनिषद्',
      description: 'वृंदोपनिषद् की सम्पादन और सत्यापन नीति। जानें कि श्लोकों, पदों और अनुवादों की प्रामाणिकता की जाँच कैसे की जाती है।',
      body: '<h1>सम्पादन एवं सत्यापन नीति</h1><p>वृंदोपनिषद् पर प्रकाशित प्रत्येक पद, श्लोक और स्तोत्र को अत्यंत कठोर सत्यापन प्रक्रिया से गुजरना पड़ता है। हम केवल मान्यता प्राप्त संस्थानों (जैसे गीता प्रेस, वृंदावन शोध संस्थान और विभिन्न मंदिरों के प्रामाणिक प्रकाशनों) द्वारा मुद्रित ग्रंथों से पाठ संकलित करते हैं। पाठ के हिज्जे (वर्तनी) की शुद्धि के लिए कम से कम तीन संस्करणों का मिलान किया जाता है। अनुवादों को संस्कृत विद्वानों द्वारा जांचा जाता है ताकि मूल दार्शनिक सिद्धांतों और रसोपासना के सिद्धांतों में कोई अंतर न आए। यदि किसी पद में कोई त्रुटि मिलती है, तो उसे तुरंत संकलित व शोधित किया जाता है।</p>'
    }
  },
  'sources': {
    en: {
      title: 'Sources & Bibliography — Authentic Vaishnava Literature',
      description: 'Explore the source bibliography of Vrindopnishad. Learn about the medieval manuscripts, printed editions, and citation methodology for our content.',
      body: '<h1>Sources & Citation Bibliography</h1><p>Our database compiles verses from authoritative published editions, including: Siddhanta Pada (Swami Haridas, Nidhivan publications); Chaurasi Pada (Shri Hit Harivansh, edited by Goswami Lalitacharan Ji); Bayaalaas Leela (Shri Dhruvdas Ji, edited by Baba Krishnadas); and Sanskrit scriptures (Bhagavad Gita and Upanishads, published by Gita Press). Each entry includes detailed disciplic metadata referencing the author, source grantha, and historical citation number to allow users to verify content against printed publications.</p>'
    },
    hi: {
      title: 'शास्त्र स्रोत एवं प्रमाण ग्रन्थ (Sources & Bibliography) — वृंदोपनिषद्',
      description: 'वृंदोपनिषद् के प्राथमिक स्रोतों और प्रमाण ग्रंथों की ग्रंथ सूची। मूल पांडुलिपियों और प्रामाणिक प्रकाशनों की सूची।',
      body: '<h1>शास्त्र स्रोत एवं प्रमाण ग्रंथ सूची</h1><p>वृंदोपनिषद् ग्रंथालय में संकलित सभी पदों का संकलन प्रामाणिक प्रकाशनों और पांडुलिपियों से किया गया है। मुख्य स्रोतों में शामिल हैं: स्वामी हरिदास जी रचित सिद्धांत के पद व केलिमाल (बाबा प्रेमलाल जी द्वारा संपादित); श्री हित हरिवंश महाप्रभु रचित हित चौरासी व स्फुट पद (श्री राधावल्लभ मंदिर प्रकाशन); श्री ध्रुवदास कृत बयालीस लीला (बाबा कृष्णदास द्वारा संपादित); और संस्कृत श्लोक व स्तोत्र (गीता प्रेस, गोरखपुर)। प्रत्येक पद के साथ उसके रचनाकार, मूल ग्रंथ और संदर्भ क्रमांक की जानकारी दी गई है ताकि शोधकर्ता और साधक मूल मुद्रित पुस्तकों से इसका मिलान कर सकें।</p>'
    }
  },
  'contact': {
    en: {
      title: 'Contact Us — Get in touch with Vrindopnishad Team',
      description: 'Reach out to the editors, Sanskrit scholars, and developers of Vrindopnishad. Submit feedback, correct scriptural text, or collaborate with us.',
      body: '<h1>Contact the Editorial Team</h1><p>For scriptural corrections, translation queries, permission requests, or collaborative archive projects, please contact us. Our email coordinates are <strong>info@vrindopnishad.in</strong>. Our review office is located at Lohia Bazar Road, Near Radhavallabh Temple, Vrindavan, Uttar Pradesh, 281121, India. We review all feedback within 48 hours to preserve database integrity.</p>'
    },
    hi: {
      title: 'सम्पर्क करें (Contact Us) — वृंदोपनिषद् सम्पादकीय टीम',
      description: 'वृंदोपनिषद् की सम्पादकीय टीम से संपर्क करें। किसी भी पद में वर्तनी सुधार, सुझाव या सहयोग के लिए संदेश भेजें।',
      body: '<h1>सम्पादकीय टीम से संपर्क करें</h1><p>पदों में वर्तनी सुधार, अनुवाद में शंका समाधान, पांडुलिपि डिजिटलीकरण सहयोग या अन्य किसी भी सुझाव के लिए आप हमसे संपर्क कर सकते हैं। हमारी ईमेल आईडी <strong>info@vrindopnishad.in</strong> है। हमारा सम्पादकीय कार्यालय लोहिया बाजार मार्ग, राधावल्लभ मंदिर के समीप, वृंदावन, उत्तर प्रदेश, 281121, भारत में स्थित है। हम आपके सभी संदेशों और संशोधनों पर 48 घंटे के भीतर विचार करते हैं।</p>'
    }
  },
  'privacy': {
    en: {
      title: 'Privacy Policy | Vrindopnishad',
      description: 'Read the privacy policy of Vrindopnishad. Learn how we handle cookies, preferences, and local data settings.',
      body: '<h1>Privacy Policy</h1><p>Your privacy is highly valued. Learn how Vrindopnishad manages local preference caching and anonymous analytical reports.</p>'
    },
    hi: {
      title: 'गोपनीयता नीति | वृंदोपनिषद्',
      description: 'वृंदोपनिषद् की गोपनीयता नीति। जानें कि हम कुकीज़, प्राथमिकताओं और स्थानीय डेटा सेटिंग्स को कैसे संभालते हैं।',
      body: '<h1>गोपनीयता नीति</h1><p>आपकी गोपनीयता हमारे लिए अत्यंत महत्वपूर्ण है। समझें कि हम आपकी स्थानीय सेटिंग्स और प्राथमिकताओं को कैसे सहेजते हैं।</p>'
    }
  },
  'terms': {
    en: {
      title: 'Terms of Service | Vrindopnishad',
      description: 'Review the terms of service of Vrindopnishad. Learn about our content licensing, scriptural preservation policy, and non-commercial guidelines.',
      body: '<h1>Terms of Service</h1><p>Preserving the sacred spiritual heritage of Vrindavan with integrity. Review our terms of content usage.</p>'
    },
    hi: {
      title: 'सेवा की शर्तें | वृंदोपनिषद्',
      description: 'वृंदोपनिषद् की सेवा की शर्तें। हमारी सामग्री लाइसेंसिंग, शास्त्र संरक्षण नीति और गैर-व्यावसायिक नियमों के बारे में जानें।',
      body: '<h1>सेवा की शर्तें</h1><p>वृंदावन की पावन आध्यात्मिक विरासत को पूर्ण प्रामाणिकता के साथ सहेजना। हमारी सामग्री के उपयोग की शर्तें पढ़ें।</p>'
    }
  },
  'references': {
    en: {
      title: 'References & Citations | Vrindopnishad',
      description: 'Explore the academic and scriptural references bibliography compiled for the Vrindopnishad digital knowledge base.',
      body: '<h1>References & Bibliography</h1><p>Comprehensive listing of manuscripts, textual sources, and historical references used in validation.</p>'
    },
    hi: {
      title: 'प्रमाण एवं संदर्भ सूची | वृंदोपनिषद्',
      description: 'वृंदोपनिषद् ग्रंथालय के प्रामाणिक संदर्भों और सहायक ग्रंथों की सूची।',
      body: '<h1>प्रमाण एवं संदर्भ सूची</h1><p>पांडुलिपियों, प्रकाशित प्रतियों और सहायक संदर्भ ग्रंथों की सूची जो हमारे सत्यापन का मुख्य प्रमाण हैं।</p>'
    }
  }
};

export default async function handler(req, res) {
  const type = req.query.type || 'home';
  const slug = req.query.slug || '';
  const lang = req.query.lang || '';
  const isHindiRoute = lang === 'hi';
  const today = new Date().toISOString().split('T')[0];

  let title = 'Vrindopnishad Paath — वृंदोपनिषद् पाठ';
  let description = 'Vrindopnishad Paath (वृंदोपनिषद् पाठ) — Read and listen to sacred Sanskrit shlokas, strotras, and devotional poetry from Vrindavan saints.';
  let pageUrl = DOMAIN + (isHindiRoute ? '/hi' : '');
  let jsonLd = '';
  let mainBodyHtml = '';
  let ogImageUrl = 'https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png';

  const visibleBreadcrumbItems = [
    { name: isHindiRoute ? "होम" : "Home", url: getRouteLink('/') },
    { name: isHindiRoute ? "पाठ/सामग्री" : "Content/Resources", url: getRouteLink('/content') }
  ];

  const faqDataEn = [
    { question: "What is Vrindopnishad?", answer: "Vrindopnishad is a sacred digital platform dedicated to preserving and sharing authentic spiritual and Vedic knowledge. It hosts sacred Sanskrit shlokas, devotional strotras, spiritual poetry, and the teachings of Vrindavan saints in Hindi, Sanskrit, and English." },
    { question: "What does the word Vrindopnishad mean?", answer: "Vrindopnishad combines 'Vrinda' (the sacred groves of Vrindavan) and 'Upanishad' (sacred, esoteric knowledge transmitted from teacher to student). Together it means 'the sacred knowledge flowing from Vrindavan.'" },
    { question: "Is Vrindopnishad free to use?", answer: "Yes, Vrindopnishad is completely free. The platform believes that sacred knowledge should be universally accessible without financial barriers." },
    { question: "What languages are available on the platform?", answer: "Content is available in Sanskrit (original texts), Hindi (transliteration and commentary), and English (translations and explanations)." },
    { question: "Can I listen to the verses being chanted?", answer: "Yes, many verses on the platform include audio narrations with traditional chanting patterns, allowing you to hear the sacred sounds as they were meant to be experienced." }
  ];

  const faqDataHi = [
    { question: "वृंदोपनिषद् क्या है?", answer: "वृंदोपनिषद् एक पवित्र डिजिटल मंच है जो प्रामाणिक आध्यात्मिक और वैदिक ज्ञान को संरक्षित करने और साझा करने के लिए समर्पित है। यहाँ आपको संस्कृत श्लोक, स्तोत्र, आध्यात्मिक कविताएँ और वृंदावन के संतों की शिक्षाएँ हिंदी, संस्कृत और अंग्रेजी में मिलेंगी।" },
    { question: "वृंदोपनिषद् शब्द का क्या अर्थ है?", answer: "वृंदोपनिषद् शब्द 'वृंदा' (वृंदावन की पवित्र तुलसी कुंज) और 'उपनिषद' (गुरु के समीप बैठकर प्राप्त किया गया पवित्र ज्ञान) से मिलकर बना है। इसका अर्थ है 'वृंदावन से प्रवाहित होने वाला पवित्र ज्ञान'।" },
    { question: "क्या वृंदोपनिषद् का उपयोग मुफ़्त है?", answer: "हाँ, वृंदोपनिषद् पूरी तरह से मुफ़्त है। हमारा मानना है कि पवित्र आध्यात्मिक ज्ञान सभी के लिए बिना किसी वित्तीय बाधा के सुलभ होना चाहिए।" },
    { question: "मंच पर कौन सी भाषाएँ उपलब्ध हैं?", answer: "सामग्री संस्कृत (मूल पाठ), हिंदी (रोमन पाठ और अनुवाद), और अंग्रेजी (अनुवाद और व्याख्या) में उपलब्ध है।" },
    { question: "क्या मैं श्लोकों का उच्चारण सुन सकता हूँ?", answer: "हाँ, इस मंच पर अधिकांश श्लोकों और पदों के साथ ऑडियो उच्चारण/गायन दिया गया है, जिससे आप पारंपरिक रागों में इनके पाठ को सुन सकते हैं।" }
  ];


  let allContentItems = [];
  let relations = null;

  if (globalCache.items && globalCache.relations) {
    allContentItems = globalCache.items;
    relations = globalCache.relations;
  } else {
    try {
      let localFilePath = path.join(process.cwd(), 'data/brajrasik_hi_full.json');
      let localSaintsPath = path.join(process.cwd(), 'data/saints_formatted.json');

      if (!fs.existsSync(localFilePath)) {
        localFilePath = path.join(process.cwd(), 'frontend/data/brajrasik_hi_full.json');
        localSaintsPath = path.join(process.cwd(), 'frontend/data/saints_formatted.json');
      }
      if (!fs.existsSync(localFilePath)) {
        localFilePath = path.join(process.cwd(), 'admin/data/brajrasik_hi_full.json');
        localSaintsPath = path.join(process.cwd(), 'admin/data/saints_formatted.json');
      }

      let backupItems = [];
      if (fs.existsSync(localFilePath)) {
        const fileContent = fs.readFileSync(localFilePath, 'utf8');
        const localData = JSON.parse(fileContent);
        const sanitizedData = localData.map((item, index) => ({
          id: item.id || `local-${index}`,
          ...item
        }));
        backupItems = backupItems.concat(sanitizedData);
      }

      if (fs.existsSync(localSaintsPath)) {
        const saintsContentRaw = fs.readFileSync(localSaintsPath, 'utf8');
        const localSaints = JSON.parse(saintsContentRaw);
        const formattedSaints = localSaints.map((s, index) => ({
          id: s.id || `local-saint-${index}`,
          ...s,
          category: 'saint'
        }));
        backupItems = backupItems.concat(formattedSaints);
      }

      allContentItems = backupItems;
      relations = extractRelations(allContentItems);

      globalCache.items = allContentItems;
      globalCache.relations = relations;
    } catch (fallbackError) {
      console.error('❌ Failed to load local backups:', fallbackError.message);
      relations = { sants: [], books: [], ragas: [] };
    }
  }

  const { sants, books, ragas } = relations;

  function getRouteLink(pathStr) {
    let normalized = pathStr;
    if (normalized === '/books') normalized = '/granthas';
    else if (normalized === '/content') normalized = '/lyrics';
    else if (normalized.startsWith('/book/')) normalized = normalized.replace('/book/', '/granthas/');
    else if (normalized.startsWith('/saint/')) normalized = normalized.replace('/saint/', '/saints/');
    else if (normalized.startsWith('/raga/')) normalized = normalized.replace('/raga/', '/ragas/');
    else if (normalized.startsWith('/content/')) normalized = normalized.replace('/content/', '/lyrics/');
    return DOMAIN + (isHindiRoute ? '/hi' : '') + normalized;
  }

  if (type === 'content' && slug) {

    const decodedSlug = decodeURIComponent(slug);
    const transliteratedSlug = slugify(transliterate(decodedSlug));
    const lowerSlug = decodedSlug.toLowerCase();

    const decodedClean = decodedSlug.replace(/-+$/, '');
    const lowerClean = lowerSlug.replace(/-+$/, '');
    const transliteratedClean = transliteratedSlug ? transliteratedSlug.replace(/-+$/, '') : '';

    let content = allContentItems.find(item => {
      const s = item.slug || '';
      const sClean = s.replace(/-+$/, '');
      if (sClean === decodedClean) return true;
      if (sClean === lowerClean) return true;
      if (sClean.toLowerCase() === lowerClean) return true;
      if (transliteratedClean && sClean === transliteratedClean) return true;
      if (transliteratedClean && sClean.toLowerCase() === transliteratedClean) return true;
      if (item.id?.toString() === decodedSlug) return true;

      const genSlug = generateSlug(item.title) || '';
      const genSlugClean = genSlug.replace(/-+$/, '');
      if (genSlugClean && genSlugClean === decodedClean) return true;
      if (genSlugClean && genSlugClean.toLowerCase() === decodedClean.toLowerCase()) return true;
      if (genSlugClean && transliteratedClean && genSlugClean === transliteratedClean) return true;
      return false;
    });

    if (!content) {
      // Direct fast query to Supabase by slug
      try {
        const response = await fetch(
          `${SUPABASE_URL}/rest/v1/content?select=id,title,slug,category,author,hindi_text,sanskrit_text,image_url&slug=eq.${encodeURIComponent(decodedSlug)}&limit=1`,
          {
            headers: {
              'apikey': SUPABASE_KEY,
              'Authorization': `Bearer ${SUPABASE_KEY}`
            }
          }
        );
        const items = await response.json();
        if (Array.isArray(items) && items.length > 0) {
          content = items[0];
        }
      } catch (err) {
        console.error('Failed to query new item by slug from Supabase:', err);
      }
    }

    if (content) {

      let fullContent = content;
      try {
        const detailResponse = await fetch(
          `${SUPABASE_URL}/rest/v1/content?select=id,title,slug,category,author,hindi_text,sanskrit_text,english_text,english_translation,content_text,commentary,description,image_url,created_at&id=eq.${content.id}&limit=1`,
          {
            headers: {
              'apikey': SUPABASE_KEY,
              'Authorization': `Bearer ${SUPABASE_KEY}`
            }
          }
        );
        const details = await detailResponse.json();
        if (Array.isArray(details) && details.length > 0) {
          fullContent = details[0];
        }
      } catch (err) {
        console.error('Error fetching content detail from Supabase:', err);
      }

      // Parse Granth Name, Pad [N], and Saint Name from title
      let padName = "";
      let parsedSaint = "";
      let parsedGranth = "";

      const titleVal = fullContent.title || "";
      const tParts = titleVal.split(/\s+-\s+/);
      if (tParts.length >= 2) {
        padName = tParts[0].trim();
        const relText = tParts[1].trim();
        const bracketMatch = relText.match(/\(([^)]+)\)$/);
        const bracketContent = bracketMatch ? bracketMatch[1].trim() : "";
        const cleanRelText = bracketMatch ? relText.replace(/\(([^)]+)\)$/, '').trim() : relText;
        const relSplit = cleanRelText.split(/\s*,\s*/);

        if (relSplit.length >= 2) {
          parsedSaint = relSplit[0].trim();
          parsedGranth = relSplit[1].trim();
        } else if (relSplit.length === 1) {
          const val = relSplit[0].trim();
          if (val.includes('वाणी') || val.includes('सागर') || val.includes('शतक') || val.includes('मिहामामृत') || val.includes('दोहे') || val.includes('ग्रंथावली') || val.includes('पदावली') || val.includes('शत') || val.includes('केलिमाल') || val.includes('चौरासी')) {
            parsedGranth = val;
          } else {
            parsedSaint = val;
          }
        }

        if (!parsedGranth && bracketContent) {
          parsedGranth = bracketContent.replace(/\d+/g, '').replace(/[१२३४५६७८९०]+/g, '').trim();
        }
      } else {
        padName = titleVal;
      }

      if (!parsedSaint) {
        parsedSaint = fullContent.author && fullContent.author !== 'Braj Rasik Heritage' ? fullContent.author : '';
      }

      const cleanSaint = parsedSaint ? parsedSaint.replace(/जी की वाणी/g, '').replace(/जी/g, '').replace(/महाप्रभु/g, '').trim() : (isHindiRoute ? 'वैष्णव संत' : 'Vaishnava Saint');
      const cleanGranth = parsedGranth ? parsedGranth.trim() : (isHindiRoute ? 'वृंदोपनिषद् ग्रन्थ' : 'Vrindopnishad Granth');

      let formattedPad = padName;
      if (!isHindiRoute) {
        formattedPad = formattedPad
          .replace(/पद्/g, 'Pad')
          .replace(/पद/g, 'Pad')
          .replace(/श्लोक/g, 'Shloka')
          .replace(/१/g, '1').replace(/२/g, '2').replace(/३/g, '3').replace(/४/g, '4')
          .replace(/५/g, '5').replace(/६/g, '6').replace(/७/g, '7').replace(/८/g, '8')
          .replace(/९/g, '9').replace(/०/g, '0');
      }

      const canonicalSlug = encodeURIComponent(fullContent.slug || fullContent.id);
      title = `${cleanGranth} — ${formattedPad} | ${cleanSaint} | Vrindopnishad`;

      description = isHindiRoute
        ? `${cleanSaint} द्वारा रचित ${fullContent.title} (ग्रन्थ: ${cleanGranth})। हिन्दी, संस्कृत, ब्रजभाषा और अंग्रेजी रोमन अनुवाद (with meaning, commentary) में बिल्कुल निःशुल्क (completely free) पढ़ें।`
        : `Read and explore ${fullContent.title} by ${cleanSaint} from the grantha ${cleanGranth}. Completely free online access with meaning, translation, and commentary. Available in Hindi, Sanskrit, Braj Bhasha, and English transliteration (with meaning, complete collection).`;

      pageUrl = getRouteLink(`/content/${canonicalSlug}`);

      if (fullContent.image_url) {
        ogImageUrl = fullContent.image_url;
      }

      // Build Breadcrumb List
      const bookSlug = parsedGranth ? slugify(transliterate(parsedGranth)) : '';
      const bookUrl = bookSlug ? getRouteLink(`/book/${bookSlug}`) : '';

      const breadcrumbListElements = [
        {
          "@type": "ListItem",
          "position": 1,
          "name": isHindiRoute ? "होम" : "Home",
          "item": getRouteLink('/')
        },
        {
          "@type": "ListItem",
          "position": 2,
          "name": isHindiRoute ? "ग्रन्थ" : "Granthas",
          "item": getRouteLink('/books')
        }
      ];

      const visibleBreadcrumbItems = [
        { name: isHindiRoute ? "होम" : "Home", url: getRouteLink('/') },
        { name: isHindiRoute ? "ग्रन्थ" : "Granthas", url: getRouteLink('/books') }
      ];

      if (cleanGranth && bookUrl) {
        breadcrumbListElements.push({
          "@type": "ListItem",
          "position": 3,
          "name": cleanGranth,
          "item": bookUrl
        });
        visibleBreadcrumbItems.push({ name: cleanGranth, url: bookUrl });
      }

      const currentPosition = breadcrumbListElements.length + 1;
      breadcrumbListElements.push({
        "@type": "ListItem",
        "position": currentPosition,
        "name": formattedPad,
        "item": pageUrl
      });
      visibleBreadcrumbItems.push({ name: formattedPad, url: pageUrl });

      jsonLd = JSON.stringify({
        "@context": "https://schema.org",
        "@graph": [
          {
            "@type": "Article",
            "@id": `${pageUrl}/#verse`,
            "name": fullContent.title,
            "headline": fullContent.title,
            "description": description,
            "image": ogImageUrl,
            "author": {
              "@type": "Person",
              "name": cleanSaint
            },
            "publisher": {
              "@type": "Organization",
              "name": "Vrindopnishad",
              "logo": {
                "@type": "ImageObject",
                "url": "https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png"
              }
            },
            "mainEntityOfPage": { "@type": "WebPage", "@id": pageUrl },
            "inLanguage": ["sa", "hi", "braj"],
            "genre": fullContent.category || "Sacred Literature",
            "datePublished": fullContent.created_at || today
          },
          {
            "@type": "BreadcrumbList",
            "@id": `${pageUrl}/#breadcrumb`,
            "itemListElement": breadcrumbListElements
          }
        ]
      });

      const transliteratedSanskrit = fullContent.sanskrit_text ? transliterate(fullContent.sanskrit_text) : "";
      const transliteratedHindi = fullContent.hindi_text ? transliterate(fullContent.hindi_text) : "";

      // Find previous and next verse in the same book/grantha
      let prevNextHtml = '';
      const bookCandidate = parsedGranth;
      if (bookCandidate) {
        const bookSlug = slugify(transliterate(bookCandidate));
        const matchedBook = books.find(b => b.slug === bookSlug);
        if (matchedBook && matchedBook.verses) {
          const sortedVerses = [...matchedBook.verses].sort((a, b) => {
            const numA = parseInt((a.title || '').match(/\d+/) || 0);
            const numB = parseInt((b.title || '').match(/\d+/) || 0);
            return numA - numB;
          });
          const currentIndex = sortedVerses.findIndex(v => v.id === fullContent.id);
          if (currentIndex !== -1) {
            const prevVerse = sortedVerses[currentIndex - 1];
            const nextVerse = sortedVerses[currentIndex + 1];

            prevNextHtml = `
              <div style="display: flex; justify-content: space-between; align-items: center; margin: 35px 0; padding: 15px 0; border-top: 1px solid #eae6df; border-bottom: 1px solid #eae6df; font-family: sans-serif; font-size: 0.9rem;">
                ${prevVerse ? `<a href="${getRouteLink(`/content/${prevVerse.slug || prevVerse.id}`)}" style="color: #f2a60d; text-decoration: none; font-weight: 500;">&larr; ${escapeHtml(prevVerse.title)}</a>` : '<span style="color: #a8a29e;">&larr; Beginning</span>'}
                ${nextVerse ? `<a href="${getRouteLink(`/content/${nextVerse.slug || nextVerse.id}`)}" style="color: #f2a60d; text-decoration: none; font-weight: 500;">${escapeHtml(nextVerse.title)} &rarr;</a>` : '<span style="color: #a8a29e;">End &rarr;</span>'}
              </div>
            `;
          }
        }
      }

      mainBodyHtml = `
        ${getBreadcrumbsHtml(isHindiRoute, visibleBreadcrumbItems)}
        <article>
          <h1>${escapeHtml(fullContent.title)}</h1>
          <p><strong>${isHindiRoute ? 'श्रेणी' : 'Category'}:</strong> ${escapeHtml(fullContent.category || (isHindiRoute ? 'पवित्र साहित्य' : 'Sacred Literature'))}</p>
          <p><strong>${isHindiRoute ? 'लेखक/संत' : 'Author/Saint'}:</strong> ${escapeHtml(fullContent.author || (isHindiRoute ? 'वैष्णव संत' : 'Vaishnava Saint'))}</p>
          ${fullContent.sanskrit_text ? `<div lang="sa" style="font-size: 1.25rem; margin: 20px 0; font-family: serif;"><h2>${isHindiRoute ? 'मूल संस्कृत श्लोक' : 'Sanskrit Verse'}</h2><p style="white-space: pre-wrap; line-height: 1.8;">${escapeHtml(fullContent.sanskrit_text)}</p></div>` : ''}
          ${fullContent.hindi_text ? `<div lang="hi" style="margin: 20px 0;"><h2>${isHindiRoute ? 'हिंदी अनुवाद' : 'Hindi Translation'}</h2><p style="white-space: pre-wrap; line-height: 1.6;">${escapeHtml(fullContent.hindi_text)}</p></div>` : ''}
          ${(transliteratedSanskrit || transliteratedHindi) ? `
            <div lang="en-Latn" style="margin: 20px 0;">
              <h2>${isHindiRoute ? 'रोमन पाठ (Hinglish Transliteration)' : 'Hinglish Transliteration (रोमन पाठ)'}</h2>
              <p style="white-space: pre-wrap; line-height: 1.6; color: #4b5563;">${escapeHtml(transliteratedSanskrit || transliteratedHindi)}</p>
            </div>
          ` : ''}
          ${fullContent.english_text ? `<div lang="en" style="margin: 20px 0;"><h2>${isHindiRoute ? 'अंग्रेजी रोमन पाठ' : 'English Text'}</h2><p style="white-space: pre-wrap; line-height: 1.6;">${escapeHtml(fullContent.english_text)}</p></div>` : ''}
          ${fullContent.english_translation ? `<div lang="en" style="margin: 20px 0;"><h2>${isHindiRoute ? 'अंग्रेजी अनुवाद' : 'English Translation'}</h2><p style="white-space: pre-wrap; line-height: 1.6;">${escapeHtml(fullContent.english_translation)}</p></div>` : ''}
          ${fullContent.commentary ? `<div lang="en" style="margin: 20px 0;"><h2>${isHindiRoute ? 'टीका / व्याख्या' : 'Commentary'}</h2><p style="white-space: pre-wrap; line-height: 1.6;">${escapeHtml(fullContent.commentary)}</p></div>` : ''}
          ${fullContent.description ? `<div lang="en" style="margin: 20px 0;"><h2>${isHindiRoute ? 'विवरण' : 'Explanation'}</h2><p>${escapeHtml(fullContent.description)}</p></div>` : ''}
          ${prevNextHtml}
        </article>
        ${(() => {
          // Build dynamic semantic cross-links
          const links = [];
          const authorName = fullContent.author && fullContent.author !== 'Braj Rasik Heritage' ? fullContent.author : null;

          // Link to the saint who composed this verse
          if (authorName) {
            const cleanAuthor = authorName.replace(/जी की वाणी/g, '').replace(/जी/g, '').replace(/महाप्रभु/g, '').trim();
            const authorSlug = slugify(transliterate(cleanAuthor));
            const matchedSant = sants.find(s => s.slug === authorSlug || (s.name && s.name.includes(cleanAuthor)));
            if (matchedSant) {
              links.push(`<li><a href="${getRouteLink(`/saint/${matchedSant.slug}`)}">${isHindiRoute ? `${escapeHtml(cleanAuthor)} — जीवनी एवं वाणी संग्रह` : `${escapeHtml(cleanAuthor)} — Biography & Complete Works`}</a></li>`);
            }
          }

          // Link to the book/grantha this verse belongs to
          const titleParts = (fullContent.title || '').split(/\s+-\s+/);
          if (titleParts.length >= 2) {
            const relText = titleParts[1].replace(/\([^)]+\)$/, '').trim();
            const relParts = relText.split(/\s*,\s*/);
            const bookCandidate = relParts.length >= 2 ? relParts[1].trim() : null;
            if (bookCandidate) {
              const bookSlug = slugify(transliterate(bookCandidate));
              const matchedBook = books.find(b => b.slug === bookSlug);
              if (matchedBook) {
                links.push(`<li><a href="${getRouteLink(`/book/${matchedBook.slug}`)}">${isHindiRoute ? `ग्रन्थ: ${escapeHtml(bookCandidate)}` : `Grantha: ${escapeHtml(bookCandidate)}`}</a></li>`);
              }
            }
          }

          // Link to the category page
          if (fullContent.category) {
            const catSlug = fullContent.category.toLowerCase().trim().replace(/\s+/g, '-');
            links.push(`<li><a href="${getRouteLink(`/category/${catSlug}`)}">${isHindiRoute ? `श्रेणी: ${escapeHtml(fullContent.category)}` : `Category: ${escapeHtml(fullContent.category)}`}</a></li>`);
          }

          // Link to 3 related verses from the same author
          if (authorName) {
            const relatedVerses = allContentItems
              .filter(item => item.author === authorName && item.id !== fullContent.id && item.category?.toLowerCase() !== 'saint')
              .slice(0, 3);
            if (relatedVerses.length > 0) {
              relatedVerses.forEach(v => {
                links.push(`<li><a href="${getRouteLink(`/content/${v.slug || v.id}`)}">${escapeHtml(v.title)}</a></li>`);
              });
            }
          }

          if (links.length > 0) {
            return `<nav aria-label="Related" style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eae6df;">
              <h2>${isHindiRoute ? 'संबंधित पाठ' : 'Related'}</h2>
              <ul>${links.join('')}</ul>
            </nav>`;
          }
          return '';
        })()}
      `;
    } else {

      res.setHeader('Content-Type', 'text/html; charset=utf-8');
      res.status(404).send(`<!doctype html><html lang="hi"><head><meta charset="utf-8"/><title>Content Not Found — Vrindopnishad</title><meta name="robots" content="noindex"/></head><body style="font-family:sans-serif;text-align:center;padding:60px 20px;"><h1>404 — Content Not Found</h1><p>The requested verse could not be located.</p><p><a href="${DOMAIN}/lyrics">Browse All Sacred Content →</a></p></body></html>`);
      return;
    }

  } else if (type === 'saint' && slug) {

    const decodedSlug = decodeURIComponent(slug);
    const transliteratedSlug = slugify(transliterate(decodedSlug));
    const lowerSlug = decodedSlug.toLowerCase();
    const sant = sants.find(s => {
      const sSlug = s.slug || '';
      return sSlug === decodedSlug ||
        sSlug.toLowerCase() === lowerSlug ||
        (transliteratedSlug && sSlug === transliteratedSlug) ||
        (transliteratedSlug && sSlug.toLowerCase() === transliteratedSlug) ||
        (s.name && slugify(transliterate(s.name)) === transliteratedSlug);
    });

    if (sant) {
      const santName = sant.name;
      const santHinglish = sant.hinglishName || sant.name;


      const meta = getSaintMetadata(sant.slug || slug);

      const lineage = meta
        ? (isHindiRoute ? meta.lineageHi : meta.lineageEn)
        : (isHindiRoute ? "वैष्णव संप्रदाय" : "Vaishnava Tradition");

      const timeline = meta
        ? (isHindiRoute ? meta.timelineHi : meta.timelineEn)
        : (isHindiRoute ? "मध्यकालीन काल" : "Medieval Era");

      const places = meta
        ? (isHindiRoute ? meta.associatedPlacesHi : meta.associatedPlacesEn)
        : (isHindiRoute ? "वृंदावन धाम" : "Vrindavan Dham");

      const bioText = meta
        ? (isHindiRoute ? meta.biographyHi : meta.biographyEn)
        : (sant.biography?.text || (isHindiRoute ? "ब्रज परंपरा के वैष्णव संत।" : "Vaishnava saint of the Braj tradition."));

      title = `${santName} — [भजन/वाणियाँ] | Vrindopnishad`;

      description = isHindiRoute
        ? `महान रसिक संत ${santName} (परंपरा: ${lineage}, काल: ${timeline}) का जीवन चरित्र, इतिहास, ग्रन्थ और वाणी संग्रह। हिन्दी, संस्कृत, ब्रजभाषा और अंग्रेजी रोमन अनुवाद (with meaning) में बिल्कुल निःशुल्क (completely free) उपलब्ध।`
        : `Explore the biography of ${santHinglish} (Lineage: ${lineage}, Era: ${timeline}), including spiritual teachings and complete verses. Available in Hindi, Sanskrit, Braj Bhasha, and English transliteration. Completely free online with meaning, biography, and complete collection.`;

      pageUrl = getRouteLink(`/saint/${encodeURIComponent(sant.slug || slug)}`);

      if (sant.imageUrl) {
        ogImageUrl = sant.imageUrl;
      }

      const faqGraph = meta && meta.faq ? [
        {
          "@type": "FAQPage",
          "@id": `${pageUrl}/#faq`,
          "mainEntity": meta.faq.map(f => ({
            "@type": "Question",
            "name": isHindiRoute ? f.qHi : f.qEn,
            "acceptedAnswer": {
              "@type": "Answer",
              "text": isHindiRoute ? f.aHi : f.aEn
            }
          }))
        }
      ] : [];

      jsonLd = JSON.stringify({
        "@context": "https://schema.org",
        "@graph": [
          {
            "@type": "Person",
            "@id": `${pageUrl}/#person`,
            "name": santName,
            "alternateName": santHinglish !== santName ? santHinglish : undefined,
            "description": bioText.substring(0, 200),
            "image": ogImageUrl,
            "knowsAbout": ["Vaishnavism", "Bhakti", "Sanskrit", "Braj Ras", "Vrindavan"],
            "url": pageUrl
          },
          {
            "@type": "BreadcrumbList",
            "@id": `${pageUrl}/#breadcrumb`,
            "itemListElement": [
              {
                "@type": "ListItem",
                "position": 1,
                "name": isHindiRoute ? "होम" : "Home",
                "item": getRouteLink('/')
              },
              {
                "@type": "ListItem",
                "position": 2,
                "name": isHindiRoute ? "संत" : "Saints",
                "item": getRouteLink('/saints')
              },
              {
                "@type": "ListItem",
                "position": 3,
                "name": santName,
                "item": pageUrl
              }
            ]
          },
          ...faqGraph
        ]
      });

      const visibleBreadcrumbItems = [
        { name: isHindiRoute ? "होम" : "Home", url: getRouteLink('/') },
        { name: isHindiRoute ? "संत" : "Saints", url: getRouteLink('/saints') },
        { name: santName, url: pageUrl }
      ];

      mainBodyHtml = `
        ${getBreadcrumbsHtml(isHindiRoute, visibleBreadcrumbItems)}
        <h1>${escapeHtml(santName)}</h1>
        <p><strong>${isHindiRoute ? 'परंपरा' : 'Lineage'}:</strong> ${escapeHtml(lineage)} | <strong>${isHindiRoute ? 'काल' : 'Era'}:</strong> ${escapeHtml(timeline)} | <strong>${isHindiRoute ? 'साधना स्थल' : 'Place'}:</strong> ${escapeHtml(places)}</p>
        ${meta ? `
          <p>
            ${meta.discipleOfEn ? `<strong>${isHindiRoute ? 'दीक्षा गुरु / पिता' : 'Disciple of / Guru'}:</strong> ${escapeHtml(isHindiRoute ? meta.discipleOfHi : meta.discipleOfEn)} | ` : ''}
            ${meta.influencedByEn ? `<strong>${isHindiRoute ? 'विचारधारा प्रभाव' : 'Influenced by'}:</strong> ${escapeHtml(isHindiRoute ? meta.influencedByHi : meta.influencedByEn)} | ` : ''}
            ${meta.devotionalMoodEn ? `<strong>${isHindiRoute ? 'भक्ति भाव / रस' : 'Devotional Mood'}:</strong> ${escapeHtml(isHindiRoute ? meta.devotionalMoodHi : meta.devotionalMoodEn)}` : ''}
          </p>
        ` : ''}
        
        <h2>${isHindiRoute ? 'जीवनी एवं भक्ति इतिहास' : 'Biography & Devotional History'}</h2>
        <div style="background: #fdfdfd; padding: 20px; border-left: 4px solid #f2a60d; margin: 20px 0;">
          <p style="white-space: pre-wrap; line-height: 1.7;">${escapeHtml(bioText)}</p>
        </div>

        ${meta ? `
          <h2>${isHindiRoute ? 'दार्शनिक सिद्धांत एवं उपदेश' : 'Philosophy & Core Teachings'}</h2>
          <div style="background: #fafafa; padding: 20px; border-left: 4px solid #a78bfa; margin: 20px 0;">
            <p style="line-height: 1.7;">${escapeHtml(isHindiRoute ? meta.teachingsHi : meta.teachingsEn)}</p>
          </div>
          
          <h2>${isHindiRoute ? 'साहित्यिक शैली एवं ग्रन्थ रचना' : 'Literary Style & Scriptural Contributions'}</h2>
          <div style="background: #fafafa; padding: 20px; border-left: 4px solid #0ea5e9; margin: 20px 0;">
            <p style="line-height: 1.7;">${escapeHtml(isHindiRoute ? meta.literaryStyleHi : meta.literaryStyleEn)}</p>
          </div>
        ` : ''}

        ${sant.books.length > 0 ? `
          <h2>${isHindiRoute ? 'मुख्य ग्रन्थ एवं साहित्य सूची' : 'Major Granthas & Literature'}</h2>
          <ul>
            ${sant.books.map(book => `<li><a href="${getRouteLink(`/book/${slugify(transliterate(book))}`)}">${escapeHtml(book)}</a></li>`).join('')}
          </ul>
        ` : ''}

        ${meta && (meta.relatedSaints || meta.relatedGranthas || meta.associatedGlossary) ? `
          <h2>${isHindiRoute ? 'सम्बन्धित सन्दर्भ (Topical Connections)' : 'Topical Connections'}</h2>
          <div style="background: #fafafa; padding: 20px; border-left: 4px solid #10b981; margin: 20px 0;">
            ${meta.relatedSaints && meta.relatedSaints.length > 0 ? `
              <p><strong>${isHindiRoute ? 'सम्बन्धित सन्त' : 'Related Saints'}:</strong> 
                ${meta.relatedSaints.map(s => `<a href="${getRouteLink(`/saint/${s.slug}`)}">${escapeHtml(isHindiRoute ? s.nameHi : s.nameEn)}</a>`).join(', ')}
              </p>
            ` : ''}
            ${meta.relatedGranthas && meta.relatedGranthas.length > 0 ? `
              <p><strong>प्रमुख ग्रन्थ (Key Scriptures):</strong> 
                ${meta.relatedGranthas.map(g => `<a href="${getRouteLink(`/book/${g.slug}`)}">${escapeHtml(isHindiRoute ? g.nameHi : g.nameEn)}</a>`).join(', ')}
              </p>
            ` : ''}
            ${meta.associatedGlossary && meta.associatedGlossary.length > 0 ? `
              <p><strong>प्रमुख अवधारणाएँ (Core Concepts):</strong> 
                ${meta.associatedGlossary.map(c => `<a href="${getRouteLink(`/glossary/${c.slug}`)}">${escapeHtml(isHindiRoute ? c.termHi : c.termEn)}</a>`).join(', ')}
              </p>
            ` : ''}
          </div>
        ` : ''}

        ${meta && meta.faq ? `
          <h2>${isHindiRoute ? 'अक्सर पूछे जाने वाले प्रश्न (FAQ)' : 'Frequently Asked Questions'}</h2>
          <div style="margin-top: 20px;">
            ${meta.faq.map(f => `
              <div style="margin-bottom: 20px; padding: 15px; border: 1px solid #eee; border-radius: 8px;">
                <p><strong>Q: ${escapeHtml(isHindiRoute ? f.qHi : f.qEn)}</strong></p>
                <p>A: ${escapeHtml(isHindiRoute ? f.aHi : f.aEn)}</p>
              </div>
            `).join('')}
          </div>
        ` : ''}

        <h2>${isHindiRoute ? 'संकलित पद एवं वाणियाँ' : 'Collected Verses & Vaanis'} (${sant.verses.length})</h2>
        <ul>
          ${sant.verses.map(v => `<li><a href="${getRouteLink(`/content/${v.slug || v.id}`)}">${escapeHtml(v.cleanTitle || v.title)}</a></li>`).join('')}
        </ul>

        ${(() => {
          const otherSants = sants.filter(s => s.slug !== sant.slug && s.name !== sant.name).slice(0, 4);
          if (otherSants.length > 0) {
            return `<nav aria-label="Related Saints" style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eae6df;">
              <h2>${isHindiRoute ? 'अन्य रसिक संत' : 'Other Rasik Saints'}</h2>
              <ul>${otherSants.map(s => `<li><a href="${getRouteLink(`/saint/${s.slug}`)}">${escapeHtml(s.name)}</a></li>`).join('')}</ul>
            </nav>`;
          }
          return '';
        })()}
      `;
    } else {
      res.setHeader('Content-Type', 'text/html; charset=utf-8');
      res.status(404).send(`<!doctype html><html lang="hi"><head><meta charset="utf-8"/><title>Saint Not Found — Vrindopnishad</title><meta name="robots" content="noindex"/></head><body style="font-family:sans-serif;text-align:center;padding:60px 20px;"><h1>404 — Saint Not Found</h1><p><a href="${DOMAIN}/saints">Browse All Saints →</a></p></body></html>`);
      return;
    }

  } else if (type === 'glossary' && slug) {

    const decodedSlug = decodeURIComponent(slug).toLowerCase();
    const termData = GLOSSARY_TERMS.find(t => t.slug === decodedSlug);

    if (termData) {
      title = isHindiRoute
        ? `${termData.term} (${termData.devanagari}) का अर्थ, परिभाषा और आध्यात्मिक संदर्भ | वृंदोपनिषद्`
        : `${termData.term} Meaning, Definition & Theological Context | Vrindopnishad`;
      description = isHindiRoute
        ? `${termData.term} (${termData.devanagari}) क्या है? जानिए इसका संस्कृत अर्थ, परिभाषा और रसिक संतों के विचार।`
        : `Explore the definition, Sanskrit meaning, etymology, and deep theological context of ${termData.term} (${termData.devanagari}) in Braj Ras.`;

      pageUrl = getRouteLink(`/glossary/${termData.slug}`);

      jsonLd = JSON.stringify({
        "@context": "https://schema.org",
        "@graph": [
          {
            "@type": "Article",
            "@id": `${pageUrl}/#article`,
            "headline": title,
            "description": description,
            "url": pageUrl,
            "datePublished": "2026-05-27",
            "author": {
              "@type": "Organization",
              "name": "Vrindopnishad",
              "url": DOMAIN
            }
          },
          {
            "@type": "BreadcrumbList",
            "@id": `${pageUrl}/#breadcrumb`,
            "itemListElement": [
              {
                "@type": "ListItem",
                "position": 1,
                "name": isHindiRoute ? "होम" : "Home",
                "item": getRouteLink('/')
              },
              {
                "@type": "ListItem",
                "position": 2,
                "name": isHindiRoute ? "शब्दकोश" : "Glossary",
                "item": getRouteLink('/glossary')
              },
              {
                "@type": "ListItem",
                "position": 3,
                "name": termData.term,
                "item": pageUrl
              }
            ]
          }
        ]
      });

      const visibleBreadcrumbItems = [
        { name: isHindiRoute ? "होम" : "Home", url: getRouteLink('/') },
        { name: isHindiRoute ? "शब्दकोश" : "Glossary", url: getRouteLink('/glossary') },
        { name: termData.term, url: pageUrl }
      ];

      mainBodyHtml = `
        ${getBreadcrumbsHtml(isHindiRoute, visibleBreadcrumbItems)}
        <h1>${escapeHtml(termData.term)} (${escapeHtml(termData.devanagari)})</h1>
        <p><strong>${isHindiRoute ? 'श्रेणी' : 'Category'}:</strong> ${escapeHtml(termData.category)} | <strong>${isHindiRoute ? 'व्युत्पत्ति' : 'Etymology'}:</strong> ${escapeHtml(termData.etymology)}</p>
        
        <h2>${isHindiRoute ? 'परिभाषा' : 'Definition'}</h2>
        <p style="font-size: 1.1rem; line-height: 1.6; font-weight: bold;">${escapeHtml(termData.definition)}</p>

        <h2>${isHindiRoute ? 'दार्शनिक संदर्भ' : 'Theological Context'}</h2>
        <div style="background: #faf9f6; padding: 20px; border-left: 4px solid #f2a60d; margin: 20px 0; line-height: 1.8;">
          <p>${escapeHtml(isHindiRoute ? termData.theologicalContextHi : termData.theologicalContextEn)}</p>
        </div>

        ${termData.references ? `
          <p><strong>${isHindiRoute ? 'शास्त्र प्रमाण' : 'Citations / References'}:</strong> <em>${escapeHtml(termData.references)}</em></p>
        ` : ''}

        ${termData.relatedSaints && termData.relatedSaints.length > 0 ? `
          <h3>${isHindiRoute ? 'सम्बन्धित सन्त' : 'Related Saints'}</h3>
          <ul>
            ${termData.relatedSaints.map(s => `<li><a href="${getRouteLink(`/saint/${s.slug}`)}">${escapeHtml(s.nameEn)}</a></li>`).join('')}
          </ul>
        ` : ''}

        ${termData.relatedGranthas && termData.relatedGranthas.length > 0 ? `
          <h3>${isHindiRoute ? 'सम्बन्धित ग्रन्थ' : 'Related Scriptures'}</h3>
          <ul>
            ${termData.relatedGranthas.map(g => `<li><a href="${getRouteLink(`/book/${g.slug}`)}">${escapeHtml(g.nameEn)}</a></li>`).join('')}
          </ul>
        ` : ''}

        <p style="margin-top: 30px;"><a href="${getRouteLink('/glossary')}">← ${isHindiRoute ? 'सम्पूर्ण शब्दकोश' : 'Back to Glossary'}</a></p>
      `;
    } else {
      res.setHeader('Content-Type', 'text/html; charset=utf-8');
      res.status(404).send(`<!doctype html><html lang="hi"><head><meta charset="utf-8"/><title>Term Not Found — Vrindopnishad</title><meta name="robots" content="noindex"/></head><body style="font-family:sans-serif;text-align:center;padding:60px 20px;"><h1>404 — Term Not Found</h1><p><a href="${DOMAIN}/glossary">Browse All Terms →</a></p></body></html>`);
      return;
    }

  } else if (type === 'book' && slug) {

    const decodedSlug = decodeURIComponent(slug);
    const transliteratedSlug = slugify(transliterate(decodedSlug));
    const lowerSlug = decodedSlug.toLowerCase();
    const book = books.find(b => {
      const bSlug = b.slug || '';
      return bSlug === decodedSlug ||
        bSlug.toLowerCase() === lowerSlug ||
        (transliteratedSlug && bSlug === transliteratedSlug) ||
        (transliteratedSlug && bSlug.toLowerCase() === transliteratedSlug) ||
        (b.name && slugify(transliterate(b.name)) === transliteratedSlug);
    });

    if (book) {
      title = isHindiRoute
        ? `${book.name} ग्रन्थ — मूल पाठ, व्याख्या एवं हिंदी अनुवाद | वृंदोपनिषद्`
        : `${book.name} Grantha — Original Text, Meaning & Translations | Vrindopnishad`;
      description = isHindiRoute
        ? `वैष्णव संत ${book.author} द्वारा रचित पवित्र ग्रन्थ ${book.name} के सभी पद, मूल संस्कृत श्लोक, हिंदी अनुवाद और व्याख्या।`
        : `Read, chant, and explore the sacred verses of ${book.name} grantha composed by ${book.author}, with detailed translations and spiritual insights.`;

      pageUrl = getRouteLink(`/book/${encodeURIComponent(book.slug || slug)}`);

      if (book.imageUrl) {
        ogImageUrl = book.imageUrl;
      }

      jsonLd = JSON.stringify({
        "@context": "https://schema.org",
        "@graph": [
          {
            "@type": "Book",
            "@id": `${pageUrl}/#book`,
            "name": book.name,
            "author": {
              "@type": "Person",
              "name": book.author
            },
            "image": ogImageUrl,
            "inLanguage": ["hi", "sa"],
            "publisher": {
              "@type": "Organization",
              "name": "Vrindopnishad"
            },
            "url": pageUrl
          },
          {
            "@type": "BreadcrumbList",
            "@id": `${pageUrl}/#breadcrumb`,
            "itemListElement": [
              {
                "@type": "ListItem",
                "position": 1,
                "name": isHindiRoute ? "होम" : "Home",
                "item": getRouteLink('/')
              },
              {
                "@type": "ListItem",
                "position": 2,
                "name": isHindiRoute ? "ग्रन्थ" : "Books",
                "item": getRouteLink('/books')
              },
              {
                "@type": "ListItem",
                "position": 3,
                "name": book.name,
                "item": pageUrl
              }
            ]
          }
        ]
      });

      const visibleBreadcrumbItems = [
        { name: isHindiRoute ? "होम" : "Home", url: getRouteLink('/') },
        { name: isHindiRoute ? "ग्रन्थ" : "Books", url: getRouteLink('/books') },
        { name: book.name, url: pageUrl }
      ];

      mainBodyHtml = `
        ${getBreadcrumbsHtml(isHindiRoute, visibleBreadcrumbItems)}
        <h1>${escapeHtml(book.name)}</h1>
        <p><strong>${isHindiRoute ? 'लेखक / मूल स्रोत' : 'Author/Authoritative Source'}:</strong> <a href="${getRouteLink(`/saint/${slugify(transliterate(book.author))}`)}">${escapeHtml(book.author)}</a></p>
        <h2>${isHindiRoute ? 'इस ग्रन्थ के अंतर्गत पद' : 'Verses under this Grantha'} (${book.verses.length})</h2>
        <ul>
          ${book.verses.map(v => `<li><a href="${getRouteLink(`/content/${v.slug || v.id}`)}">${escapeHtml(v.title)}</a></li>`).join('')}
        </ul>
        ${(() => {
          const otherBooks = books.filter(b => b.slug !== book.slug && b.name !== book.name).slice(0, 4);
          if (otherBooks.length > 0) {
            return `<nav aria-label="Related Books" style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eae6df;">
              <h2>${isHindiRoute ? 'अन्य पवित्र ग्रन्थ' : 'Other Sacred Granthas'}</h2>
              <ul>${otherBooks.map(b => `<li><a href="${getRouteLink(`/book/${b.slug}`)}">${escapeHtml(b.name)} — ${escapeHtml(b.author)}</a></li>`).join('')}</ul>
            </nav>`;
          }
          return '';
        })()}
      `;
    } else {
      res.setHeader('Content-Type', 'text/html; charset=utf-8');
      res.status(404).send(`<!doctype html><html lang="hi"><head><meta charset="utf-8"/><title>Book Not Found — Vrindopnishad</title><meta name="robots" content="noindex"/></head><body style="font-family:sans-serif;text-align:center;padding:60px 20px;"><h1>404 — Book Not Found</h1><p><a href="${DOMAIN}/granthas">Browse All Books →</a></p></body></html>`);
      return;
    }

  } else if (type === 'raga' && slug) {

    const decodedSlug = decodeURIComponent(slug);
    const transliteratedSlug = slugify(transliterate(decodedSlug));
    const lowerSlug = decodedSlug.toLowerCase();
    const raga = ragas.find(r => {
      const rSlug = r.slug || '';
      return rSlug === decodedSlug ||
        rSlug.toLowerCase() === lowerSlug ||
        (transliteratedSlug && rSlug === transliteratedSlug) ||
        (transliteratedSlug && rSlug.toLowerCase() === transliteratedSlug) ||
        (r.name && slugify(transliterate(r.name)) === transliteratedSlug);
    });

    if (raga) {
      title = isHindiRoute
        ? `राग ${raga.name} के भजन, पद एवं संकीर्तन संग्रह | वृंदोपनिषद्`
        : `Raga ${raga.hinglishName || raga.name} Bhajans, Padas & Sankirtan Collection | Vrindopnishad`;
      description = isHindiRoute
        ? `शास्त्रीय संगीत के राग ${raga.name} में निबद्ध सभी वैष्णव भजन, पद और संकीर्तन पाठ। मूल स्वर और भावार्थ के साथ पढ़ें।`
        : `Browse and read the collection of devotional verses, bhajans, and temple kirtans composed in the traditional classical melody of Raga ${raga.hinglishName || raga.name}.`;

      pageUrl = getRouteLink(`/raga/${encodeURIComponent(raga.slug || slug)}`);

      if (raga.imageUrl) {
        ogImageUrl = raga.imageUrl;
      }

      jsonLd = JSON.stringify({
        "@context": "https://schema.org",
        "@graph": [
          {
            "@type": "CollectionPage",
            "@id": `${pageUrl}/#raga`,
            "name": isHindiRoute ? `राग ${raga.name}` : `Raga ${raga.name}`,
            "description": description,
            "image": ogImageUrl,
            "url": pageUrl
          },
          {
            "@type": "BreadcrumbList",
            "@id": `${pageUrl}/#breadcrumb`,
            "itemListElement": [
              {
                "@type": "ListItem",
                "position": 1,
                "name": isHindiRoute ? "होम" : "Home",
                "item": getRouteLink('/')
              },
              {
                "@type": "ListItem",
                "position": 2,
                "name": isHindiRoute ? "राग" : "Ragas",
                "item": getRouteLink('/ragas')
              },
              {
                "@type": "ListItem",
                "position": 3,
                "name": raga.name,
                "item": pageUrl
              }
            ]
          }
        ]
      });

      const visibleBreadcrumbItems = [
        { name: isHindiRoute ? "होम" : "Home", url: getRouteLink('/') },
        { name: isHindiRoute ? "राग" : "Ragas", url: getRouteLink('/ragas') },
        { name: raga.name, url: pageUrl }
      ];

      mainBodyHtml = `
        ${getBreadcrumbsHtml(isHindiRoute, visibleBreadcrumbItems)}
        <h1>${isHindiRoute ? `राग ${escapeHtml(raga.name)}` : `Raga ${escapeHtml(raga.name)}`}</h1>
        <p>${isHindiRoute ? `राग ${escapeHtml(raga.name)} में निबद्ध पद एवं संकीर्तन भजन।` : `Classical melody and sankirtan hymns set in Raga ${escapeHtml(raga.name)}.`}</p>
        <h2>${isHindiRoute ? 'इस राग में संकलित पद' : 'Verses set in this Raga'} (${raga.verses.length})</h2>
        <ul>
          ${raga.verses.map(v => `<li><a href="${getRouteLink(`/content/${v.slug || v.id}`)}">${escapeHtml(v.title)}</a></li>`).join('')}
        </ul>
      `;
    } else {
      res.setHeader('Content-Type', 'text/html; charset=utf-8');
      res.status(404).send(`<!doctype html><html lang="hi"><head><meta charset="utf-8"/><title>Raga Not Found — Vrindopnishad</title><meta name="robots" content="noindex"/></head><body style="font-family:sans-serif;text-align:center;padding:60px 20px;"><h1>404 — Raga Not Found</h1><p><a href="${DOMAIN}/ragas">Browse All Ragas →</a></p></body></html>`);
      return;
    }

  } else if (type === 'category' && slug) {

    const decodedSlug = decodeURIComponent(slug).toLowerCase().trim().replace(/\s+/g, '-');
    const filteredVerses = allContentItems.filter(item => item.category?.toLowerCase().trim().replace(/\s+/g, '-') === decodedSlug);
    const categoryTitle = decodedSlug.charAt(0).toUpperCase() + decodedSlug.slice(1);

    title = isHindiRoute
      ? `${categoryTitle} संग्रह, अर्थ एवं व्याख्या सहित | वृंदोपनिषद्`
      : `${categoryTitle} Collection, Meanings & Commentary | Vrindopnishad`;
    description = isHindiRoute
      ? `वृंदोपनिषद् पर ${categoryTitle} श्रेणी के अंतर्गत संकलित सभी पवित्र श्लोक, स्तोत्र, पद और भजन हिंदी अनुवाद के साथ।`
      : `Read and contemplate the complete collection of sacred texts, shlokas, and hyms categorized under ${categoryTitle} on Vrindopnishad.`;
    pageUrl = getRouteLink(`/category/${encodeURIComponent(slug)}`);

    mainBodyHtml = `
      <h1>${isHindiRoute ? `श्रेणी: ${escapeHtml(categoryTitle)}` : `Category: ${escapeHtml(categoryTitle)}`}</h1>
      <p>${isHindiRoute ? `${escapeHtml(categoryTitle)} के अंतर्गत संकलित श्लोक/पद पढ़ें।` : `Browse through our collection of sacred verses tagged under ${escapeHtml(categoryTitle)}.`}</p>
      <h2>${isHindiRoute ? 'संकलित पद' : 'Verses'} (${filteredVerses.length})</h2>
      <ul>
        ${filteredVerses.map(v => `<li><a href="${getRouteLink(`/content/${v.slug || v.id}`)}">${escapeHtml(v.title)}</a></li>`).join('')}
      </ul>
    `;

  } else if (type === 'static' && slug) {
    const decodedSlug = decodeURIComponent(slug);
    const staticPageData = STATIC_SEO_PAGES[decodedSlug];

    if (staticPageData) {
      const staticPage = isHindiRoute ? (staticPageData.hi || staticPageData.en) : (staticPageData.en || staticPageData.hi);
      title = staticPage.title;
      description = staticPage.description;
      pageUrl = getRouteLink(`/${decodedSlug}`);

      const pageName = title.split('—')[0].trim();
      const visibleBreadcrumbItems = [
        { name: isHindiRoute ? "होम" : "Home", url: getRouteLink('/') },
        { name: pageName, url: pageUrl }
      ];

      mainBodyHtml = `
        ${getBreadcrumbsHtml(isHindiRoute, visibleBreadcrumbItems)}
        <article>
          ${staticPage.body}
        </article>
      `;

      if (decodedSlug === 'faq') {
        const faqList = isHindiRoute ? faqDataHi : faqDataEn;
        jsonLd = JSON.stringify({
          "@context": "https://schema.org",
          "@graph": [
            {
              "@type": "FAQPage",
              "@id": `${pageUrl}/#faq`,
              "mainEntity": faqList.map(item => ({
                "@type": "Question",
                "name": item.question,
                "acceptedAnswer": {
                  "@type": "Answer",
                  "text": item.answer
                }
              }))
            },
            {
              "@type": "BreadcrumbList",
              "@id": `${pageUrl}/#breadcrumb`,
              "itemListElement": [
                {
                  "@type": "ListItem",
                  "position": 1,
                  "name": isHindiRoute ? "होम" : "Home",
                  "item": getRouteLink('/')
                },
                {
                  "@type": "ListItem",
                  "position": 2,
                  "name": isHindiRoute ? "प्रश्नोत्तर" : "FAQ",
                  "item": pageUrl
                }
              ]
            }
          ]
        });
      } else {
        jsonLd = JSON.stringify({
          "@context": "https://schema.org",
          "@graph": [
            {
              "@type": "Article",
              "@id": `${pageUrl}/#article`,
              "isPartOf": {
                "@type": "WebPage",
                "@id": pageUrl
              },
              "headline": title,
              "description": description,
              "image": ogImageUrl,
              "author": {
                "@type": "Organization",
                "name": "Vrindopnishad",
                "url": DOMAIN
              },
              "publisher": {
                "@type": "Organization",
                "name": "Vrindopnishad",
                "logo": {
                  "@type": "ImageObject",
                  "url": "https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png"
                }
              },
              "inLanguage": isHindiRoute ? "hi" : "en",
              "mainEntityOfPage": pageUrl
            },
            {
              "@type": "BreadcrumbList",
              "@id": `${pageUrl}/#breadcrumb`,
              "itemListElement": [
                {
                  "@type": "ListItem",
                  "position": 1,
                  "name": isHindiRoute ? "होम" : "Home",
                  "item": getRouteLink('/')
                },
                {
                  "@type": "ListItem",
                  "position": 2,
                  "name": pageName,
                  "item": pageUrl
                }
              ]
            }
          ]
        });
      }
    } else {
      let listName = "";

      if (decodedSlug === 'search') {
        title = isHindiRoute ? `खोज (Search) — वृंदोपनिषद् लाइब्रेरी` : `Search Sacred Verses & Saints | Vrindopnishad`;
        description = isHindiRoute
          ? `वृंदोपनिषद् पर संकलित श्लोक, स्तोत्र, संत जीवनियाँ और ग्रंथ खोजें।`
          : `Search the complete archive of Vrindavan saint biographies, sacred verses, shlokas, and granthas on Vrindopnishad.`;
        pageUrl = getRouteLink('/search');
        listName = isHindiRoute ? "खोज" : "Search";

        const popularTags = [
          { name: 'राधा', query: 'राधा' },
          { name: 'कृष्ण', query: 'कृष्ण' },
          { name: 'कृपा', query: 'कृपा' },
          { name: 'वृंदावन', query: 'वृंदावन' },
          { name: 'Radha', query: 'Radha' },
          { name: 'Krishna', query: 'Krishna' },
          { name: 'Raga', query: 'राग' },
          { name: 'Swami Haridas', query: 'स्वामी हरिदास' },
          { name: 'Hit Harivansh', query: 'हरिवंश' }
        ];

        const breadcrumbItems = [
          { name: isHindiRoute ? "होम" : "Home", url: getRouteLink('/') },
          { name: isHindiRoute ? "खोज" : "Search", url: pageUrl }
        ];

        mainBodyHtml = `
          ${getBreadcrumbsHtml(isHindiRoute, breadcrumbItems)}
          <h1>${isHindiRoute ? 'आध्यात्मिक लाइब्रेरी खोज' : 'Search Sacred Archive'}</h1>
          <p>${isHindiRoute ? 'वृंदोपनिषद् के संपूर्ण संग्रह में श्लोक, पद, संत, राग या व्याख्या खोजें।' : 'Search across all shlokas, verses, saints, ragas, and commentaries in Vrindopnishad.'}</p>
          
          <div style="margin: 30px 0; background: #faf9f6; padding: 25px; border-radius: 8px; border: 1px solid #eae6df;">
            <form action="${getRouteLink('/content')}" method="GET" style="display: flex; gap: 10px; flex-wrap: wrap;">
              <input type="text" name="q" placeholder="${isHindiRoute ? 'यहाँ खोजें (जैसे: राधा, कृपा, यमुना)...' : 'Type search terms (e.g. Radha, Kripa, Yamuna)...'}" style="flex: 1; min-width: 250px; padding: 12px; border: 1px solid #ccc; border-radius: 6px; font-size: 1.1rem;" required autofocus/>
              <button type="submit" style="background: #f2a60d; color: #fff; border: none; padding: 12px 30px; border-radius: 6px; font-size: 1.1rem; font-weight: bold; cursor: pointer;">
                ${isHindiRoute ? 'खोजें' : 'Search'}
              </button>
            </form>
          </div>

          <h3>${isHindiRoute ? 'लोकप्रिय खोज शब्द (Popular Tags)' : 'Popular Search Tags'}</h3>
          <div style="display: flex; gap: 10px; flex-wrap: wrap; margin-top: 15px;">
            ${popularTags.map(tag => `
              <a href="${getRouteLink(`/content?q=${encodeURIComponent(tag.query)}`)}" style="background: #f5f5f4; color: #44403c; padding: 8px 16px; border-radius: 20px; text-decoration: none; border: 1px solid #e7e5e4; font-size: 0.9rem; font-weight: 500;">
                # ${escapeHtml(tag.name)}
              </a>
            `).join('')}
          </div>
        `;
      } else if (decodedSlug === 'saints') {
        title = isHindiRoute ? `रसिक सन्त एवं चरित्र (Rasik Saints & Biographies) | Vrindopnishad` : `Vaishnava Rasik Saints & Biographies | Vrindopnishad`;
        description = isHindiRoute ? `ब्रज के महान रसिक संतों की जीवनी, इतिहास और उनके वाणी पदों का संग्रह पढ़ें।` : `Learn about the lives, teachings, and spiritual literature of the Rasik saints of Vrindavan, Barsana, and Braj.`;
        pageUrl = getRouteLink('/saints');
        listName = isHindiRoute ? "वैष्णव रसिक संत" : "Vaishnava Rasik Saints";

        const visibleBreadcrumbItems = [
          { name: isHindiRoute ? "होम" : "Home", url: getRouteLink('/') },
          { name: listName, url: pageUrl }
        ];

        mainBodyHtml = `
          ${getBreadcrumbsHtml(isHindiRoute, visibleBreadcrumbItems)}
          <h1>${isHindiRoute ? 'वैष्णव रसिक संत' : 'Vaishnava Rasik Saints'}</h1>
          ${isHindiRoute ? `
            <p>वृंदावन और संपूर्ण ब्रजमंडल पिछले पाँच सौ से अधिक वर्षों से भक्ति और रहस्यवाद का केंद्र रहा है। इस पावन भूमि को समय-समय पर अनेक <strong>रसिक संतों</strong> के चरण-कमलों का स्पर्श प्राप्त हुआ है। इन संतों ने शुष्क कर्मकांडों और बौद्धिक दर्शन के स्थान पर हृदय के सहज अनुराग और स्वतःस्फूर्त दिव्य प्रेम (रागानुगा भक्ति) को अपनाया। <em>रसिक</em> शब्द का अर्थ उस साधक से है जो श्री राधा-कृष्ण की नित्य निकुंज क्रीड़ाओं के मधुर दिव्य रस (ब्रज रस) का आस्वादन करने में समर्थ हो चुका है।</p>
            <p>इन संतों का इतिहास विभिन्न संप्रदायों और गुरु-शिष्य परंपराओं में विभाजित है, जिनमें से प्रत्येक संप्रदाय प्रेम के एक अनूठे पहलू पर बल देता है। <strong>हरिदासी संप्रदाय</strong> (या सखी संप्रदाय) की स्थापना संगीत और साधना के शिखर पुरुष <strong>स्वामी हरिदास जी</strong> ने की थी। यह परंपरा 'नित्य विहार' की उपासना करती है, जहाँ सखियाँ युगल के अखंड प्रेम-विलास का दर्शन करती हैं। स्वामी हरिदास जी ने ही अपनी संगीत साधना के बल पर निधिवन में श्री बांके बिहारी जी के विग्रह को प्रकट किया था।</p>
            <p><strong>राधावल्लभ संप्रदाय</strong> की स्थापना <strong>गोस्वामी हित हरिवंश महाप्रभु</strong> द्वारा की गई थी। इस संप्रदाय में श्री राधा रानी को उपासना के केंद्र बिंदु में रखा गया है। हित हरिवंश जी ने <em>राधा दास्य</em> (श्री राधा की अनन्य दासी बनना) के सिद्धांत को प्रतिपादित किया, जहाँ स्वयं भगवान कृष्ण श्रीजी के चरणों की सेवा करते हैं। श्री राधा जी को वृंदावन की एकमात्र स्वामिनी और साम्राज्य के रूप में पूजा जाता है, और इस मार्ग में विरह (वियोग) का पूर्णतः निषेध है।</p>
            <p><strong>गौड़ीय वैष्णव संप्रदाय</strong>, जिसे <strong>श्रीमन् महाप्रभु चैतन्य देव</strong> ने नवजीवन दिया और जिसे वृंदावन के <strong>षड गोस्वामियों</strong> ने दार्शनिक रूप से सुदृढ़ किया, 'अचिन्त्य भेदाभेद' दर्शन और 'मंजरी भाव' की उपासना सिखाता है। इसके अतिरिक्त <strong>निम्बार्क संप्रदाय</strong> और <strong>पुष्टिमार्ग (वल्लभ संप्रदाय)</strong> ने भी ब्रज की रसमय उपासना पद्धति में अतुलनीय योगदान दिया है।</p>
            <p>इन संतों का साहित्यिक योगदान अद्भुत है। उन्होंने <strong>ब्रजभाषा</strong> में हजारों पदों और वाणियों की रचना की। ये रचनाएँ केवल साधारण कविताएँ नहीं हैं, बल्कि उनके गहरे आध्यात्मिक अनुभवों की ध्वन्यात्मक अभिव्यक्ति हैं, जिन्हें आज भी वृंदावन के मंदिरों में <em>समाज गायन</em> के रूप में गाया जाता है। संतों के चरित्र और वाणियों का अनुशीलन करने से हृदय निर्मल होता है और ईश्वर के प्रति वास्तविक भक्ति जाग्रत होती है।</p>
          ` : `
            <p>Vrindavan and the surrounding Braj Dham have been the epicenters of devotional mysticism for over five centuries. This sacred landscape has been blessed by the physical presence of the <strong>Rasik saints</strong>—devotees who chose the path of spontaneous, intimate divine love (Raganuga Bhakti) over formal rituals or intellectual philosophies. The term <em>Rasik</em> refers to one who has cultivated the subtle spiritual capacity to taste the divine nectar (Ras) of the pastimes of Shri Radha and Shri Krishna in the eternal, transcendental bowers (Nikunj) of Nitya Vrindavan.</p>
            <p>The history of these saints is categorized by their respective lineages (sampradayas), each emphasizing a unique facet of this divine love. The <strong>Haridasi Sampradaya</strong> (or Sakhi Sampradaya), established by the legendary musician-saint <strong>Swami Haridas</strong>, focuses on Nitya Vihar—the continuous, uninterrupted love-play of the Divine Couple observed by their intimate companions (Sakhis). Swami Haridas is famous for manifesting the deity of Bankey Bihari Ji in Nidhivan through the power of his musical devotion.</p>
            <p>The <strong>Radhavallabh Sampradaya</strong>, founded by <strong>Goswami Hit Harivansh Mahaprabhu</strong>, places Srimati Radharani at the absolute center of devotion. Hit Harivansh pioneered the concept of <em>Radha Dasya</em> (the servitude of Shri Radha), holding that Krishna Himself serves Her feet in the highest state of love. Srimati Radharani is worshiped as the sovereign queen of Vrindavan, and the path is celebrated for its sheer sweetness (madhurya) and exclusion of any mood of separation.</p>
            <p>The <strong>Gaudiya Vaishnava Sampradaya</strong>, revitalized by <strong>Sri Chaitanya Mahaprabhu</strong> and systematically codified by the <strong>Six Goswamis of Vrindavan</strong> (Sanatana, Rupa, Raghunatha Bhatta, Raghunatha Das, Jiva, and Gopala Bhatta), provides a solid philosophical foundation (Achintya Bheda Abheda) alongside the confidential practice of <em>Manjari Bhava</em>—servitude as a young maidservant of Shri Radha. Other lineages, including the <strong>Nimbarka Sampradaya</strong> and the <strong>Vallabha Sampradaya (Pushtimarg)</strong>, have also contributed immensely to the rich tapestry of Braj devotion.</p>
            <p>The literary contributions of these saints are unparalleled. They composed thousands of devotional songs (padas) in the sweet, musical dialect of <strong>Braj Bhasha</strong>. These compositions are not merely poetry; they are sonic maps of spiritual experiences, sung daily in the temples of Vrindavan in a traditional style known as <em>Samaj Gayan</em>. Exploring their biographies and songs is a transformative journey that purifies the heart and awakens the soul's innate capacity for divine love.</p>
          `}
          <h2 style="margin-top: 30px;">${isHindiRoute ? 'संतों की सूची' : 'Saint Biographies'}</h2>
          <ul>
            ${sants.map(s => `<li><a href="${getRouteLink(`/saint/${s.slug}`)}">${escapeHtml(s.name)}</a></li>`).join('')}
          </ul>
        `;
      } else if (decodedSlug === 'books' || decodedSlug === 'granthas') {
        title = isHindiRoute ? `पवित्र ग्रन्थ एवं वाणी साहित्य (Sacred Scriptures & Literature) | Vrindopnishad` : `Sacred Scriptures & Literature | Vrindopnishad`;
        description = isHindiRoute ? `पवित्र वैष्णव ग्रंथों, वाणियों और साहित्यों के डिजिटल संस्करण पढ़ें।` : `Browse and read the digital editions of sacred Vaishnava granthas, vanis, and spiritual scriptures.`;
        pageUrl = getRouteLink('/books');
        listName = isHindiRoute ? "पवित्र ग्रन्थ" : "Sacred Granthas";

        const visibleBreadcrumbItems = [
          { name: isHindiRoute ? "होम" : "Home", url: getRouteLink('/') },
          { name: listName, url: pageUrl }
        ];

        mainBodyHtml = `
          ${getBreadcrumbsHtml(isHindiRoute, visibleBreadcrumbItems)}
          <h1>${isHindiRoute ? 'पवित्र ग्रन्थ साहित्य' : 'Sacred Granthas'}</h1>
          ${isHindiRoute ? `
            <p>ब्रज रसिक परंपरा का संपूर्ण आध्यात्मिक ज्ञान जिस विशाल साहित्य में सुरक्षित है, उसे <strong>वाणी साहित्य</strong> या ग्रन्थ कहा जाता है। सामान्य वैदिक ग्रंथों के विपरीत, जो नैतिक नियमों, सृष्टि विज्ञान या अमूर्त अद्वैतवाद पर ध्यान केंद्रित करते हैं, रसिकों का वाणी साहित्य पूरी तरह से प्रेम रस (भक्ति रस) और वृंदावन निकुंज के अंतर्गत होने वाली युगल सरकार की अंतरंग लीलाओं पर आधारित है। ये ग्रंथ साधक के लिए मार्गदर्शिका का कार्य करते हैं, जो मन को दैनिक ध्यान और स्मरण की दिशा में मोड़ने में सहायक होते हैं।</p>
            <p>इस परंपरा के साहित्य में दो भाषाओं का अद्भुत समन्वय दिखाई देता है: <strong>संस्कृत</strong> और <strong>ब्रजभाषा</strong>। आचार्यों ने संस्कृत का उपयोग गंभीर दार्शनिक सिद्धांतों, उपनिषदों पर टीकाओं और जटिल भक्ति स्तोत्रों की रचना के लिए किया। <em>श्री राधा सुधा निधि</em> और श्रील जीव गोस्वामी के ग्रंथ इसके प्रत्यक्ष उदाहरण हैं, जिन्होंने भक्ति मार्ग को अकाट्य तर्कों से सिद्ध किया। दूसरी ओर, ब्रजभाषा—जो पश्चिमी हिंदी की एक अत्यंत मधुर बोली है—संतों के हृदय की भाषा बनी। स्वामी हरिदास जी ने <em>केलिमाल</em> और हित हरिवंश जी ने <em>हित चौरासी</em> के माध्यम से अपने प्रेममय आध्यात्मिक अनुभवों को ब्रजभाषा में पिरोया, ताकि संगीत के माध्यम से यह रस जन-साधारण तक पहुँच सके।</p>
            <p>एक साधक के दैनिक जीवन में इन पवित्र ग्रंथों का पाठ (जिसे <strong>वाणी स्वाध्याय</strong> कहते हैं) साक्षात् संतों के संग के समान माना जाता है। मान्यता है कि संतों के शब्द और उनका अस्तित्व एक ही हैं; जब हम इन वाणियों का पाठ करते हैं, तो हमारा मन संसार के कोलाहल से दूर होकर वृंदावन के पावन दिव्य भाव में स्थित होने लगता है। वृंदोपनिषद् परियोजना इस अमूल्य वाणी धरोहर के डिजिटल संरक्षण के लिए समर्पित है, ताकि प्राचीन आश्रमों की दुर्लभ पांडुलिपियों को आधुनिक पीढ़ी के लिए सहेजकर प्रस्तुत किया जा सके।</p>
          ` : `
            <p>The spiritual knowledge of the Braj Rasik tradition is preserved in a vast body of literature collectively known as <strong>Vani Sahitya</strong> or scriptural granthas. Unlike mainstream Vedic scriptures that focus on general ethics, cosmology, or abstract monism, the literature of the Rasik saints is highly specialized, focusing on the aesthetics of divine love (Bhakti Rasa) and the confidential pastimes of the Divine Couple in Nikunj Vrindavan. These texts serve as essential guidebooks for practitioners, directing their minds toward daily contemplation and meditation (Smarana).</p>
            <p>The bibliography of this tradition features an organic integration of two languages: <strong>Sanskrit</strong> and <strong>Braj Bhasha</strong>. Sanskrit was utilized by the early acharyas to write formal theological treatises, commentaries on the Upanishads and Vedanta, and intricate devotional hymns. Masterpieces like the <em>Radha Sudha Nidhi</em> (credited to Hit Harivansh or Prabodhananda Sarasvati) and the commentaries of Srila Jiva Goswami are written in classical Sanskrit, establishing the philosophical validity of the path of devotion. On the other hand, Braj Bhasha—a sweet, musical dialect of western Hindi—was the language of the heart. Saints like Swami Haridas in his <em>Kelimal</em> and Hit Harivansh in his <em>Hit Chaurasi</em> composed their direct, ecstatic realizations in Braj Bhasha, making the deepest spiritual nectar accessible to everyone through song.</p>
            <p>In the daily life of a practitioner, reading these scriptures (known as <strong>Vani Swadhyaya</strong>) is considered a form of direct association (Satsanga) with the saints themselves. It is believed that the words of the saints are non-different from their presence; by reciting and contemplating these verses, the mind is purified of mundane desires and aligned with the transcendental mood of Vrindavan. Vrindopnishad is dedicated to the digital preservation of this invaluable heritage, collecting rare manuscripts from ancient ashrams and temples, and presenting them with structured translations, annotations, and clear definitions for modern seekers.</p>
          `}
          <h2 style="margin-top: 30px;">${isHindiRoute ? 'ग्रन्थ सूची' : 'Sacred Scriptures'}</h2>
          <ul>
            ${books.map(b => `<li><a href="${getRouteLink(`/book/${b.slug}`)}">${escapeHtml(b.name)}</a></li>`).join('')}
          </ul>
        `;
      } else if (decodedSlug === 'ragas') {
        title = isHindiRoute ? `शास्त्रीय राग एवं कीर्तन राग (Vaishnava Raga Registry) | Vrindopnishad` : `Vaishnava Raga Registry | Vrindopnishad`;
        description = isHindiRoute ? `शास्त्रीय रागों में रचित संकीर्तन पद और भजनों का राग-अनुसार संग्रह।` : `Explore devotional songs and verses organized by their classical raag melodies.`;
        pageUrl = getRouteLink('/ragas');
        listName = isHindiRoute ? "शास्त्रीय देवभक्ति राग" : "Vaishnava Ragas";

        const visibleBreadcrumbItems = [
          { name: isHindiRoute ? "होम" : "Home", url: getRouteLink('/') },
          { name: listName, url: pageUrl }
        ];

        mainBodyHtml = `
          ${getBreadcrumbsHtml(isHindiRoute, visibleBreadcrumbItems)}
          <h1>${isHindiRoute ? 'देवभक्ति शास्त्रीय राग' : 'Devotional Classical Ragas'}</h1>
          <p>${isHindiRoute ? 'शास्त्रीय संगीत के रागों के आधार पर वर्गीकृत पदों और संकीर्तन का संग्रह। यहाँ प्रत्येक पद के संगीतबद्ध राग की जानकारी दी गई है।' : 'Explore holy verses and kirtan hymns classified by traditional Indian classical ragas.'}</p>
          <h2 style="margin-top: 30px;">${isHindiRoute ? 'राग सूची' : 'Classical Ragas'}</h2>
          <ul>
            ${ragas.map(r => `<li><a href="${getRouteLink(`/raga/${r.slug}`)}">${escapeHtml(r.name)}</a></li>`).join('')}
          </ul>
        `;
      } else if (decodedSlug === 'content') {
        const searchQuery = req.query.q ? req.query.q.toString().trim() : '';
        if (searchQuery) {
          const lowerQuery = searchQuery.toLowerCase();
          const filtered = allContentItems.filter(item => {
            return (item.title && item.title.toLowerCase().includes(lowerQuery)) ||
              (item.author && item.author.toLowerCase().includes(lowerQuery)) ||
              (item.hindi_text && item.hindi_text.toLowerCase().includes(lowerQuery)) ||
              (item.sanskrit_text && item.sanskrit_text.toLowerCase().includes(lowerQuery));
          });

          title = isHindiRoute
            ? `खोज परिणाम: "${escapeHtml(searchQuery)}" | वृंदोपनिषद्`
            : `Search Results for "${escapeHtml(searchQuery)}" | Vrindopnishad`;
          description = isHindiRoute
            ? `वृंदोपनिषद् पर "${escapeHtml(searchQuery)}" के खोज परिणाम। संकलित श्लोक, पद और भजनों की सूची।`
            : `Browse search results for "${escapeHtml(searchQuery)}" on Vrindopnishad. Access matching verses and spiritual scriptures.`;
          pageUrl = getRouteLink(`/content?q=${encodeURIComponent(searchQuery)}`);
          listName = isHindiRoute ? "खोज परिणाम" : "Search Results";

          const visibleBreadcrumbItems = [
            { name: isHindiRoute ? "होम" : "Home", url: getRouteLink('/') },
            { name: isHindiRoute ? "खोज" : "Search", url: getRouteLink('/search') },
            { name: `"${searchQuery}"`, url: pageUrl }
          ];

          mainBodyHtml = `
            ${getBreadcrumbsHtml(isHindiRoute, visibleBreadcrumbItems)}
            <h1>${isHindiRoute ? `खोज परिणाम: "${escapeHtml(searchQuery)}"` : `Search Results for "${escapeHtml(searchQuery)}"`}</h1>
            <p>${isHindiRoute ? `"${escapeHtml(searchQuery)}" से मेल खाते ${filtered.length} परिणाम मिले:` : `Found ${filtered.length} matching results for "${escapeHtml(searchQuery)}":`}</p>
            ${filtered.length > 0 ? `
              <ul style="margin-top: 20px;">
                ${filtered.map(v => `<li><a href="${getRouteLink(`/content/${v.slug || v.id}`)}">${escapeHtml(v.title)}</a></li>`).join('')}
              </ul>
            ` : `
              <p style="margin: 20px 0; color: #888;">${isHindiRoute ? 'कोई परिणाम नहीं मिला। कृपया अन्य शब्दों का प्रयोग करें।' : 'No results found. Please try with different keywords.'}</p>
            `}
            <div style="margin-top: 30px;">
              <form action="${getRouteLink('/content')}" method="GET" style="display: flex; gap: 10px; max-width: 500px;">
                <input type="text" name="q" value="${escapeHtml(searchQuery)}" placeholder="${isHindiRoute ? 'अन्य पद या संत खोजें...' : 'Search other verses or saints...'}" style="flex: 1; padding: 10px; border: 1px solid #ccc; border-radius: 4px; font-size: 1rem;"/>
                <button type="submit" style="background: #f2a60d; color: #fff; border: none; padding: 10px 20px; border-radius: 4px; font-weight: bold; cursor: pointer;">${isHindiRoute ? 'खोजें' : 'Search'}</button>
              </form>
            </div>
          `;
        } else {
          title = isHindiRoute ? `वृंदोपनिषद् पाठ लाइब्रेरी (Browse All Sacred Content) | Vrindopnishad` : `Vrindopnishad Paath Library (Browse All Sacred Content) | Vrindopnishad`;
          description = isHindiRoute ? `संस्कृत श्लोकों, स्तोत्रों, भजनों, और आध्यात्मिक कविताओं की संपूर्ण लाइब्रेरी।` : `Access the complete index of shlokas, strotras, bhajans, kirtans, and spiritual poetry.`;
          pageUrl = getRouteLink('/content');
          listName = isHindiRoute ? "सभी संकलित पाठ" : "All Sacred Verses";

          const visibleBreadcrumbItems = [
            { name: isHindiRoute ? "होम" : "Home", url: getRouteLink('/') },
            { name: listName, url: pageUrl }
          ];

          mainBodyHtml = `
            ${getBreadcrumbsHtml(isHindiRoute, visibleBreadcrumbItems)}
            <h1>${isHindiRoute ? 'सभी संकलित पाठ एवं श्लोक' : 'All Sacred Verses & Content'}</h1>
            ${isHindiRoute ? `
              <p><strong>वृंदोपनिषद् पाठ पुस्तकालय</strong> के पावन डिजिटल संग्रह में स्वागत है। यह पुस्तकालय हमारे संरक्षण कार्य का हृदय है, जिसमें सैकड़ों संस्कृत श्लोक, स्तुति स्तोत्र और रसिक संतों के ब्रजभाषा पद संकलित हैं। <em>पाठ</em> का अर्थ है शास्त्रों का नियमपूर्वक और सस्वर वाचन करना। वैदिक और वैष्णव परंपरा में ध्वनि को केवल अर्थ समझाने का साधन नहीं, बल्कि एक दिव्य आध्यात्मिक ऊर्जा माना गया है। श्रद्धापूर्वक इन पवित्र वाणियों का पाठ करने से एक सूक्ष्म, पवित्र कंपन उत्पन्न होता है, जो मन के तनाव को दूर कर आंतरिक शांति प्रदान करता है।</p>
              <p>इस पुस्तकालय की सामग्री को इस प्रकार व्यवस्थित किया गया है कि यह शोधकर्ताओं और दैनिक साधकों दोनों के लिए समान रूप से उपयोगी सिद्ध हो। प्रत्येक पद के पृष्ठ पर देवनागरी मूल पाठ, शुद्ध उच्चारण में सहायक रोमन लिप्यंतरण (Hinglish), और हिंदी-अंग्रेजी अनुवाद के साथ विस्तृत व्याख्या दी गई है। हिंग्लिश की उपलब्धता के कारण विश्व भर के जिज्ञासु, जिन्हें देवनागरी लिपि का अभ्यास नहीं है, वे भी सुगमता से इन पदों का पाठ कर सकते हैं। यह पुस्तकालय विभिन्न श्रेणियों में विभाजित है, जैसे श्री राधा रानी की महिमा, भगवान कृष्ण की लीलाएँ, वृंदावन धाम का महात्म्य और संतों के उपदेशपरक दोहे।</p>
              <p>हम साधकों से अनुरोध करते हैं कि वे इस पुस्तकालय का उपयोग अपनी दैनिक साधना में अवश्य करें। प्रतिदिन कुछ मिनटों के लिए पवित्र वाणियों का स्वाध्याय करने से अशांत जीवन में स्थिरता और एकाग्रता आती है। हमारी उन्नत खोज प्रणाली और रसिक लिंक रजिस्ट्री के माध्यम से आप किसी भी पद के लेखक, राग, संबंधित ग्रंथ और दार्शनिक अवधारणाओं के बीच के संबंधों को आसानी से समझ सकते हैं, जिससे इस अमूल्य आध्यात्मिक धरोहर की गहरी समझ प्राप्त होती है।</p>
            ` : `
              <p>Welcome to the digital sanctuary of the <strong>Vrindopnishad Paath Library</strong>. This repository represents the heart of our archiving mission, containing hundreds of sacred Sanskrit shlokas, devotional stotras, and Braj Bhasha poetry from the Rasik saints. The word <em>Paath</em> refers to the traditional practice of systematic, vocal recitation of scriptural texts. In the Vedic and Vaishnava traditions, sound is understood not merely as a medium for conveying semantic meaning, but as a dynamic spiritual energy. Reciting these verses with devotion creates a subtle, purifying vibration that clears the mind of stress and establishes a deep sense of inner peace.</p>
              <p>The content in this library is carefully organized to facilitate both academic research and daily spiritual practice. Each verse page is designed to return fully rendered HTML, featuring the original Devanagari text, a clear romanized transliteration (Hinglish) to assist with pronunciation, and a detailed translation with historical commentary. The inclusion of Hinglish ensures that seekers from across the globe, regardless of their familiarity with the Devanagari script, can participate in the chanting. The library is categorized into distinct spiritual domains, including verses dedicated to the glory of Shri Radha, the pastimes of Lord Krishna, the sacred landscape of Vrindavan Dham, and the instructions of the saints.</p>
              <p>We encourage users to make this library a part of their daily routine. Engaging in scriptural contemplation—even for a few minutes each day—helps to establish a meditative anchor in our fast-paced lives. By utilizing our advanced search filters and internal linking registry, you can easily trace the connections between different verses, their authors, their respective classical ragas, and their underlying theological concepts, unlocking the deeper layers of this profound heritage.</p>
            `}
            <h2 style="margin-top: 30px;">${isHindiRoute ? 'सभी संकलित पदों की सूची' : 'Collected Verses'}</h2>
            <ul>
              ${allContentItems.map(item => `<li><a href="${getRouteLink(`/content/${item.slug || item.id}`)}">${escapeHtml(item.title)}</a></li>`).join('')}
            </ul>
          `;
        }
      } else {
        res.setHeader('Content-Type', 'text/html; charset=utf-8');
        res.status(404).send(`<!doctype html><html lang="hi"><head><meta charset="utf-8"/><title>Page Not Found — Vrindopnishad</title><meta name="robots" content="noindex"/></head><body style="font-family:sans-serif;text-align:center;padding:60px 20px;"><h1>404 — Page Not Found</h1><p><a href="${DOMAIN}/">Go Home →</a></p></body></html>`);
        return;
      }

      if (listName) {
        jsonLd = JSON.stringify({
          "@context": "https://schema.org",
          "@graph": [
            {
              "@type": "CollectionPage",
              "@id": `${pageUrl}/#collection`,
              "name": listName,
              "description": description,
              "url": pageUrl
            },
            {
              "@type": "BreadcrumbList",
              "@id": `${pageUrl}/#breadcrumb`,
              "itemListElement": [
                {
                  "@type": "ListItem",
                  "position": 1,
                  "name": isHindiRoute ? "होम" : "Home",
                  "item": getRouteLink('/')
                },
                {
                  "@type": "ListItem",
                  "position": 2,
                  "name": listName,
                  "item": pageUrl
                }
              ]
            }
          ]
        });
      }
    }

  } else {

    pageUrl = getRouteLink('/');
    title = isHindiRoute ? `वृंदोपनिषद् पाठ | श्लोक, स्तोत्र, और आध्यात्मिक कविता संग्रह` : `Vrindopnishad Paath — वृंदोपनिषद् पाठ | Sacred Shlokas, Strotras & Devotional Poetry`;
    description = `Vrindopnishad Paath (वृंदोपनिषद् पाठ) — Read and listen to sacred Sanskrit shlokas, strotras, devotional poetry and Vedic wisdom from Vrindavan saints. Free online paath in Hindi, Sanskrit and English. भगवद्गीता, मंत्र, श्लोक, स्तोत्र सब यहाँ पढ़ें।`;

    jsonLd = JSON.stringify({
      "@context": "https://schema.org",
      "@graph": [
        {
          "@type": "Organization",
          "@id": `${DOMAIN}/#organization`,
          "name": "Vrindopnishad",
          "url": DOMAIN,
          "logo": {
            "@type": "ImageObject",
            "url": "https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png",
            "width": 512,
            "height": 512
          },
          "sameAs": [
            "https://www.instagram.com/vrindopnishad",
            "https://www.facebook.com/vrindopnishad",
            "https://www.youtube.com/@vrindopnishad"
          ],
          "description": "Vrindopnishad is a digital sanctuary for authentic spiritual and Vedic knowledge, connecting tradition with modern innovation."
        },
        {
          "@type": "WebSite",
          "@id": `${DOMAIN}/#website`,
          "name": "Vrindopnishad Paath",
          "url": DOMAIN,
          "publisher": { "@id": `${DOMAIN}/#organization` },
          "description": "Vrindopnishad Paath — The official digital sanctuary of sacred shlokas, strotras, and devotional poetry.",
          "potentialAction": {
            "@type": "SearchAction",
            "target": `${DOMAIN}/content?q={search_term_string}`,
            "query-input": "required name=search_term_string"
          }
        },
        {
          "@type": "WebPage",
          "@id": `${DOMAIN}/#webpage`,
          "url": DOMAIN,
          "name": "Vrindopnishad Paath — Home",
          "isPartOf": { "@id": `${DOMAIN}/#website` },
          "description": "Read and listen to sacred Sanskrit shlokas, strotras, and devotional poetry from Vrindavan."
        }
      ]
    });

    mainBodyHtml = `
      <h1>Vrindopnishad Paath — वृंदोपनिषद् पाठ</h1>
      <p>Welcome to Vrindopnishad, the premier digital sanctuary for Vaishnava literature, Sanskrit shlokas, strotras, kirtans, and devotional characters of the saints of Vrindavan.</p>
      
      <h2>Explore Wisdom Hub — ज्ञान केन्द्र</h2>
      <ul>
        <li><a href="${getRouteLink('/saints')}">Saints &amp; Biographies — रसिक संत</a></li>
        <li><a href="${getRouteLink('/books')}">Granthas &amp; Literature — ग्रन्थ साहित्य</a></li>
        <li><a href="${getRouteLink('/ragas')}">Classical Devotional Ragas — राग संकीर्तन</a></li>
        <li><a href="${getRouteLink('/content')}">All Collections — सभी पाठ</a></li>
      </ul>

      <h2>Confidential Spiritual Wisdom — आध्यात्मिक विषय</h2>
      <ul>
        <li><a href="${getRouteLink('/what-is-vrindopnishad')}">What is Vrindopnishad?</a></li>
        <li><a href="${getRouteLink('/meaning')}">Meaning of the Compound Name</a></li>
        <li><a href="${getRouteLink('/origin')}">History &amp; Divine Origin</a></li>
        <li><a href="${getRouteLink('/philosophy')}">Vedic &amp; Vaishnava Philosophy</a></li>
        <li><a href="${getRouteLink('/teachings')}">Core Spiritual Teachings</a></li>
        <li><a href="${getRouteLink('/importance')}">Importance of Scriptural Contemplation</a></li>
        <li><a href="${getRouteLink('/devotion')}">The Philosophy of Bhakti (Devotion)</a></li>
        <li><a href="${getRouteLink('/faq')}">Frequently Asked Questions</a></li>
        <li><a href="${getRouteLink('/comparison-with-upanishads')}">Comparison study with Vedic Upanishads</a></li>
        <li><a href="${getRouteLink('/guide')}">User Practice Guide</a></li>
        <li><a href="${getRouteLink('/braj-rasik-heritage')}">Braj Rasik Heritage</a></li>
      </ul>
    `;
  }


  const currentPath = pageUrl.replace(DOMAIN, '');
  const isHi = currentPath.startsWith('/hi');
  const cleanPath = isHi ? (currentPath.replace(/^\/hi/, '') || '/') : currentPath;
  const enUrl = DOMAIN + cleanPath;
  const hiUrl = DOMAIN + '/hi' + (cleanPath === '/' ? '' : cleanPath);


  let html = `<!doctype html>
<html lang="hi" dir="ltr">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover"/>
  <title>${title}</title>
  <meta name="description" content="${description}"/>
  <link rel="canonical" href="${pageUrl}"/>
  <link rel="alternate" hreflang="en" href="${enUrl}"/>
  <link rel="alternate" hreflang="hi" href="${hiUrl}"/>
  <link rel="alternate" hreflang="x-default" href="${enUrl}"/>
  <meta property="og:type" content="article"/>
  <meta property="og:title" content="${title}"/>
  <meta property="og:description" content="${description}"/>
  <meta property="og:url" content="${pageUrl}"/>
  <meta property="og:image" content="${ogImageUrl}"/>
  <meta property="og:site_name" content="Vrindopnishad Paath — वृंदोपनिषद् पाठ"/>
  <meta property="og:locale" content="hi_IN"/>
  <meta name="twitter:card" content="summary_large_image"/>
  <meta name="twitter:title" content="${title}"/>
  <meta name="twitter:description" content="${description}"/>
  <meta name="twitter:image" content="${ogImageUrl}"/>
  ${jsonLd ? `<script type="application/ld+json">${jsonLd}</script>` : ''}
  <meta name="theme-color" content="#0D0D12"/>
  <link rel="icon" href="${DOMAIN}/favicon.ico" sizes="any"/>
  <link rel="icon" href="${DOMAIN}/favicon-32x32.png" sizes="32x32" type="image/png"/>
  <link rel="icon" href="${DOMAIN}/icon-192.png" sizes="192x192" type="image/png"/>
  <link rel="apple-touch-icon" href="${DOMAIN}/apple-touch-icon.png" sizes="180x180"/>
  <meta name="robots" content="index, follow"/>
</head>
<body style="font-family: sans-serif; background: #faf9f6; color: #1c1917; padding: 20px; line-height: 1.6;">
  <div style="max-width: 800px; margin: 0 auto; background: #ffffff; padding: 30px 40px; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); border: 1px solid #eae6df;">
    <header style="margin-bottom: 30px; border-bottom: 2px solid #f2a60d; padding-bottom: 15px;">
      <a href="${getRouteLink('/')}" style="text-decoration: none; color: #f2a60d; font-size: 1.5rem; font-weight: bold;">ॐ Vrindopnishad — वृंदोपनिषद्</a>
    </header>
    <main>
      ${mainBodyHtml}
    </main>
    <footer style="margin-top: 40px; border-top: 1px solid #eae6df; padding-top: 15px; font-size: 0.8rem; color: #8c857b; text-align: center;">
      <p>© ${new Date().getFullYear()} Vrindopnishad. Serving the spiritual heritage of Vrindavan.</p>
    </footer>
  </div>
  <div id="root"></div>
</body>
</html>`;

  try {
    let indexPath = path.join(process.cwd(), 'build/index.html');
    if (!fs.existsSync(indexPath)) {
      indexPath = path.join(process.cwd(), 'frontend/build/index.html');
    }
    if (!fs.existsSync(indexPath)) {
      indexPath = path.join(process.cwd(), 'index.html');
    }
    if (fs.existsSync(indexPath)) {
      let indexHtml = fs.readFileSync(indexPath, 'utf8');

      // Replace title and description
      indexHtml = indexHtml.replace(/<title>[^<]*<\/title>/, `<title>${title}</title>`);
      indexHtml = indexHtml.replace(/<meta name="description" content="[^"]*"\s*\/?>/, `<meta name="description" content="${description}"/>`);

      // Add extra tags in head
      const extraHead = `
  <link rel="canonical" href="${pageUrl}"/>
  <link rel="alternate" hreflang="en" href="${enUrl}"/>
  <link rel="alternate" hreflang="hi" href="${hiUrl}"/>
  <link rel="alternate" hreflang="x-default" href="${enUrl}"/>
  <meta property="og:type" content="article"/>
  <meta property="og:title" content="${title}"/>
  <meta property="og:description" content="${description}"/>
  <meta property="og:url" content="${pageUrl}"/>
  <meta property="og:image" content="${ogImageUrl}"/>
  <meta property="og:site_name" content="Vrindopnishad Paath — वृंदोपनिषद् पाठ"/>
  <meta property="og:locale" content="hi_IN"/>
  <meta name="twitter:card" content="summary_large_image"/>
  <meta name="twitter:title" content="${title}"/>
  <meta name="twitter:description" content="${description}"/>
  <meta name="twitter:image" content="${ogImageUrl}"/>
  ${jsonLd ? `<script type="application/ld+json">${jsonLd}</script>` : ''}
  <meta name="theme-color" content="#0D0D12"/>
  <link rel="icon" href="${DOMAIN}/favicon.ico" sizes="any"/>
  <link rel="icon" href="${DOMAIN}/favicon-32x32.png" sizes="32x32" type="image/png"/>
  <link rel="icon" href="${DOMAIN}/icon-192.png" sizes="192x192" type="image/png"/>
  <link rel="apple-touch-icon" href="${DOMAIN}/apple-touch-icon.png" sizes="180x180"/>
  <meta name="robots" content="index, follow"/>
`;
      indexHtml = indexHtml.replace('</head>', `${extraHead}</head>`);

      // Replace noscript
      const newNoscript = `<noscript>
  <div style="max-width: 800px; margin: 0 auto; background: #ffffff; padding: 30px 40px; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); border: 1px solid #eae6df; font-family: sans-serif; line-height: 1.6;">
    <header style="margin-bottom: 30px; border-bottom: 2px solid #f2a60d; padding-bottom: 15px;">
      <a href="${getRouteLink('/')}" style="text-decoration: none; color: #f2a60d; font-size: 1.5rem; font-weight: bold;">ॐ Vrindopnishad — वृंदोपनिषद्</a>
    </header>
    <main>
      ${mainBodyHtml}
    </main>
    <footer style="margin-top: 40px; border-top: 1px solid #eae6df; padding-top: 15px; font-size: 0.8rem; color: #8c857b; text-align: center;">
      <p>© ${new Date().getFullYear()} Vrindopnishad. Serving the spiritual heritage of Vrindavan.</p>
    </footer>
  </div>
</noscript>`;
      indexHtml = indexHtml.replace(/<noscript>[\s\S]*?<\/noscript>/, newNoscript);

      html = indexHtml;
    }
  } catch (err) {
    console.error('Failed to load and inject index.html template:', err);
  }

  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.setHeader('Cache-Control', 'public, s-maxage=86400, stale-while-revalidate=604800');
  res.status(200).send(html);
}
