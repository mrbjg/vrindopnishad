const fs = require('fs');
const path = require('path');

const dataPath = path.join(__dirname, '../data/brajrasik_hi_full.json');
const data = JSON.parse(fs.readFileSync(dataPath, 'utf8'));

const m = data.find(item => item.title && item.title.includes('हीन हौं, अधीन हौं'));
if (m) {
  console.log('Title:', m.title);
  console.log('Author:', m.author);
  console.log('Hindi Text:\n', m.hindi_text);
  console.log('Sanskrit Text:\n', m.sanskrit_text);
} else {
  console.log('Not found');
}
