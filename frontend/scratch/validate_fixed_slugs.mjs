import { getVerseBySlug, getSaintBySlug, getGranthaBySlug } from '../src/lib/contentData.js';

const testSlugs = [
  'sambhu-sur-dhyaavain-sada-ses-gun-gaavai-shri-hati-ji-radha-sudha-shatak',
  'किं-रे-धूर्त्त',
  'करू-मन-नंदनँदनको-ध्यान',
  'जब-सम्राट-अकबर-स्वामी-हरिदास-से-निधिवन-वृंदावन-में-मिले',
  'बिछुरन-मिलन-जहाँ-रहै-सुद्ध-प्रेम-नहिं-होइ',
  'ansbhuja-diyain-aavat-jamuna-teer-shri-roop-manjari',
  'janam-janam-jinke-sada-hum-chakar-shri-bhata-devacharya-yugal-shatak'
];

console.log('--- Testing Updated getVerseBySlug ---');
testSlugs.forEach(slug => {
  const result = getVerseBySlug(slug);
  if (result) {
    console.log(`Slug: ${slug} -> FOUND. ID: ${result.id}, Title: ${result.title}`);
  } else {
    console.log(`Slug: ${slug} -> NOT FOUND`);
  }
});

console.log('\n--- Testing getSaintBySlug ---');
const saintResult = getSaintBySlug('bhagavan-shiva');
if (saintResult) {
  console.log(`Saint "bhagavan-shiva" -> FOUND. Title: ${saintResult.title}`);
} else {
  console.log(`Saint "bhagavan-shiva" -> NOT FOUND`);
}

console.log('\n--- Testing getGranthaBySlug ---');
const bookResult = getGranthaBySlug('hit-chaurasi');
if (bookResult) {
  console.log(`Grantha "hit-chaurasi" -> FOUND. Name: ${bookResult.name}`);
} else {
  console.log(`Grantha "hit-chaurasi" -> NOT FOUND`);
}
