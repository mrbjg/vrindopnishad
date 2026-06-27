'use client';

import React from 'react';
import { Link } from '@/lib/router-compat';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';

export default function TermsPage() {
  const title = 'Terms of Service | Vrindopnishad';
  const description = 'Review the terms of service of Vrindopnishad. Learn about our content licensing, scriptural preservation policy, and non-commercial guidelines.';

  return (
    <div className="animate-fade-in max-w-4xl mx-auto">
      <article className="py-12">
        <header className="mb-12">
          <div className="badge border-amber-400/30 text-amber-400/80 bg-amber-400/5 mb-4">Guidelines & Terms</div>
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-white leading-tight">Terms of Service</h1>
          <p className="text-lg text-white/60 leading-relaxed">
            Preserving the sacred spiritual heritage of Vrindavan with integrity. Review our terms of content usage.
          </p>
        </header>

        <section className="prose-content text-white/70 space-y-6 leading-relaxed">
          <p>
            Welcome to Vrindopnishad (accessible at <strong>https://path.vrindopnishad.in</strong>). By accessing our digital ashram and scriptural library, you agree to comply with and be bound by the following terms of service.
          </p>

          <h2 className="text-2xl font-bold text-white/90 pt-4">1. Permitted Use</h2>
          <p>
            Vrindopnishad is established strictly for non-commercial, educational, devotional, and research purposes. You are welcome to browse, study, read, and listen to the audio recordings of the Sanskrit shlokas and Hindi/Braj lyrics.
          </p>

          <h2 className="text-2xl font-bold text-white/90 pt-4">2. Intellectual Property & Copyright</h2>
          <ul className="list-disc pl-6 space-y-2">
            <li>
              <strong>Public Domain Scriptures:</strong> The original Sanskrit shlokas, medieval Braj Bhasha lyrics, and historical compositions of the Rasik Saints are in the public domain and belong to the spiritual heritage of humanity.
            </li>
            <li>
              <strong>Translations and Commentary:</strong> The translations, editorial notes, biographies, and commentary rendered on this site represent proprietary archival work written by our editorial board. You may quote or copy brief selections of these translations for non-commercial educational purposes, provided you credit and link back to Vrindopnishad.
            </li>
            <li>
              <strong>AI Generated Media:</strong> Any AI-narrated audio or AI-generated visual content displayed on this site is licensed for personal devotional use only and must not be used for commercial monetization.
            </li>
          </ul>

          <h2 className="text-2xl font-bold text-white/90 pt-4">3. Conduct Guidelines</h2>
          <p>
            We request all visitors to engage with the sacred scriptures, saints, and concepts with a spirit of reverence and respect. In order to preserve server performance for everyone, automated scraping or mass querying of our database is restricted.
          </p>

          <h2 className="text-2xl font-bold text-white/90 pt-4">4. Scriptural Disclaimer</h2>
          <p>
            Our translations and notes are curated from traditional acharyas and critical prints. However, translations are approximate representations of medieval poetic bards. Seekers are encouraged to read them under the guidance of traditional lineage masters.
          </p>

          <h2 className="text-2xl font-bold text-white/90 pt-4">5. Contact</h2>
          <p>
            If you have questions regarding content attribution, manuscript updates, or corrections to any shloka, please reach out via our <Link href="/contact" className="text-amber-400 hover:underline">Contact page</Link>.
          </p>
        </section>

        <InternalLinks exclude={['/terms']} count={4} />
      </article>
      <SEOFooter />
    </div>
  );
}
