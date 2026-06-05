import { writeFileSync, readFileSync, mkdirSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { initializeApp } from "firebase/app";
import { getDataConnect } from "firebase/data-connect";
import { connectorConfig, listAllContent } from "../src/lib/dataconnect/esm/index.esm.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const firebaseConfig = {
    apiKey: "AIzaSyBV89ziohwoKmshLiZLxKm5JnbVPrYWL_o",
    authDomain: "santvaanig.firebaseapp.com",
    projectId: "santvaanig",
    storageBucket: "santvaanig.firebasestorage.app",
    messagingSenderId: "1027361942428",
    appId: "1:1027361942428:web:c71feffde5f3567853b659",
    databaseURL: "https://santvaanig-default-rtdb.asia-southeast1.firebasedatabase.app"
};

const app = initializeApp(firebaseConfig);
const dataConnect = getDataConnect(app, connectorConfig);

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

async function run() {
  console.log("📡 Fetching all content from Firebase Data Connect...");
  try {
    const response = await listAllContent(dataConnect, { limit: 25000 });
    if (!response || !response.data || !response.data.contents) {
      throw new Error("Invalid response structure from Data Connect");
    }
    
    const contents = response.data.contents;
    console.log(`✅ Fetched ${contents.length} items from database.`);
    
    // Map camelCase fields to snake_case for compatibility with local cache logic
    const mapped = contents.map(item => ({
      id: item.id,
      title: item.title,
      sanskrit_text: item.sanskritText || '',
      hindi_text: item.hindiText || '',
      english_text: item.englishText || '',
      english_translation: item.englishTranslation || '',
      category: item.category || 'poem',
      description: item.description || '',
      content_text: item.contentText || '',
      tags: item.tags || [],
      status: (item.status || 'PUBLISHED').toLowerCase(),
      author: item.author || '',
      media_links: item.mediaLinks || [],
      audio_url: item.audioUrl || '',
      image_urls: item.imageUrls || [],
      video_urls: item.videoUrls || [],
      slug: item.slug,
      created_at: item.createdAt,
      updated_at: item.updatedAt
    }));

    const dataDir = join(__dirname, '../data');
    if (!existsSync(dataDir)) {
      mkdirSync(dataDir, { recursive: true });
    }
    
    // 1. Write the main local hi_full file
    const targetPath = join(dataDir, 'brajrasik_hi_full.json');
    writeFileSync(targetPath, JSON.stringify(mapped, null, 2), 'utf8');
    console.log(`💾 Saved ${mapped.length} mapped items to ${targetPath}`);

    // 2. Write the processed_cache.json file used by contentData.js
    const saintsPath = join(dataDir, 'saints_formatted.json');
    let rawSaints = [];
    if (existsSync(saintsPath)) {
      try {
        rawSaints = JSON.parse(readFileSync(saintsPath, 'utf8'));
      } catch (e) {
        console.warn("⚠️ Failed to parse saints_formatted.json:", e.message);
      }
    }
    const processedCachePath = join(dataDir, 'processed_cache.json');
    writeFileSync(processedCachePath, JSON.stringify({
      verses: mapped,
      saintsRaw: rawSaints
    }, null, 2), 'utf8');
    console.log(`💾 Saved flat cache to ${processedCachePath}`);

    // 3. Write public/data backup files
    const publicDataDir = join(__dirname, '../public/data');
    if (!existsSync(publicDataDir)) {
      mkdirSync(publicDataDir, { recursive: true });
    }

    const backupFile = join(publicDataDir, 'content_backup.json');
    writeFileSync(backupFile, JSON.stringify(mapped, null, 2), 'utf8');
    console.log(`💾 Saved backup to ${backupFile}`);

    // 4. Split and write category-specific files
    const categories = ['shloka', 'strotra', 'poem', 'saint', 'dham'];
    categories.forEach(cat => {
      const catFile = join(publicDataDir, `content_backup_${cat}.json`);
      let catVerses = [];
      if (cat === 'saint') {
        catVerses = rawSaints.map((s, idx) => ({
          id: s.id || `saint-local-${idx}`,
          ...s,
          category: 'saint'
        }));
      } else {
        catVerses = mapped.filter(v => classifyItemCategory(v) === cat);
      }
      writeFileSync(catFile, JSON.stringify(catVerses, null, 2), 'utf8');
      console.log(`💾 Saved category split (${cat}) with ${catVerses.length} items to ${catFile}`);
    });

  } catch (err) {
    console.error("❌ Failed to fetch from Firebase Data Connect:", err.message);
    process.exit(1);
  }
}

run();
