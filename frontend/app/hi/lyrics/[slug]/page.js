import React from 'react';
import { notFound, permanentRedirect } from 'next/navigation';
import Layout from '../../../../src/components/Layout';
import { Link } from '../../../../src/lib/router-compat';
import { 
  getVerseBySlug, 
  getAllVerses, 
  getAllSaints, 
  getAllGranthas, 
  getAllRagas, 
  ensureDataLoaded 
} from '../../../../src/lib/contentData';
import { generatePageMetadata } from '../../../../src/lib/metadata';
import { generateMusicCompositionSchema } from '../../../../src/lib/schemas';
import JsonLd from '../../../../src/components/seo/JsonLd';
import Breadcrumbs from '../../../../src/components/seo/Breadcrumbs';
import ShareButtons from '../../../../src/components/seo/ShareButtons';
import FAQ from '../../../../src/components/seo/FAQ';
import RelatedContent, { RelatedItem } from '../../../../src/components/seo/RelatedContent';
import ReadingTime from '../../../../src/components/seo/ReadingTime';
import LastUpdated from '../../../../src/components/seo/LastUpdated';
import AuthorCard from '../../../../src/components/seo/AuthorCard';

export async function generateStaticParams() {
  await ensureDataLoaded();
  const verses = getAllVerses().slice(0, 200);
  return verses.map(verse => ({
    slug: encodeURIComponent(verse.slug),
  }));
}

export const dynamicParams = true;

export async function generateMetadata({ params }) {
  await ensureDataLoaded();
  const decodedSlug = decodeURIComponent(params.slug);
  const verse = getVerseBySlug(decodedSlug);
  if (!verse) return {};

  const cleanAuthor = verse.author ? verse.author.replace(/जी की वाणी/g, '').replace(/जी/g, '').trim() : 'वैष्णव संत';

  return generatePageMetadata({
    title: `${verse.cleanTitle || verse.title} — मूल पाठ और व्याख्या | ${cleanAuthor} | वृंदोपनिषद्`,
    description: verse.description || `संत ${cleanAuthor} द्वारा रचित पद/भजन ${verse.title}। मूल देवनागरी पाठ, हिंदी अनुवाद, व्याख्या और श्रवण ऑडियो।`,
    path: `/lyrics/${verse.slug}`,
    keywords: [verse.cleanTitle || verse.title, 'भजन', 'पद अनुवाद', cleanAuthor, 'ब्रजभाषा काव्य'],
    type: 'music.song'
  });
}

export default async function HindiLyricsDetailPage({ params }) {
  await ensureDataLoaded();
  const decodedSlug = decodeURIComponent(params.slug);
  const verse = getVerseBySlug(decodedSlug);
  if (!verse) {
    notFound();
  }

  // Canonical redirection if slug mismatch
  if (params.slug !== verse.slug) {
    permanentRedirect(`/hi/lyrics/${verse.slug}`);
  }

  const base = 'https://path.vrindopnishad.in';
  const pageUrl = `${base}/hi/lyrics/${verse.slug}`;

  // Find related entities
  const saints = getAllSaints();
  const books = getAllGranthas();
  const ragas = getAllRagas();

  const currentAuthor = verse.author;
  let matchedSaint = null;
  if (currentAuthor) {
    const cleanAuthorKey = currentAuthor.replace(/जी की वाणी/g, '').replace(/जी/g, '').replace(/महाप्रभु/g, '').trim();
    matchedSaint = saints.find(s => s.name.includes(cleanAuthorKey) || cleanAuthorKey.includes(s.name));
  }

  let bookName = null;
  const cleanTitle = verse.title || "";
  const titleParts = cleanTitle.split(/\s+-\s+/);
  if (titleParts.length >= 2) {
    const relationText = titleParts[1].trim();
    const verseMatch = relationText.match(/\(([^)]+)\)$/);
    const textWithoutVerse = verseMatch ? relationText.replace(/\(([^)]+)\)$/, '').trim() : relationText;
    const relParts = textWithoutVerse.split(/\s*,\s*/);
    if (relParts.length >= 2) {
      bookName = relParts[1].trim();
    } else if (relParts.length === 1) {
      const val = relParts[0].trim();
      if (val.includes('वाणी') || val.includes('सागर') || val.includes('शतक') || val.includes('महिमामृत') || val.includes('दोहे') || val.includes('केलिमाल') || val.includes('चौरासी')) {
        bookName = val;
      }
    }
  }
  const matchedBook = bookName ? books.find(b => b.name === bookName) : null;

  let ragaName = null;
  const ragaRegex = /(राग\s+[^\s,;()-]+)/;
  const matchTitle = cleanTitle.match(ragaRegex);
  const matchSanskrit = verse.sanskrit_text?.match(ragaRegex);
  const matchHindi = verse.hindi_text?.match(ragaRegex);
  if (matchTitle) ragaName = matchTitle[1];
  else if (matchSanskrit) ragaName = matchSanskrit[1];
  else if (matchHindi) ragaName = matchHindi[1];
  if (ragaName) ragaName = ragaName.split(/[,]/)[0].trim();
  const matchedRaga = ragaName ? ragas.find(r => r.name === ragaName) : null;

  // Build breadcrumbs
  const breadcrumbItems = [
    { name: 'मुख्यपृष्ठ', path: '/hi' },
    { name: 'पुस्तकालय', path: '/hi/content' }
  ];
  if (matchedBook) {
    breadcrumbItems.push({ name: matchedBook.name, path: `/hi/granthas/${matchedBook.slug}` });
  }
  breadcrumbItems.push({ name: verse.cleanTitle || verse.title, path: `/hi/lyrics/${verse.slug}` });

  // Schema structured data
  const compositionSchema = generateMusicCompositionSchema({
    title: verse.cleanTitle || verse.title,
    slug: verse.slug,
    hindi_text: verse.hindi_text,
    sanskrit_text: verse.sanskrit_text,
    english_translation: verse.english_translation,
    author: verse.author,
    raga: ragaName
  });

  // Dynamic FAQs
  const faqs = [
    {
      question: `"${verse.cleanTitle || verse.title}" के रचयिता संत कौन हैं?`,
      answer: `इस पद की रचना महान रसिक संत ${verse.author || 'ब्रज रसिक धरोहर'} द्वारा की गई है।`
    }
  ];
  if (ragaName) {
    faqs.push({
      question: `"${verse.cleanTitle || verse.title}" किस शास्त्रीय राग में निबद्ध है?`,
      answer: `यह पद शास्त्रीय राग ${ragaName} में निबद्ध है।`
    });
  }
  if (matchedBook) {
    faqs.push({
      question: `यह पद किस ग्रन्थ से लिया गया है?`,
      answer: `यह पद ${matchedBook.author} द्वारा रचित ग्रन्थ "${matchedBook.name}" के अंतर्गत संकलित है।`
    });
  }

  // Cross-entity linking items
  const relatedItems = [];
  if (matchedSaint) {
    relatedItems.push({ name: matchedSaint.name, slug: matchedSaint.slug, type: 'saint' });
  }
  if (matchedBook) {
    relatedItems.push({ name: matchedBook.name, slug: matchedBook.slug, type: 'grantha' });
  }
  if (matchedRaga) {
    relatedItems.push({ name: matchedRaga.name, slug: matchedRaga.slug, type: 'raga' });
  }

  // Text contents for reading progress / estimation
  const fullTextContent = `${verse.sanskrit_text || ''} ${verse.hindi_text || ''} ${verse.english_translation || ''}`;
  const lastmodDate = verse.updated_at || verse.updatedAt || verse.created_at || verse.createdAt || '2026-06-27';

  return (
    <>
      <JsonLd data={compositionSchema} />
      <Breadcrumbs items={breadcrumbItems} />
      <Layout>
        <div className="max-w-4xl mx-auto px-4 py-8">
          <header className="mb-8 border-b border-white/5 pb-6">
            <h1 className="text-2xl md:text-4xl font-bold font-serif text-white mb-4 leading-tight">
              {verse.title}
            </h1>
            <div className="flex flex-wrap items-center gap-4 text-xs">
              {verse.category && (
                <span className="text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-full bg-amber-500/10 text-amber-400 select-none">
                  {verse.category}
                </span>
              )}
              <ReadingTime text={fullTextContent} />
              <LastUpdated date={lastmodDate} />
            </div>
          </header>

          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            {/* Main content body */}
            <div className="lg:col-span-2 space-y-8">
              {verse.sanskrit_text && (
                <section>
                  <h2 className="text-xs font-bold uppercase tracking-widest text-amber-500/80 mb-3 select-none">
                    मूल देवनागरी पाठ (श्लोक/पद)
                  </h2>
                  <div className="p-6 rounded-2xl bg-white/[0.01] border border-white/5 font-serif text-base leading-relaxed text-white/90 text-center whitespace-pre-line">
                    {verse.sanskrit_text}
                  </div>
                </section>
              )}

              {verse.hindi_text && (
                <section>
                  <h2 className="text-xs font-bold uppercase tracking-widest text-amber-500/80 mb-3 select-none">
                    हिंदी भावार्थ एवं अनुवाद
                  </h2>
                  <div className="p-6 rounded-2xl bg-white/[0.01] border border-white/5 font-serif text-sm leading-relaxed text-white/80 whitespace-pre-line">
                    {verse.hindi_text}
                  </div>
                </section>
              )}

              {verse.english_translation && (
                <section>
                  <h2 className="text-xs font-bold uppercase tracking-widest text-amber-500/80 mb-3 select-none">
                    English Commentary &amp; Translation
                  </h2>
                  <div className="p-6 rounded-2xl bg-white/[0.01] border border-white/5 text-xs leading-relaxed text-white/70 whitespace-pre-line">
                    {verse.english_translation}
                  </div>
                </section>
              )}

              {verse.description && (
                <section>
                  <h2 className="text-xs font-bold uppercase tracking-widest text-amber-500/80 mb-3 select-none">
                    लीला प्रसंग एवं व्याख्या
                  </h2>
                  <p className="text-xs text-white/60 leading-relaxed font-serif italic border-l-2 border-amber-500/30 pl-4">
                    {verse.description}
                  </p>
                </section>
              )}

              {verse.audio_url && (
                <section className="p-4 border border-white/5 rounded-2xl bg-amber-500/[0.02]">
                  <h3 className="text-xs font-bold text-white/80 mb-3 flex items-center gap-1.5">
                    <svg className="w-4 h-4 text-amber-500" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                      <path strokeLinecap="round" strokeLinejoin="round" d="M15.536 8.464a5 5 0 010 7.072m2.828-9.9a9 9 0 010 12.728M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" />
                    </svg>
                    <span>सस्वर वाणी पाठ सुनें</span>
                  </h3>
                  <audio src={verse.audio_url} controls className="w-full h-9 outline-none" />
                </section>
              )}

              <AuthorCard
                name={verse.author || 'ब्रज रसिक धरोहर मण्डल'}
                role={matchedSaint ? 'रसिक संत' : 'ग्रन्थ संपादक'}
                slug={matchedSaint?.slug}
              />

              <ShareButtons title={`वृंदोपनिषद् पर "${verse.cleanTitle || verse.title}" का पाठ और व्याख्या पढ़ें`} />

              <FAQ questions={faqs} title="शास्त्र जिज्ञासा एवं समाधान" />

              <RelatedContent items={relatedItems} />
            </div>

            {/* Sidebar widgets */}
            <div className="space-y-6">
              {matchedSaint && (
                <div className="p-5 border border-white/5 rounded-2xl bg-white/[0.01]">
                  <h3 className="text-[10px] font-bold uppercase tracking-widest text-amber-500/80 mb-3 select-none">
                    रसिक संत परिचय
                  </h3>
                  <h4 className="text-sm font-bold font-serif text-white mb-1.5">{matchedSaint.name}</h4>
                  <p className="text-[11px] text-white/50 leading-relaxed line-clamp-3 mb-3">
                    {matchedSaint.rawItem?.biographyHi || 'वृन्दावन की रसिक उपासना परंपरा के महान वैष्णव संत।'}
                  </p>
                  <Link href={`/hi/saints/${matchedSaint.slug}`} className="text-[11px] font-medium text-amber-500 hover:text-amber-400">
                    विस्तृत जीवनी पढ़ें →
                  </Link>
                </div>
              )}

              {matchedBook && (
                <div className="p-5 border border-white/5 rounded-2xl bg-white/[0.01]">
                  <h3 className="text-[10px] font-bold uppercase tracking-widest text-amber-500/80 mb-3 select-none">
                    मूल स्त्रोत ग्रन्थ
                  </h3>
                  <h4 className="text-sm font-bold font-serif text-white mb-1.5">{matchedBook.name}</h4>
                  <p className="text-[11px] text-white/50 leading-relaxed line-clamp-2 mb-3">
                    रचयिता: {matchedBook.author}
                  </p>
                  <Link href={`/hi/granthas/${matchedBook.slug}`} className="text-[11px] font-medium text-amber-500 hover:text-amber-400">
                    ग्रन्थ के अन्य पद देखें →
                  </Link>
                </div>
              )}
            </div>
          </div>
        </div>
      </Layout>
    </>
  );
}
export const revalidate = 604800;
