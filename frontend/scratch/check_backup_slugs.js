const fs = require('fs');
const backupPath = './public/data/content_backup.json';

if (!fs.existsSync(backupPath)) {
  console.log('Backup file does not exist.');
  process.exit(1);
}

const items = JSON.parse(fs.readFileSync(backupPath, 'utf8'));
console.log('Total backup items:', items.length);

const matches = items.filter(v => 
  (v.slug && v.slug.includes('jori')) || 
  (v.title && v.title.includes('जोड़ी')) ||
  (v.title && v.title.includes('जोडी')) ||
  (v.title && v.title.includes('jori'))
);

console.log(`Found ${matches.length} matching items:`);
matches.slice(0, 10).forEach(v => {
  console.log(`ID: ${v.id}, Slug: ${v.slug}, Title: ${v.title}`);
});
