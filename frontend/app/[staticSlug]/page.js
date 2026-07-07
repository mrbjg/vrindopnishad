import React from 'react';
import { notFound } from 'next/navigation';
import Layout from '../../src/components/Layout';
import KnowledgeBaseLayout from '../../src/components/KnowledgeBaseLayout';
import { STATIC_SEO_PAGES } from '../../src/data/staticPagesData';
import { generateArticleSchema, generateBreadcrumbSchema, generateFAQSchema, SITE_URL } from '../../src/utils/seoSchemas';

// Import all static pages
import WhatIsVrindopnishad from '../../src/views/seo/WhatIsVrindopnishad';
import MeaningPage from '../../src/views/seo/MeaningPage';
import OriginPage from '../../src/views/seo/OriginPage';
import PhilosophyPage from '../../src/views/seo/PhilosophyPage';
import TeachingsPage from '../../src/views/seo/TeachingsPage';
import ImportancePage from '../../src/views/seo/ImportancePage';
import DevotionalPage from '../../src/views/seo/DevotionalPage';
import FAQPage from '../../src/views/seo/FAQPage';
import { faqData } from '../../src/data/faqData';
import ComparisonPage from '../../src/views/seo/ComparisonPage';
import GuidePage from '../../src/views/seo/GuidePage';
import BrajRasikHeritage from '../../src/views/seo/BrajRasikHeritage';
import RadhaSnataPage from '../../src/views/seo/RadhaSnataPage';
import NityaViharPage from '../../src/views/seo/NityaViharPage';
import GlossaryPage from '../../src/views/seo/GlossaryPage';
import PlacesPage from '../../src/views/seo/PlacesPage';
import HariraeJiPage from '../../src/views/seo/HariraeJiPage';
import MadhuryaBhavaPage from '../../src/views/seo/MadhuryaBhavaPage';
import RadhavallabhVsGaudiya from '../../src/views/seo/RadhavallabhVsGaudiya';
import ParikramaGuide from '../../src/views/seo/ParikramaGuide';
import HistoryOfRadhavallabh from '../../src/views/seo/HistoryOfRadhavallabh';
import MajorRasikSaints from '../../src/views/seo/MajorRasikSaints';
import AboutPage from '../../src/views/seo/AboutPage';
import EditorialPolicyPage from '../../src/views/seo/EditorialPolicyPage';
import SourcesPage from '../../src/views/seo/SourcesPage';
import ContactPage from '../../src/views/seo/ContactPage';
import PrivacyPage from '../../src/views/seo/PrivacyPage';
import TermsPage from '../../src/views/seo/TermsPage';
import ReferencesPage from '../../src/views/seo/ReferencesPage';

// Import new entity pages
import ShriHitHarivansh from '../../src/views/seo/ShriHitHarivansh';
import ShriHariraeJi from '../../src/views/seo/ShriHariraeJi';
import Vrindavan from '../../src/views/seo/Vrindavan';
import Barsana from '../../src/views/seo/Barsana';
import HitChaurasi from '../../src/views/seo/HitChaurasi';
import AuthorPage from '../../src/views/seo/AuthorPage';

const componentMap = {
  'author': AuthorPage,
  'what-is-vrindopnishad': WhatIsVrindopnishad,
  'meaning': MeaningPage,
  'origin': OriginPage,
  'philosophy': PhilosophyPage,
  'teachings': TeachingsPage,
  'importance': ImportancePage,
  'devotion': DevotionalPage,
  'faq': FAQPage,
  'comparison-with-upanishads': ComparisonPage,
  'guide': GuidePage,
  'braj-rasik-heritage': BrajRasikHeritage,
  'what-is-radha-snata': RadhaSnataPage,
  'nitya-vihar-vs-nikunj-vihar': NityaViharPage,
  'glossary': GlossaryPage,
  'places': PlacesPage,
  'who-is-harirae-ji': HariraeJiPage,
  'what-is-madhurya-and-sakhi-bhava': MadhuryaBhavaPage,
  'radhavallabh-vs-gaudiya-sampradaya': RadhavallabhVsGaudiya,
  'vrindavan-parikrama-guide': ParikramaGuide,
  'history-of-radhavallabh-sampradaya': HistoryOfRadhavallabh,
  'major-rasik-saints-of-braj': MajorRasikSaints,
  'about': AboutPage,
  'editorial-policy': EditorialPolicyPage,
  'sources': SourcesPage,
  'contact': ContactPage,
  'privacy': PrivacyPage,
  'terms': TermsPage,
  'references': ReferencesPage,
  
  // New entity pages
  'shri-hit-harivansh-mahaprabhu': ShriHitHarivansh,
  'shri-harirae-ji': ShriHariraeJi,
  'vrindavan': Vrindavan,
  'barsana': Barsana,
  'hit-chaurasi': HitChaurasi
};

export async function generateStaticParams() {
  return Object.keys(componentMap).map(slug => ({
    staticSlug: slug
  }));
}

export async function generateMetadata({ params }) {
  const pageData = STATIC_SEO_PAGES[params.staticSlug];
  if (!pageData) return {};
  const enData = pageData.en;
  return {
    title: enData.title,
    description: enData.description,
    alternates: {
      canonical: `https://path.vrindopnishad.in/${params.staticSlug}`,
    }
  };
}

export default function StaticWikiRoute({ params }) {
  const StaticComponent = componentMap[params.staticSlug];
  if (!StaticComponent) {
    notFound();
  }

  const pageData = STATIC_SEO_PAGES[params.staticSlug];
  if (!pageData) {
    notFound();
  }

  const enData = pageData.en;
  const pageUrl = `${SITE_URL}/${params.staticSlug}`;
  
  // E-E-A-T Dates logic: Static pages published in Jan 2025, modified on June 2, 2026
  const datePublished = '2025-01-15';
  const dateModified = '2026-06-02';

  const articleSchema = generateArticleSchema(enData.title, enData.description, pageUrl, datePublished, dateModified);

  const cleanPageTitle = enData.title.split('—')[0].split('|')[0].trim();
  const breadcrumbItems = [
    { name: 'Home', path: '/' },
    { name: 'Knowledge Base', path: '/knowledge-base' },
    { name: cleanPageTitle, path: `/${params.staticSlug}` }
  ];
  const breadcrumbSchema = generateBreadcrumbSchema(breadcrumbItems);

  let faqSchema = null;
  if (params.staticSlug === 'faq' && faqData) {
    faqSchema = generateFAQSchema(faqData);
  }

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(articleSchema) }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumbSchema) }}
      />
      {faqSchema && (
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(faqSchema) }}
        />
      )}
      <Layout>
        <KnowledgeBaseLayout>
          <StaticComponent />
        </KnowledgeBaseLayout>
      </Layout>
    </>
  );
}
export const revalidate = false;
