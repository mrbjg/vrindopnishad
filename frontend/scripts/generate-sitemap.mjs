import fs from 'fs';
import axios from 'axios';

const SUPABASE_URL = 'https://tilimltxgeucefxzerqi.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpbGltbHR4Z2V1Y2VmeHplcnFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2MjQyNTQsImV4cCI6MjA4MzIwMDI1NH0.lwaCJyTRW6jNsfQJ32R_wAwp11yj6bvsJ4fzC0EX_00';
const DOMAIN = 'https://path.vrindopnishad.in';

const generateSlug = (text) => {
  if (!text) return '';
  // Support Hindi characters in slugs for better SEO and readability
  return text
    .toString()
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '-')     // Replace spaces with -
    .replace(/[^\u0900-\u097F\w-]+/g, '')  // Remove non-word and non-Hindi chars
    .replace(/--+/g, '-')     // Replace multiple - with single -
    .replace(/^-+/, '')        // Trim - from start of text
    .replace(/-+$/, '');       // Trim - from end of text
};

async function generateSitemap() {
  console.log('Fetching content from Supabase for dynamic sitemap...');
  try {
    // Verified that select=title,id works. slug might not exist as a column.
    const response = await axios.get(`${SUPABASE_URL}/rest/v1/content?select=title,id`, {
        headers: {
            'apikey': SUPABASE_KEY,
            'Authorization': `Bearer ${SUPABASE_KEY}`
        }
    });
    
    const content = response.data;
    
    if (!content || content.length === 0) {
        console.error('No content found in Supabase!');
        return;
    }

    console.log(`Found ${content.length} items. Generating URLs...`);

    const urls = content.map(item => {
      const slug = generateSlug(item.title); // Generate from title since slug column is missing
      return `
  <url>
    <loc>${DOMAIN}/content/${slug || item.id}</loc>
    <changefreq>weekly</changefreq>
    <priority>0.8</priority>
  </url>`;
    }).join('');

    const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>${DOMAIN}/</loc>
    <changefreq>daily</changefreq>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>${DOMAIN}/content</loc>
    <changefreq>daily</changefreq>
    <priority>0.9</priority>
  </url>
${urls}
</urlset>`;

    fs.writeFileSync('public/sitemap.xml', sitemap);
    console.log('Dynamic sitemap.xml generated successfully in public/');
    
    if (fs.existsSync('build')) {
        fs.writeFileSync('build/sitemap.xml', sitemap);
        console.log('Dynamic sitemap.xml copied to build/');
    }

  } catch (error) {
    console.error('Error generating sitemap:', error.message);
  }
}

generateSitemap();
