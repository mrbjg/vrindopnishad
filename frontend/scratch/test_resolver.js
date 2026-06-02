const { ensureDataLoaded, getVerseBySlug } = require('./src/lib/contentData.js');

async function run() {
  await ensureDataLoaded();
  const verse = getVerseBySlug('bani-shriradha-mohan-ki-jori');
  console.log('Result for "bani-shriradha-mohan-ki-jori":', verse ? { id: verse.id, title: verse.title, slug: verse.slug } : 'null');
}

run();
