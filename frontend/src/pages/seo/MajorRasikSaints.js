import React from 'react';
import { Helmet } from 'react-helmet-async';
import { BookOpen, Sparkles, Landmark, Award, Users, Compass } from 'lucide-react';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';

const MajorRasikSaints = () => {
  const pageUrl = `${SITE_URL}/major-rasik-saints-of-braj`;
  const title = 'Major Rasik Saints of Braj — Lineages, Biographies & Contributions';
  const description = 'A comprehensive guide and disciplic map of the prominent Rasik saints of Vrindavan, including Swami Haridas, Hit Harivansh, Hariram Vyas, and Dhruvdas.';

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
            { name: 'Major Rasik Saints of Braj', path: '/major-rasik-saints-of-braj' }
          ]))}
        </script>
      </Helmet>

      <header className="mb-10 text-center max-w-3xl mx-auto">
        <div className="badge border-amber-500/20 text-amber-500 bg-amber-500/5 mb-3 uppercase tracking-widest text-[9px] font-bold">
          Pillar Article • Spiritual Lineages
        </div>
        <h1 className="text-3xl md:text-5xl font-bold font-headings text-sacred-gradient mb-4">
          All Major Rasik Saints of Braj
        </h1>
        <p className="text-white/60 text-sm leading-relaxed">
          Explore the lives, disciplic lineages, devotional moods, and literary contributions of the great masters who established the Rasik tradition of Vrindavan.
        </p>
      </header>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 items-stretch mb-12">
        
        <div className="lg:col-span-2 space-y-8 text-left">
          
          <section className="glass-card p-6 rounded-3xl border border-white/5 space-y-4">
            <h2 className="text-lg font-bold text-minimal-gold flex items-center gap-2">
              <Compass size={18} className="text-primary" />
              1. Introduction to the Rasik Tradition
            </h2>
            <p className="text-xs text-white/70 leading-relaxed">
              Vrindavan’s spiritual culture is defined by the **Rasik tradition** — a distinct movement within Vaishnavism that prioritizes the tasting of divine love-mellows (Rasa) over intellectual debate or scriptural formality. A Rasik saint is a spiritual connoisseur whose mind is continuously absorbed in the intimate, sweet pastimes (Keli Lila) of Srimati Radharani and Lord Krishna inside the secluded bowers (Nikunj) of Vrindavan.
            </p>
            <p className="text-xs text-white/70 leading-relaxed">
              Historically, the tradition emerged in the 16th century during the Bhakti movement, when several great saints arrived in Vrindavan and revived its sacred groves. Rather than establishing dry schools of logic, these saints composed sweet, musical verses (Vaanis) in the local **Braj Bhasha** dialect, expressing their direct visions of the eternal pastimes.
            </p>
          </section>

          <section className="glass-card p-6 rounded-3xl border border-white/5 space-y-4">
            <h2 className="text-lg font-bold text-minimal-gold flex items-center gap-2">
              <Users size={18} className="text-primary" />
              2. The "Haritrayi" — The Spiritual Triad of Vrindavan
            </h2>
            <p className="text-xs text-white/70 leading-relaxed">
              The foundation of Vrindavan’s Rasik theology rests on the three contemporary saints known as the **Haritrayi** (the spiritual triad):
            </p>
            <div className="space-y-4 pl-4 border-l-2 border-primary/20">
              <div>
                <h3 className="font-bold text-sm text-white/95">Swami Haridas (1478–1573 AD)</h3>
                <p className="text-xs text-white/70 mt-1">
                  Revered as the incarnation of Lalita Sakhi (the chief confidante of Srimati Radharani). Swami Haridas performed bhajan in the sacred grove of Nidhivan, where his classical music was so pure that it manifested the deity of Shri Bankey Bihari Ji. He established the **Haridasi Sampradaya**, focusing purely on the eternal love-play (Nitya Vihar) devoid of any separation.
                </p>
              </div>
              <div>
                <h3 className="font-bold text-sm text-white/95">Shri Hit Harivansh Mahaprabhu (1502–1552 AD)</h3>
                <p className="text-xs text-white/70 mt-1">
                  Worshiped as the incarnation of Krishna's divine flute. He founded the **Radhavallabh Sampradaya**, establishing the historical Radha Vallabh temple and discovering Seva Kunj. Hit Harivansh introduced the path of **Radha Dasya**, where Radharani is worshiped as the supreme controller.
                </p>
              </div>
              <div>
                <h3 className="font-bold text-sm text-white/95">Shri Hariram Vyas (1510–1612 AD)</h3>
                <p className="text-xs text-white/70 mt-1">
                  Affectionately called Vyas Ji, he left a royal position in Orchha to live in the dust of Vrindavan. He established Vyas Ghera and worshiped Shri Jugal Kishor Ji. His writings (*Vyas Vani*) are famous for their bold criticism of hypocrisy and absolute emphasis on humility.
                </p>
              </div>
            </div>
          </section>

          <section className="glass-card p-6 rounded-3xl border border-white/5 space-y-4">
            <h2 className="text-lg font-bold text-minimal-gold flex items-center gap-2">
              <BookOpen size={18} className="text-primary" />
              3. The Prolific Chronicles: Shri Dhruvdas
            </h2>
            <p className="text-xs text-white/70 leading-relaxed">
              Living in the 17th century, **Shri Dhruvdas** was one of the most prolific authors of the Radhavallabh lineage. He took it upon himself to systematically record the spiritual history and theology of the earlier Rasik acharyas. His masterpiece, the **Bayalees Leela (बयालीस लीला)**, consists of forty-two distinct poetic works detailing everything from the physical and spiritual layout of Vrindavan to guidelines for daily meditation and the practice of Sahachari Bhava. His works remain the most accessed manuals for studying the philosophy of Braj Ras.
            </p>
          </section>

          <section className="glass-card p-6 rounded-3xl border border-white/5 space-y-4">
            <h2 className="text-lg font-bold text-minimal-gold flex items-center gap-2">
              <Sparkles size={18} className="text-primary" />
              4. Contemporary Continuation: Shri Premanand Ji Maharaj
            </h2>
            <p className="text-xs text-white/70 leading-relaxed">
              The Rasik tradition is not merely a historical phenomenon; it is a living lineage. In the present day, the tradition is represented by **Shri Premanand Ji Maharaj** at Shri Radha Keli Kunj in Vrindavan. Despite facing severe physical health challenges, Maharaj Ji continues to hold daily Satsangs in clear, practical Hindi, urging millions globally to chant the holy name "Radha", serve their parents, maintain high moral character, and strictly avoid speaking ill of other Vaishnavas (Ninda).
            </p>
          </section>
        </div>

        
        <div className="space-y-6 text-left">
          <div className="glass-card p-6 rounded-3xl border border-white/5 space-y-4 bg-white/[0.015]">
            <h3 className="font-bold text-sm text-minimal-gold uppercase tracking-wider flex items-center gap-1.5">
              <Landmark size={14} className="text-primary" />
              Historical Summary
            </h3>
            <div className="space-y-3 text-xs">
              <div className="py-2 border-b border-white/5">
                <span className="text-[9px] uppercase tracking-wider text-white/35 block">Total Saints Covered</span>
                <span className="font-bold text-white/80 mt-0.5 block">5 Main + Ashtachap Poets</span>
              </div>
              <div className="py-2 border-b border-white/5">
                <span className="text-[9px] uppercase tracking-wider text-white/35 block">Timeline</span>
                <span className="font-bold text-white/80 mt-0.5 block">15th Century to Present Day</span>
              </div>
              <div className="py-2 border-b border-white/5">
                <span className="text-[9px] uppercase tracking-wider text-white/35 block">Sampradayas Represented</span>
                <span className="font-bold text-white/80 mt-0.5 block">Haridasi, Radhavallabhi, Gaudiya</span>
              </div>
              <div className="py-2">
                <span className="text-[9px] uppercase tracking-wider text-white/35 block">Primary Language</span>
                <span className="font-bold text-white/80 mt-0.5 block">Braj Bhasha, Sanskrit, Hindi</span>
              </div>
            </div>
          </div>

          <div className="glass-card p-6 rounded-3xl border border-white/5 bg-amber-500/[0.02] border-amber-500/10 space-y-3">
            <h3 className="font-bold text-xs text-primary uppercase tracking-wider flex items-center gap-1">
              <Award size={14} />
              Core Principle
            </h3>
            <p className="text-[11px] text-white/60 leading-relaxed font-light">
              "The Rasik saints proved that God is not captured by Vedic scholarship or severe austerities, but is easily bound by the sweet thread of pure, selfless love."
            </p>
          </div>

          <div className="glass-card p-6 rounded-3xl border border-white/5 space-y-3">
            <h3 className="font-bold text-xs text-minimal-gold uppercase tracking-wider">
              Disciplic Lineages
            </h3>
            <ul className="text-[10px] text-white/50 space-y-2 list-decimal pl-4">
              <li>Swami Haridas disciplic chain</li>
              <li>Hit Harivansh disciplic chain</li>
              <li>Madhavgaudiya disciplic chain</li>
            </ul>
          </div>
        </div>
      </div>

      <InternalLinks exclude={['/major-rasik-saints-of-braj']} count={4} />
      <SEOFooter />
    </div>
  );
};

export default MajorRasikSaints;
