export default function robots() {
  const commonDisallows = [
    '/admin',
    '/admin-old',
    '/api',
    '/private',
    '/preview',
    '/draft',
    '/bookmarks',
  ];

  const aiUserAgents = [
    'GPTBot',
    'ChatGPT-User',
    'ClaudeBot',
    'Claude-Web',
    'Anthropic-ai',
    'PerplexityBot',
    'Google-Extended',
    'Applebot-Extended',
    'Amazonbot',
    'Cohere-AI',
    'Meta-ExternalAgent',
    'Bytespider',
    'Ccbot',
  ];

  return {
    rules: [
      {
        userAgent: aiUserAgents,
        allow: [
          '/',
          '/lyrics/',
          '/hi/lyrics/',
          '/saints/',
          '/hi/saints/',
          '/granthas/',
          '/hi/granthas/',
          '/ragas/',
          '/hi/ragas/',
          '/places/',
          '/hi/places/',
          '/data/',
          '/llms.txt',
          '/llms-full.txt',
          '/.well-known/mcp.json',
          '/.well-known/ai.txt'
        ],
        disallow: commonDisallows,
      },
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
