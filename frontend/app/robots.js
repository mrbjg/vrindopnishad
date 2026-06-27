export default function robots() {
  const commonDisallows = [
    '/admin',
    '/admin-old',
    '/api',
    '/private',
    '/preview',
    '/draft',
    '/bookmarks',
    '/*.json$',
  ];

  return {
    rules: [
      {
        userAgent: ['Googlebot', 'Bingbot', 'DuckDuckBot'],
        allow: '/',
        disallow: commonDisallows,
      },
      {
        userAgent: '*',
        allow: '/',
        disallow: commonDisallows,
      }
    ],
    sitemap: 'https://path.vrindopnishad.in/sitemap.xml',
  };
}
