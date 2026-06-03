const fs = require('fs');
const path = require('path');

const dataPath = path.join(__dirname, '../data/brajrasik_hi_full.json');
const data = JSON.parse(fs.readFileSync(dataPath, 'utf8'));

const searchWords = ['ansbhuja', 'ans', 'bhuj', 'sambhu', 'shambhu', 'dhyaavain', 'hati', 'bhata', 'janam', 'chakar'];

searchWords.forEach(word => {
  console.log(`\n=== SEARCHING WORD: ${word} ===`);
  const matches = data.filter(item => {
    const text = (item.title || '') + ' ' + (item.hindi_text || '') + ' ' + (item.author || '');
    return text.toLowerCase().includes(word.toLowerCase());
  });
  console.log(`Matches found: ${matches.length}`);
  matches.slice(0, 5).forEach(m => {
    console.log(`- Title: ${m.title}`);
    console.log(`  Author: ${m.author}`);
  });
});
