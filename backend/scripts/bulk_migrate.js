const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { execSync } = require('child_process');

const rawDataPath = '/Users/sakhi/Code/Company/Projects/VrindaVaani/admin/data/vrindavaani_content.json';

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

function escapeBlockString(val) {
  if (!val) return '';
  return val.replace(/"""/g, '\\"""');
}

function formatValue(val) {
  if (val === null || val === undefined) return 'null';
  if (typeof val === 'string') {
    return `"""${escapeBlockString(val)}"""`;
  }
  if (Array.isArray(val)) {
    return '[' + val.map(formatValue).join(', ') + ']';
  }
  if (typeof val === 'object') {
    // Escape and format as JSON string stringifier
    return `"""${escapeBlockString(JSON.stringify(val))}"""`;
  }
  return val;
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
console.log(`Loaded ${items.length} items from ${rawDataPath}. Mapping to bulk SQL Connect operations...`);

const scratchDir = '/Users/sakhi/.gemini/antigravity/scratch';
if (!fs.existsSync(scratchDir)) {
  fs.mkdirSync(scratchDir, { recursive: true });
}

const BATCH_SIZE = 50;

async function migrateAll() {
  console.log(`Starting bulk migration of ${items.length} records in batches of ${BATCH_SIZE}...`);
  
  for (let batchIdx = 0; batchIdx < items.length; batchIdx += BATCH_SIZE) {
    const batchItems = items.slice(batchIdx, batchIdx + BATCH_SIZE);
    
    let gql = `mutation BulkUpsertBatch${batchIdx} {\n`;
    
    batchItems.forEach((item, idx) => {
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

      const tags = Array.isArray(item.tags) ? item.tags : [];
      const mediaLinks = Array.isArray(item.media_links) ? item.media_links : [];
      const imageUrls = Array.isArray(item.image_urls) ? item.image_urls : [];
      const videoUrls = Array.isArray(item.video_urls) ? item.video_urls : [];

      gql += `  m${idx}: content_upsert(data: {
        id: "${id}"
        title: ${formatValue(item.title)}
        sanskritText: ${formatValue(item.sanskrit_text)}
        hindiText: ${formatValue(item.hindi_text)}
        englishText: ${formatValue(item.english_text)}
        englishTranslation: ${formatValue(item.english_translation)}
        category: "${category}"
        description: ${formatValue((item.description || '').substring(0, 500))}
        contentText: ${formatValue(item.content_text)}
        tags: ${formatValue(tags)}
        status: ${status}
        author: ${formatValue(item.author || 'Team VrindaVaani')}
        mediaLinks: ${formatValue(mediaLinks)}
        audioUrl: ${formatValue(item.audio_url)}
        imageUrls: ${formatValue(imageUrls)}
        videoUrls: ${formatValue(videoUrls)}
        slug: "${slug}"
        updatedAt_expr: "request.time"
      })\n`;
    });
    
    gql += `}\n`;
    
    const tempGqlFile = path.join(scratchDir, `batch_${batchIdx}.gql`);
    fs.writeFileSync(tempGqlFile, gql, 'utf8');
    
    try {
      console.log(`[Batch ${batchIdx / BATCH_SIZE + 1}/${Math.ceil(items.length / BATCH_SIZE)}] Migrating items ${batchIdx} to ${batchIdx + batchItems.length}...`);
      const cmd = `npx firebase dataconnect:execute "${tempGqlFile}"`;
      execSync(cmd, { cwd: '/Users/sakhi/Code/Company', stdio: 'pipe' });
      console.log(`[Batch ${batchIdx / BATCH_SIZE + 1}] Successfully migrated!`);
    } catch (err) {
      console.error(`[Batch ${batchIdx / BATCH_SIZE + 1}] Failed:`, err.message);
      // Wait a moment and retry once
      try {
        console.log(`Retrying batch...`);
        const cmd = `npx firebase dataconnect:execute "${tempGqlFile}"`;
        execSync(cmd, { cwd: '/Users/sakhi/Code/Company', stdio: 'pipe' });
        console.log(`[Batch ${batchIdx / BATCH_SIZE + 1}] Successfully migrated on retry!`);
      } catch (retryErr) {
        console.error(`Retry failed:`, retryErr.message);
      }
    }
    
    await new Promise(resolve => setTimeout(resolve, 500));
  }
  
  console.log('Bulk migration complete!');
}

migrateAll();
