'use client';

import React from 'react';
import { Link } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';

const WhatIsVrindopnishad = () => {
  const pageUrl = `${SITE_URL}/what-is-vrindopnishad`;
  const title = 'What is Vrindopnishad? — Complete Introduction to the Sacred Digital Sanctuary';
  const description = 'Learn what Vrindopnishad is — a sacred digital platform preserving Vedic knowledge, Sanskrit shlokas, devotional poetry, and spiritual wisdom from Vrindavan saints.';

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
          <div className="badge border-amber-400/30 text-amber-400/80 bg-amber-400/5 mb-4">Introduction</div>
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-white leading-tight">
            What is Vrindopnishad?
          </h1>
          <p className="text-lg text-white/60 leading-relaxed">
            A scholarly and devotional digital archive preserving the manuscript heritage, Sanskrit verses, and Braj Bhasha poetry of Vrindavan saints.
          </p>
        </header>

        <section className="prose-content">
          <h2 className="text-2xl font-bold mb-4 text-white/90">Definition & Spiritual Etymology</h2>
          <p className="text-white/70 leading-relaxed mb-6">
            The name <strong>Vrindopnishad</strong> is a compound of two profound Sanskrit terms: <em>Vrindavana</em> (वृन्दावन), the transcendental play-land of Lord Krishna, and <em>Upanishad</em> (उपनिषद्), which literally translates to "sitting down near a teacher to receive esoteric truth." Together, Vrindopnishad defines the spiritual methodology of preserving and contemplating the confidential loving devotion (Rasa-upasana) that originated in the groves of Braj.
          </p>

          <h2>Scriptural Foundation & Verse Citation</h2>
          <p className="text-white/70 leading-relaxed mb-4">
            The platform is anchored in the Vedic and Puranic traditions, specifically tracing its lineage to the teachings of the <em>Gopala-tapani Upanishad</em> (one of the mukhya Atharvaveda Upanishads) which glorifies the personal, aesthetic form of the Divine.
          </p>
          <div className="verse-card">
            <p className="devanagari">एषो हि देवः प्रदिशोऽनु सर्वाः</p>
            <p className="devanagari">पूर्वों हि जातः स उ गर्भे अन्तः।</p>
            <p className="devanagari">स एव जातः स जनिष्यमाणः</p>
            <p className="devanagari">प्रत्यङ्जनास्तिष्ठति सर्वतोमुखः॥</p>
            <p className="translation">
              <strong>Source Citation:</strong> <em>Gopala-tapani Upanishad (Uttara, Verse 32)</em>. 
              <strong>Translation:</strong> This Supreme Lord indeed pervades all directions. He is the firstborn, present in the womb, born and yet to be born. He dwells in the hearts of all living beings, looking everywhere.
            </p>
          </div>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Manuscript Archival & Preservation Vision</h2>
          <p className="text-white/70 leading-relaxed mb-6">
            Unlike general databases, Vrindopnishad is a dedicated digital conservation effort. We collaborate with scholars to archive decaying hand-written manuscripts (*pothis*). Major archival works focus on:
          </p>
          <ul className="list-disc pl-6 text-white/70 mb-6 space-y-2">
            <li><strong>Lineage Cataloging:</strong> Digitally archiving the compositions of Swami Haridas (*Kelimal*), Shri Hit Harivansh (*Hit Chaurasi*), and Shri Hariram Vyas (*Vyas Vani*).</li>
            <li><strong>Fidelity Auditing:</strong> Cross-referencing digital text files against critical prints stored at the <strong>Vrindavan Research Institute (VRI MS. No. 10425)</strong> to preserve the authentic archaic Braj dialects.</li>
            <li><strong>Audio Restoration:</strong> Recording the padas in traditional temple *Dhrupada* and *Haveli Sangeet* Ragas to maintain the oral chanting lineage.</li>
          </ul>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Original Commentary on Rasa Theology</h2>
          <p className="text-white/70 leading-relaxed mb-6">
            In traditional Vaishnavism, the ultimate truth is defined as *Raso Vai Sah* (He is indeed Rasa, the sweet aesthetic taste). While classical Upanishads explain the majesty (Aishwarya) of formless Brahman, Vrindopnishad centers around the sweetness (Madhurya) of the Divine Couple, Srimati Radharani and Shri Krishna, in the secluded groves (Nikunj) of Vrindavan. The soul\'s highest destination is not merging into the light, but entering the eternal, active service (*Prema Seva*) as a helper (*Sahachari*) in the nitya-vihar.
          </p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Stewardship and Verification</h2>
          <p className="text-white/70 leading-relaxed mb-8">
            The platform is curated by traditional Sanskrit scholars and manuscript editors. Each verse is accompanied by structural commentaries, Hinglish transliterations, and literal translations to serve both academic researchers and daily practitioners. Discover more by browsing our <Link to="/sources" className="text-primary hover:underline">Bibliography & Sources</Link> or checking our <Link to="/editorial-policy" className="text-primary hover:underline">Editorial Policy</Link>.
          </p>
        </section>

        <InternalLinks exclude={['/what-is-vrindopnishad']} count={4} />
      </article>
      <SEOFooter />
    </div>
  );
};

export default WhatIsVrindopnishad;
