#!/usr/bin/env node
/**
 * clean_english_translations.mjs
 * Removes copyrighted English translations, commentary/description details,
 * and strips embedded English sentences from Hindi/content fields.
 * Also removes hindi_text if sanskrit_text is present.
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const dataDir = path.join(__dirname, '../data');
const publicDataDir = path.join(__dirname, '../public/data');

const dbPath = path.join(dataDir, 'brajrasik_hi_full.json');
const saintsPath = path.join(dataDir, 'saints_formatted.json');

// Helper to determine if a string/sentence is primarily English
function stripEnglishSentences(text) {
  if (!text) return "";
  const lines = text.split(/\r?\n/);
  const cleanedLines = lines.map(line => {
    // Split by sentence boundaries, including semicolons and colons
    const sentences = line.split(/(?<=[.!?।॥;:])\s+/);
    const cleanedSentences = sentences.filter(sentence => {
      const trimmed = sentence.trim();
      if (!trimmed) return false;
      const devanagariMatch = trimmed.match(/[\u0900-\u097F]/g) || [];
      // Keep only if it contains at least one Devanagari character
      return devanagariMatch.length > 0;
    });
    return cleanedSentences.join(" ");
  }).filter(line => line.trim().length > 0);
  return cleanedLines.join("\n");
}

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

function cleanDatabase() {
  console.log('🔄 Starting data cleaning...');

  if (!fs.existsSync(dbPath)) {
    console.error(`❌ Main DB file not found at: ${dbPath}`);
    process.exit(1);
  }

  const data = JSON.parse(fs.readFileSync(dbPath, 'utf8'));
  console.log(`Loaded ${data.length} items from main DB.`);

  let dualTextCleanedCount = 0;
  let englishStrippedHindiCount = 0;

  const cleanedData = data.map((item, idx) => {
    let sanskrit = item.sanskrit_text ? item.sanskrit_text.trim() : "";
    let hindi = item.hindi_text ? item.hindi_text.trim() : "";
    let content = item.content_text ? item.content_text.trim() : "";

    // 1. Condition: If BOTH sanskrit_text and hindi_text are present, keep sanskrit_text and remove hindi_text
    if (sanskrit.length > 0 && hindi.length > 0) {
      hindi = "";
      dualTextCleanedCount++;
    }

    // 2. Strip English sentences from hindi_text and content_text
    if (hindi.length > 0) {
      const origHindi = hindi;
      hindi = stripEnglishSentences(hindi);
      if (hindi !== origHindi) {
        englishStrippedHindiCount++;
      }
    }

    if (content.length > 0) {
      content = stripEnglishSentences(content);
    }

    return {
      ...item,
      english_translation: "",
      english_text: "",
      description: "",
      hindi_text: hindi,
      content_text: content
    };
  });

  console.log(`✅ Cleaned English fields and descriptions on all ${cleanedData.length} items.`);
  console.log(`✅ Removed Hindi text on ${dualTextCleanedCount} items where Sanskrit was also present.`);
  console.log(`✅ Stripped embedded English sentences from ${englishStrippedHindiCount} Hindi text fields.`);

  // 3. Write back to data/brajrasik_hi_full.json
  fs.writeFileSync(dbPath, JSON.stringify(cleanedData, null, 2), 'utf8');
  console.log(`💾 Saved cleaned data to: ${dbPath}`);

  // 4. Write back to public/data/content_backup.json
  const backupPath = path.join(publicDataDir, 'content_backup.json');
  fs.writeFileSync(backupPath, JSON.stringify(cleanedData, null, 2), 'utf8');
  console.log(`💾 Saved cleaned backup to: ${backupPath}`);

  // 5. Split and write category backup files
  const categories = ['shloka', 'strotra', 'poem', 'dham'];
  categories.forEach(cat => {
    const catFile = path.join(publicDataDir, `content_backup_${cat}.json`);
    const catVerses = cleanedData.filter(v => classifyItemCategory(v) === cat);
    fs.writeFileSync(catFile, JSON.stringify(catVerses, null, 2), 'utf8');
    console.log(`💾 Saved split file (${cat}) with ${catVerses.length} items to: ${catFile}`);
  });

  // 6. Clean saints_formatted.json
  if (fs.existsSync(saintsPath)) {
    const saints = JSON.parse(fs.readFileSync(saintsPath, 'utf8'));
    const cleanedSaints = saints.map(s => ({
      ...s,
      english_translation: "",
      description: ""
    }));
    fs.writeFileSync(saintsPath, JSON.stringify(cleanedSaints, null, 2), 'utf8');
    console.log(`💾 Cleaned and saved saints_formatted.json`);

    // Write content_backup_saint.json
    const saintBackupPath = path.join(publicDataDir, 'content_backup_saint.json');
    const saintBackupVerses = cleanedSaints.map((s, idx) => ({
      id: s.id || `saint-local-${idx}`,
      category: 'saint',
      ...s
    }));
    fs.writeFileSync(saintBackupPath, JSON.stringify(saintBackupVerses, null, 2), 'utf8');
    console.log(`💾 Saved content_backup_saint.json with ${saintBackupVerses.length} items.`);
  }

  console.log('🎉 Cleanup complete!');
}

cleanDatabase();
