import React from 'react';
import Layout from '../../src/components/Layout';

export const metadata = {
  title: 'About Us & Editorial Principles | Vrindopnishad Sanctuary',
  description: 'Learn about Vrindopnishad Sanctuary, our non-commercial mission to archive authentic Braj Rasik Vani, scriptural verification process, and editorial standards.',
  alternates: {
    canonical: 'https://path.vrindopnishad.in/about',
  },
};

export default function AboutPage() {
  return (
    <Layout>
      <div className="min-h-screen bg-zinc-950 text-zinc-100 py-12 px-4 sm:px-6 lg:px-8">
        <div className="max-w-4xl mx-auto space-y-12">
          {/* Header */}
          <div className="text-center space-y-4">
            <span className="inline-block px-3 py-1 bg-amber-500/10 text-amber-400 text-xs font-semibold uppercase tracking-widest rounded-full border border-amber-500/20">
              Preservation & Archival Sanctuary
            </span>
            <h1 className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">
              About Vrindopnishad
            </h1>
            <p className="text-base text-zinc-400 max-w-2xl mx-auto">
              Dedicated to preserving, indexing, and serving authentic Braj Rasik Vani, Grantha literature, and Vedic Shlokas of Vrindavan with complete accuracy and scholarly reverence.
            </p>
          </div>

          {/* Core Pillars */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="p-6 bg-zinc-900/60 border border-white/10 rounded-2xl space-y-3">
              <div className="w-10 h-10 rounded-xl bg-amber-500/20 text-amber-400 flex items-center justify-center font-bold text-lg">
                📜
              </div>
              <h3 className="text-lg font-bold text-white">Authentic Text Preservation</h3>
              <p className="text-xs text-zinc-400 leading-relaxed">
                All padavali, shlokas, and granthas are cross-referenced with traditional published works, authentic Rasik Sampraday compilations, and historical manuscript records.
              </p>
            </div>

            <div className="p-6 bg-zinc-900/60 border border-white/10 rounded-2xl space-y-3">
              <div className="w-10 h-10 rounded-xl bg-amber-500/20 text-amber-400 flex items-center justify-center font-bold text-lg">
                🏛️
              </div>
              <h3 className="text-lg font-bold text-white">Non-Commercial Pledge</h3>
              <p className="text-xs text-zinc-400 leading-relaxed">
                Vrindopnishad is a free, non-commercial digital sanctuary. We do not monetize sacred verses or collect paywalled subscriptions for devotional content.
              </p>
            </div>

            <div className="p-6 bg-zinc-900/60 border border-white/10 rounded-2xl space-y-3">
              <div className="w-10 h-10 rounded-xl bg-amber-500/20 text-amber-400 flex items-center justify-center font-bold text-lg">
                🌐
              </div>
              <h3 className="text-lg font-bold text-white">Open Attribution & API</h3>
              <p className="text-xs text-zinc-400 leading-relaxed">
                We support open citation formats (APA, MLA, BibTeX, Markdown) and provide iframe embed widgets so scholars, writers, and spiritual portals can share content easily.
              </p>
            </div>
          </div>

          {/* Editorial Guidelines */}
          <div className="p-8 bg-zinc-900/80 border border-white/10 rounded-2xl space-y-6">
            <h2 className="text-xl font-bold text-amber-400 border-b border-white/10 pb-3">
              Editorial Guidelines & Source Text Standards
            </h2>
            <div className="space-y-4 text-sm text-zinc-300 leading-relaxed">
              <p>
                <strong className="text-white">1. Source Verification:</strong> Every verse entry includes canonical titles, composer attribution (Saint/Acharya), traditional Raga setting, and Devanagari script integrity.
              </p>
              <p>
                <strong className="text-white">2. Bhasha & Translation Integrity:</strong> We provide authentic Hinglish transliterations alongside complete Hindi and English prose explanations to aid seekers worldwide while retaining Braj Bhasha linguistic nuances.
              </p>
              <p>
                <strong className="text-white">3. Security & Privacy Compliance:</strong> Vrindopnishad operates in strict accordance with RFC 9116 security standards and respects user data privacy under transparent non-tracking principles.
              </p>
            </div>
          </div>

          {/* Contact & Security Disclosure */}
          <div className="p-8 bg-gradient-to-r from-amber-950/30 to-zinc-900 border border-amber-500/20 rounded-2xl text-center space-y-4">
            <h2 className="text-xl font-bold text-white">Research & Editorial Enquiries</h2>
            <p className="text-xs text-zinc-400 max-w-lg mx-auto">
              If you represent an academic institution, manuscript archive, or devotional publication and wish to suggest additions or corrections, please reach out directly:
            </p>
            <div className="inline-flex items-center gap-3 px-6 py-2.5 bg-amber-500/10 border border-amber-500/30 rounded-full text-amber-400 text-xs font-semibold">
              <span>contact@vrindopnishad.in</span>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}
