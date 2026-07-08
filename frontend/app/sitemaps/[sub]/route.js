import { 
  getAllVerses, 
  getAllSaints, 
  getAllGranthas, 
  getAllRagas, 
  getGlossaryTerms,
  ensureDataLoaded
} from '../../../src/lib/contentData';
import { STATIC_SEO_PAGES } from '../../../src/data/staticPagesData';
import { FESTIVALS_DATA } from '../../../src/data/festivalsData';

export async function generateStaticParams() {
  return [
    { sub: 'pages.xml' },
    { sub: 'content.xml' },
    { sub: 'saints.xml' },
    { sub: 'granthas.xml' },
    { sub: 'ragas.xml' },
    { sub: 'glossary.xml' },
    { sub: 'festivals.xml' }
  ];
}

export async function GET(request, { params }) {
  await ensureDataLoaded();
  const sub = params.sub || '';
  const type = sub.replace('.xml', '');

  let urlItems = [];
  const base = 'https://path.vrindopnishad.in';

  if (type === 'pages') {
    // Core routes
    const coreRoutes = [
      '',
      '/hi',
      '/lyrics',
      '/hi/lyrics',
      '/saints',
      '/hi/saints',
      '/granthas',
      '/hi/granthas',
      '/ragas',
      '/hi/ragas',
      '/knowledge-base',
      '/hi/knowledge-base'
    ];

    coreRoutes.forEach(route => {
      urlItems.push({
        loc: `${base}${route}`,
        changefreq: 'daily',
        priority: '1.0',
        lastmod: '2026-06-27'
      });
    });

    // Static pages
    const staticSlugs = Object.keys(STATIC_SEO_PAGES);
    staticSlugs.forEach(slug => {
      urlItems.push({
        loc: `${base}/${slug}`,
        changefreq: 'weekly',
        priority: '0.7',
        lastmod: '2026-06-02'
      });
      urlItems.push({
        loc: `${base}/hi/${slug}`,
        changefreq: 'weekly',
        priority: '0.7',
        lastmod: '2026-06-02'
      });
    });
  } else if (type === 'content') {
    const items = getAllVerses();
    items.forEach(v => {
      const slug = encodeURIComponent(v.slug || v.id?.toString() || '');
      const lastmodDate = v.updated_at || v.updatedAt || v.created_at || v.createdAt || '2026-06-27';
      const formattedDate = new Date(lastmodDate).toISOString().split('T')[0];
      urlItems.push({
        loc: `${base}/lyrics/${slug}`,
        changefreq: 'weekly',
        priority: '0.8',
        lastmod: formattedDate
      });
      urlItems.push({
        loc: `${base}/hi/lyrics/${slug}`,
        changefreq: 'weekly',
        priority: '0.8',
        lastmod: formattedDate
      });
    });
  } else if (type === 'saints') {
    const items = getAllSaints();
    items.forEach(s => {
      const slug = encodeURIComponent(s.slug);
      const lastmodDate = s.rawItem?.updated_at || s.rawItem?.updatedAt || '2026-06-27';
      const formattedDate = new Date(lastmodDate).toISOString().split('T')[0];
      urlItems.push({
        loc: `${base}/saints/${slug}`,
        changefreq: 'weekly',
        priority: '0.9',
        lastmod: formattedDate
      });
      urlItems.push({
        loc: `${base}/hi/saints/${slug}`,
        changefreq: 'weekly',
        priority: '0.9',
        lastmod: formattedDate
      });
    });
  } else if (type === 'granthas') {
    const items = getAllGranthas();
    items.forEach(b => {
      const slug = encodeURIComponent(b.slug);
      let lastmod = '2026-06-27';
      if (b.verses && b.verses.length > 0) {
        const timestamps = b.verses.map(v => v.updated_at || v.updatedAt || v.created_at || v.createdAt).filter(Boolean);
        if (timestamps.length > 0) {
          lastmod = new Date(Math.max(...timestamps.map(t => new Date(t).getTime()))).toISOString().split('T')[0];
        }
      }
      urlItems.push({
        loc: `${base}/granthas/${slug}`,
        changefreq: 'weekly',
        priority: '0.8',
        lastmod
      });
      urlItems.push({
        loc: `${base}/hi/granthas/${slug}`,
        changefreq: 'weekly',
        priority: '0.8',
        lastmod
      });
    });
  } else if (type === 'ragas') {
    const items = getAllRagas();
    items.forEach(r => {
      const slug = encodeURIComponent(r.slug);
      let lastmod = '2026-06-27';
      if (r.verses && r.verses.length > 0) {
        const timestamps = r.verses.map(v => v.updated_at || v.updatedAt || v.created_at || v.createdAt).filter(Boolean);
        if (timestamps.length > 0) {
          lastmod = new Date(Math.max(...timestamps.map(t => new Date(t).getTime()))).toISOString().split('T')[0];
        }
      }
      urlItems.push({
        loc: `${base}/ragas/${slug}`,
        changefreq: 'weekly',
        priority: '0.8',
        lastmod
      });
      urlItems.push({
        loc: `${base}/hi/ragas/${slug}`,
        changefreq: 'weekly',
        priority: '0.8',
        lastmod
      });
    });
  } else if (type === 'glossary') {
    const items = getGlossaryTerms();
    items.forEach(t => {
      const slug = encodeURIComponent(t.slug);
      urlItems.push({
        loc: `${base}/glossary/${slug}`,
        changefreq: 'monthly',
        priority: '0.6',
        lastmod: '2026-06-27'
      });
      urlItems.push({
        loc: `${base}/hi/glossary/${slug}`,
        changefreq: 'monthly',
        priority: '0.6',
        lastmod: '2026-06-27'
      });
    });
  } else if (type === 'festivals') {
    const slugs = Object.keys(FESTIVALS_DATA);
    slugs.forEach(slug => {
      urlItems.push({
        loc: `${base}/festivals/${slug}`,
        changefreq: 'weekly',
        priority: '0.8',
        lastmod: '2026-06-27'
      });
      urlItems.push({
        loc: `${base}/hi/festivals/${slug}`,
        changefreq: 'weekly',
        priority: '0.8',
        lastmod: '2026-06-27'
      });
    });
  } else {
    return new Response('Not Found', { status: 404 });
  }

  const xmlUrls = urlItems.map(item => `  <url>
    <loc>${item.loc}</loc>
    <lastmod>${item.lastmod}</lastmod>
    <changefreq>${item.changefreq}</changefreq>
    <priority>${item.priority}</priority>
  </url>`).join('\n');

  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${xmlUrls}
</urlset>`;

  return new Response(xml, {
    headers: {
      'Content-Type': 'application/xml; charset=utf-8',
    },
  });
}
