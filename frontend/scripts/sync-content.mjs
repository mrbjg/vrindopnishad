import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

// Set up __dirname equivalent for ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const projectRoot = path.resolve(__dirname, '..');

// Helper to resolve paths to the project root
const resolvePath = (relPath) => path.join(projectRoot, relPath);

// Import our classification, slugification, and relation utilities
import { 
  generateSlug, 
  slugify, 
  classifyItemCategory 
} from '../src/lib/contentData.js';
import { extractRelations } from '../src/utils/relations.js';

// Import raw saints formatting
const saintsPath = resolvePath('data/saints_formatted.json');
const rawSaintsData = fs.readFileSync(saintsPath, 'utf8');
const rawSaintsList = JSON.parse(rawSaintsData);

// Import Firebase config and initialization
import { dataConnect } from '../src/firebase.js';
import { listAllContent } from '../src/lib/dataconnect/esm/index.esm.js';

console.log("[Sync] Initializing Firebase App and Data Connect client...");

async function runSync() {
  console.log("[Sync] Querying Firebase Data Connect for all content (limit 25000)...");
  try {
    const result = await listAllContent(dataConnect, { limit: 25000 });
    if (!result || !result.data || !result.data.contents) {
      throw new Error("No data returned from Firebase Data Connect!");
    }
    
    const contents = result.data.contents;
    console.log(`[Sync] Downloaded ${contents.length} items successfully.`);
    
    // 1. Map to Application Data Model
    const mappedVerses = contents.map(item => {
      let slug = item.slug;
      if (!slug || slug.startsWith('untitled')) {
        slug = generateSlug(item.title);
      } else {
        slug = slugify(slug);
      }
      if (slug.length > 100) {
        slug = slug.substring(0, 100).replace(/-+$/, '');
      }
      return {
        id: item.id,
        title: item.title,
        sanskrit_text: item.sanskritText || '',
        hindi_text: item.hindiText || '',
        english_text: item.englishText || '',
        english_translation: item.englishTranslation || '',
        category: item.category,
        description: item.description || '',
        content_text: item.contentText || '',
        tags: item.tags || [],
        status: (item.status || 'PUBLISHED').toLowerCase(),
        author: item.author || '',
        media_links: item.mediaLinks || [],
        audio_url: item.audioUrl || '',
        image_urls: item.imageUrls || [],
        video_urls: item.videoUrls || [],
        slug: slug,
        created_at: item.createdAt,
        updated_at: item.updatedAt
      };
    });
    
    // 2. Prepare saints list
    const saintsRaw = rawSaintsList.map((saint, idx) => ({
      id: saint.id || `saint-local-${idx}`,
      ...saint,
      category: 'saint',
      slug: saint.slug || generateSlug(saint.title)
    }));
    
    // 3. Build relations
    const combined = [...mappedVerses, ...saintsRaw];
    console.log("[Sync] Computing entity relations...");
    const relations = extractRelations(combined);
    
    // 4. Save flat cache file
    const cacheFile = resolvePath('data/processed_cache.json');
    console.log(`[Sync] Saving processed cache layout to: ${cacheFile}...`);
    const cachePayload = {
      verses: mappedVerses,
      saintsRaw: saintsRaw
    };
    fs.writeFileSync(cacheFile, JSON.stringify(cachePayload), 'utf8');
    
    // 5. Save backup JSON files
    const backupDir = resolvePath('public/data');
    if (!fs.existsSync(backupDir)) {
      fs.mkdirSync(backupDir, { recursive: true });
    }
    
    const mainBackup = path.join(backupDir, 'content_backup.json');
    console.log(`[Sync] Saving main backup file: ${mainBackup}...`);
    fs.writeFileSync(mainBackup, JSON.stringify(mappedVerses), 'utf8');
    
    // Split and save category-specific backup files
    const categories = ['shloka', 'strotra', 'poem', 'saint', 'dham'];
    categories.forEach(cat => {
      const catFile = path.join(backupDir, `content_backup_${cat}.json`);
      const catVerses = combined.filter(v => classifyItemCategory(v) === cat);
      console.log(`[Sync] Saving category backup [${cat}] (${catVerses.length} items) to: ${catFile}...`);
      fs.writeFileSync(catFile, JSON.stringify(catVerses), 'utf8');
    });
    
    // Save relations backup file
    const relationsFile = path.join(backupDir, 'relations_backup.json');
    console.log(`[Sync] Saving relations backup file: ${relationsFile}...`);
    fs.writeFileSync(relationsFile, JSON.stringify(relations), 'utf8');
    
    console.log("[Sync] Content synchronization pipeline completed successfully!");
    process.exit(0);
  } catch (error) {
    console.error("[Sync] Content synchronization failed:", error);
    process.exit(1);
  }
}

runSync();
