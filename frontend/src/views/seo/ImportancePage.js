'use client';

import React from 'react';
import { Link } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
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
        <script type="application/ld+json">{JSON.stringify(generateArticleSchema(title, description, pageUrl))}</script>
        <script type="application/ld+json">{JSON.stringify(generateBreadcrumbSchema([{ name: 'Home', path: '/' }, { name: 'Importance', path: '/importance' }]))}</script>
      </Helmet>

      <article className="py-12">
        <header className="mb-12">
          <div className="badge border-amber-400/30 text-amber-400/80 bg-amber-400/5 mb-4">Significance</div>
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-white leading-tight">Importance of Vrindopnishad</h1>
          <p className="text-lg text-white/60 leading-relaxed">Why preserving and sharing Vedic wisdom matters more than ever in the modern world.</p>
        </header>

        <section className="prose-content">
          <h2 className="text-2xl font-bold mb-4 text-white/90">Preserving an Endangered Heritage</h2>
          <p className="text-white/70 leading-relaxed mb-6">India's spiritual literary heritage represents one of humanity's greatest intellectual and artistic achievements — a continuous tradition of contemplative literature spanning over five millennia. Yet this heritage faces unprecedented threats in the modern era. Traditional systems of knowledge transmission — the guru-shishya parampara, temple-based education, ashram learning — are weakening under the pressures of urbanization, modernization, and changing social structures. Manuscripts decay in neglected libraries, elderly scholars pass away without transmitting their knowledge, and living traditions risk being reduced to museum exhibits.</p>
          <p className="text-white/70 leading-relaxed mb-6">Vrindopnishad addresses this cultural emergency with urgency and reverence. The <Link to="/origin" className="text-primary hover:underline">origins of the platform</Link> lie in the recognition that digital preservation is not a luxury but a necessity. Every verse saved on the platform, every devotional poem transcribed and made searchable, every philosophical text made accessible to a global audience — these are acts of cultural preservation with implications that extend far beyond the present moment.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Spiritual Well-being in the Modern World</h2>
          <p className="text-white/70 leading-relaxed mb-6">The modern world, for all its material achievements, faces a profound crisis of meaning. Rates of depression, anxiety, loneliness, and existential despair are rising across the globe, particularly among younger generations. While material abundance has increased, inner fulfillment remains elusive for many. The <Link to="/teachings" className="text-primary hover:underline">teachings preserved on Vrindopnishad</Link> offer time-tested wisdom for addressing this inner crisis — not through escapism or denial of modern realities, but through a deeper understanding of human nature and purpose.</p>
          <p className="text-white/70 leading-relaxed mb-6">The Vedic and Bhakti traditions understand that lasting happiness cannot be found in external circumstances alone but must be cultivated through inner transformation. The practices of meditation, devotional chanting, contemplative reading, and selfless service — all abundantly documented on the platform — are practical tools for developing inner peace, purpose, and joy. In this sense, Vrindopnishad is not merely a repository of old texts but a pharmacy of spiritual medicines for modern ailments.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Cultural Identity and Continuity</h2>
          <p className="text-white/70 leading-relaxed mb-6">For the Indian diaspora and for young Indians growing up in increasingly globalized environments, maintaining a connection with their spiritual and cultural heritage is both a challenge and a deep need. Vrindopnishad serves as a bridge between generations and geographies, allowing a young professional in London or Silicon Valley to access the same devotional verses their grandparents chanted in a village temple. This cultural continuity — maintained not through rigid traditionalism but through living, accessible engagement — is vital for psychological well-being and community cohesion.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Global Contribution to Spiritual Knowledge</h2>
          <p className="text-white/70 leading-relaxed mb-6">The <Link to="/philosophy" className="text-primary hover:underline">philosophical traditions</Link> preserved on Vrindopnishad are not merely of parochial interest but represent a global heritage of human wisdom. Concepts like karma, dharma, yoga, and moksha have already entered global discourse, often in diluted or distorted forms. Vrindopnishad contributes to a more authentic, nuanced understanding of these concepts by presenting them in their original context, with proper scholarly commentary and devotional sensitivity.</p>
          <p className="text-white/70 leading-relaxed mb-6">In an era of increasing intercultural dialogue and comparative philosophy, platforms like Vrindopnishad play a crucial role in ensuring that India's spiritual traditions are represented accurately and with integrity. The <Link to="/comparison-with-upanishads" className="text-primary hover:underline">scholarly comparisons</Link> available on the platform model how traditional knowledge can be presented with both academic rigor and devotional warmth.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Democratizing Access to Sacred Knowledge</h2>
          <p className="text-white/70 leading-relaxed mb-6">Historically, access to India's deepest spiritual knowledge was often restricted by barriers of language (Sanskrit), caste, gender, geography, and social status. While the Bhakti movement made significant strides in breaking down these barriers, digital technology offers an unprecedented opportunity to complete this democratization. Vrindopnishad makes its entire collection freely accessible to anyone with an internet connection, regardless of their social background, geographical location, or formal education.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">The Urgency of Now</h2>
          <p className="text-white/70 leading-relaxed mb-8">The <Link to="/what-is-vrindopnishad" className="text-primary hover:underline">mission of Vrindopnishad</Link> gains urgency with each passing year. Elderly scholars who carry rare knowledge are aging. Handwritten manuscripts are deteriorating. Living traditions are fading. The window for digital preservation, while still open, will not remain open indefinitely. By supporting and engaging with Vrindopnishad, users become part of this vital preservation effort. Begin your journey by <Link to="/content" className="text-primary hover:underline">exploring the content</Link> or reading the <Link to="/devotion" className="text-primary hover:underline">devotional explanations</Link>.</p>
        </section>

        <InternalLinks exclude={['/importance']} count={4} />
      </article>
      <SEOFooter />
    </div>
  );
};

export default ImportancePage;
