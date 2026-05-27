/**
 * Vercel Serverless Function: Unified Dynamic Meta Tag & Content Injector (SEO Handler)
 * 
 * Serves fully populated HTML with unique titles, meta tags, and readable plain-text
 * content to search engines and crawler bots, solving indexation issues (Soft 404s,
 * duplicates without canonicals, crawled not indexed) in client-side React SPAs.
 * 
 * Cached aggressively at the Vercel Edge Network CDN (s-maxage=86400 / 24 hours).
 */

const SUPABASE_URL = process.env.REACT_APP_SUPABASE_URL || 'https://tilimltxgeucefxzerqi.supabase.co';
const SUPABASE_KEY = process.env.REACT_APP_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpbGltbHR4Z2V1Y2VmeHplcnFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2MjQyNTQsImV4cCI6MjA4MzIwMDI1NH0.lwaCJyTRW6jNsfQJ32R_wAwp11yj6bvsJ4fzC0EX_00';
const DOMAIN = 'https://path.vrindopnishad.in';

// Devanagari to Hinglish Phonetic Map for SEO Slugs
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
      body: '<h1>Core Teachings of Vrindopnishad</h1><p>The teachings of Vrindopnishad offer a practical roadmap for spiritual awakening in the modern world. The foremost teaching is the cultivation of Nama Japa (chanting the holy names of God) as the most effective means of purification and mental stabilization. The teachings instruct seekers to practice humility, respect all living beings, and avoid the pride of material acquisition.</p><p>A key teaching is Sadhu Sanga — keeping the company of saintly, selfless individuals whose presence naturally elevates one\'s consciousness. Seekers are encouraged to perform Swadhyaya (daily reading of sacred verses), dedicate their work to the divine, and live a life of simple, mindful devotion. The teachings emphasize that the divine is accessed not through wealth or power, but through a clean, loving heart.</p><p>By reading the commentary provided on the platform, seekers learn to recognize the presence of the divine in all of creation. This awareness fosters compassion, inner peace, and a sense of responsibility toward the environment and society. The teachings are not passive doctrines but living invitations to transform one\'s character and experience the bliss of divine connection.</p>'
    },
    hi: {
      title: 'वृंदोपनिषद् की मुख्य शिक्षाएँ — जीवन बदलने वाले उपदेश',
      description: 'ब्रज के रसिक आचार्यों और संतों के मुख्य उपदेश। मन की शुद्धि, दैनिक साधना और आध्यात्मिक जीवन जीने के व्यावहारिक नियम।',
      body: '<h1>महत्वपूर्ण शिक्षाएँ</h1><p>वृंदोपनिषद् की शिक्षाएँ हमें आधुनिक जीवन के तनावों के बीच आंतरिक शांति और आनंद से जीने का व्यावहारिक मार्ग दिखाती हैं। इन शिक्षाओं का मूल केंद्र मन की शुद्धि और भगवान के प्रति अनन्य प्रेम है।</p><p>मुख्य शिक्षाओं में सर्वोपरि है — "नाम जप" और "संकीर्तन"। संतों का कथन है कि कलयुग में भगवान का नाम ही सबसे बड़ा सहारा है। इसके अतिरिक्त, साधक को अपने आचरण में परम विनम्रता (तृणादपि सुनीचेन) और सहनशीलता धारण करनी चाहिए। किसी भी जीव को कष्ट न देना और सभी का सम्मान करना साधना की पहली सीढ़ी है।</p><p>"साधु संग" अर्थात सत्संगति को सबसे अधिक बल दिया गया है, क्योंकि संतों के विचारों के प्रभाव से ही मन में अच्छे संस्कार जाग्रत होते हैं। प्रतिदिन पवित्र ग्रंथों का स्वाध्याय (स्वाध्याय) करना और अपने दैनिक कार्यों को निष्काम भाव से भगवान को समर्पित करना इसकी प्रमुख व्यावहारिक शिक्षाएँ हैं।</p>'
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

  // FAQ structured data definitions
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

  // 1. Fetch content index from Supabase (with image_url)
  let allContentItems = [];
  try {
    const PAGE_SIZE = 1000;
    let offset = 0;
    let hasMore = true;

    while (hasMore) {
      const response = await fetch(
        `${SUPABASE_URL}/rest/v1/content?select=id,title,slug,category,author,hindi_text,sanskrit_text,image_url&order=id&offset=${offset}&limit=${PAGE_SIZE}`,
        {
          headers: {
            'apikey': SUPABASE_KEY,
            'Authorization': `Bearer ${SUPABASE_KEY}`
          }
        }
      );
      const items = await response.json();

      if (Array.isArray(items) && items.length > 0) {
        allContentItems = allContentItems.concat(items);
        offset += PAGE_SIZE;
        hasMore = items.length === PAGE_SIZE;
      } else {
        hasMore = false;
      }
    }
  } catch (e) {
    console.error('Supabase fetch failed:', e.message);
  }

  // Extract relationships
  const { sants, books, ragas } = extractRelations(allContentItems);

  // Helper to build links matching the active language route
  const getRouteLink = (path) => {
    return DOMAIN + (isHindiRoute ? '/hi' : '') + path;
  };

  // 2. Render route content based on requested type
  if (type === 'content' && slug) {
    // Dynamic Verse Detail page — fuzzy slug matching for Devanagari/transliterated slugs
    const decodedSlug = decodeURIComponent(slug);
    const transliteratedSlug = slugify(transliterate(decodedSlug));
    const lowerSlug = decodedSlug.toLowerCase();
    const content = allContentItems.find(item => {
      const s = item.slug || '';
      if (s === decodedSlug) return true;
      if (s === lowerSlug) return true;
      if (s.toLowerCase() === lowerSlug) return true;
      if (transliteratedSlug && s === transliteratedSlug) return true;
      if (transliteratedSlug && s.toLowerCase() === transliteratedSlug) return true;
      if (item.id?.toString() === decodedSlug) return true;
      
      // Fallback to derived slug from title
      const genSlug = generateSlug(item.title);
      if (genSlug && genSlug === decodedSlug) return true;
      if (genSlug && genSlug.toLowerCase() === decodedSlug.toLowerCase()) return true;
      if (genSlug && transliteratedSlug && genSlug === transliteratedSlug) return true;
      return false;
    });
    
    if (content) {
      // Fetch full details for this specific content item dynamically (with image_url)
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

      const canonicalSlug = encodeURIComponent(fullContent.slug || fullContent.id);
      title = isHindiRoute
        ? `${fullContent.title} — ${fullContent.category || 'पवित्र पाठ'} | ${fullContent.author || 'वृंदोपनिषद्'}`
        : `${fullContent.title} — ${fullContent.category || 'Sacred Verse'} | ${fullContent.author || 'Vrindopnishad'}`;
      
      const categoryLabel = isHindiRoute ? (fullContent.category || 'पवित्र पाठ') : (fullContent.category || 'Sacred Verse');
      const authorLabel = fullContent.author && fullContent.author !== 'Braj Rasik Heritage' ? fullContent.author : (isHindiRoute ? 'वैष्णव संत' : 'Vaishnava Saint');
      
      description = isHindiRoute
        ? `पढ़ें और समझें ${fullContent.title}, एक पवित्र ${categoryLabel} जो कि ${authorLabel} द्वारा रचित है। इसका संस्कृत मूल पाठ, हिंदी भावार्थ और व्याख्या यहाँ उपलब्ध है।`
        : `Read and explore ${fullContent.title}, a sacred ${categoryLabel} written by ${authorLabel}. Access the original Sanskrit shloka, Hindi translation, and English commentary.`;
      
      pageUrl = getRouteLink(`/content/${canonicalSlug}`);

      if (fullContent.image_url) {
        ogImageUrl = fullContent.image_url;
      }

      jsonLd = JSON.stringify({
        "@context": "https://schema.org",
        "@graph": [
          {
            "@type": "ScholarlyArticle",
            "@id": `${pageUrl}/#article`,
            "headline": fullContent.title,
            "description": description,
            "image": ogImageUrl,
            "author": { 
              "@type": "Person", 
              "name": authorLabel 
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
            "inLanguage": ["sa", "hi", "en"],
            "genre": fullContent.category || "Sacred Literature",
            "datePublished": fullContent.created_at || today
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
                "name": isHindiRoute ? "सभी पाठ" : "All Content",
                "item": getRouteLink('/content')
              },
              {
                "@type": "ListItem",
                "position": 3,
                "name": fullContent.title,
                "item": pageUrl
              }
            ]
          }
        ]
      });

      const transliteratedSanskrit = fullContent.sanskrit_text ? transliterate(fullContent.sanskrit_text) : "";
      const transliteratedHindi = fullContent.hindi_text ? transliterate(fullContent.hindi_text) : "";

      mainBodyHtml = `
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
      // Proper 404 HTML response — prevents GSC soft-404/redirect misclassification
      res.setHeader('Content-Type', 'text/html; charset=utf-8');
      res.status(404).send(`<!doctype html><html lang="hi"><head><meta charset="utf-8"/><title>Content Not Found — Vrindopnishad</title><meta name="robots" content="noindex"/></head><body style="font-family:sans-serif;text-align:center;padding:60px 20px;"><h1>404 — Content Not Found</h1><p>The requested verse could not be located.</p><p><a href="${DOMAIN}/content">Browse All Sacred Content →</a></p></body></html>`);
      return;
    }

  } else if (type === 'saint' && slug) {
    // Dynamic Saint Detail page
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
      title = isHindiRoute
        ? `${santName} की जीवनी, ग्रन्थ एवं सम्पूर्ण वाणी संग्रह | वृंदोपनिषद्`
        : `${santHinglish} Biography, Granthas & Complete Vaanis | Vrindopnishad`;
        
      const bioSnippet = sant.biography?.text ? sant.biography.text.substring(0, 150) : "";
      description = isHindiRoute
        ? `महान वैष्णव संत ${santName} का जीवन चरित्र, इतिहास, उनके द्वारा रचित ग्रन्थ और वाणी पदों का भावार्थ सहित संग्रह। ${bioSnippet}`
        : `Explore the life history, spiritual teachings, and complete collection of verses written by the revered Vaishnava saint ${santHinglish}. ${bioSnippet}`;
      
      pageUrl = getRouteLink(`/saint/${encodeURIComponent(sant.slug || slug)}`);

      if (sant.imageUrl) {
        ogImageUrl = sant.imageUrl;
      }

      jsonLd = JSON.stringify({
        "@context": "https://schema.org",
        "@graph": [
          {
            "@type": "Person",
            "@id": `${pageUrl}/#person`,
            "name": santName,
            "alternateName": santHinglish !== santName ? santHinglish : undefined,
            "description": sant.biography?.text ? sant.biography.text.substring(0, 200) : description,
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
          }
        ]
      });

      mainBodyHtml = `
        <h1>${escapeHtml(sant.name)}</h1>
        <h2>${isHindiRoute ? 'जीवनी एवं भक्ति इतिहास' : 'Biography & Devotional History'}</h2>
        <div style="background: #fdfdfd; padding: 20px; border-left: 4px solid #f2a60d; margin: 20px 0;">
          <p style="white-space: pre-wrap; line-height: 1.7;">${escapeHtml(sant.biography?.text || (isHindiRoute ? 'ब्रज परंपरा के वैष्णव संत।' : 'Vaishnava saint of the Braj tradition.'))}</p>
        </div>
        ${sant.books.length > 0 ? `
          <h2>${isHindiRoute ? 'मुख्य ग्रन्थ एवं साहित्य' : 'Major Granthas & Literature'}</h2>
          <ul>
            ${sant.books.map(book => `<li><a href="${getRouteLink(`/book/${slugify(transliterate(book))}`)}">${escapeHtml(book)}</a></li>`).join('')}
          </ul>
        ` : ''}
        <h2>${isHindiRoute ? 'संकलित पद एवं वाणियाँ' : 'Collected Verses & Vaanis'} (${sant.verses.length})</h2>
        <ul>
          ${sant.verses.map(v => `<li><a href="${getRouteLink(`/content/${v.slug || v.id}`)}">${escapeHtml(v.title)}</a></li>`).join('')}
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

  } else if (type === 'book' && slug) {
    // Dynamic Book Detail page
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

      mainBodyHtml = `
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
      res.status(404).send(`<!doctype html><html lang="hi"><head><meta charset="utf-8"/><title>Book Not Found — Vrindopnishad</title><meta name="robots" content="noindex"/></head><body style="font-family:sans-serif;text-align:center;padding:60px 20px;"><h1>404 — Book Not Found</h1><p><a href="${DOMAIN}/books">Browse All Books →</a></p></body></html>`);
      return;
    }

  } else if (type === 'raga' && slug) {
    // Dynamic Raga Detail page
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

      mainBodyHtml = `
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
    // Category page
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
    // Static page lookup
    const decodedSlug = decodeURIComponent(slug);
    const staticPageData = STATIC_SEO_PAGES[decodedSlug];

    if (staticPageData) {
      const staticPage = isHindiRoute ? (staticPageData.hi || staticPageData.en) : (staticPageData.en || staticPageData.hi);
      title = staticPage.title;
      description = staticPage.description;
      pageUrl = getRouteLink(`/${decodedSlug}`);

      mainBodyHtml = `
        <article>
          ${staticPage.body}
        </article>
      `;

      // Schemas for static pages
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
        const pageName = title.split('—')[0].trim();
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
      // Fallback list pages
      let listName = "";
      if (decodedSlug === 'saints') {
        title = isHindiRoute ? `रसिक सन्त एवं चरित्र (Rasik Saints & Biographies) | Vrindopnishad` : `Vaishnava Rasik Saints & Biographies | Vrindopnishad`;
        description = isHindiRoute ? `ब्रज के महान रसिक संतों की जीवनी, इतिहास और उनके वाणी पदों का संग्रह पढ़ें।` : `Learn about the lives, teachings, and spiritual literature of the Rasik saints of Vrindavan, Barsana, and Braj.`;
        pageUrl = getRouteLink('/saints');
        listName = isHindiRoute ? "वैष्णव रसिक संत" : "Vaishnava Rasik Saints";
        mainBodyHtml = `
          <h1>${isHindiRoute ? 'वैष्णव रसिक संत' : 'Vaishnava Rasik Saints'}</h1>
          <p>${isHindiRoute ? 'वृंदावन और ब्रज के संतों की विस्तृत जीवनी और उनके पद।' : 'Read detailed biographies and collected works of Vrindavan saints.'}</p>
          <ul>
            ${sants.map(s => `<li><a href="${getRouteLink(`/saint/${s.slug}`)}">${escapeHtml(s.name)}</a></li>`).join('')}
          </ul>
        `;
      } else if (decodedSlug === 'books') {
        title = isHindiRoute ? `पवित्र ग्रन्थ एवं वाणी साहित्य (Sacred Scriptures & Literature) | Vrindopnishad` : `Sacred Scriptures & Literature | Vrindopnishad`;
        description = isHindiRoute ? `पवित्र वैष्णव ग्रंथों, वाणियों और साहित्यों के डिजिटल संस्करण पढ़ें।` : `Browse and read the digital editions of sacred Vaishnava granthas, vanis, and spiritual scriptures.`;
        pageUrl = getRouteLink('/books');
        listName = isHindiRoute ? "पवित्र ग्रन्थ" : "Sacred Granthas";
        mainBodyHtml = `
          <h1>${isHindiRoute ? 'पवित्र ग्रन्थ साहित्य' : 'Sacred Granthas'}</h1>
          <p>${isHindiRoute ? 'वैष्णव संप्रदाय के पवित्र शास्त्रों और ग्रंथों के भावार्थ।' : 'Browse digital editions of Vaishnava sacred scriptures.'}</p>
          <ul>
            ${books.map(b => `<li><a href="${getRouteLink(`/book/${b.slug}`)}">${escapeHtml(b.name)}</a></li>`).join('')}
          </ul>
        `;
      } else if (decodedSlug === 'ragas') {
        title = isHindiRoute ? `शास्त्रीय राग एवं कीर्तन राग (Vaishnava Raga Registry) | Vrindopnishad` : `Vaishnava Raga Registry | Vrindopnishad`;
        description = isHindiRoute ? `शास्त्रीय रागों में रचित संकीर्तन पद और भजनों का राग-अनुसार संग्रह।` : `Explore devotional songs and verses organized by their classical raag melodies.`;
        pageUrl = getRouteLink('/ragas');
        listName = isHindiRoute ? "शास्त्रीय देवभक्ति राग" : "Vaishnava Ragas";
        mainBodyHtml = `
          <h1>${isHindiRoute ? 'देवभक्ति शास्त्रीय राग' : 'Devotional Classical Ragas'}</h1>
          <p>${isHindiRoute ? 'रागों के आधार पर वर्गीकृत पद और संकीर्तन संग्रह।' : 'Explore verses and hymns classified by raag.'}</p>
          <ul>
            ${ragas.map(r => `<li><a href="${getRouteLink(`/raga/${r.slug}`)}">${escapeHtml(r.name)}</a></li>`).join('')}
          </ul>
        `;
      } else if (decodedSlug === 'content') {
        title = isHindiRoute ? `वृंदोपनिषद् पाठ लाइब्रेरी (Browse All Sacred Content) | Vrindopnishad` : `Vrindopnishad Paath Library (Browse All Sacred Content) | Vrindopnishad`;
        description = isHindiRoute ? `संस्कृत श्लोकों, स्तोत्रों, भजनों, और आध्यात्मिक कविताओं की संपूर्ण लाइब्रेरी।` : `Access the complete index of shlokas, strotras, bhajans, kirtans, and spiritual poetry.`;
        pageUrl = getRouteLink('/content');
        listName = isHindiRoute ? "सभी संकलित पाठ" : "All Sacred Verses";
        mainBodyHtml = `
          <h1>${isHindiRoute ? 'सभी संकलित पाठ एवं श्लोक' : 'All Sacred Verses & Content'}</h1>
          <ul>
            ${allContentItems.map(item => `<li><a href="${getRouteLink(`/content/${item.slug || item.id}`)}">${escapeHtml(item.title)}</a></li>`).join('')}
          </ul>
        `;
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
    // Default: Home Page
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

  // Build hreflang alternate URLs
  const currentPath = pageUrl.replace(DOMAIN, '');
  const isHi = currentPath.startsWith('/hi');
  const cleanPath = isHi ? (currentPath.replace(/^\/hi/, '') || '/') : currentPath;
  const enUrl = DOMAIN + cleanPath;
  const hiUrl = DOMAIN + '/hi' + (cleanPath === '/' ? '' : cleanPath);

  // Build the final complete pre-rendered HTML payload
  const html = `<!doctype html>
<html lang="hi" dir="ltr">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=0,viewport-fit=cover"/>
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
  <link rel="icon" href="https://vrindopnishad.in/favicon.ico" sizes="48x48"/>
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

  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.setHeader('Cache-Control', 'public, s-maxage=86400, stale-while-revalidate=604800');
  res.status(200).send(html);
}
