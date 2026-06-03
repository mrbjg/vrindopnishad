const fs = require('fs');
const path = require('path');

const cachePath = path.join(__dirname, '../data/processed_cache.json');
const cacheData = JSON.parse(fs.readFileSync(cachePath, 'utf8'));
const verses = cacheData.verses || [];

const targetSlug = 'ansbhuja-diyain-aavat-jamuna-teer-shri-roop-manjari';
const item = verses.find(v => v.slug === targetSlug);

if (item) {
  console.log('Found item in cache:');
  console.log(JSON.stringify(item, null, 2));
} else {
  console.log('Item not found for slug:', targetSlug);
}
