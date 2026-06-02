import { 
  getAllVerses, 
  getAllSaints, 
  getAllGranthas, 
  getAllRagas, 
  getGlossaryTerms,
  ensureDataLoaded
} from '../../../src/lib/contentData';
import { STATIC_SEO_PAGES } from '../../../src/data/staticPagesData';

export async function generateStaticParams() {
  return [
    { sub: 'pages.xml' },
    { sub: 'content.xml' },
    { sub: 'saints.xml' },
    { sub: 'granthas.xml' },
    { sub: 'ragas.xml' },
    { sub: 'glossary.xml' }
  ];
}

export async function GET(request, { params }) {
  await ensureDataLoaded();
  const sub = params.sub || '';
  const type = sub.replace('.xml', '');

  let urls = [];
  const base = 'https://path.vrindopnishad.in';

  if (type === 'pages') {
    // Core routes
    urls.push(`${base}`);
    urls.push(`${base}/hi`);
    urls.push(`${base}/content`);
    urls.push(`${base}/hi/content`);
    urls.push(`${base}/saints`);
    urls.push(`${base}/hi/saints`);
    urls.push(`${base}/granthas`);
    urls.push(`${base}/hi/granthas`);
    urls.push(`${base}/ragas`);
    urls.push(`${base}/hi/ragas`);
    urls.push(`${base}/knowledge-base`);
    urls.push(`${base}/hi/knowledge-base`);

    // Static pages
    const staticSlugs = Object.keys(STATIC_SEO_PAGES);
    staticSlugs.forEach(slug => {
      urls.push(`${base}/${slug}`);
      urls.push(`${base}/hi/${slug}`);
    });
  } else if (type === 'content') {
    const items = getAllVerses();
    items.forEach(v => {
      const slug = encodeURIComponent(v.slug || v.id?.toString() || '');
      urls.push(`${base}/content/${slug}`);
      urls.push(`${base}/hi/content/${slug}`);
    });
  } else if (type === 'saints') {
    const items = getAllSaints();
    items.forEach(s => {
      const slug = encodeURIComponent(s.slug);
      urls.push(`${base}/saints/${slug}`);
      urls.push(`${base}/hi/saints/${slug}`);
    });
  } else if (type === 'granthas') {
    const items = getAllGranthas();
    items.forEach(b => {
      const slug = encodeURIComponent(b.slug);
      urls.push(`${base}/granthas/${slug}`);
      urls.push(`${base}/hi/granthas/${slug}`);
    });
  } else if (type === 'ragas') {
    const items = getAllRagas();
    items.forEach(r => {
      const slug = encodeURIComponent(r.slug);
      urls.push(`${base}/ragas/${slug}`);
      urls.push(`${base}/hi/ragas/${slug}`);
    });
  } else if (type === 'glossary') {
    const items = getGlossaryTerms();
    items.forEach(t => {
      const slug = encodeURIComponent(t.slug);
      urls.push(`${base}/glossary/${slug}`);
      urls.push(`${base}/hi/glossary/${slug}`);
    });
  } else {
    return new Response('Not Found', { status: 404 });
  }

  const xmlUrls = urls.map(url => `  <url>
    <loc>${url}</loc>
    <changefreq>weekly</changefreq>
    <priority>0.7</priority>
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
