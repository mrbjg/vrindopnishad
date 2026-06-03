const fs = require('fs');
const path = require('path');

const cachePath = path.join(__dirname, '../data/processed_cache.json');
if (!fs.existsSync(cachePath)) {
  console.log('Cache file not found:', cachePath);
  process.exit(1);
}

const cacheData = JSON.parse(fs.readFileSync(cachePath, 'utf8'));
const verses = cacheData.verses || [];
console.log('Total verses in cache:', verses.length);

const testSlugs = [
  'sambhu-sur-dhyaavain-sada-ses-gun-gaavai-shri-hati-ji-radha-sudha-shatak',
  'किं-रे-धूर्त्त',
  'करू-मन-नंदनँदनको-ध्यान',
  'जब-सम्राट-अकबर-स्वामी-हरिदास-से-निधिवन-वृंदावन-में-मिले',
  'बिछुरन-मिलन-जहाँ-रहै-सुद्ध-प्रेम-नहिं-होइ',
  'ansbhuja-diyain-aavat-jamuna-teer-shri-roop-manjari',
  'janam-janam-jinke-sada-hum-chakar-shri-bhata-devacharya-yugal-shatak'
];

testSlugs.forEach(slug => {
  console.log(`\n--- Searching for slug: ${slug} ---`);
  
  // 1. Try finding by exact slug in cache
  const matchBySlug = verses.find(v => v.slug === slug || (v.slug && v.slug.toLowerCase() === slug.toLowerCase()));
  if (matchBySlug) {
    console.log(`FOUND EXACT SLUG MATCH:`);
    console.log(`- ID: ${matchBySlug.id}`);
    console.log(`  Title: ${matchBySlug.title}`);
    console.log(`  Author: ${matchBySlug.author}`);
    console.log(`  Slug: ${matchBySlug.slug}`);
    return;
  }
  
  // 2. Try fuzzy title search
  const decoded = decodeURIComponent(slug);
  console.log(`Decoded slug: ${decoded}`);
  const matches = verses.filter(v => {
    const text = (v.title || '') + ' ' + (v.hindi_text || '') + ' ' + (v.author || '');
    return text.toLowerCase().includes(decoded.toLowerCase()) || 
           text.toLowerCase().replace(/[^a-z0-9]/g, '').includes(decoded.toLowerCase().replace(/[^a-z0-9]/g, ''));
  });
  
  console.log(`Fuzzy Matches found: ${matches.length}`);
  matches.slice(0, 3).forEach(m => {
    console.log(`- ID: ${m.id}`);
    console.log(`  Title: ${m.title}`);
    console.log(`  Author: ${m.author}`);
    console.log(`  Slug: ${m.slug}`);
  });
});
