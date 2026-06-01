import { fileURLToPath } from 'url';
import path from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
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
    ];
  },
};

export default nextConfig;
