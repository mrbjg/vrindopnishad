

const SITE_URL = 'https://path.vrindopnishad.in';
const ORG_NAME = 'Vrindopnishad';
const LOGO_URL = 'https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png';

export const generateArticleSchema = (title, description, url, datePublished = '2025-01-15', dateModified = '2026-06-02') => ({
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": title,
  "description": description,
  "url": url,
  "datePublished": datePublished,
  "dateModified": dateModified,
  "author": {
    "@type": "Person",
    "name": "Team VrindaVaani Editorial Board",
    "jobTitle": "Scriptural Archivists & Editors",
    "sameAs": `${SITE_URL}/author`
  },
  "editor": {
    "@type": "Person",
    "name": "Swami Haridas Shastri",
    "jobTitle": "Traditional Manuscript Scholar",
    "sameAs": `${SITE_URL}/author`
  },
  "reviewedBy": {
    "@type": "Person",
    "name": "Vrindopnishad Editorial Board",
    "jobTitle": "Sanskrit Scholars & Traditional Acharyas",
    "sameAs": `${SITE_URL}/editorial-policy`
  },
  "publisher": {
    "@type": "Organization",
    "name": ORG_NAME,
    "url": SITE_URL,
    "logo": {
      "@type": "ImageObject",
      "url": "https://path.vrindopnishad.in/official-logo-dark.svg"
    }
  },
  "mainEntityOfPage": {
    "@type": "WebPage",
    "@id": url
  },
  "inLanguage": ["en", "hi"]
});

export const generateFAQSchema = (questions) => ({
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": questions.map(q => ({
    "@type": "Question",
    "name": q.question,
    "acceptedAnswer": {
      "@type": "Answer",
      "text": q.answer
    }
  }))
});

export const generateBreadcrumbSchema = (items) => ({
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": items.map((item, index) => ({
    "@type": "ListItem",
    "position": index + 1,
    "name": item.name,
    "item": `${SITE_URL}${item.path}`
  }))
});

export { SITE_URL, ORG_NAME, LOGO_URL };
