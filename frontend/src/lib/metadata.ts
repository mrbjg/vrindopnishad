import { Metadata } from 'next';

export const SITE_URL = 'https://path.vrindopnishad.in';
export const ORG_NAME = 'Vrindopnishad';
export const LOGO_URL = 'https://path.vrindopnishad.in/official-logo-dark.svg';
export const DEFAULT_KEYWORDS = [
  'Vrindopnishad',
  'Radhavallabh Sampraday',
  'Braj Literature',
  'Rasik Saints',
  'Granthas',
  'Padavali',
  'Vrindavan Devotion',
  'Vaishnava History',
  'Bhakti Poetry',
  'Shloka Meaning'
];

interface PageMetadataProps {
  title: string;
  description: string;
  path: string;
  type?: 'website' | 'article' | 'book' | 'profile' | 'music.song' | 'music.playlist';
  image?: string;
  keywords?: string[];
  noIndex?: boolean;
}

export function generatePageMetadata({
  title,
  description,
  path,
  type = 'website',
  image = 'https://path.vrindopnishad.in/official-logo-dark.svg',
  keywords = [],
  noIndex = false
}: PageMetadataProps): Metadata {
  const cleanPath = path.startsWith('/') ? path : `/${path}`;
  
  // Strip trailing slashes and normalize /index
  const normalizedPath = cleanPath === '/' ? '' : cleanPath;
  
  // Detect if the path already starts with /hi
  const isHiPath = normalizedPath.startsWith('/hi');
  const basePath = isHiPath ? normalizedPath.substring(3) : normalizedPath;
  
  const canonicalUrl = `${SITE_URL}${normalizedPath}`;
  const absoluteImageUrl = image.startsWith('http') ? image : `${SITE_URL}${image}`;

  const allKeywords = Array.from(new Set([...DEFAULT_KEYWORDS, ...keywords]));

  // Truncate title to max 60 characters for search snippet fitting
  const truncatedTitle = title.length > 60 
    ? title.substring(0, 57) + '...' 
    : title;

  // Truncate description to max 155 characters for search snippet fitting
  const truncatedDescription = description.length > 155 
    ? description.substring(0, 152) + '...' 
    : description;

  const metadata: Metadata = {
    title: truncatedTitle,
    description: truncatedDescription,
    keywords: allKeywords,
    alternates: {
      canonical: canonicalUrl,
      languages: {
        'en': `${SITE_URL}${basePath}`,
        'hi': `${SITE_URL}/hi${basePath}`,
      }
    },
    robots: {
      index: !noIndex,
      follow: !noIndex,
      googleBot: {
        index: !noIndex,
        follow: !noIndex,
        'max-video-preview': -1,
        'max-image-preview': 'large',
        'max-snippet': -1,
      },
    },
    openGraph: {
      title: truncatedTitle,
      description: truncatedDescription,
      url: canonicalUrl,
      siteName: 'Vrindopnishad',
      locale: 'en_US',
      type,
      images: [
        {
          url: absoluteImageUrl,
          width: 1200,
          height: 630,
          alt: truncatedTitle,
        }
      ]
    },
    twitter: {
      card: 'summary_large_image',
      title: truncatedTitle,
      description: truncatedDescription,
      images: [absoluteImageUrl],
    },
    icons: {
      icon: [
        { url: '/favicon.ico', sizes: 'any' },
        { url: '/favicon-16x16.png', sizes: '16x16', type: 'image/png' },
        { url: '/favicon-32x32.png', sizes: '32x32', type: 'image/png' },
        { url: '/icon-192.png', sizes: '192x192', type: 'image/png' },
        { url: '/icon-512.png', sizes: '512x512', type: 'image/png' },
      ],
      apple: [
        { url: '/apple-touch-icon.png', sizes: '180x180', type: 'image/png' },
      ],
    },
  };

  return metadata;
}
