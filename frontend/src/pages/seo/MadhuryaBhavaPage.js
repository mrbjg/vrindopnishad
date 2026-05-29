import React from 'react';
import { Helmet } from 'react-helmet-async';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';
import { BookOpen, Sparkles, Compass } from 'lucide-react';

const MadhuryaBhavaPage = () => {
  const pageUrl = `${SITE_URL}/what-is-madhurya-and-sakhi-bhava`;
  const title = 'What is Madhurya Bhava & Sakhi Bhava? — Sentiments of Divine Love';
  const description = 'Understand the deep spiritual sentiments of Madhurya Bhava (conjugal love) and Sakhi Bhava (friendship/maidservant mood) in Vrindavan Vaishnavism.';

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
        <script type="application/ld+json">{JSON.stringify(generateBreadcrumbSchema([{ name: 'Home', path: '/' }, { name: 'Madhurya and Sakhi Bhava', path: '/what-is-madhurya-and-sakhi-bhava' }]))}</script>
      </Helmet>

      <header className="mb-10 text-center max-w-3xl mx-auto">
        <div className="badge border-amber-500/20 text-amber-500 bg-amber-500/5 mb-3 uppercase tracking-widest text-[9px] font-bold">
          Spiritual Sentiments
        </div>
        <h1 className="text-3xl md:text-5xl font-bold font-headings text-sacred-gradient mb-4">
          Madhurya Bhava & Sakhi Bhava
        </h1>
        <p className="text-white/60 text-sm leading-relaxed">
          An exploration of the confidential spiritual sentiments (Bhavas) of conjugal love and companion service in the rasik tradition of Vrindavan.
        </p>
      </header>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-12 items-stretch text-left">
        
        <section className="glass-card p-6 rounded-3xl border border-white/5 flex flex-col justify-between space-y-4">
          <div className="space-y-3">
            <div className="w-10 h-10 rounded-2xl bg-amber-500/5 border border-amber-500/10 flex items-center justify-center text-amber-500">
              <Sparkles size={18} />
            </div>
            <h2 className="text-xl font-bold text-minimal-gold leading-tight">
              Madhurya Bhava (माधुर्य भाव)
            </h2>
            <p className="text-xs text-white/70 leading-relaxed font-light">
              **Madhurya Bhava** represents the conjugal or romantic relationship sentiment between the soul and God. Regarded as the highest and sweetest of the five primary devotional relationships (Rasas) in Vaishnavism, it transcends the awe and reverence of majestic worship, replacing it with absolute intimacy, mutual surrender, and complete selflessness.
            </p>
            <p className="text-xs text-white/70 leading-relaxed font-light">
              In this mood, Lord Krishna is not approached as the almighty creator or king, but as the supreme beloved (Shyamasundar). Srimati Radharani is the ideal embodiment of Madhurya Bhava, where every action is performed solely for the sensory and spiritual pleasure of the Divine.
            </p>
          </div>
          <div className="border-t border-white/5 pt-3 text-[10px] text-white/35 font-light">
            Key Principle: Supreme intimacy and selfless love.
          </div>
        </section>

        
        <section className="glass-card p-6 rounded-3xl border border-white/5 flex flex-col justify-between space-y-4">
          <div className="space-y-3">
            <div className="w-10 h-10 rounded-2xl bg-sky-500/5 border border-sky-500/10 flex items-center justify-center text-sky-400">
              <Compass size={18} />
            </div>
            <h2 className="text-xl font-bold text-minimal-gold leading-tight">
              Sakhi Bhava & Manjari Bhava (सखी एवं मंजरी भाव)
            </h2>
            <p className="text-xs text-white/70 leading-relaxed font-light">
              **Sakhi Bhava** is the mood of serving as an intimate friend or female companion (Sakhi) to Shri Radha and Krishna. Sakhis (like Lalita and Vishakha) coordinate the pastimes, decorate the arbors, and directly share in the blissful sport of the Divine Couple.
            </p>
            <p className="text-xs text-white/70 leading-relaxed font-light">
              An even more confidential aspect is **Manjari Bhava** (the mood of maidservants), championed by the Gaudiya tradition. Manjaris are young assistant sakhis who serve Srimati Radharani exclusively. They do not seek direct association with Krishna; rather, their ultimate joy lies in assisting Radha in Her union, representing the highest peak of selflessness.
            </p>
          </div>
          <div className="border-t border-white/5 pt-3 text-[10px] text-white/35 font-light">
            Key Principle: Assisting Srimati Radharani in Her service.
          </div>
        </section>
      </div>

      
      <section className="glass-card p-8 rounded-3xl border border-white/5 text-left max-w-4xl mx-auto mb-12 space-y-4">
        <h2 className="text-lg font-bold text-minimal-gold flex items-center gap-2">
          <BookOpen size={18} className="text-primary" />
          The Difference in Sadhana Practice
        </h2>
        <p className="text-xs text-white/70 leading-relaxed">
          While *Madhurya Bhava* focuses on the relationship between the lover and the beloved, *Sakhi Bhava* and *Manjari Bhava* redirect this love into **assistant service (Seva)**. The practitioner of Manjari Bhava does not conceptualize themselves as Krishna’s consort, but rather as Radha’s maidservant. This removes even the slightest trace of spiritual ego, establishing a state of absolute purity.
        </p>
        <p className="text-xs text-white/70 leading-relaxed">
          Saints of Vrindavan (like Hit Harivansh and Swami Haridas) composed their Vaanis (verses) in the mood of these Sahacharis (companions), allowing practitioners to listen, chant, and mentally project themselves into the eternal groves of Nikunj for daily visualization.
        </p>
      </section>

      
      <section className="glass-card p-8 rounded-3xl border border-white/5 text-left max-w-4xl mx-auto mb-12">
        <h2 className="text-xl font-bold text-minimal-gold mb-6 flex items-center gap-2">
          <BookOpen size={20} className="text-primary" />
          Frequently Asked Questions
        </h2>
        <div className="space-y-6">
          <div className="border-b border-white/5 pb-4 space-y-2">
            <h3 className="font-bold text-sm text-white/90">What is the difference between Sakhi Bhava and Manjari Bhava?</h3>
            <p className="text-xs text-white/60 leading-relaxed">
              Sakhis have a friend-like relationship with both Radha and Krishna and sometimes participate in pastimes directly. Manjaris, being younger, serve Srimati Radharani exclusively and are allowed entry into the most private arbors (Nikunj) during intimate pastimes where older sakhis cannot go.
            </p>
          </div>
          <div className="space-y-2">
            <h3 className="font-bold text-sm text-white/90">How does one practice Sakhi Bhava?</h3>
            <p className="text-xs text-white/60 leading-relaxed">
              In Raganuga sadhana, the devotee performs mental worship (Manasi Seva) by assuming a spiritual identity (Siddha Deha) as a young sakhi in Vrindavan, daily meditating on cleaning the groves, making garlands, and dressing Srimati Radharani.
            </p>
          </div>
        </div>
      </section>

      <InternalLinks exclude={['/what-is-madhurya-and-sakhi-bhava']} count={4} />
      <SEOFooter />
    </div>
  );
};

export default MadhuryaBhavaPage;
