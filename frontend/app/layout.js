import '../src/index.css';
import '../src/App.css';
import { ClientProviders } from '../src/contexts/ClientProviders';

export const metadata = {
  title: 'Vrindopnishad | Divine Teachings of Vrindavan',
  description: 'A crawlable, server-rendered content platform dedicated to the sacred verses, saints, granthas, and teachings of Vrindavan.',
  viewport: 'width=device-width, initial-scale=1, maximum-scale=5',
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
