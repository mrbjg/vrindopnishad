

const SITE_URL = 'https://path.vrindopnishad.in';
const ORG_NAME = 'Vrindopnishad';
const LOGO_URL = 'https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png';

export const generateArticleSchema = (title, description, url, datePublished = '2025-01-01') => ({
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": title,
  "description": description,
  "url": url,
  "datePublished": datePublished,
  "dateModified": new Date().toISOString().split('T')[0],
  "author": {
    "@type": "Organization",
    "name": ORG_NAME,
    "url": SITE_URL
  },
  "publisher": {
    "@type": "Organization",
    "name": ORG_NAME,
    "logo": {
      "@type": "ImageObject",
      "url": LOGO_URL
    }
  },
  "mainEntityOfPage": {
    "@type": "WebPage",
    "@id": url
  },
  "inLanguage": "en"
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
