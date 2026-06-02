'use client';

import React from 'react';
import { Link } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';

import { faqData } from '../../data/faqData';

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
