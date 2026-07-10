import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { transliterate } from '../src/utils/transliterate.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Paths
const sitemapPath = '/Users/sakhi/.gemini/antigravity-ide/brain/a8bc031e-410f-4ff9-9e87-10e8d6dd4c48/.system_generated/steps/577/content.md';
const dbPath = path.join(__dirname, '../data/brajrasik_hi_full.json');

// 1. Read brajrasik.org sitemap to collect copyrighted slugs
console.log("Reading sitemap...");
const sitemapContent = fs.readFileSync(sitemapPath, 'utf8');
const locRegex = /<loc>(https:\/\/www\.brajrasik\.org\/(?:hi\/)?articles\/[^\/]+\/([^<]+))<\/loc>/g;
const copyrightedSlugs = new Set();
let match;
while ((match = locRegex.exec(sitemapContent)) !== null) {
  copyrightedSlugs.add(match[2].trim().toLowerCase());
}
console.log(`Loaded ${copyrightedSlugs.size} copyrighted slugs from sitemap.`);

// 2. Load our database
console.log("Loading database...");
const localData = JSON.parse(fs.readFileSync(dbPath, 'utf8'));
console.log(`Database loaded: ${localData.length} items.`);

// 3. Process items
let sanitizedCount = 0;
const processedData = localData.map(item => {
  sanitizedCount++;
  
  // Original poetry text (public domain)
  const basePoetry = item.sanskrit_text || item.hindi_text || "";
  
  // Generate clean transliteration for English
  const cleanTransliteration = basePoetry ? transliterate(basePoetry) : "";
  
  return {
    ...item,
    // Strip copyrighted commentaries/descriptions
    description: "",
    // Keep only public domain poetry in sanskrit_text
    sanskrit_text: basePoetry,
    // Replace copyrighted translation with clean transliteration
    english_translation: cleanTransliteration,
    english_text: cleanTransliteration,
    // Remove modern translation/commentary
    hindi_text: ""
  };
});

console.log(`Sanitization complete. Sanitized ${sanitizedCount} items.`);

// 4. Save the updated database
console.log("Saving database...");
fs.writeFileSync(dbPath, JSON.stringify(processedData, null, 2), 'utf8');
console.log("Database saved successfully.");
