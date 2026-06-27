'use client';

import React from 'react';
import { Link } from '@/lib/router-compat';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';

export default function PrivacyPage() {
  const title = 'Privacy Policy | Vrindopnishad';
  const description = 'Read the privacy policy of Vrindopnishad. Learn how we handle cookies, preferences, and local data settings.';

  return (
    <div className="animate-fade-in max-w-4xl mx-auto">
      <article className="py-12">
        <header className="mb-12">
          <div className="badge border-amber-400/30 text-amber-400/80 bg-amber-400/5 mb-4">Legal & Transparency</div>
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-white leading-tight">Privacy Policy</h1>
          <p className="text-lg text-white/60 leading-relaxed">
            Your privacy is highly valued. Explore how Vrindopnishad manages local preference caching and analytics data.
          </p>
        </header>

        <section className="prose-content text-white/70 space-y-6 leading-relaxed">
          <p>
            Welcome to Vrindopnishad (accessible at <strong>https://path.vrindopnishad.in</strong>). We are dedicated to providing a safe, clean, and distraction-free environment for exploring sacred devotional literature. Because we do not run ads or sell commercial services, our privacy practices are very minimal and focused entirely on providing a smooth user experience.
          </p>

          <h2 className="text-2xl font-bold text-white/90 pt-4">1. Information We Collect</h2>
          <p>
            Vrindopnishad operates primarily as a static/ISR information portal. We do not require you to sign in or create an account to browse our library of saints, scriptures, and verses.
          </p>
          <ul className="list-disc pl-6 space-y-2">
            <li>
              <strong>Local Preferences:</strong> We use your browser's local storage (such as <code>localStorage</code>) to save settings like your preferred theme (dark/light mode), font size preferences, audio settings, and your bookmarked shlokas. This data remains entirely on your device and is never sent to our servers.
            </li>
            <li>
              <strong>Japa Counters:</strong> Your daily chanting log (Mala logs) is stored locally on your device. We do not transmit or store your spiritual counts on any central server.
            </li>
            <li>
              <strong>Analytics Data:</strong> We use lightweight performance and analytics tracking (such as Vercel Speed Insights and Google Analytics) to monitor crawl stats and load times. This logs aggregated, non-personally identifiable technical information (e.g. browser type, referrers, region).
            </li>
          </ul>

          <h2 className="text-2xl font-bold text-white/90 pt-4">2. Cookies and Tracking</h2>
          <p>
            We do not use tracking cookies for advertising or profiling. Small session storage variables are used solely to preserve current search states or navigation states as you browse from page to page.
          </p>

          <h2 className="text-2xl font-bold text-white/90 pt-4">3. Third-Party Services</h2>
          <p>
            Our site may contain links to external scriptures, manuscript archives, or video embeddings (e.g., YouTube). These external platforms maintain their own privacy policies, and we encourage you to review them when visiting those external links.
          </p>

          <h2 className="text-2xl font-bold text-white/90 pt-4">4. Updates and Contact</h2>
          <p>
            We may update our privacy policies from time to time to align with new accessibility features. If you have questions regarding data storage or cookies, you can reach our editorial archivists via our <Link href="/contact" className="text-amber-400 hover:underline">Contact page</Link>.
          </p>
        </section>

        <InternalLinks exclude={['/privacy']} count={4} />
      </article>
      <SEOFooter />
    </div>
  );
}
