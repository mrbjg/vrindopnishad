import { fileURLToPath } from 'url';
import path from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  optimizeFonts: false,
  staticPageGenerationTimeout: 1000,
  transpilePackages: [
    'firebase',
    '@firebase/app',
    '@firebase/database',
    '@firebase/auth',
    '@firebase/firestore',
    '@firebase/data-connect',
    '@firebase/component',
    '@firebase/util',
    '@firebase/logger'
  ],
  experimental: {
    outputFileTracingIncludes: {
      '/**/*': [
        'data/processed_cache.json',
        'data/saints_formatted.json',
        'data/vrindavaani_content.json',
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
  productionBrowserSourceMaps: false,
  webpack: (config, { dev }) => {
    config.resolve.alias['react-router-dom'] = path.resolve(__dirname, 'src/lib/router-compat.js');
    config.resolve.alias['react-helmet-async'] = path.resolve(__dirname, 'src/lib/helmet-compat.js');
    config.ignoreWarnings = [
      /Failed to parse source map/,
      /sourceMap/,
      /index\.esm\.js\.map/
    ];
    if (dev) {
      config.devtool = false;
    }
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
        source: '/hi/book/:slug',
        destination: '/hi/granthas/:slug',
        permanent: true,
      },
      {
        source: '/books',
        destination: '/granthas',
        permanent: true,
      },
      {
        source: '/hi/books',
        destination: '/hi/granthas',
        permanent: true,
      },
      {
        source: '/books/:slug',
        destination: '/granthas/:slug',
        permanent: true,
      },
      {
        source: '/hi/books/:slug',
        destination: '/hi/granthas/:slug',
        permanent: true,
      },
      {
        source: '/dham',
        destination: '/places',
        permanent: true,
      },
      {
        source: '/dhams',
        destination: '/places',
        permanent: true,
      },
      {
        source: '/hi/dham',
        destination: '/hi/places',
        permanent: true,
      },
      {
        source: '/hi/dhams',
        destination: '/hi/places',
        permanent: true,
      },
      {
        source: '/dham/:slug',
        destination: '/places/:slug',
        permanent: true,
      },
      {
        source: '/hi/dham/:slug',
        destination: '/hi/places/:slug',
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
        source: '/hi/saint/:slug',
        destination: '/hi/saints/:slug',
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
        source: '/shlokas',
        destination: '/lyrics',
        permanent: true,
      },
      {
        source: '/hi/shlokas',
        destination: '/hi/lyrics',
        permanent: true,
      },
      {
        source: '/shlokas/:slug',
        destination: '/lyrics/:slug',
        permanent: true,
      },
      {
        source: '/shloka/:slug',
        destination: '/lyrics/:slug',
        permanent: true,
      },
      {
        source: '/hi/shlokas/:slug',
        destination: '/hi/lyrics/:slug',
        permanent: true,
      },
      {
        source: '/hi/shloka/:slug',
        destination: '/hi/lyrics/:slug',
        permanent: true,
      },
      {
        source: '/strotras',
        destination: '/lyrics',
        permanent: true,
      },
      {
        source: '/strotra',
        destination: '/lyrics',
        permanent: true,
      },
      {
        source: '/hi/strotras',
        destination: '/hi/lyrics',
        permanent: true,
      },
      {
        source: '/strotras/:slug',
        destination: '/lyrics/:slug',
        permanent: true,
      },
      {
        source: '/strotra/:slug',
        destination: '/lyrics/:slug',
        permanent: true,
      },
      {
        source: '/hi/strotras/:slug',
        destination: '/hi/lyrics/:slug',
        permanent: true,
      },
      {
        source: '/hi/strotra/:slug',
        destination: '/hi/lyrics/:slug',
        permanent: true,
      },
      {
        source: '/poems',
        destination: '/lyrics',
        permanent: true,
      },
      {
        source: '/poem',
        destination: '/lyrics',
        permanent: true,
      },
      {
        source: '/hi/poems',
        destination: '/hi/lyrics',
        permanent: true,
      },
      {
        source: '/poems/:slug',
        destination: '/lyrics/:slug',
        permanent: true,
      },
      {
        source: '/poem/:slug',
        destination: '/lyrics/:slug',
        permanent: true,
      },
      {
        source: '/hi/poems/:slug',
        destination: '/hi/lyrics/:slug',
        permanent: true,
      },
      {
        source: '/hi/poem/:slug',
        destination: '/hi/lyrics/:slug',
        permanent: true,
      },
      {
        source: '/sankirtan',
        destination: '/lyrics',
        permanent: true,
      },
      {
        source: '/sankirtans',
        destination: '/lyrics',
        permanent: true,
      },
      {
        source: '/hi/sankirtan',
        destination: '/hi/lyrics',
        permanent: true,
      },
      {
        source: '/sankirtan/:slug',
        destination: '/lyrics/:slug',
        permanent: true,
      },
      {
        source: '/sankirtans/:slug',
        destination: '/lyrics/:slug',
        permanent: true,
      },
      {
        source: '/hi/sankirtan/:slug',
        destination: '/hi/lyrics/:slug',
        permanent: true,
      },
      {
        source: '/hi/sankirtans/:slug',
        destination: '/hi/lyrics/:slug',
        permanent: true,
      },
      {
        source: '/pilgrimage',
        destination: '/places',
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
            key: 'Access-Control-Allow-Origin',
            value: '*',
          },
          {
            key: 'Access-Control-Allow-Methods',
            value: 'GET, POST, PUT, DELETE, OPTIONS',
          },
          {
            key: 'Access-Control-Allow-Headers',
            value: 'X-Requested-With, Content-Type, Authorization, Accept, rsc, next-router-state-tree, next-router-prefetch, next-url',
          },
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
            value: "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://www.googletagmanager.com https://www.clarity.ms https://c.bing.com https://translate.google.com https://translate.googleapis.com https://apis.google.com https://*.googleapis.com https://www.gstatic.com https://unpkg.com https://cdn.jsdelivr.net https://va.vercel-scripts.com https://*.vercel-scripts.com https://vercel.live https://*.vercel.live https://santvaanig-default-rtdb.asia-southeast1.firebasedatabase.app https://santvaanig-default-rtdb.firebaseio.com https://*.firebasedatabase.app https://*.asia-southeast1.firebasedatabase.app https://*.firebaseio.com https://*.firebase.com https://*.vercel.app; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://translate.googleapis.com https://cdnjs.cloudflare.com https://cdn.jsdelivr.net; font-src 'self' data: https://fonts.gstatic.com https://cdnjs.cloudflare.com; img-src 'self' data: blob: https: http:; connect-src 'self' https: http: wss: ws: https://va.vercel-scripts.com https://*.vercel-scripts.com https://vercel.live https://*.vercel.live https://santvaanig-default-rtdb.asia-southeast1.firebasedatabase.app wss://santvaanig-default-rtdb.asia-southeast1.firebasedatabase.app https://santvaanig-default-rtdb.firebaseio.com wss://santvaanig-default-rtdb.firebaseio.com https://*.firebasedatabase.app https://*.asia-southeast1.firebasedatabase.app https://*.firebaseio.com https://*.firebase.com https://*.googleapis.com https://*.vercel.app; media-src 'self' data: blob: https: http:; object-src 'self' data:; frame-src 'self' https: http: https://vercel.live https://*.vercel.live https://santvaanig-default-rtdb.asia-southeast1.firebasedatabase.app https://santvaanig-default-rtdb.firebaseio.com https://*.firebasedatabase.app https://*.asia-southeast1.firebasedatabase.app https://*.firebaseio.com https://*.firebase.com https://*.googleapis.com https://*.vercel.app;",
          }
        ],
      },
    ];
  },
};

export default nextConfig;
