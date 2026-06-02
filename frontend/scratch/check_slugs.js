const fs = require('fs');
const cachePath = './data/processed_cache.json';

if (!fs.existsSync(cachePath)) {
  console.log('Cache file does not exist.');
  process.exit(0);
}

const cache = JSON.parse(fs.readFileSync(cachePath, 'utf8'));

if (cache.verses) {
  const weirdSlugs = cache.verses.filter(v => v.slug && (/[A-Z]/.test(v.slug) || /\s+/.test(v.slug) || /[^a-z0-9-]/.test(v.slug)));
  console.log('Total verses with non-standard slugs:', weirdSlugs.length);
  if (weirdSlugs.length > 0) {
    console.log('Sample weird slugs:', weirdSlugs.slice(0, 15).map(v => ({ id: v.id, title: v.title, slug: v.slug })));
  }
}
