import React, { Suspense } from 'react';
import '../src/index.css';
import '../src/App.css';
import { ClientProviders } from '../src/contexts/ClientProviders';
import { Analytics } from '@vercel/analytics/react';
import { SpeedInsights } from '@vercel/speed-insights/react';

export const viewport = {
  width: 'device-width',
  initialScale: 1,
};

export const metadata = {
  title: 'Vrindopnishad | Divine Teachings of Vrindavan',
  description: 'A crawlable, server-rendered content platform dedicated to the sacred verses, saints, granthas, and teachings of Vrindavan.',
  alternates: {
    canonical: 'https://path.vrindopnishad.in',
  },
};

export default function RootLayout({ children }) {
  return (
    <html lang="en" className="dark">
      <body className="antialiased">
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
