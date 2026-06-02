const fs = require('fs');
const cachePath = './data/processed_cache.json';

if (!fs.existsSync(cachePath)) {
  console.log('Cache file does not exist.');
  process.exit(0);
}

const cache = JSON.parse(fs.readFileSync(cachePath, 'utf8'));

if (cache.verses) {
  const verse = cache.verses.find(v => v.slug && v.slug.includes('bani-shriradha-mohan-ki-jori'));
  console.log('Found verse by slug:', verse);
  
  const verseById = cache.verses.find(v => v.id === 'bani-shriradha-mohan-ki-jori');
  console.log('Found verse by ID:', verseById);
}
