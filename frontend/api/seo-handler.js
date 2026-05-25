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
        text: item.hindi_text || item.description || ''
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
          verses: []
        };
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
          verses: []
        };
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
    title: 'What is Vrindopnishad? — Definition & Core Concept | वृंदोपनिषद् क्या है',
    description: 'Learn about Vrindopnishad. Understand what this sacred digital platform represents, its vision, and how it connects tradition with modern tech.',
    body: '<h1>What is Vrindopnishad?</h1><p>Vrindopnishad is a digital sanctuary dedicated to the preservation and dissemination of Vaishnava literature, Sanskrit shlokas, and the direct teachings of Braj Rasik saints. By uniting the pastoral devotion of Vrindavan (Vrinda) with the high philosophical inquiry of the Upanishads, Vrindopnishad offers a comprehensive, interactive knowledge hub for spiritual seekers worldwide.'
  },
  'meaning': {
    title: 'Meaning of Vrindopnishad — Etymology & Spiritual Significance | वृंदोपनिषद् अर्थ',
    description: 'Explore the profound meaning of Vrindopnishad. Understand the Sanskrit etymology, spiritual symbolism, and deeper significance behind this sacred name.',
    body: '<h1>Meaning of Vrindopnishad (वृंदोपनिषद्)</h1><p>The word "Vrindopnishad" is a Sanskrit compound uniting "Vrinda" (sacred groves of Tulsi in Vrindavan) and "Upanishad" (esoteric wisdom received at the feet of a master). Thus, it translates to "the sacred, confidential wisdom flowing from Vrindavan." It represents the synthesis of scriptural knowledge (Jnana) and divine emotional attachment (Bhakti).</p>'
  },
  'origin': {
    title: 'Origin & History of Vrindopnishad — Scriptural Roots | वृंदोपनिषद् इतिहास',
    description: 'Trace the origin and scriptural history of the teachings found in Vrindopnishad. Learn how these sacred texts have been preserved over generations.',
    body: '<h1>Origin & History</h1><p>The teachings of Vrindopnishad originate from the eternal Ras Lila of Shri Radha Krishna in Braj Dham. Over centuries, these confidential spiritual traditions were systematized by the Six Goswamis of Vrindavan (Rupa Goswami, Sanatana Goswami, etc.) and carried forward by Braj Rasik saints including Swami Haridas and Hit Harivansh Mahaprabhu.</p>'
  },
  'philosophy': {
    title: 'Philosophy of Vrindopnishad — Achintya Bheda Abheda & Bhakti | दर्शन',
    description: 'Dive deep into the theological philosophy of Vrindopnishad. Explore concepts of divine love (Raganuga Bhakti) and relationships of the self.',
    body: '<h1>Spiritual Philosophy</h1><p>The core philosophy of Vrindopnishad centers on Raganuga Bhakti (spontaneous loving devotion) and Achintya Bheda Abheda (inconceivable simultaneous oneness and difference). It explains that the ultimate goal of the soul is to participate in the eternal loving service of the Divine Couple in Nitya Vrindavan.</p>'
  },
  'teachings': {
    title: 'Teachings of Vrindopnishad — Wisdom from Rasik Saints | शिक्षाएँ',
    description: 'Discover the core teachings and spiritual guidelines of Vrindopnishad. Practical wisdom and guidance for daily devotion and inner peace.',
    body: '<h1>Core Teachings</h1><p>Vrindopnishad teaches that chanting the divine names (Naam Jap), maintaining the association of saints (Sadhu Sanga), cultivating humility, and reading sacred texts are key to purification. The teachings provide practical instructions for transcending material anxiety through devotion.</p>'
  },
  'importance': {
    title: 'Importance of Vrindopnishad in Modern Times — Spiritual Value | महत्व',
    description: 'Why is Vrindopnishad relevant today? Read about the critical importance of preserving scriptural wisdom in the digital age.',
    body: '<h1>Importance of the Wisdom</h1><p>In our modern fast-paced world, the message of Vrindopnishad serves as a stabilizing, peaceful anchor. It provides the digital age with accessible, authenticated translations of spiritual literature, ensuring that the legacy of the saints remains a living guide for humanity.</p>'
  },
  'devotion': {
    title: 'Devotional Significance (Bhakti Marg) of Vrindopnishad | भक्ति',
    description: 'Explore the path of devotion (Bhakti) on Vrindopnishad. Learn how reciting shlokas and contemplation can evoke divine consciousness.',
    body: '<h1>The Path of Devotion</h1><p>Bhakti, or pure devotion, is the heart of the Vrindopnishad collection. Unlike paths based on austere meditation or ritual work, Bhakti values love and emotional relationship with the Divine. It emphasizes the recitation of sweet kirtans and meditative chanting.</p>'
  },
  'faq': {
    title: 'FAQ — Frequently Asked Questions about Vrindopnishad | प्रश्नोत्तर',
    description: 'Find answers to common questions about Vrindopnishad, Vaishnavism, spiritual practice, and the authenticity of our texts.',
    body: '<h1>Frequently Asked Questions</h1><h3>What is the source of the texts?</h3><p>All verses and biographies are compiled from authorized Vaishnava publications and original palm-leaf transcripts stored in Vrindavan.</p><h3>How can I practice daily?</h3><p>You can engage in daily Japa chanting using our digital sanctuary dashboard and read one verse (Swadhyaya) every morning.</p>'
  },
  'comparison-with-upanishads': {
    title: 'Comparison of Vrindopnishad with Classical Upanishads | तुलना',
    description: 'How does Vrindopnishad compare to principal Vedic Upanishads? Read a detailed comparative study of theology and methods.',
    body: '<h1>Comparison with Upanishads</h1><p>While classical Upanishads focus primarily on the formless aspect of truth (Nirguna Brahman) and absolute liberation (Mukti), Vrindopnishad focuses on the personal aspect of truth (Saguna Brahman) and the bliss of divine pastimes, highlighting that Prema (divine love) surpasses simple liberation.</p>'
  },
  'guide': {
    title: 'Complete Guide to Vrindopnishad — How to Practice | मार्गदर्शिका',
    description: 'A step-by-step seeker\'s guide to utilizing Vrindopnishad for daily paath, meditation, Japa chanting, and spiritual growth.',
    body: '<h1>Spiritual Guide</h1><p>Begin your day with the Swadhyaya widget on our home page. Review the Sanskrit text, contemplate the takeaways, and use the Japa counter to chant the holy names. Focus your awareness on the divine sound vibration to cultivate mental clarity.</p>'
  },
  'braj-rasik-heritage': {
    title: 'Braj Rasik Heritage — The Sacred Tradition of Vrindavan | विरासत',
    description: 'Discover the rich spiritual legacy of the Braj region and Vaishnava Rasik saints. Explore their contributions to kirtan, literature, and art.',
    body: '<h1>Braj Rasik Heritage</h1><p>Braj Rasik Heritage is the spiritual repository of divine songs, literature, poetry, and theology compiled by the rasik saints of Vrindavan. This heritage centers on absolute selflessness, sweet aesthetic devotion, and ecstatic communion with Shri Radha Krishna.</p>'
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

  // 1. Fetch content index from Supabase
  let allContentItems = [];
  try {
    const PAGE_SIZE = 1000;
    let offset = 0;
    let hasMore = true;

    while (hasMore) {
      const response = await fetch(
        `${SUPABASE_URL}/rest/v1/content?select=id,title,slug,category,author,hindi_text,sanskrit_text&order=id&offset=${offset}&limit=${PAGE_SIZE}`,
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
    // Dynamic Verse Detail page
    const decodedSlug = decodeURIComponent(slug);
    const content = allContentItems.find(item => item.slug === decodedSlug || item.id?.toString() === decodedSlug);
    
    if (content) {
      title = `${content.title} — ${content.category || 'Sacred Verse'} | ${content.author || 'Vrindopnishad'}`;
      description = (content.sanskrit_text || content.hindi_text || content.description || '').substring(0, 160).replace(/[\r\n]+/g, ' ') + '...';
      pageUrl = getRouteLink(`/content/${encodeURIComponent(slug)}`);

      jsonLd = JSON.stringify({
        "@context": "https://schema.org",
        "@type": "Article",
        "headline": content.title,
        "description": description,
        "author": { "@type": "Person", "name": content.author || "Vrindopnishad" },
        "publisher": {
          "@type": "Organization",
          "name": "Vrindopnishad",
          "logo": { "@type": "ImageObject", "url": "https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png" }
        },
        "mainEntityOfPage": { "@type": "WebPage", "@id": pageUrl },
        "inLanguage": ["hi", "sa", "en"],
        "genre": content.category || "Sacred Literature",
        "datePublished": content.created_at || today
      });

      mainBodyHtml = `
        <article>
          <h1>${escapeHtml(content.title)}</h1>
          <p><strong>Category:</strong> ${escapeHtml(content.category || 'Sacred Literature')}</p>
          <p><strong>Author/Saint:</strong> ${escapeHtml(content.author || 'Vaishnava Saint')}</p>
          ${content.sanskrit_text ? `<div lang="sa" style="font-size: 1.25rem; margin: 20px 0; font-family: serif;"><h2>Sanskrit Verse</h2><p style="white-space: pre-wrap; line-height: 1.8;">${escapeHtml(content.sanskrit_text)}</p></div>` : ''}
          ${content.hindi_text ? `<div lang="hi" style="margin: 20px 0;"><h2>Hindi Translation</h2><p style="white-space: pre-wrap; line-height: 1.6;">${escapeHtml(content.hindi_text)}</p></div>` : ''}
          ${content.description ? `<div lang="en" style="margin: 20px 0;"><h2>Explanation / Commentary</h2><p>${escapeHtml(content.description)}</p></div>` : ''}
        </article>
      `;
    } else {
      res.status(404).send('Content not found');
      return;
    }

  } else if (type === 'saint' && slug) {
    // Dynamic Saint Detail page
    const decodedSlug = decodeURIComponent(slug);
    const sant = sants.find(s => s.slug === decodedSlug);

    if (sant) {
      title = isHindiRoute ? `${sant.name} जीवनी एवं वाणी संग्रह | Vrindopnishad` : `${sant.hinglishName} Biography & Vaanis | Vrindopnishad`;
      description = sant.biography?.text ? sant.biography.text.substring(0, 160) : `Complete collection of spiritual poetry and hymns written by ${sant.hinglishName}.`;
      pageUrl = getRouteLink(`/saint/${encodeURIComponent(slug)}`);

      mainBodyHtml = `
        <h1>${escapeHtml(sant.name)}</h1>
        <h2>Biography & Devotional History</h2>
        <div style="background: #fdfdfd; padding: 20px; border-left: 4px solid #f2a60d; margin: 20px 0;">
          <p style="white-space: pre-wrap; line-height: 1.7;">${escapeHtml(sant.biography?.text || 'Vaishnava saint of the Braj tradition.')}</p>
        </div>
        ${sant.books.length > 0 ? `
          <h2>Major Granthas & Literature</h2>
          <ul>
            ${sant.books.map(book => `<li><a href="${getRouteLink(`/book/${slugify(transliterate(book))}`)}">${escapeHtml(book)}</a></li>`).join('')}
          </ul>
        ` : ''}
        <h2>Collected Verses & Vaanis (${sant.verses.length})</h2>
        <ul>
          ${sant.verses.map(v => `<li><a href="${getRouteLink(`/content/${v.slug || v.id}`)}">${escapeHtml(v.title)}</a></li>`).join('')}
        </ul>
      `;
    } else {
      res.status(404).send('Saint not found');
      return;
    }

  } else if (type === 'book' && slug) {
    // Dynamic Book Detail page
    const decodedSlug = decodeURIComponent(slug);
    const book = books.find(b => b.slug === decodedSlug);

    if (book) {
      title = `${book.name} ग्रन्थ - वाणी संग्रह एवं हिंदी अनुवाद | Vrindopnishad`;
      description = `Read and contemplate the sacred verses and translations from the grantha ${book.name} written by ${book.author}.`;
      pageUrl = getRouteLink(`/book/${encodeURIComponent(slug)}`);

      mainBodyHtml = `
        <h1>${escapeHtml(book.name)}</h1>
        <p><strong>Author/Authoritative Source:</strong> <a href="${getRouteLink(`/saint/${slugify(transliterate(book.author))}`)}">${escapeHtml(book.author)}</a></p>
        <h2>Verses under this Grantha (${book.verses.length})</h2>
        <ul>
          ${book.verses.map(v => `<li><a href="${getRouteLink(`/content/${v.slug || v.id}`)}">${escapeHtml(v.title)}</a></li>`).join('')}
        </ul>
      `;
    } else {
      res.status(404).send('Book not found');
      return;
    }

  } else if (type === 'raga' && slug) {
    // Dynamic Raga Detail page
    const decodedSlug = decodeURIComponent(slug);
    const raga = ragas.find(r => r.slug === decodedSlug);

    if (raga) {
      title = `राग ${raga.name} के पद एवं संकीर्तन | Vrindopnishad`;
      description = `Explore kirtan, bhajans and verses set to the classical melody of Raga ${raga.name}.`;
      pageUrl = getRouteLink(`/raga/${encodeURIComponent(slug)}`);

      mainBodyHtml = `
        <h1>Raga ${escapeHtml(raga.name)}</h1>
        <p>Classical melody and sankirtan hymns set in Raga ${escapeHtml(raga.name)}.</p>
        <h2>Verses set in this Raga (${raga.verses.length})</h2>
        <ul>
          ${raga.verses.map(v => `<li><a href="${getRouteLink(`/content/${v.slug || v.id}`)}">${escapeHtml(v.title)}</a></li>`).join('')}
        </ul>
      `;
    } else {
      res.status(404).send('Raga not found');
      return;
    }

  } else if (type === 'category' && slug) {
    // Category page
    const decodedSlug = decodeURIComponent(slug).toLowerCase().trim().replace(/\s+/g, '-');
    const filteredVerses = allContentItems.filter(item => item.category?.toLowerCase().trim().replace(/\s+/g, '-') === decodedSlug);
    const categoryTitle = decodedSlug.charAt(0).toUpperCase() + decodedSlug.slice(1);

    title = `${categoryTitle} संग्रह एवं व्याख्या | Vrindopnishad`;
    description = `Read the complete collection of ${categoryTitle} on Vrindopnishad. Text, Hindi translations, and English explanations available.`;
    pageUrl = getRouteLink(`/category/${encodeURIComponent(slug)}`);

    mainBodyHtml = `
      <h1>Category: ${escapeHtml(categoryTitle)}</h1>
      <p>Browse through our collection of sacred verses tagged under ${escapeHtml(categoryTitle)}.</p>
      <h2>Verses (${filteredVerses.length})</h2>
      <ul>
        ${filteredVerses.map(v => `<li><a href="${getRouteLink(`/content/${v.slug || v.id}`)}">${escapeHtml(v.title)}</a></li>`).join('')}
      </ul>
    `;

  } else if (type === 'static' && slug) {
    // Static page lookup
    const decodedSlug = decodeURIComponent(slug);
    const staticPage = STATIC_SEO_PAGES[decodedSlug];

    if (staticPage) {
      title = staticPage.title;
      description = staticPage.description;
      pageUrl = getRouteLink(`/${decodedSlug}`);

      mainBodyHtml = `
        <article>
          ${staticPage.body}
        </article>
      `;
    } else {
      // Fallback list pages
      if (decodedSlug === 'saints') {
        title = `रसिक सन्त एवं चरित्र (Rasik Saints & Biographies) | Vrindopnishad`;
        description = `Learn about the lives, teachings, and spiritual literature of the Rasik saints of Vrindavan, Barsana, and Braj.`;
        pageUrl = getRouteLink('/saints');
        mainBodyHtml = `
          <h1>Vaishnava Rasik Saints</h1>
          <p>Read detailed biographies and collected works of Vrindavan saints.</p>
          <ul>
            ${sants.map(s => `<li><a href="${getRouteLink(`/saint/${s.slug}`)}">${escapeHtml(s.name)}</a></li>`).join('')}
          </ul>
        `;
      } else if (decodedSlug === 'books') {
        title = `पवित्र ग्रन्थ एवं साहित्य (Sacred Scriptures & Literature) | Vrindopnishad`;
        description = `Browse and read the digital editions of sacred Vaishnava granthas, vanis, and spiritual scriptures.`;
        pageUrl = getRouteLink('/books');
        mainBodyHtml = `
          <h1>Sacred Granthas</h1>
          <p>Browse digital editions of Vaishnava sacred scriptures.</p>
          <ul>
            ${books.map(b => `<li><a href="${getRouteLink(`/book/${b.slug}`)}">${escapeHtml(b.name)}</a></li>`).join('')}
          </ul>
        `;
      } else if (decodedSlug === 'ragas') {
        title = `शास्त्रीय राग एवं कीर्तन राग (Vaishnava Raga Registry) | Vrindopnishad`;
        description = `Explore devotional songs and verses organized by their classical raag melodies.`;
        pageUrl = getRouteLink('/ragas');
        mainBodyHtml = `
          <h1>Devotional Classical Ragas</h1>
          <p>Explore verses and hymns classified by raag.</p>
          <ul>
            ${ragas.map(r => `<li><a href="${getRouteLink(`/raga/${r.slug}`)}">${escapeHtml(r.name)}</a></li>`).join('')}
          </ul>
        `;
      } else if (decodedSlug === 'content') {
        title = `वृंदोपनिषद् पाठ लाइब्रेरी (Browse All Sacred Content) | Vrindopnishad`;
        description = `Access the complete index of shlokas, strotras, bhajans, kirtans, and spiritual poetry.`;
        pageUrl = getRouteLink('/content');
        mainBodyHtml = `
          <h1>All Sacred Verses & Content</h1>
          <ul>
            ${allContentItems.map(item => `<li><a href="${getRouteLink(`/content/${item.slug || item.id}`)}">${escapeHtml(item.title)}</a></li>`).join('')}
          </ul>
        `;
      } else {
        res.status(404).send('Page not found');
        return;
      }
    }

  } else {
    // Default: Home Page
    pageUrl = getRouteLink('/');
    title = isHindiRoute ? `वृंदोपनिषद् पाठ | श्लोक, स्तोत्र, और आध्यात्मिक कविता संग्रह` : `Vrindopnishad Paath — वृंदोपनिषद् पाठ | Sacred Shlokas, Strotras & Devotional Poetry`;
    description = `Vrindopnishad Paath (वृंदोपनिषद् पाठ) — Read and listen to sacred Sanskrit shlokas, strotras, devotional poetry and Vedic wisdom from Vrindavan saints. Free online paath in Hindi, Sanskrit and English. भगवद्गीता, मंत्र, श्लोक, स्तोत्र सब यहाँ पढ़ें।`;

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

  // Build the final complete pre-rendered HTML payload
  const html = `<!doctype html>
<html lang="hi" dir="ltr">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=0,viewport-fit=cover"/>
  <title>${title}</title>
  <meta name="description" content="${description}"/>
  <link rel="canonical" href="${pageUrl}"/>
  <meta property="og:type" content="article"/>
  <meta property="og:title" content="${title}"/>
  <meta property="og:description" content="${description}"/>
  <meta property="og:url" content="${pageUrl}"/>
  <meta property="og:image" content="https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png"/>
  <meta property="og:site_name" content="Vrindopnishad Paath — वृंदोपनिषद् पाठ"/>
  <meta property="og:locale" content="hi_IN"/>
  <meta name="twitter:card" content="summary_large_image"/>
  <meta name="twitter:title" content="${title}"/>
  <meta name="twitter:description" content="${description}"/>
  <meta name="twitter:image" content="https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png"/>
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
