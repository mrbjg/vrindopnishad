#!/usr/bin/env node
/**
 * sync_cache.mjs
 * Regenerates processed_cache.json from vrindavaani_content.json + saints_formatted.json
 * Run this after ANY modification to the main database file.
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const dataDir = path.join(__dirname, '../data');
const dbPath = path.join(dataDir, 'vrindavaani_content.json');
const saintsPath = path.join(dataDir, 'saints_formatted.json');
const cachePath = path.join(dataDir, 'processed_cache.json');

console.log('[sync_cache] Reading main database...');
const data = JSON.parse(fs.readFileSync(dbPath, 'utf8'));

let saints = [];
if (fs.existsSync(saintsPath)) {
  saints = JSON.parse(fs.readFileSync(saintsPath, 'utf8')).map((s, i) => ({
    id: s.id || `saint-local-${i}`,
    ...s,
    category: 'saint',
    slug: s.slug || ''
  }));
}

const cachePayload = { verses: data, saintsRaw: saints };
fs.writeFileSync(cachePath, JSON.stringify(cachePayload), 'utf8');

const sizeMB = (fs.statSync(cachePath).size / (1024 * 1024)).toFixed(1);
console.log(`[sync_cache] ✅ Regenerated processed_cache.json (${data.length} verses, ${saints.length} saints, ${sizeMB} MB)`);
