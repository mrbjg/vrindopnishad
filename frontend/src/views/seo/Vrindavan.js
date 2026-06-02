'use client';

import React from 'react';
import { useLocation } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { SITE_URL } from '../../utils/seoSchemas';
import { STATIC_SEO_PAGES } from '../../data/staticPagesData';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';

const Vrindavan = () => {
  const location = useLocation();
  const isHindiRoute = location.pathname.startsWith('/hi');
  const slug = 'vrindavan';
  const pageUrl = `${SITE_URL}/${slug}`;
  
  const pageData = STATIC_SEO_PAGES[slug];
  const currentLangData = isHindiRoute ? pageData.hi : pageData.en;
  
  return (
    <div className="animate-fade-in max-w-4xl mx-auto">
      <Helmet>
        <title>{currentLangData.title}</title>
        <meta name="description" content={currentLangData.description} />
        <link rel="canonical" href={pageUrl} />
        <meta property="og:title" content={currentLangData.title} />
        <meta property="og:description" content={currentLangData.description} />
        <meta property="og:url" content={pageUrl} />
        <meta property="og:type" content="article" />
      </Helmet>

      <article className="py-12">
        <header className="mb-12">
          <div className="badge border-amber-400/30 text-amber-400/80 bg-amber-400/5 mb-4">
            {isHindiRoute ? 'पवित्र स्थल' : 'Sacred Place'}
          </div>
        </header>

        <section 
          className="prose-content"
          dangerouslySetInnerHTML={{ __html: currentLangData.body }}
        />

        <InternalLinks exclude={[`/${slug}`]} count={4} />
      </article>
      <SEOFooter />
    </div>
  );
};

export default Vrindavan;
