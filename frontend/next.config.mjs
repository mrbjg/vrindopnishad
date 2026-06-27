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
        'data/saints_formatted.json'
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
        source: '/shlokas',
        destination: '/content',
        permanent: true,
      },
      {
        source: '/pilgrimage',
        destination: '/places',
        permanent: true,
      },
      {
        source: '/hi/shlokas',
        destination: '/hi/content',
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
            value: "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://www.googletagmanager.com https://www.clarity.ms https://c.bing.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: blob: https: http:; font-src 'self' data: https://fonts.gstatic.com; connect-src 'self' https: http: wss: ws:; media-src 'self' https: http: blob: data:; frame-src 'self' https: http:;",
          }
        ],
      },
    ];
  },
};

export default nextConfig;
