import fs from 'fs';
import path from 'path';

let sitemapManifestCache = null;

export function getSitemapManifest() {
  if (sitemapManifestCache) return sitemapManifestCache;

  const appDirectory = process.cwd();
  const possiblePaths = [
    path.join(appDirectory, 'data/sitemap_manifest.json'),
    path.join(appDirectory, 'frontend/data/sitemap_manifest.json'),
    path.join(appDirectory, 'public/data/sitemap_manifest.json'),
    path.join(appDirectory, 'frontend/public/data/sitemap_manifest.json')
  ];

  for (const p of possiblePaths) {
    if (fs.existsSync(p)) {
      try {
        const raw = fs.readFileSync(p, 'utf8');
        sitemapManifestCache = JSON.parse(raw);
        if (typeof global !== 'undefined') {
          global.sitemapManifestCache = sitemapManifestCache;
        }
        return sitemapManifestCache;
      } catch (e) {
        console.warn('[sitemapData] Failed reading manifest at ' + p, e);
      }
    }
  }

  return { content: [], saints: [], granthas: [], ragas: [] };
}
