export async function GET() {
  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <sitemap>
    <loc>https://path.vrindopnishad.in/sitemaps/pages.xml</loc>
  </sitemap>
  <sitemap>
    <loc>https://path.vrindopnishad.in/sitemaps/content.xml</loc>
  </sitemap>
  <sitemap>
    <loc>https://path.vrindopnishad.in/sitemaps/saints.xml</loc>
  </sitemap>
  <sitemap>
    <loc>https://path.vrindopnishad.in/sitemaps/granthas.xml</loc>
  </sitemap>
  <sitemap>
    <loc>https://path.vrindopnishad.in/sitemaps/ragas.xml</loc>
  </sitemap>
  <sitemap>
    <loc>https://path.vrindopnishad.in/sitemaps/glossary.xml</loc>
  </sitemap>
</sitemapindex>`;

  return new Response(xml, {
    headers: {
      'Content-Type': 'application/xml; charset=utf-8',
    },
  });
}
