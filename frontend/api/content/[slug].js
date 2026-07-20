
import fs, { readFileSync } from 'fs';
import { join } from 'path';

const SUPABASE_URL = process.env.REACT_APP_SUPABASE_URL || 'https://tilimltxgeucefxzerqi.supabase.co';
const SUPABASE_KEY = process.env.REACT_APP_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpbGltbHR4Z2V1Y2VmeHplcnFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2MjQyNTQsImV4cCI6MjA4MzIwMDI1NH0.lwaCJyTRW6jNsfQJ32R_wAwp11yj6bvsJ4fzC0EX_00';
const DOMAIN = 'https://path.vrindopnishad.in';

function escapeHtml(str) {
  if (!str) return '';
  return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

export default async function handler(req, res) {
  const ua = req.headers['user-agent'] || '';
  const isBadBot = /python|scrapy|curl|wget|postman|urllib|axios|http-client|node-fetch|got|needle|superagent|request|crawler|spider|bot/i.test(ua) && 
                   !/googlebot|bingbot|yandexbot|duckduckbot|baiduspider|slurp|facebookexternalhit|twitterbot/i.test(ua);
  
  if (isBadBot) {
    res.status(403).send('Forbidden: Access denied.');
    return;
  }

  const slug = req.query.slug;
  if (!slug) {
    res.status(400).send('Missing slug');
    return;
  }

  // Fetch content from Supabase by slug
  let content = null;
  try {
    const response = await fetch(
      `${SUPABASE_URL}/rest/v1/content?slug=eq.${encodeURIComponent(slug)}&limit=1`,
      {
        headers: {
          'apikey': SUPABASE_KEY,
          'Authorization': `Bearer ${SUPABASE_KEY}`
        }
      }
    );
    const data = await response.json();
    if (Array.isArray(data) && data.length > 0) {
      content = data[0];
    }
  } catch (e) {
    console.error('Supabase fetch failed:', e.message);
  }
  // If no content found by slug, try by title match from Supabase
  if (!content) {
    try {
      const decodedSlug = decodeURIComponent(slug);
      const response = await fetch(
        `${SUPABASE_URL}/rest/v1/content?title=ilike.*${encodeURIComponent(decodedSlug.replace(/-/g, '*'))}*&limit=1`,
        {
          headers: {
            'apikey': SUPABASE_KEY,
            'Authorization': `Bearer ${SUPABASE_KEY}`
          }
        }
      );
      const data = await response.json();
      if (Array.isArray(data) && data.length > 0) {
        content = data[0];
      }
    } catch (e) {
      console.error('Supabase title match failed:', e.message);
    }
  }

  if (!content) {
    try {

      const decodedSlug = decodeURIComponent(slug).toLowerCase();
      let localFilePath = join(process.cwd(), 'data/vrindavaani_content.json');

      if (!fs.existsSync(localFilePath)) {
        localFilePath = join(process.cwd(), 'frontend/data/vrindavaani_content.json');
      }
      if (!fs.existsSync(localFilePath)) {
        localFilePath = join(process.cwd(), 'admin/data/vrindavaani_content.json');
      }

      if (fs.existsSync(localFilePath)) {
        const fileContent = fs.readFileSync(localFilePath, 'utf8');
        const localData = JSON.parse(fileContent);

        content = localData.find(item =>
          (item.slug && item.slug.toLowerCase() === decodedSlug) ||
          (item.title && item.title.toLowerCase().replace(/\s+/g, '-') === decodedSlug)
        );
      }
    } catch (fallbackError) {
      console.error('Fallback fetch failed in content slug handler:', fallbackError.message);
    }
  }

  // Build the meta tags
  const title = content
    ? `${escapeHtml(content.title)} — ${escapeHtml(content.category || 'Sacred Verse')} | ${escapeHtml(content.author || 'Vrindopnishad')}`
    : 'Vrindopnishad Paath — वृंदोपनिषद् पाठ';

  const description = content
    ? escapeHtml(
      (content.sanskrit_text || content.hindi_text || content.description || '')
        .substring(0, 160)
        .replace(/[\r\n]+/g, ' ')
    ) + '...'
    : 'Sacred shlokas, strotras, and devotional poetry from Vrindavan saints.';

  const pageUrl = `${DOMAIN}/lyrics/${encodeURIComponent(slug)}`;
  const imageUrl = content?.image_url || 'https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png';

  // JSON-LD structured data
  const jsonLd = content ? JSON.stringify({
    "@context": "https:",
    "@type": "Article",
    "headline": content.title || "Sacred Verse",
    "description": (content.description || content.hindi_text || '').substring(0, 200),
    "author": { "@type": "Person", "name": content.author || "Vrindopnishad" },
    "publisher": {
      "@type": "Organization",
      "name": "Vrindopnishad",
      "logo": { "@type": "ImageObject", "url": "https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png" }
    },
    "mainEntityOfPage": { "@type": "WebPage", "@id": pageUrl },
    "inLanguage": ["hi", "sa", "en"],
    "genre": content.category || "Sacred Literature",
    "datePublished": content.created_at || new Date().toISOString(),
    ...(content.image_url ? { "image": content.image_url } : {})
  }) : '';





  const html = `<!doctype html>
<html lang="hi" dir="ltr">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover"/>
  <title>${title}</title>
  <meta name="description" content="${description}"/>
  <meta name="keywords" content="${escapeHtml((content?.title || '') + ', ' + (content?.author || '') + ', ' + (content?.category || '') + ', vrindopnishad, sant vaani, sacred shloka, braj rasik')}"/>
  <link rel="canonical" href="${pageUrl}"/>
  <meta property="og:type" content="article"/>
  <meta property="og:title" content="${title}"/>
  <meta property="og:description" content="${description}"/>
  <meta property="og:url" content="${pageUrl}"/>
  <meta property="og:image" content="${escapeHtml(imageUrl)}"/>
  <meta property="og:site_name" content="Vrindopnishad Paath — वृंदोपनिषद् पाठ"/>
  <meta property="og:locale" content="hi_IN"/>
  <meta name="twitter:card" content="summary_large_image"/>
  <meta name="twitter:title" content="${title}"/>
  <meta name="twitter:description" content="${description}"/>
  <meta name="twitter:image" content="${escapeHtml(imageUrl)}"/>
  ${jsonLd ? `<script type="application/ld+json">${jsonLd}</script>` : ''}
  <meta name="theme-color" content="#0D0D12"/>
  <link rel="icon" href="${DOMAIN}/favicon.ico" sizes="any"/>
  <link rel="icon" href="${DOMAIN}/favicon-32x32.png" sizes="32x32" type="image/png"/>
  <link rel="icon" href="${DOMAIN}/icon-192.png" sizes="192x192" type="image/png"/>
  <link rel="apple-touch-icon" href="${DOMAIN}/apple-touch-icon.png" sizes="180x180"/>
  <meta name="robots" content="index, follow"/>
</head>
<body>
  <div style="max-width:800px;margin:0 auto;padding:40px 20px;font-family:sans-serif;">
    <h1>${content ? escapeHtml(content.title) : 'Vrindopnishad Paath'}</h1>
    ${content?.author ? `<p><strong>Author:</strong> ${escapeHtml(content.author)}</p>` : ''}
    ${content?.category ? `<p><strong>Category:</strong> ${escapeHtml(content.category)}</p>` : ''}
    ${content?.sanskrit_text ? `<div lang="sa"><h2>Sanskrit</h2><p>${escapeHtml(content.sanskrit_text.substring(0, 1000))}</p></div>` : ''}
    ${content?.hindi_text ? `<div lang="hi"><h2>Hindi</h2><p>${escapeHtml(content.hindi_text.substring(0, 1000))}</p></div>` : ''}
    ${content?.english_text ? `<div lang="en"><h2>English</h2><p>${escapeHtml(content.english_text.substring(0, 1000))}</p></div>` : ''}
    <nav>
      <p><a href="${DOMAIN}/">Vrindopnishad Home</a> | <a href="${DOMAIN}/content">Browse All Content</a></p>
      <p><a href="${DOMAIN}/category/shloka">Shlokas</a> | <a href="${DOMAIN}/category/dham">Dham</a> | <a href="${DOMAIN}/category/saint">Saints</a></p>
    </nav>
  </div>
  <div id="root"></div>
</body>
</html>`;

  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.setHeader('Cache-Control', 'public, s-maxage=86400, stale-while-revalidate=604800');
  res.status(200).send(html);
}
