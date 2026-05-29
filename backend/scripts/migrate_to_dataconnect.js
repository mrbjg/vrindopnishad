const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { execSync } = require('child_process');

const rawDataPath = '/Users/sakhi/Code/Company/Projects/VrindaVaani/admin/data/brajrasik_dual_full.json';

function getDeterministicUuid(inputString) {
  const hash = crypto.createHash('sha256').update(inputString).digest('hex');
  return `${hash.substring(0, 8)}-${hash.substring(8, 12)}-${hash.substring(12, 16)}-${hash.substring(16, 20)}-${hash.substring(20, 32)}`;
}

function cleanSlug(slug) {
  return slug
    .toString()
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/--+/g, '-')
    .replace(/^-+/, '')
    .replace(/-+$/, '');
}

function classifyCategory(title, sanskritText) {
  const titleLower = (title || '').toLowerCase();
  const sanskritLower = (sanskritText || '').toLowerCase();
  
  if (
    titleLower.includes('स्तोत्र') || titleLower.includes('strotra') || titleLower.includes('stotra') ||
    titleLower.includes('शतक') || titleLower.includes('shatak') ||
    titleLower.includes('अष्टक') || titleLower.includes('ashtak')
  ) {
    return 'strotra';
  }
  
  if (sanskritLower.includes('॥') || sanskritLower.includes('ॐ') || titleLower.includes('gita') || titleLower.includes('गीता')) {
    return 'shloka';
  }
  
  return 'poem';
}

if (!fs.existsSync(rawDataPath)) {
  console.error(`Error: Raw data file not found at ${rawDataPath}`);
  process.exit(1);
}

const items = JSON.parse(fs.readFileSync(rawDataPath, 'utf8'));
console.log(`Loaded ${items.length} items from ${rawDataPath}. Mapping to database structure...`);

const mapped = items.map(item => {
  const sourceUrl = item.source_url || item.description || '';
  const parts = sourceUrl.split('/');
  let slug = parts[parts.length - 1] || parts[parts.length - 2] || cleanSlug(item.title);
  if (slug.length > 200) {
    slug = slug.substring(0, 200);
  }
  slug = cleanSlug(slug);

  const uuidInput = sourceUrl || item.title;
  const id = getDeterministicUuid(uuidInput);

  let category = (item.category || '').toLowerCase().trim();
  if (category !== 'saint' && category !== 'dham') {
    category = classifyCategory(item.title, item.sanskrit_text);
  }

  let status = 'PUBLISHED';
  if (item.status) {
    status = item.status.toUpperCase();
    if (status !== 'DRAFT' && status !== 'PUBLISHED' && status !== 'ARCHIVED') {
      status = 'PUBLISHED';
    }
  }

  return {
    id,
    title: item.title || 'Untitled',
    sanskritText: item.sanskrit_text || null,
    hindiText: item.hindi_text || null,
    englishText: item.english_text || null,
    englishTranslation: item.english_translation || null,
    category,
    description: (item.description || '').substring(0, 500),
    contentText: item.content_text || null,
    tags: Array.isArray(item.tags) ? item.tags : [],
    status,
    author: item.author || 'Braj Rasik Heritage',
    mediaLinks: Array.isArray(item.media_links) ? item.media_links : [],
    audioUrl: item.audio_url || null,
    imageUrls: Array.isArray(item.image_urls) ? item.image_urls : [],
    videoUrls: Array.isArray(item.video_urls) ? item.video_urls : [],
    slug
  };
});

const scratchDir = '/Users/sakhi/.gemini/antigravity/scratch';
if (!fs.existsSync(scratchDir)) {
  fs.mkdirSync(scratchDir, { recursive: true });
}
const tempVarsFile = path.join(scratchDir, 'temp_vars.json');

async function migrateAll() {
  console.log(`Starting migration of ${mapped.length} records to Firebase Data Connect...`);
  
  for (let i = 0; i < mapped.length; i++) {
    const item = mapped[i];
    fs.writeFileSync(tempVarsFile, JSON.stringify(item, null, 2), 'utf8');
    
    const cmd = `npx firebase dataconnect:execute dataconnect/content/mutations.gql UpsertContent --vars "@${tempVarsFile}"`;
    
    try {
      execSync(cmd, { cwd: '/Users/sakhi/Code/Company', stdio: 'pipe' });
      console.log(`[${i + 1}/${mapped.length}] Successfully migrated: "${item.title}" (${item.category})`);
    } catch (err) {
      console.error(`[${i + 1}/${mapped.length}] Failed migrating "${item.title}":`, err.message);
      try {
        console.log(`Retrying "${item.title}"...`);
        execSync(cmd, { cwd: '/Users/sakhi/Code/Company', stdio: 'pipe' });
        console.log(`[${i + 1}/${mapped.length}] Successfully migrated on retry: "${item.title}"`);
      } catch (retryErr) {
        console.error(`Retry failed for "${item.title}":`, retryErr.message);
      }
    }
    
    await new Promise(resolve => setTimeout(resolve, 50));
  }
  
  console.log('Migration complete!');
}

migrateAll();
