import { fileURLToPath } from 'url';
import path from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  optimizeFonts: false,
  experimental: {
    outputFileTracingIncludes: {
      '/**/*': [
        'data/processed_cache.json',
        'data/saints_formatted.json',
        'data/brajrasik_hi_full.json',
        'public/data/content_backup.json',
        'public/data/relations_backup.json'
      ]
    }
  },
  eslint: {
    ignoreDuringBuilds: true,
  },
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '**',
      },
      {
        protocol: 'http',
        hostname: '**',
      }
    ],
  },
  webpack: (config) => {
    config.resolve.alias['react-router-dom'] = path.resolve(__dirname, 'src/lib/router-compat.js');
    config.resolve.alias['react-helmet-async'] = path.resolve(__dirname, 'src/lib/helmet-compat.js');
    return config;
  },
  async redirects() {
    return [
      {
        source: '/book/:slug',
        destination: '/granthas/:slug',
        permanent: true,
      },
      {
        source: '/saint/:slug',
        destination: '/saints/:slug',
        permanent: true,
      },
      {
        source: '/raga/:slug',
        destination: '/ragas/:slug',
        permanent: true,
      },
      {
        source: '/hi/raga/:slug',
        destination: '/hi/ragas/:slug',
        permanent: true,
      },
      {
        source: '/books',
        destination: '/granthas',
        permanent: true,
      },
      {
        source: '/hi/book/:slug',
        destination: '/hi/granthas/:slug',
        permanent: true,
      },
      {
        source: '/hi/saint/:slug',
        destination: '/hi/saints/:slug',
        permanent: true,
      },
      {
        source: '/hi/books',
        destination: '/hi/granthas',
        permanent: true,
      },
      {
        source: '/content/:slug',
        destination: '/lyrics/:slug',
        permanent: true,
      },
      {
        source: '/hi/content/:slug',
        destination: '/hi/lyrics/:slug',
        permanent: true,
      },
      {
        source: '/content',
        destination: '/lyrics',
        permanent: true,
      },
      {
        source: '/hi/content',
        destination: '/hi/lyrics',
        permanent: true,
      },
      {
        source: '/shlokas',
        destination: '/lyrics',
        permanent: true,
      },
      {
        source: '/pilgrimage',
        destination: '/places',
        permanent: true,
      },
      {
        source: '/hi/shlokas',
        destination: '/hi/lyrics',
        permanent: true,
      },
      {
        source: '/hi/pilgrimage',
        destination: '/hi/places',
        permanent: true,
      },
    ];
  },
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'X-Frame-Options',
            value: 'SAMEORIGIN',
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin',
          },
          {
            key: 'Content-Security-Policy',
            value: "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://www.googletagmanager.com https://www.clarity.ms https://c.bing.com https://translate.google.com https://translate.googleapis.com https://apis.google.com https://www.gstatic.com https://unpkg.com https://cdn.jsdelivr.net; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://translate.googleapis.com https://cdnjs.cloudflare.com https://cdn.jsdelivr.net; font-src 'self' data: https://fonts.gstatic.com https://cdnjs.cloudflare.com; img-src 'self' data: blob: https: http:; connect-src 'self' https: http: wss: ws:; media-src 'self' data: blob: https: http:; frame-src 'self' https: http:;",
          }
        ],
      },
    ];
  },
};

export default nextConfig;
