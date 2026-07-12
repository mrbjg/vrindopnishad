const fs = require('fs');
const path = require('path');

const dataPath = path.join(__dirname, '../data/vrindavaani_content.json');
const data = JSON.parse(fs.readFileSync(dataPath, 'utf8'));

// We are looking for something like "sambhu sur dhyaavain sada ses gun gaavai..."
// Hindi equivalent: "शंभु सुर ध्यावैं सदा सेस गुन गावै..." or "सम्भु सुर ध्यावैं..."
// Let's search for verses containing "सुर" and "सदा" and "सेस" or similar words.

const matches = data.filter(item => {
  const title = item.title || '';
  const text = item.hindi_text || '';
  return (title.includes('सुर') && title.includes('सदा')) || 
         (text.includes('सुर') && text.includes('सदा') && text.includes('गावै'));
});

console.log(`Found ${matches.length} possible matches:`);
matches.forEach(m => {
  console.log(`- Title: ${m.title}`);
  console.log(`  Author: ${m.author}`);
  console.log(`  First line: ${(m.hindi_text || '').substring(0, 100)}`);
});
