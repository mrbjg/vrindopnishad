import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Paths
const originalDbPath = path.join(__dirname, '../data/vrindavaani_content.original.json');
const targetDbPath = path.join(__dirname, '../data/vrindavaani_content.json');
const cachePath = path.join(__dirname, '../data/paraphrase_cache.json');
const backupsDir = path.join(__dirname, '../public/data');

// Concurrency settings
const CONCURRENCY = 40;
const RETRIES = 3;
const RETRY_DELAY = 2000;

// Google Translate Helper
async function translateText(text, fromLang, toLang) {
  if (!text || !text.trim()) return "";
  const url = `https://translate.googleapis.com/translate_a/single?client=gtx&sl=${fromLang}&tl=${toLang}&dt=t&q=${encodeURIComponent(text)}`;
  const res = await fetch(url);
  if (!res.ok) throw new Error(`HTTP error ${res.status}`);
  const result = await res.json();
  return result[0].map(item => item[0]).join('');
}

async function translateWithRetry(text, fromLang, toLang) {
  for (let i = 0; i < RETRIES; i++) {
    try {
      return await translateText(text, fromLang, toLang);
    } catch (err) {
      if (i === RETRIES - 1) throw err;
      console.warn(`[Translate] Request failed (Attempt ${i+1}/${RETRIES}). Retrying in ${RETRY_DELAY}ms...`);
      await new Promise(resolve => setTimeout(resolve, RETRY_DELAY));
    }
  }
}

// Paraphrase Helpers
async function paraphraseHindi(text) {
  try {
    const englishText = await translateWithRetry(text, 'hi', 'en');
    const paraphrasedHindi = await translateWithRetry(englishText, 'en', 'hi');
    return paraphrasedHindi;
  } catch (err) {
    console.error("[Paraphrase] Failed to paraphrase Hindi meaning:", err.message);
    return text; // Fallback to original
  }
}

async function paraphraseEnglish(text) {
  try {
    const hindiText = await translateWithRetry(text, 'en', 'hi');
    const paraphrasedEnglish = await translateWithRetry(hindiText, 'hi', 'en');
    return paraphrasedEnglish;
  } catch (err) {
    console.error("[Paraphrase] Failed to paraphrase English translation:", err.message);
    return text; // Fallback to original
  }
}

// Main Execution
async function main() {
  if (!fs.existsSync(originalDbPath)) {
    console.error("Original database file not found at:", originalDbPath);
    process.exit(1);
  }

  const originalData = JSON.parse(fs.readFileSync(originalDbPath, 'utf8'));
  console.log(`Loaded ${originalData.length} items from original database.`);

  let cache = {};
  if (fs.existsSync(cachePath)) {
    cache = JSON.parse(fs.readFileSync(cachePath, 'utf8'));
    console.log(`Resuming from cache with ${Object.keys(cache).length} processed items.`);
  }

  const total = originalData.length;
  let processedCount = Object.keys(cache).length;
  let batch = [];

  for (let i = 0; i < total; i++) {
    const item = originalData[i];
    if (cache[item.id]) {
      continue;
    }

    batch.push((async () => {
      let updatedItem = { ...item };
      
      // Clean description completely
      updatedItem.description = "";

      // Paraphrase Hindi Meaning
      if (item.hindi_text && item.hindi_text.trim()) {
        updatedItem.hindi_text = await paraphraseHindi(item.hindi_text);
      }

      // Paraphrase English Translation
      if (item.english_translation && item.english_translation.trim()) {
        updatedItem.english_translation = await paraphraseEnglish(item.english_translation);
        updatedItem.english_text = updatedItem.english_translation;
      }

      cache[item.id] = updatedItem;
      processedCount++;

      if (processedCount % 10 === 0 || processedCount === total) {
        console.log(`Progress: ${processedCount}/${total} items paraphrased...`);
      }
    })());

    if (batch.length >= CONCURRENCY || i === total - 1) {
      await Promise.all(batch);
      batch = [];
      // Save cache progress to disk periodically
      fs.writeFileSync(cachePath, JSON.stringify(cache, null, 2), 'utf8');
      // Sleep a bit to avoid hammering Google Translate
      await new Promise(resolve => setTimeout(resolve, 50));
    }
  }

  // Compile final clean database
  const finalData = originalData.map(item => cache[item.id] || item);
  fs.writeFileSync(targetDbPath, JSON.stringify(finalData, null, 2), 'utf8');
  console.log("Database successfully paraphrased and saved.");

  // Generate clean backups
  console.log("Generating clean backups in public/data...");
  if (!fs.existsSync(backupsDir)) {
    fs.mkdirSync(backupsDir, { recursive: true });
  }

  // Helper classification function
  function classifyItemCategory(item) {
    const title = (item.title || '').toLowerCase();
    const sanskrit = (item.sanskrit_text || '').toLowerCase();
    const rawCat = (item.category || '').toLowerCase();

    if (rawCat === 'shloka' || rawCat === 'strotra' || rawCat === 'poem' || rawCat === 'saint' || rawCat === 'dham') {
      return rawCat;
    }
    
    if (
      title.includes('strotra') || title.includes('stotra') || title.includes('स्तोत्र') ||
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

  // 1. Save main content_backup.json
  const mainBackupPath = path.join(backupsDir, 'content_backup.json');
  fs.writeFileSync(mainBackupPath, JSON.stringify(finalData, null, 2), 'utf8');
  console.log("Saved content_backup.json");

  // 2. Save category content backups
  const categories = ['shloka', 'strotra', 'poem', 'saint', 'dham'];
  categories.forEach(cat => {
    const catVerses = finalData.filter(v => classifyItemCategory(v) === cat);
    const catPath = path.join(backupsDir, `content_backup_${cat}.json`);
    fs.writeFileSync(catPath, JSON.stringify(catVerses, null, 2), 'utf8');
    console.log(`Saved content_backup_${cat}.json (${catVerses.length} items)`);
  });

  // Clean cache file
  try {
    fs.unlinkSync(cachePath);
  } catch (e) {}

  console.log("Backup files generation complete.");
  process.exit(0);
}

main().catch(err => {
  console.error("Critical error in main loop:", err);
  process.exit(1);
});
