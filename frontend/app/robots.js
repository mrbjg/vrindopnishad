export default function robots() {
  return {
    rules: {
      userAgent: '*',
      allow: '/',
      disallow: ['/admin', '/admin-old'],
    },
    sitemap: 'https://path.vrindopnishad.in/sitemap.xml',
  };
}
