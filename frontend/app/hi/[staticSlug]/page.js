import React from 'react';
import { notFound } from 'next/navigation';
import Layout from '../../../src/components/Layout';
import KnowledgeBaseLayout from '../../../src/components/KnowledgeBaseLayout';
import { STATIC_SEO_PAGES } from '../../../src/data/staticPagesData';

// Import all static pages
import WhatIsVrindopnishad from '../../../src/views/seo/WhatIsVrindopnishad';
import MeaningPage from '../../../src/views/seo/MeaningPage';
import OriginPage from '../../../src/views/seo/OriginPage';
import PhilosophyPage from '../../../src/views/seo/PhilosophyPage';
import TeachingsPage from '../../../src/views/seo/TeachingsPage';
import ImportancePage from '../../../src/views/seo/ImportancePage';
import DevotionalPage from '../../../src/views/seo/DevotionalPage';
import FAQPage from '../../../src/views/seo/FAQPage';
import ComparisonPage from '../../../src/views/seo/ComparisonPage';
import GuidePage from '../../../src/views/seo/GuidePage';
import BrajRasikHeritage from '../../../src/views/seo/BrajRasikHeritage';
import RadhaSnataPage from '../../../src/views/seo/RadhaSnataPage';
import NityaViharPage from '../../../src/views/seo/NityaViharPage';
import GlossaryPage from '../../../src/views/seo/GlossaryPage';
import PlacesPage from '../../../src/views/seo/PlacesPage';
import HariraeJiPage from '../../../src/views/seo/HariraeJiPage';
import MadhuryaBhavaPage from '../../../src/views/seo/MadhuryaBhavaPage';
import RadhavallabhVsGaudiya from '../../../src/views/seo/RadhavallabhVsGaudiya';
import ParikramaGuide from '../../../src/views/seo/ParikramaGuide';
import HistoryOfRadhavallabh from '../../../src/views/seo/HistoryOfRadhavallabh';
import MajorRasikSaints from '../../../src/views/seo/MajorRasikSaints';
import AboutPage from '../../../src/views/seo/AboutPage';
import EditorialPolicyPage from '../../../src/views/seo/EditorialPolicyPage';
import SourcesPage from '../../../src/views/seo/SourcesPage';
import ContactPage from '../../../src/views/seo/ContactPage';

const componentMap = {
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
  'contact': ContactPage
};

export async function generateStaticParams() {
  return Object.keys(componentMap).map(slug => ({
    staticSlug: slug
  }));
}

export async function generateMetadata({ params }) {
  const pageData = STATIC_SEO_PAGES[params.staticSlug];
  if (!pageData) return {};
  const hiData = pageData.hi || pageData.en;
  return {
    title: hiData.title,
    description: hiData.description,
    alternates: {
      canonical: `https://path.vrindopnishad.in/hi/${params.staticSlug}`,
    }
  };
}

export default function HindiStaticWikiRoute({ params }) {
  const StaticComponent = componentMap[params.staticSlug];
  if (!StaticComponent) {
    notFound();
  }

  return (
    <Layout>
      <KnowledgeBaseLayout>
        <StaticComponent />
      </KnowledgeBaseLayout>
    </Layout>
  );
}
export const revalidate = false;
