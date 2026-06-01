const fs = require('fs');
const path = require('path');

const dataPath = path.join(__dirname, 'data/brajrasik_hi_full.json');
const data = JSON.parse(fs.readFileSync(dataPath, 'utf8'));

console.log('Total items:', data.length);

const testItems = [];

data.forEach((item, idx) => {
  const text = JSON.stringify(item).toLowerCase();
  
  // 1. Check for obvious test/dummy words as separate tokens
  const isTestWord = /\b(test|demo|dummy|temp|placeholder|asdf|qwerty)\b/i.test(text);
  
  // 2. Check for empty or extremely short titles/texts
  const isShort = (item.title && item.title.trim().length <= 2) || 
                  (!item.title) || 
                  (item.hindi_text && item.hindi_text.trim().length <= 5);
                  
  // 3. Check for numeric book or saint names
  const hasWeirdAuthor = item.author && (/^\d+$/.test(item.author) || item.author.trim() === 'Braj Rasik Heritage');

  if (isTestWord || isShort || hasWeirdAuthor) {
    testItems.push({ idx, id: item.id, title: item.title, author: item.author, category: item.category });
  }
});

console.log('Found potentially test/weird items:', testItems.length);
console.log(JSON.stringify(testItems, null, 2));
