const fs = require('fs');
const path = require('path');

const dataPath = path.join(__dirname, '../data/vrindavaani_content.json');
const data = JSON.parse(fs.readFileSync(dataPath, 'utf8'));

const matches = data.filter(item => {
  const author = item.author || '';
  return author.includes('हठी') || author.includes('हठि') || author.includes('भट्ट');
});

console.log(`Matched ${matches.length} verses:`);
matches.forEach(m => {
  console.log(`- Title: ${m.title}`);
  console.log(`  Author: ${m.author}`);
  console.log(`  GenSlug: ${m.slug || 'N/A'}`);
});
