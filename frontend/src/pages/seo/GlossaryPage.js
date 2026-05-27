import React, { useState } from 'react';
import { Helmet } from 'react-helmet-async';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';
import { Search, BookOpen, Sparkles } from 'lucide-react';

const GLOSSARY_TERMS = [
  {
    term: 'Braj Ras',
    devanagari: 'ब्रज रस',
    category: 'Theology',
    definition: 'The sweet, transcendental mellow or essence of divine love experienced in the sacred groves of Vrindavan. It is the ultimate goal of the Rasik saints, characterized by complete selflessness and absorption in the pleasure of the Divine Couple.',
    etymology: 'From "Braj" (pastoral land of Krishna) + "Rasa" (taste, nectar, emotional essence).'
  },
  {
    term: 'Nitya Vihar',
    devanagari: 'नित्य विहार',
    category: 'Lila',
    definition: 'The eternal, continuous love-play of Shri Radha and Shri Krishna in the secluded bowers of Vrindavan. Unlike other pastimes, it has no beginning, no end, and no element of physical or emotional separation (viraha).',
    etymology: 'From "Nitya" (eternal) + "Vihar" (play, roaming, pastimes).'
  },
  {
    term: 'Nikunj',
    devanagari: 'निकुंज',
    category: 'Landscape',
    definition: 'Secluded forest bowers or dynamic, lush green groves of Vrindavan. In Rasik theology, the Nikunj is the most intimate sanctuary where the confidential morning, afternoon, and nocturnal pastimes of the Divine Couple unfold in absolute privacy.',
    etymology: 'Sanskrit term for an arbor, bower, or grove of climbing plants.'
  },
  {
    term: 'Manjari Bhava',
    devanagari: 'मंजरी भाव',
    category: ' Sadhana',
    definition: 'The highly confidential mood of spiritual practice in Gaudiya Vaishnavism where the practitioner identifies as a "Manjari" (a young maidservant of Srimati Radharani). The goal is to assist in Her service without desiring any direct association with Shri Krishna.',
    etymology: 'From "Manjari" (bud, blossom, maidservant) + "Bhava" (devotional sentiment).'
  },
  {
    term: 'Sakhi Bhava',
    devanagari: 'सखी भाव',
    category: 'Sadhana',
    definition: 'The devotional sentiment of being a friend, companion, or confidante (Sakhi) to Shri Radha and Shri Krishna. Sakhis coordinate the pastimes, decorate the bowers, and share in the blissful interactions of the Divine Couple.',
    etymology: 'From "Sakhi" (female friend/companion) + "Bhava" (spiritual emotion).'
  },
  {
    term: 'Rasa',
    devanagari: 'रस',
    category: 'Philosophy',
    definition: 'The taste, flavor, or aesthetic essence of spiritual relationship. In Vaishnava theology, there are five primary rasas: Shanta (neutrality), Dasya (servitude), Sakhya (friendship), Vatsalya (parenthood), and Madhurya (conjugal love).',
    etymology: 'Sanskrit root meaning juice, essence, taste, or aesthetic flavor.'
  },
  {
    term: 'Rasik',
    devanagari: 'रसिक',
    category: 'People',
    definition: 'A spiritual connoisseur who has tasted the nectar of divine love (Rasa). A Rasik saint is one whose entire consciousness is absorbed in the sweet, intimate, non-majestic pastimes of Shri Radha and Shri Krishna in Vrindavan.',
    etymology: 'One who possesses or appreciates "Rasa" (aesthetic/spiritual flavor).'
  },
  {
    term: 'Keli Lila',
    devanagari: 'केलि लीला',
    category: 'Lila',
    definition: 'The confidential, intimate loving pastimes and play of the Divine Couple. These activities are described in great detail in Rasik poetry (Vaanis) to assist practitioners in deep visual meditation.',
    etymology: 'From "Keli" (amorous sport/play) + "Lila" (divine pastime).'
  },
  {
    term: 'Asta-kaliya-lila',
    devanagari: 'अष्टकालीन लीला',
    category: 'Lila',
    definition: 'The eight-fold daily cycle of Radha and Krishna\'s eternal pastimes in Vrindavan: Pratah (morning), Sangava (forenoon), Madhyahna (midday), Aparahna (afternoon), Sayahna (sunset), Pradosha (evening), Nisha (night), and Nishanta (dawn).',
    etymology: 'From "Asta" (eight) + "Kala" (time periods) + "Lila" (pastimes).'
  },
  {
    term: 'Yugal Sarkar',
    devanagari: 'युगल सरकार',
    category: 'Theology',
    definition: 'The Divine Couple, Srimati Radharani and Shri Krishna, worshiped together as a single, undivided theological unit. In Braj devotion, they are never conceptualized or worshiped in separation.',
    etymology: 'From "Yugal" (couple/pair) + "Sarkar" (sovereign/authority).'
  },
  {
    term: 'Radha Dasya',
    devanagari: 'राधा दास्य',
    category: 'Philosophy',
    definition: 'The philosophical premise that absolute surrender and servitude to Srimati Radharani is the highest spiritual attainment, superior even to direct service of Shri Krishna, as Krishna Himself is controlled by Radha\'s love.',
    etymology: 'From "Radha" + "Dasya" (servitude/discipleship).'
  },
  {
    term: 'Achintya Bheda Abheda',
    devanagari: 'अचिन्त्य भेदाभेद',
    category: 'Philosophy',
    definition: 'The theological doctrine of "inconceivable simultaneous oneness and difference" between the individual soul (jiva) and the Supreme Lord (Brahman). It reconciles the Advaita (non-dualism) and Dvaita (dualism) perspectives.',
    etymology: 'From "Achintya" (inconceivable) + "Bheda" (difference) + "Abheda" (oneness).'
  },
  {
    term: 'Madhurya Rasa',
    devanagari: 'माधुर्य रस',
    category: 'Philosophy',
    definition: 'The sweetest and most intense of the five devotional relationship flavors, mirroring conjugal or romantic love. It represents the highest level of intimacy and complete selflessness between the soul and God.',
    etymology: 'From "Madhurya" (sweetness/loveliness) + "Rasa" (devotional flavor).'
  },
  {
    term: 'Sampradaya',
    devanagari: 'सम्प्रदाय',
    category: 'Theology',
    definition: 'A disciplic succession of spiritual teachers and disciples through which spiritual knowledge and lineage authority are transmitted across generations. Vrindavan features four major historical Vaishnava sampradayas.',
    etymology: 'Sanskrit term meaning tradition, school of thought, or established system of transmission.'
  },
  {
    term: 'Bhao / Bhava',
    devanagari: 'भाव',
    category: 'Sadhana',
    definition: 'Ecstatic devotional emotion or sentiment. It is the preliminary stage of pure love for God (Prema), characterized by a melting of the heart, tears of joy, and a constant desire for spiritual service.',
    etymology: 'Sanskrit root meaning state of being, feeling, or spiritual emotion.'
  },
  {
    term: 'Bhajan',
    devanagari: 'भजन',
    category: 'Sadhana',
    definition: 'Spiritual chanting, singing of devotional hymns, or absorbing the mind in silent contemplation and worship of the Divine Couple.',
    etymology: 'From Sanskrit root "bhaj" meaning to revere, worship, or belong to.'
  },
  {
    term: 'Asta Sakhi',
    devanagari: 'अष्ट सखी',
    category: 'People',
    definition: 'The eight principal sakhis (eternal female companions) of Srimati Radharani in Nikunj: Lalita, Vishakha, Chitra, Champakalata, Tungavidya, Indulekha, Rangadevi, and Sudevi.',
    etymology: 'From "Asta" (eight) + "Sakhi" (companion/friend).'
  },
  {
    term: 'Kirtan',
    devanagari: 'संकीर्तन',
    category: 'Sadhana',
    definition: 'Congregational or individual singing and chanting of the holy names, attributes, and pastimes of Radha and Krishna, often accompanied by musical instruments.',
    etymology: 'From Sanskrit root "kirt" meaning to mention, praise, or glorify.'
  },
  {
    term: 'Lila',
    devanagari: 'लीला',
    category: 'Lila',
    definition: 'The transcendental, divine play or pastimes of Radha and Krishna. Unlike ordinary activities, Lila is entirely free from material karma and is executed purely for spiritual pleasure.',
    etymology: 'Sanskrit term meaning play, sport, or drama.'
  },
  {
    term: 'Seva',
    devanagari: 'सेवा',
    category: 'Sadhana',
    definition: 'Selfless devotional service performed with love for the satisfaction of the Guru, the Vaishnavas, and the Divine Couple Radha Krishna.',
    etymology: 'Sanskrit root meaning to serve, attend, or honor.'
  },
  {
    term: 'Bhakti',
    devanagari: 'भक्ति',
    category: 'Philosophy',
    definition: 'Active loving devotion and surrender to the Supreme Lord. It is both the practice (sadhana) and the ultimate goal (sadhya) of the soul\'s existence.',
    etymology: 'From "bhaj" meaning to share, distribute, or worship.'
  },
  {
    term: 'Prema',
    devanagari: 'प्रेम',
    category: 'Philosophy',
    definition: 'The highest stage of pure, unalloyed, and unconditional love for God, completely devoid of any desire for personal sensory gratification.',
    etymology: 'Sanskrit term meaning affection, divine love, or passion.'
  },
  {
    term: 'Saranagati',
    devanagari: 'शरणागति',
    category: 'Philosophy',
    definition: 'Unconditional surrender to the refuge of the Divine Couple, characterized by six limbs including humility, dedication, and faith in the Lord\'s protection.',
    etymology: 'From "Sarana" (refuge/shelter) + "Agati" (approach/surrender).'
  },
  {
    term: 'Sadhana',
    devanagari: 'साधना',
    category: 'Sadhana',
    definition: 'Spiritual practice or discipline undertaken to achieve purification of the heart and realization of divine love (Bhakti).',
    etymology: 'Sanskrit root "sadh" meaning to accomplish, succeed, or go straight to the goal.'
  },
  {
    term: 'Braj Bhasha',
    devanagari: 'ब्रजभाषा',
    category: 'Landscape',
    definition: 'The sweet, highly expressive western dialect of Hindi spoken in the Braj region. It is the primary literary language in which Rasik saints composed their sacred poetry (Vaanis).',
    etymology: 'From "Braj" (pastoral land) + "Bhasha" (language).'
  }
];

const GlossaryPage = () => {
  const pageUrl = `${SITE_URL}/glossary`;
  const title = 'Braj Rasik Glossary — Vrindavan Spiritual & Theological Terms';
  const description = 'Explore the comprehensive Braj Rasik Glossary of spiritual, theological, and devotional terms from Vrindavan, including etymology, Hindi, and English definitions.';

  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('All');

  const categories = ['All', ...new Set(GLOSSARY_TERMS.map(t => t.category))];

  const filteredTerms = GLOSSARY_TERMS.filter(t => {
    const matchesSearch = t.term.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          t.devanagari.includes(searchTerm) ||
                          t.definition.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesCategory = selectedCategory === 'All' || t.category === selectedCategory;
    return matchesSearch && matchesCategory;
  });

  return (
    <div className="animate-fade-in max-w-5xl mx-auto px-4 py-8">
      <Helmet>
        <title>{title}</title>
        <meta name="description" content={description} />
        <link rel="canonical" href={pageUrl} />
        <meta property="og:title" content={title} />
        <meta property="og:description" content={description} />
        <meta property="og:url" content={pageUrl} />
        <meta property="og:type" content="article" />
        <script type="application/ld+json">{JSON.stringify(generateArticleSchema(title, description, pageUrl))}</script>
        <script type="application/ld+json">{JSON.stringify(generateBreadcrumbSchema([{ name: 'Home', path: '/' }, { name: 'Glossary', path: '/glossary' }]))}</script>
      </Helmet>

      <header className="mb-10 text-center max-w-3xl mx-auto">
        <div className="badge border-amber-500/20 text-amber-500 bg-amber-500/5 mb-3 uppercase tracking-widest text-[9px] font-bold">
          Spiritual Encyclopedia
        </div>
        <h1 className="text-3xl md:text-5xl font-bold font-headings text-sacred-gradient mb-4">
          Braj Rasik Glossary
        </h1>
        <p className="text-white/60 text-sm leading-relaxed">
          A curated dictionary of theological terms, spiritual sentiments, and philosophical concepts from the rasik traditions of Vrindavan.
        </p>
      </header>

      {/* Filter and Search Controls */}
      <div className="glass-card p-4 rounded-2xl border border-white/5 mb-8 flex flex-col md:flex-row gap-4 items-center justify-between">
        {/* Search */}
        <div className="relative w-full md:w-80">
          <input
            type="text"
            placeholder="Search terms, Devanagari or meanings..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full bg-white/5 border border-white/10 rounded-xl py-2 pl-10 pr-4 text-xs text-white outline-none focus:border-primary/50 transition-all"
          />
          <Search size={14} className="absolute left-3.5 top-3 text-white/30" />
        </div>

        {/* Category Tabs */}
        <div className="flex flex-wrap gap-1.5 justify-center">
          {categories.map(cat => (
            <button
              key={cat}
              onClick={() => setSelectedCategory(cat)}
              className={`px-3 py-1.5 rounded-xl border text-[10px] font-bold uppercase tracking-wider transition-all ${
                selectedCategory === cat
                  ? 'border-primary bg-primary/10 text-primary'
                  : 'border-white/5 bg-white/2 text-white/50 hover:border-white/10'
              }`}
            >
              {cat}
            </button>
          ))}
        </div>
      </div>

      {/* Glossary Grid */}
      {filteredTerms.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {filteredTerms.map(t => (
            <div
              key={t.term}
              className="glass-card p-5 rounded-2xl border border-white/5 hover:border-primary/20 transition-all flex flex-col justify-between"
            >
              <div className="space-y-3">
                <div className="flex justify-between items-start border-b border-white/5 pb-2.5">
                  <div>
                    <h3 className="text-lg font-bold text-white/95 leading-tight">{t.term}</h3>
                    <span className="text-xs text-primary font-bold font-headings block mt-0.5">{t.devanagari}</span>
                  </div>
                  <span className="text-[9px] uppercase tracking-wider text-white/30 bg-white/5 px-2 py-0.5 rounded-md font-bold">
                    {t.category}
                  </span>
                </div>
                <p className="text-xs text-white/70 leading-relaxed font-light">{t.definition}</p>
              </div>

              {t.etymology && (
                <div className="mt-4 pt-3 border-t border-white/5 text-[10px] text-white/35 font-light italic leading-relaxed flex items-center gap-1.5">
                  <BookOpen size={10} className="text-primary shrink-0" />
                  <span>{t.etymology}</span>
                </div>
              )}
            </div>
          ))}
        </div>
      ) : (
        <div className="text-center py-20 glass-card rounded-2xl border border-white/5">
          <BookOpen size={48} className="text-white/15 mx-auto mb-4" />
          <h3 className="text-lg font-bold text-white/70">No terms found</h3>
          <p className="text-xs text-white/40 mt-1">Try adjusting your search query or category filters.</p>
        </div>
      )}

      {/* Structured SEO Guide */}
      <section className="mt-16 bg-white/[0.015] border border-white/5 rounded-3xl p-8 max-w-4xl mx-auto text-left">
        <h2 className="text-lg font-bold text-minimal-gold mb-4 flex items-center gap-2">
          <Sparkles size={18} className="text-primary" />
          Understanding the Language of Braj Ras
        </h2>
        <p className="text-xs text-white/60 leading-relaxed mb-4">
          The poetry and verses (Vaanis) composed by the saints of Vrindavan are primarily in <strong>Braj Bhasha</strong>, a sweet western dialect of Hindi, interspersed with technical Sanskrit theological terms. To fully appreciate the emotional depth (Bhava) of their writings, one must familiarize oneself with these foundational concepts.
        </p>
        <p className="text-xs text-white/60 leading-relaxed">
          For example, terms like <em>Nikunj</em> and <em>Nitya Vihar</em> form the core setting and activity of the supreme reality, indicating that divine union is the highest destination. In this encyclopedia, we collect and index these terms with scholarly precision to aid seekers in their daily Swadhyaya (study).
        </p>
      </section>

      <InternalLinks exclude={['/glossary']} count={4} />
      <SEOFooter />
    </div>
  );
};

export default GlossaryPage;
export { GLOSSARY_TERMS };
