import '../src/index.css';
import '../src/App.css';
import { ClientProviders } from '../src/contexts/ClientProviders';

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
          {children}
        </ClientProviders>
      </body>
    </html>
  );
}
