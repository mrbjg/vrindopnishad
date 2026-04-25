import React from 'react';
import { Link } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { generateFAQSchema, generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';

const faqData = [
  { question: 'What is Vrindopnishad?', answer: 'Vrindopnishad is a sacred digital platform dedicated to preserving and sharing authentic spiritual and Vedic knowledge. It hosts sacred Sanskrit shlokas, devotional strotras, spiritual poetry, and the teachings of Vrindavan saints in Hindi, Sanskrit, and English.' },
  { question: 'What does the word Vrindopnishad mean?', answer: 'Vrindopnishad combines "Vrinda" (the sacred groves of Vrindavan) and "Upanishad" (sacred, esoteric knowledge transmitted from teacher to student). Together it means "the sacred knowledge flowing from Vrindavan."' },
  { question: 'Is Vrindopnishad free to use?', answer: 'Yes, Vrindopnishad is completely free. The platform believes that sacred knowledge should be universally accessible without financial barriers.' },
  { question: 'What languages are available on the platform?', answer: 'Content is available in Sanskrit (original texts), Hindi (transliteration and commentary), and English (translations and explanations).' },
  { question: 'How is Vrindopnishad different from other spiritual websites?', answer: 'Vrindopnishad specializes in the Vrindavan devotional tradition and includes contemporary devotional literature alongside classical texts. Its contemplative design and audio features create a unique, sanctuary-like experience.' },
  { question: 'Can I listen to the verses being chanted?', answer: 'Yes, many verses on the platform include audio narrations with traditional chanting patterns, allowing you to hear the sacred sounds as they were meant to be experienced.' },
  { question: 'What types of content can I find?', answer: 'You can find sacred shlokas from the Vedas and Upanishads, devotional strotras (hymns), spiritual poetry, Bhagavad Gita verses, and contemporary devotional compositions from Vrindavan saints.' },
  { question: 'Is Vrindopnishad associated with any particular sect?', answer: 'While rooted in the Gaudiya Vaishnava tradition of Vrindavan, Vrindopnishad welcomes seekers of all backgrounds and presents content with scholarly objectivity alongside devotional reverence.' },
  { question: 'How can I start exploring the platform?', answer: 'Begin with the homepage to browse categories, or visit the content library to search and filter through the entire collection. The complete guide page provides a structured introduction for newcomers.' },
  { question: 'Does Vrindopnishad have a mobile app?', answer: 'Yes, Vrindopnishad is available as a progressive web app (PWA) that can be installed on any device, and a dedicated mobile app is also available for Android devices.' },
  { question: 'How often is new content added?', answer: 'New content is added regularly as the team continues to collect, translate, and digitize spiritual literature from the Vrindavan tradition.' },
  { question: 'Can I contribute content to Vrindopnishad?', answer: 'The platform welcomes contributions from scholars, devotees, and practitioners. Contact the team through the main Vrindopnishad website for contribution guidelines.' },
  { question: 'What is the relationship between Vrindopnishad and Vrindavan?', answer: 'Vrindopnishad is deeply rooted in the spiritual traditions of Vrindavan, the sacred town associated with Krishna. The platform preserves literature from saints and poets of Vrindavan, Barsana, Nandgaon, and Govardhan.' },
  { question: 'Are the Sanskrit texts authenticated?', answer: 'Yes, all Sanskrit texts are verified against established scholarly editions and traditional sources. The team works with Sanskrit scholars and temple authorities to ensure accuracy.' },
  { question: 'How does Vrindopnishad compare with the classical Upanishads?', answer: 'While the classical Upanishads focus on jnana (knowledge) and Brahman realization, Vrindopnishad synthesizes this Upanishadic wisdom with the Bhakti (devotional) tradition of Vrindavan. See our detailed comparison page for more.' },
];

const FAQPage = () => {
  const pageUrl = `${SITE_URL}/faq`;
  const title = 'Vrindopnishad FAQ — Frequently Asked Questions Answered';
  const description = 'Find answers to common questions about Vrindopnishad — what it is, how to use it, content types, languages, and more.';

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
        <script type="application/ld+json">{JSON.stringify(generateFAQSchema(faqData))}</script>
        <script type="application/ld+json">{JSON.stringify(generateArticleSchema(title, description, pageUrl))}</script>
        <script type="application/ld+json">{JSON.stringify(generateBreadcrumbSchema([{ name: 'Home', path: '/' }, { name: 'FAQ', path: '/faq' }]))}</script>
      </Helmet>

      <article className="py-12">
        <header className="mb-12">
          <div className="badge border-cyan-400/30 text-cyan-400/80 bg-cyan-400/5 mb-4">Questions & Answers</div>
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-white leading-tight">Frequently Asked Questions</h1>
          <p className="text-lg text-white/60 leading-relaxed">Everything you need to know about Vrindopnishad — answered clearly and comprehensively.</p>
        </header>

        <section className="prose-content">
          <p className="text-white/70 leading-relaxed mb-8">Below you'll find answers to the most common questions about <Link to="/what-is-vrindopnishad" className="text-primary hover:underline">Vrindopnishad</Link>, its <Link to="/meaning" className="text-primary hover:underline">meaning</Link>, and how to make the most of the platform.</p>

          <div className="space-y-6">
            {faqData.map((faq, index) => (
              <div key={index} className="glass-card p-6">
                <h2 className="text-lg font-bold text-white/90 mb-3">{faq.question}</h2>
                <p className="text-white/60 leading-relaxed">{faq.answer}</p>
              </div>
            ))}
          </div>

          <div className="mt-12">
            <h2 className="text-2xl font-bold mb-4 text-white/90">Still Have Questions?</h2>
            <p className="text-white/70 leading-relaxed mb-6">If your question wasn't answered above, explore our detailed pages on specific topics: <Link to="/philosophy" className="text-primary hover:underline">Philosophy</Link>, <Link to="/teachings" className="text-primary hover:underline">Teachings</Link>, <Link to="/devotion" className="text-primary hover:underline">Devotion</Link>, or the <Link to="/guide" className="text-primary hover:underline">Complete Guide</Link>. You can also <Link to="/content" className="text-primary hover:underline">browse the full content library</Link> to discover more.</p>
          </div>
        </section>

        <InternalLinks exclude={['/faq']} count={4} />
      </article>
      <SEOFooter />
    </div>
  );
};

export default FAQPage;
