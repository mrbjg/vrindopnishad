const fs = require('fs');
const path = require('path');

const cachePath = './data/processed_cache.json';

if (!fs.existsSync(cachePath)) {
  console.log('Cache file does not exist at:', cachePath);
  process.exit(1);
}

try {
  const cache = JSON.parse(fs.readFileSync(cachePath, 'utf8'));
  console.log('Cache Keys:', Object.keys(cache));
  
  if (cache.verses) {
    console.log('Total verses:', cache.verses.length);
    console.log('Sample verse slugs:', cache.verses.slice(0, 10).map(v => v.slug));
    
    const nullSlugs = cache.verses.filter(v => !v.slug);
    console.log('Verses with empty/null slugs:', nullSlugs.length);
    if (nullSlugs.length > 0) {
      console.log('First 5 null slug verses:', nullSlugs.slice(0, 5).map(v => ({ id: v.id, title: v.title })));
    }
    
    // Check duplicate slugs
    const slugMap = {};
    const dupSlugs = [];
    cache.verses.forEach(v => {
      if (v.slug) {
        if (slugMap[v.slug]) {
          dupSlugs.push(v.slug);
        }
        slugMap[v.slug] = true;
      }
    });
    console.log('Duplicate verse slugs:', dupSlugs.length);
    if (dupSlugs.length > 0) {
      console.log('Sample duplicate slugs:', dupSlugs.slice(0, 10));
    }
  }
  
  if (cache.saints) {
    console.log('Total saints:', cache.saints.length);
    console.log('Saints slugs:', cache.saints.map(s => s.slug));
  }
  
  if (cache.books) {
    console.log('Total books:', cache.books.length);
    console.log('Books slugs:', cache.books.map(b => b.slug));
  }
  
  if (cache.ragas) {
    console.log('Total ragas:', cache.ragas.length);
    console.log('Ragas slugs:', cache.ragas.map(r => r.slug));
  }
  
} catch (err) {
  console.error('Failed to parse cache:', err);
}
