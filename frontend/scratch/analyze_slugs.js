const fs = require('fs');
const path = require('path');

const dataPath = path.join(__dirname, '../data/vrindavaani_content.json');
if (!fs.existsSync(dataPath)) {
  console.log('File not found:', dataPath);
  process.exit(1);
}

const data = JSON.parse(fs.readFileSync(dataPath, 'utf8'));
console.log('Total items:', data.length);

let hindiSlugsCount = 0;
let emptySlugsCount = 0;
let sampleHindiSlugs = [];

data.forEach((item, idx) => {
  if (!item.slug) {
    emptySlugsCount++;
    return;
  }
  // Check if slug contains non-ASCII characters (e.g. Hindi)
  if (/[^\x00-\x7F]/.test(item.slug)) {
    hindiSlugsCount++;
    if (sampleHindiSlugs.length < 10) {
      sampleHindiSlugs.push({ idx, id: item.id, title: item.title, slug: item.slug });
    }
  }
});

console.log('Empty slugs:', emptySlugsCount);
console.log('Slugs containing non-ASCII characters:', hindiSlugsCount);
console.log('Samples of non-ASCII slugs:', JSON.stringify(sampleHindiSlugs, null, 2));
