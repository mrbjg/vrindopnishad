import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const dbPath = path.join(__dirname, '../data/vrindavaani_content.json');
const cachePath = path.join(__dirname, '../data/hindi_gen_cache.json');
const backupsDir = path.join(__dirname, '../public/data');

const CONCURRENCY = 40;
const RETRIES = 3;
const RETRY_DELAY = 2000;

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
      console.warn(`[Translate] Attempt ${i+1}/${RETRIES} failed. Retrying...`);
      await new Promise(resolve => setTimeout(resolve, RETRY_DELAY));
    }
  }
}

async function main() {
  const data = JSON.parse(fs.readFileSync(dbPath, 'utf8'));
  console.log(`Loaded ${data.length} items.`);

  // Load cache
  let cache = {};
  if (fs.existsSync(cachePath)) {
    cache = JSON.parse(fs.readFileSync(cachePath, 'utf8'));
    console.log(`Resuming from cache with ${Object.keys(cache).length} items.`);
  }

  // Find items needing Hindi text
  const needsHindi = data.filter(item => {
    if (cache[item.id]) return false; // already processed
    const hasHindi = item.hindi_text && item.hindi_text.trim();
    const hasEnglish = item.english_translation && item.english_translation.trim();
    return !hasHindi && hasEnglish;
  });

  console.log(`Items needing Hindi generation: ${needsHindi.length}`);

  let processed = Object.keys(cache).length;
  let batch = [];

  for (let i = 0; i < needsHindi.length; i++) {
    const item = needsHindi[i];

    batch.push((async () => {
      try {
        const hindiText = await translateWithRetry(item.english_translation, 'en', 'hi');
        cache[item.id] = hindiText;
      } catch (err) {
        console.error(`[Error] Failed for ${item.id}: ${err.message}`);
        cache[item.id] = ""; // store empty so we don't retry
      }
      processed++;
      if (processed % 20 === 0) {
        console.log(`Progress: ${processed} items processed...`);
      }
    })());

    if (batch.length >= CONCURRENCY || i === needsHindi.length - 1) {
      await Promise.all(batch);
      batch = [];
      fs.writeFileSync(cachePath, JSON.stringify(cache, null, 2), 'utf8');
      await new Promise(resolve => setTimeout(resolve, 50));
    }
  }

  // Apply generated Hindi text to main database
  console.log("Applying Hindi translations to database...");
  let applied = 0;
  const finalData = data.map(item => {
    const hasHindi = item.hindi_text && item.hindi_text.trim();
    if (!hasHindi && cache[item.id] && cache[item.id].trim()) {
      applied++;
      return { ...item, hindi_text: cache[item.id] };
    }
    return item;
  });

  console.log(`Applied Hindi text to ${applied} items.`);

  // Count final stats
  let withHindi = 0;
  finalData.forEach(item => {
    if (item.hindi_text && item.hindi_text.trim()) withHindi++;
  });
  console.log(`Final: ${withHindi}/${finalData.length} items now have hindi_text.`);

  // Save main database
  fs.writeFileSync(dbPath, JSON.stringify(finalData, null, 2), 'utf8');
  console.log("Saved main database.");

  // Save backups
  console.log("Updating backup files...");
  fs.writeFileSync(path.join(backupsDir, 'content_backup.json'), JSON.stringify(finalData, null, 2), 'utf8');
  console.log("Saved content_backup.json");

  // Clean cache
  try { fs.unlinkSync(cachePath); } catch (e) {}

  console.log("Done! All items now have Hindi text.");
  process.exit(0);
}

main().catch(err => {
  console.error("Critical error:", err);
  process.exit(1);
});
