const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.REACT_APP_SUPABASE_URL;
const supabaseKey = process.env.REACT_APP_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error("Error: Supabase environment variables are missing in .env");
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

function formatValue(val) {
  if (val === null || val === undefined) return 'null';
  if (typeof val === 'string') {
    return JSON.stringify(val);
  }
  if (Array.isArray(val)) {
    return JSON.stringify(val);
  }
  if (typeof val === 'object') {
    return JSON.stringify(val);
  }
  return val;
}

function cleanSlug(slug, title) {
  const base = slug || title || '';
  return base
    .toString()
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/--+/g, '-')
    .replace(/^-+/, '')
    .replace(/-+$/, '');
}

const scratchDir = '/Users/sakhi/.gemini/antigravity/scratch';
if (!fs.existsSync(scratchDir)) {
  fs.mkdirSync(scratchDir, { recursive: true });
}

const BATCH_SIZE = 500;

async function runMigration() {
  console.log("Fetching all content rows from Supabase...");
  let hasMore = true;
  let offset = 0;
  const limit = 1000;
  let allContent = [];
  
  while (hasMore) {
    console.log(`Querying range ${offset} to ${offset + limit - 1}...`);
    const { data, error } = await supabase
      .from('content')
      .select('*')
      .range(offset, offset + limit - 1);
      
    if (error) {
      console.error("Error querying Supabase:", error.message);
      process.exit(1);
    }
    
    allContent = allContent.concat(data || []);
    console.log(`Fetched ${data.length} rows. Total gathered: ${allContent.length}`);
    
    if (data.length < limit) {
      hasMore = false;
    } else {
      offset += limit;
    }
  }

  console.log(`Successfully fetched ${allContent.length} rows from Supabase. Beginning bulk upload...`);

  
  const slugMap = new Map(); 
  allContent.forEach(item => {
    const title = item.title || 'Untitled';
    let baseSlug = item.slug || cleanSlug(null, title);
    if (!baseSlug) baseSlug = 'untitled';
    baseSlug = baseSlug.substring(0, 180); 
    
    if (!slugMap.has(baseSlug)) {
      slugMap.set(baseSlug, item.id);
      item.resolvedSlug = baseSlug;
    } else {
      if (slugMap.get(baseSlug) === item.id) {
        item.resolvedSlug = baseSlug;
      } else {
        const suffix = item.id.split('-')[0] || item.id.substring(0, 8);
        let uniqueSlug = `${baseSlug}-${suffix}`.substring(0, 200);
        let counter = 1;
        while (slugMap.has(uniqueSlug) && slugMap.get(uniqueSlug) !== item.id) {
          uniqueSlug = `${baseSlug}-${suffix}-${counter}`.substring(0, 200);
          counter++;
        }
        item.resolvedSlug = uniqueSlug;
        slugMap.set(uniqueSlug, item.id);
      }
    }
  });

  for (let batchIdx = 0; batchIdx < allContent.length; batchIdx += BATCH_SIZE) {
    const batchItems = allContent.slice(batchIdx, batchIdx + BATCH_SIZE);
    
    let gql = `mutation SupabaseBatch${batchIdx} {\n`;
    
    batchItems.forEach((item, idx) => {
      
      const id = item.id;
      const title = item.title || 'Untitled';
      const sanskritText = item.sanskrit_text || item.sanskritText || null;
      const hindiText = item.hindi_text || item.hindiText || null;
      const englishText = item.english_text || item.englishText || null;
      const englishTranslation = item.english_translation || item.englishTranslation || null;
      const category = (item.category || 'poem').toLowerCase().trim();
      const description = (item.description || '').substring(0, 500);
      const contentText = item.content_text || item.contentText || null;
      const tags = Array.isArray(item.tags) ? item.tags : [];
      
      let status = 'PUBLISHED';
      if (item.status) {
        status = item.status.toUpperCase();
        if (status !== 'DRAFT' && status !== 'PUBLISHED' && status !== 'ARCHIVED') {
          status = 'PUBLISHED';
        }
      }
      
      const author = item.author || 'Team VrindaVaani';
      const mediaLinks = Array.isArray(item.media_links) ? item.media_links : (Array.isArray(item.mediaLinks) ? item.mediaLinks : []);
      const audioUrl = item.audio_url || item.audioUrl || null;
      const imageUrls = Array.isArray(item.image_urls) ? item.image_urls : (Array.isArray(item.imageUrls) ? item.imageUrls : []);
      const videoUrls = Array.isArray(item.video_urls) ? item.video_urls : (Array.isArray(item.videoUrls) ? item.videoUrls : []);
      const slug = item.resolvedSlug;

      gql += `  m${idx}: content_upsert(data: {
        id: "${id}"
        title: ${formatValue(title)}
        sanskritText: ${formatValue(sanskritText)}
        hindiText: ${formatValue(hindiText)}
        englishText: ${formatValue(englishText)}
        englishTranslation: ${formatValue(englishTranslation)}
        category: "${category}"
        description: ${formatValue(description)}
        contentText: ${formatValue(contentText)}
        tags: ${formatValue(tags)}
        status: ${status}
        author: ${formatValue(author)}
        mediaLinks: ${formatValue(mediaLinks)}
        audioUrl: ${formatValue(audioUrl)}
        imageUrls: ${formatValue(imageUrls)}
        videoUrls: ${formatValue(videoUrls)}
        slug: ${formatValue(slug)}
        updatedAt_expr: "request.time"
      })\n`;
    });
    
    gql += `}\n`;
    
    const tempGqlFile = path.join(scratchDir, `supabase_batch_${batchIdx}.gql`);
    fs.writeFileSync(tempGqlFile, gql, 'utf8');
    
    try {
      console.log(`[Batch ${batchIdx / BATCH_SIZE + 1}/${Math.ceil(allContent.length / BATCH_SIZE)}] Uploading items ${batchIdx} to ${batchIdx + batchItems.length}...`);
      
      const cmd = `npx firebase dataconnect:execute "${tempGqlFile}"`;
      execSync(cmd, { cwd: '/Users/sakhi/Code/Company', stdio: 'pipe' });
      console.log(`[Batch ${batchIdx / BATCH_SIZE + 1}] Successfully migrated!`);
    } catch (err) {
      console.error(`[Batch ${batchIdx / BATCH_SIZE + 1}] Failed:`, err.message);
      
      try {
        console.log(`Retrying batch...`);
        const cmd = `npx firebase dataconnect:execute "${tempGqlFile}"`;
        execSync(cmd, { cwd: '/Users/sakhi/Code/Company', stdio: 'pipe' });
        console.log(`[Batch ${batchIdx / BATCH_SIZE + 1}] Successfully migrated on retry!`);
      } catch (retryErr) {
        console.error(`Retry failed:`, retryErr.message);
      }
    }
    
    
    await new Promise(resolve => setTimeout(resolve, 300));
  }

  console.log("Migration complete!");
}

runMigration();
