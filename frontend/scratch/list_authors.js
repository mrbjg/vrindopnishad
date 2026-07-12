const fs = require('fs');
const path = require('path');

const dataPath = path.join(__dirname, '../data/vrindavaani_content.json');
const data = JSON.parse(fs.readFileSync(dataPath, 'utf8'));

const authors = new Set();
data.forEach(item => {
  if (item.author) {
    authors.add(item.author);
  }
});

console.log('Unique authors:', Array.from(authors).sort());
