import React, { Suspense } from 'react';
import '../src/index.css';
import '../src/App.css';
import { ClientProviders } from '../src/contexts/ClientProviders';
import { Analytics } from '@vercel/analytics/react';
import { SpeedInsights } from '@vercel/speed-insights/react';
import { Laila, Poppins, Inter, Noto_Serif_Devanagari } from 'next/font/google';
import Script from 'next/script';

const laila = Laila({
  subsets: ['latin', 'devanagari'],
  weight: ['400', '500', '600', '700'],
  variable: '--font-laila',
  display: 'swap',
});

const poppins = Poppins({
  subsets: ['latin'],
  weight: ['300', '400', '500', '600', '700'],
  variable: '--font-poppins',
  display: 'swap',
});

const inter = Inter({
  subsets: ['latin'],
  weight: ['300', '400', '500', '600', '700'],
  variable: '--font-inter',
  display: 'swap',
});

const notoSerifDevanagari = Noto_Serif_Devanagari({
  subsets: ['latin', 'devanagari'],
  weight: ['400', '500', '700'],
  variable: '--font-noto-serif-devanagari',
  display: 'swap',
});

export const viewport = {
  width: 'device-width',
  initialScale: 1,
  themeColor: '#7c2d12',
};

export const metadata = {
  metadataBase: new URL('https://path.vrindopnishad.in'),
  title: 'Vrindopnishad | Divine Teachings of Vrindavan',
  description: 'A crawlable, server-rendered content platform dedicated to the sacred verses, saints, granthas, and teachings of Vrindavan.',
  alternates: {
    canonical: '/',
    languages: {
      'en': '/',
      'hi': '/hi',
    },
  },
  keywords: [
    'Vrindopnishad', 'Radhavallabh Sampraday', 'Braj Literature', 
    'Rasik Saints', 'Granthas', 'Padavali', 'Vrindavan Devotion', 
    'Vaishnava History', 'Bhakti Poetry', 'Shloka Meaning'
  ],
  openGraph: {
    title: 'Vrindopnishad | Divine Teachings of Vrindavan',
    description: 'A crawlable, server-rendered content platform dedicated to the sacred verses, saints, granthas, and teachings of Vrindavan.',
    url: 'https://path.vrindopnishad.in',
    siteName: 'Vrindopnishad',
    locale: 'en_US',
    type: 'website',
    images: [
      {
        url: '/official-logo-dark.svg',
        width: 1200,
        height: 630,
        alt: 'Vrindopnishad Logo',
      }
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Vrindopnishad | Divine Teachings of Vrindavan',
    description: 'A crawlable, server-rendered content platform dedicated to the sacred verses, saints, granthas, and teachings of Vrindavan.',
    images: ['/official-logo-dark.svg'],
  },
  verification: {
    google: 'google27b1a7fc60901288',
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

export default function RootLayout({ children }) {
  return (
    <html lang="en" suppressHydrationWarning className={`dark ${laila.variable} ${poppins.variable} ${inter.variable} ${notoSerifDevanagari.variable}`}>
      <head>
        <script
          dangerouslySetInnerHTML={{
            __html: `(function(){
              try {
                var s = localStorage.getItem('user_settings');
                if (s) {
                  var p = JSON.parse(s);
                  var t = p.theme || 'light';
                  var darkThemes = ['dark', 'night', 'space', 'void', 'waterfall', 'cherryblossom', 'aurora'];
                  var isDark = darkThemes.indexOf(t) !== -1;
                  document.documentElement.setAttribute('data-theme', t);
                  if (p.fontSize) document.documentElement.setAttribute('data-font-size', p.fontSize);
                  if (p.fontStyle) document.documentElement.setAttribute('data-font-style', p.fontStyle);
                  if (p.layoutMode) document.documentElement.setAttribute('data-layout-mode', p.layoutMode);
                  if (isDark) {
                    document.documentElement.classList.add('dark');
                    document.documentElement.classList.remove('light-mode');
                  } else {
                    document.documentElement.classList.remove('dark');
                    document.documentElement.classList.add('light-mode');
                  }
                } else {
                  document.documentElement.classList.remove('dark');
                  document.documentElement.classList.add('light-mode');
                }
              } catch(e) {}
            })()`
          }}
        />
      </head>
      <body className="antialiased">
        <Script
          src="https://www.googletagmanager.com/gtag/js?id=G-FJWN1FJE6H"
          strategy="afterInteractive"
        />
        <Script id="google-analytics" strategy="afterInteractive">
          {`
            window.dataLayer = window.dataLayer || [];
            function gtag(){dataLayer.push(arguments);}
            gtag('js', new Date());
            gtag('config', 'G-FJWN1FJE6H');
          `}
        </Script>
        <Script id="clarity-analytics" strategy="afterInteractive">
          {`
            (function(c,l,a,r,i,t,y){
                c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
                t=l.createElement(r);t.async=1;t.src="https://www.clarity.ms/tag/"+i;
                y=l.getElementsByTagName(r)[0];y.parentNode.insertBefore(t,y);
            })(window,document,"clarity","script","ov88e7y4m6");
          `}
        </Script>
        <ClientProviders>
          <Suspense fallback={null}>
            {children}
          </Suspense>
        </ClientProviders>
        <Analytics />
        <SpeedInsights />
      </body>
    </html>
  );
}
