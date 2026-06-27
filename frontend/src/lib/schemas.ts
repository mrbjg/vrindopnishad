import { SITE_URL, ORG_NAME, LOGO_URL } from './metadata';

export interface BreadcrumbItem {
  name: string;
  path: string;
}

export interface FAQItem {
  question: string;
  answer: string;
}

// 1. Site-wide Organization Schema
export const generateOrganizationSchema = () => ({
  "@context": "https://schema.org",
  "@type": "Organization",
  "@id": `${SITE_URL}/#organization`,
  "name": ORG_NAME,
  "url": SITE_URL,
  "logo": {
    "@type": "ImageObject",
    "url": `${SITE_URL}/official-logo-dark.svg`,
    "caption": ORG_NAME
  },
  "sameAs": [
    "https://facebook.com/vrindopnishad",
    "https://instagram.com/vrindopnishad",
    "https://twitter.com/vrindopnishad"
  ]
});

// 2. Site-wide WebSite Schema
export const generateWebSiteSchema = () => ({
  "@context": "https://schema.org",
  "@type": "WebSite",
  "@id": `${SITE_URL}/#website`,
  "name": ORG_NAME,
  "url": SITE_URL,
  "potentialAction": {
    "@type": "SearchAction",
    "target": `${SITE_URL}/search?q={search_term_string}`,
    "query-input": "required name=search_term_string"
  }
});

// 3. WebPage Schema
export const generateWebPageSchema = (title: string, description: string, url: string) => ({
  "@context": "https://schema.org",
  "@type": "WebPage",
  "@id": `${url}/#webpage`,
  "url": url,
  "name": title,
  "description": description,
  "isPartOf": {
    "@id": `${SITE_URL}/#website`
  }
});

// 4. BreadcrumbList Schema
export const generateBreadcrumbSchema = (items: BreadcrumbItem[]) => ({
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": items.map((item, index) => ({
    "@type": "ListItem",
    "position": index + 1,
    "name": item.name,
    "item": item.path.startsWith('http') ? item.path : `${SITE_URL}${item.path}`
  }))
});

// 5. Article & BlogPosting Schema
export const generateArticleSchema = (
  title: string,
  description: string,
  url: string,
  datePublished = '2025-01-15',
  dateModified = '2026-06-02',
  authorName = 'Braj Rasik Heritage Board',
  image = `${SITE_URL}/official-logo-dark.svg`
) => ({
  "@context": "https://schema.org",
  "@type": "Article",
  "@id": `${url}/#article`,
  "isPartOf": {
    "@id": `${url}/#webpage`
  },
  "headline": title,
  "description": description,
  "image": image,
  "datePublished": datePublished,
  "dateModified": dateModified,
  "inLanguage": ["en", "hi"],
  "author": {
    "@type": "Person",
    "name": authorName,
    "jobTitle": "Scriptural Archivists & Editors",
    "sameAs": `${SITE_URL}/author`
  },
  "publisher": {
    "@id": `${SITE_URL}/#organization`
  },
  "mainEntityOfPage": {
    "@type": "WebPage",
    "@id": url
  }
});

// 6. FAQPage Schema
export const generateFAQSchema = (questions: FAQItem[]) => ({
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

// 7. Person / Saint Schema
export const generatePersonSchema = (saint: {
  name: string;
  hinglishName?: string;
  biography?: string;
  slug: string;
  imageUrl?: string;
}) => ({
  "@context": "https://schema.org",
  "@type": "Person",
  "@id": `${SITE_URL}/saints/${saint.slug}/#person`,
  "name": saint.name,
  "alternateName": saint.hinglishName && saint.hinglishName !== saint.name ? saint.hinglishName : undefined,
  "description": saint.biography || `Vaishnava saint of the Braj tradition.`,
  "image": saint.imageUrl || undefined,
  "url": `${SITE_URL}/saints/${saint.slug}`,
  "jobTitle": "Braj Rasik Saint",
  "knowsAbout": ["Vaishnavism", "Bhakti Yoga", "Braj Rasik Heritage", "Vrindavan", "Radhavallabh Sampraday"]
});

// 8. Book / Grantha Schema
export const generateBookSchema = (book: {
  name: string;
  slug: string;
  author: string;
  verses?: Array<{ title: string; sanskrit_text?: string; hindi_text?: string }>;
}) => ({
  "@context": "https://schema.org",
  "@type": "Book",
  "@id": `${SITE_URL}/granthas/${book.slug}/#book`,
  "name": book.name,
  "url": `${SITE_URL}/granthas/${book.slug}`,
  "author": {
    "@type": "Person",
    "name": book.author
  },
  "workExample": book.verses ? book.verses.slice(0, 10).map(v => ({
    "@type": "CreativeWork",
    "name": v.title,
    "text": v.sanskrit_text || v.hindi_text
  })) : []
});

// 9. MusicComposition / Bhajan / Verse Schema
export const generateMusicCompositionSchema = (verse: {
  title: string;
  slug: string;
  hindi_text?: string;
  sanskrit_text?: string;
  english_translation?: string;
  author?: string;
  raga?: string;
}) => ({
  "@context": "https://schema.org",
  "@type": "MusicComposition",
  "@id": `${SITE_URL}/content/${verse.slug}/#composition`,
  "name": verse.title,
  "composer": {
    "@type": "Person",
    "name": verse.author || "Braj Rasik Heritage"
  },
  "lyricist": {
    "@type": "Person",
    "name": verse.author || "Braj Rasik Heritage"
  },
  "lyrics": {
    "@type": "CreativeWork",
    "text": verse.hindi_text || verse.sanskrit_text || verse.english_translation
  },
  "genre": "Bhajan / Devotional Pad",
  "inLanguage": "hi",
  "musicArrangement": verse.raga ? `Raga ${verse.raga}` : undefined
});

// 10. DefinedTerm Schema for Glossary
export const generateDefinedTermSchema = (term: {
  term: string;
  devanagari: string;
  definition: string;
  slug: string;
}) => ({
  "@context": "https://schema.org",
  "@type": "DefinedTerm",
  "@id": `${SITE_URL}/glossary/${term.slug}/#definedterm`,
  "name": term.term,
  "alternateName": term.devanagari,
  "description": term.definition,
  "inDefinedTermSet": {
    "@type": "DefinedTermSet",
    "name": "Vrindopnishad Glossary of Braj Rasik Theology",
    "url": `${SITE_URL}/glossary`
  }
});

// 11. ImageObject Schema
export const generateImageObjectSchema = (url: string, caption?: string) => ({
  "@context": "https://schema.org",
  "@type": "ImageObject",
  "url": url,
  "caption": caption || "Vrindopnishad Media Image"
});

// 12. VideoObject Schema
export const generateVideoObjectSchema = (video: {
  name: string;
  description: string;
  thumbnailUrl: string;
  uploadDate: string;
  contentUrl: string;
}) => ({
  "@context": "https://schema.org",
  "@type": "VideoObject",
  "name": video.name,
  "description": video.description,
  "thumbnailUrl": video.thumbnailUrl,
  "uploadDate": video.uploadDate,
  "contentUrl": video.contentUrl
});
