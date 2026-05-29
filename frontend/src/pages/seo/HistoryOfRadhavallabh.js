import React from 'react';
import { Helmet } from 'react-helmet-async';
import { BookOpen, Landmark, Award, Calendar, ShieldCheck } from 'lucide-react';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';

const HistoryOfRadhavallabh = () => {
  const pageUrl = `${SITE_URL}/history-of-radhavallabh-sampradaya`;
  const title = 'History of Radha Vallabh Sampradaya — Founder, Philosophy & Temples';
  const description = 'An in-depth historical and theological guide to the Radhavallabh Sampradaya of Vrindavan, founded by Shri Hit Harivansh Mahaprabhu. Learn about Sahachari Bhava and Radha Dasya.';

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
        <script type="application/ld+json">
          {JSON.stringify(generateBreadcrumbSchema([
            { name: 'Home', path: '/' },
            { name: 'History of Radha Vallabh Sampradaya', path: '/history-of-radhavallabh-sampradaya' }
          ]))}
        </script>
      </Helmet>

      <header className="mb-10 text-center max-w-3xl mx-auto">
        <div className="badge border-amber-500/20 text-amber-500 bg-amber-500/5 mb-3 uppercase tracking-widest text-[9px] font-bold">
          Pillar Article • Sampradaya History
        </div>
        <h1 className="text-3xl md:text-5xl font-bold font-headings text-sacred-gradient mb-4">
          Complete History of Radha Vallabh Sampradaya
        </h1>
        <p className="text-white/60 text-sm leading-relaxed">
          Discover the origin, philosophical foundations, disciplic lineage, and historical temples of the Radhavallabh school of Vaishnavism in Vrindavan.
        </p>
      </header>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 items-stretch mb-12">
        
        <div className="lg:col-span-2 space-y-8 text-left">
          
          <section className="glass-card p-6 rounded-3xl border border-white/5 space-y-4">
            <h2 className="text-lg font-bold text-minimal-gold flex items-center gap-2">
              <Calendar size={18} className="text-primary" />
              1. The Divine Appearance of Shri Hit Harivansh Mahaprabhu
            </h2>
            <p className="text-xs text-white/70 leading-relaxed">
              The Radha Vallabh Sampradaya was founded in the 16th century by the great saint-reformer **Shri Hit Harivansh Mahaprabhu** (1502–1552 AD). Born in Baad village near Mathura, Mahaprabhu is worshiped in the Vaishnava tradition as the direct incarnation of Lord Krishna’s divine flute (Vamshi). From his early childhood, he showed signs of deep devotional absorption (Bhava), remaining detached from worldly play and composing sweet verses.
            </p>
            <p className="text-xs text-white/70 leading-relaxed">
              At the age of thirty-two, inspired by Srimati Radharani herself in a dream, Hit Harivansh left for Vrindavan. Along the way, at Charthawal village, Srimati Radharani again directed him in a dream to meet a Brahmin named Atmadeva, who possessed a sacred deity of Shri Radha Vallabh Lal Ji. Following the divine command, Atmadeva gave the deity to Hit Harivansh, who brought the deity to the holy dust of Vrindavan. He installed the deity under a tree at Madan Ter (Madan Mohan hill) on Ekadashi of the bright half of Kartik month in 1534 AD.
            </p>
          </section>

          <section className="glass-card p-6 rounded-3xl border border-white/5 space-y-4">
            <h2 className="text-lg font-bold text-minimal-gold flex items-center gap-2">
              <Landmark size={18} className="text-primary" />
              2. Manifestation of Shri Radha Vallabh Lal Ji
            </h2>
            <p className="text-xs text-white/70 leading-relaxed">
              The deity of **Shri Radha Vallabh Lal Ji** is unique in Vaishnava history. In most temples, deities are carved out of stone or wood by human hands. However, according to local records, the deity of Radha Vallabh Ji was manifested directly from the heart of Lord Krishna by Srimati Radharani’s intense love. It was given to a devotee after years of rigorous penance.
            </p>
            <p className="text-xs text-white/70 leading-relaxed">
              The deity represents the combined sweet essence of the Divine Couple. Standing next to Radha Vallabh Ji is a throne (Gaddi) representing Srimati Radharani, demonstrating that She is the sovereign controller of the pastimes and that the worship is centered around Her supreme position. The temple is famous for its intricate daily rituals, including dressing the deity in seasonal garments and offering classical music during different periods of the day (Asta-kaliya Seva).
            </p>
          </section>

          <section className="glass-card p-6 rounded-3xl border border-white/5 space-y-4">
            <h2 className="text-lg font-bold text-minimal-gold flex items-center gap-2">
              <ShieldCheck size={18} className="text-primary" />
              3. Philosophical Foundation: Sahachari Bhava and Radha Dasya
            </h2>
            <p className="text-xs text-white/70 leading-relaxed">
              The philosophy of the Radha Vallabh Sampradaya is distinct from other Vaishnava schools. It does not focus on scriptural rules, ritual restrictions, or the fear of hell. Instead, it is the path of **Raganuga Bhakti** (spontaneous love) and **Rasa** (aesthetic taste). The core theology centers on **Radha Dasya** — the belief that Srimati Radharani is the supreme, absolute ruler, and Krishna Himself is completely controlled by Her love.
            </p>
            <p className="text-xs text-white/70 leading-relaxed">
              The practitioner seeks to enter the mood of a **Sahachari** (companion maidservant). A Sahachari does not desire direct union with Krishna; her supreme happiness is to witness the mutual love play of the Divine Couple inside the secluded bowers (Nikunj) and to assist them. This mood is characterized by absolute selflessness. The sampradaya also rejects the idea of physical or emotional separation (Viraha), focusing purely on the eternal, uninterrupted union (**Nitya Vihar**) in Vrindavan.
            </p>
          </section>

          <section className="glass-card p-6 rounded-3xl border border-white/5 space-y-4">
            <h2 className="text-lg font-bold text-minimal-gold flex items-center gap-2">
              <BookOpen size={18} className="text-primary" />
              4. Canonical Literature: Hit Chaurasi and Radha Sudha Nidhi
            </h2>
            <p className="text-xs text-white/70 leading-relaxed">
              The teachings and realizations of the sampradaya are preserved in two foundational texts:
            </p>
            <ul className="list-disc pl-5 text-xs text-white/70 space-y-2">
              <li>
                <strong>Hit Chaurasi (हित चौरासी)</strong>: Composed by Hit Harivansh Mahaprabhu in sweet, musical Braj Bhasha. It consists of eighty-four verses describing the confidential pastimes (Nikunj Lila) of the Divine Couple, the beauty of Srimati Radharani, and the duties of the Sahachari.
              </li>
              <li>
                <strong>Radha Sudha Nidhi (राधासुधानिधि)</strong>: A masterpiece of two hundred and seventy Sanskrit verses glorifying the lotus feet of Srimati Radharani. It represents the height of Radha Dasya poetry, where the author begs to become the servant of Radha's servants.
              </li>
            </ul>
          </section>
        </div>

        
        <div className="space-y-6 text-left">
          <div className="glass-card p-6 rounded-3xl border border-white/5 space-y-4 bg-white/[0.015]">
            <h3 className="font-bold text-sm text-minimal-gold uppercase tracking-wider flex items-center gap-1.5">
              <Landmark size={14} className="text-primary" />
              Key Details
            </h3>
            <div className="space-y-3 text-xs">
              <div className="py-2 border-b border-white/5">
                <span className="text-[9px] uppercase tracking-wider text-white/35 block">Founder Acharya</span>
                <span className="font-bold text-white/80 mt-0.5 block">Shri Hit Harivansh Mahaprabhu</span>
              </div>
              <div className="py-2 border-b border-white/5">
                <span className="text-[9px] uppercase tracking-wider text-white/35 block">Establishment Era</span>
                <span className="font-bold text-white/80 mt-0.5 block">1534 AD (Vrindavan, India)</span>
              </div>
              <div className="py-2 border-b border-white/5">
                <span className="text-[9px] uppercase tracking-wider text-white/35 block">Primary Deity</span>
                <span className="font-bold text-white/80 mt-0.5 block">Shri Radha Vallabh Lal Ji</span>
              </div>
              <div className="py-2 border-b border-white/5">
                <span className="text-[9px] uppercase tracking-wider text-white/35 block">Core Philosophy</span>
                <span className="font-bold text-white/80 mt-0.5 block">Radha Dasya & Nitya Vihar</span>
              </div>
              <div className="py-2">
                <span className="text-[9px] uppercase tracking-wider text-white/35 block">Primary Texts</span>
                <span className="font-bold text-white/80 mt-0.5 block">Hit Chaurasi, Radha Sudha Nidhi</span>
              </div>
            </div>
          </div>

          <div className="glass-card p-6 rounded-3xl border border-white/5 bg-amber-500/[0.02] border-amber-500/10 space-y-3">
            <h3 className="font-bold text-xs text-primary uppercase tracking-wider flex items-center gap-1">
              <Award size={14} />
              Spiritual Essence
            </h3>
            <p className="text-[11px] text-white/60 leading-relaxed font-light">
              "The path of Radha Vallabh does not ask for severe penance or knowledge. It asks only for the heart to be tuned to the sweet flute-song of the Nikunj, under the shade of Srimati Radharani's lotus feet."
            </p>
          </div>

          <div className="glass-card p-6 rounded-3xl border border-white/5 space-y-3">
            <h3 className="font-bold text-xs text-minimal-gold uppercase tracking-wider">
              References
            </h3>
            <ul className="text-[10px] text-white/50 space-y-2 list-decimal pl-4">
              <li>Chaurasi Vaishnavan Ki Varta</li>
              <li>Bhakti-ratnakar (Historical Text)</li>
              <li>Radhavallabh Sampradaya Siddhanta (Acharya Goswami)</li>
            </ul>
          </div>
        </div>
      </div>

      <InternalLinks exclude={['/history-of-radhavallabh-sampradaya']} count={4} />
      <SEOFooter />
    </div>
  );
};

export default HistoryOfRadhavallabh;
