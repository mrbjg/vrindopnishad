'use client';

import React from 'react';
import { Link } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';

const ImportancePage = () => {
  const pageUrl = `${SITE_URL}/importance`;
  const title = 'Importance of Vrindopnishad — Why Vedic Wisdom Matters Today';
  const description = 'Understand why Vrindopnishad is vital for preserving Vedic heritage, spiritual well-being, cultural identity, and making ancient wisdom accessible in the digital age.';

  return (
    <div className="animate-fade-in max-w-4xl mx-auto">
      <Helmet>
        <title>{title}</title>
        <meta name="description" content={description} />
        <link rel="canonical" href={pageUrl} />
        <meta property="og:title" content={title} />
        <meta property="og:description" content={description} />
        <meta property="og:url" content={pageUrl} />
        <meta property="og:type" content="article" />
      </Helmet>

      <article className="py-12">
        <header className="mb-12">
          <div className="badge border-amber-400/30 text-amber-400/80 bg-amber-400/5 mb-4">Significance</div>
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-white leading-tight">Importance of Vrindopnishad</h1>
          <p className="text-lg text-white/60 leading-relaxed">Why preserving and sharing Vedic wisdom matters more than ever in the modern world.</p>
        </header>

        <section className="prose-content">
          <h2 className="text-2xl font-bold mb-4 text-white/90">Preserving an Endangered Heritage</h2>
          <p className="text-white/70 leading-relaxed mb-6">
            The medieval scriptural heritage of the Braj region represents a high-water mark of human devotional literature. However, thousands of unique handwritten paper and palm-leaf manuscripts (*pothis*) are currently decaying. Due to high humidity, acidic ink corrosion, lack of climate-controlled environments, and infestation by insects like silverfish, these original works are rapidly turning to dust in private collections and neglected temple archives across Vrindavan and Barsana.
          </p>

          <h2>Scriptural Injunction on Hearing Glories</h2>
          <p className="text-white/70 leading-relaxed mb-4">
            In the <em>Srimad Bhagavatam</em>, the Gopis sing about the life-giving nature of hearing the glories of the Divine. This verse defines the core spiritual necessity of preservation:
          </p>
          <div className="verse-card">
            <p className="devanagari">तव कथामृतं तप्तजीवनं</p>
            <p className="devanagari">कविभिरीडितं कल्मषापहम्।</p>
            <p className="devanagari">श्रवणमङ्गलं श्रीमदाततं</p>
            <p className="devanagari">भुवि गृणन्ति ते भूरिदा जनाः॥</p>
            <p className="translation">
              <strong>Source Citation:</strong> <em>Srimad Bhagavatam (Canto 10, Chapter 31, Verse 9 - Gopika Gitam)</em>. 
              <strong>Translation:</strong> The nectar of Your words is life-giving to those suffering in the material world. It is praised by the great sages and purifies all sins. Simply hearing it brings auspiciousness and spiritual wealth. Those who distribute this nectar on earth are indeed the most generous.
            </p>
          </div>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Institutional Cooperation & Conservation</h2>
          <p className="text-white/70 leading-relaxed mb-6">
            Vrindopnishad bridges this archival gap by digitizing texts directly from physical libraries under the guidance of traditional scholars. We actively cross-check transcriptions against:
          </p>
          <ul className="list-disc pl-6 text-white/70 mb-6 space-y-2">
            <li><strong>Vrindavan Research Institute (VRI):</strong> Checking manuscripts of the Haritrayi corpus dating back to Vikram Samvat 1650.</li>
            <li><strong>Radhavallabh Temple Archives:</strong> Verifying the medieval prints of <em>Hit Chaurasi</em> and commentaries by Shri Chacha Vrindavandas Ji.</li>
            <li><strong>Gita Press Editions:</strong> Using standard critical editions of the principal Upanishads and Puranic scriptures for absolute spelling fidelity.</li>
          </ul>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Bilingual Accessibility & Demography</h2>
          <p className="text-white/70 leading-relaxed mb-6">
            Historically, access to these esoteric texts was confined to scholars proficient in ancient languages like Sanskrit and classical Braj Bhasha. Vrindopnishad democratizes access by providing standard Roman transliterations (IAST) and modern English translations. This allows both the native Hindi-speaking devotees and the global academic diaspora to connect directly with the original meanings, devoid of arbitrary simplifications.
          </p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Original Commentary: Spiritual Medicine for the Digital Age</h2>
          <p className="text-white/70 leading-relaxed mb-8">
            The anxiety and spiritual vacuum of modern life are often aggravated by digital fragmentation. By providing a clean, dark-themed, and ad-free sanctuary for scriptural contemplation, Vrindopnishad translates the traditional concept of an ashram into the digital age. Reading these verified padas acts as a spiritual anchor, establishing inner peace and connecting seekers to the lineage of the Rasik saints. Learn more about our <Link to="/teachings" className="text-primary hover:underline">Teachings</Link> or begin practicing with our <Link to="/guide" className="text-primary hover:underline">Sadhana Guide</Link>.
          </p>
        </section>

        <InternalLinks exclude={['/importance']} count={4} />
      </article>
      <SEOFooter />
    </div>
  );
};

export default ImportancePage;
