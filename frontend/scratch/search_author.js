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

const matchedAuthors = Array.from(authors).filter(a => 
  a.includes('हठी') || a.includes('हठि') || a.includes('भट्ट') || a.includes('भट')
);

console.log('Matched authors:', matchedAuthors);
