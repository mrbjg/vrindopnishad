'use client';

import React from 'react';
import { Helmet } from 'react-helmet-async';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';
import { BookOpen, Sparkles, Landmark, Award } from 'lucide-react';

const HariraeJiPage = () => {
  const pageUrl = `${SITE_URL}/who-is-harirae-ji`;
  const title = 'Who is Harirae Ji? — Biography, Teachings & Varta Literature';
  const description = 'Discover the life and spiritual contributions of Shri Harirae Ji Mahaprabhu, the prominent acharya of Pushtimarg and writer of historical Varta literature.';

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
        <script type="application/ld+json">{JSON.stringify(generateBreadcrumbSchema([{ name: 'Home', path: '/' }, { name: 'Who is Harirae Ji', path: '/who-is-harirae-ji' }]))}</script>
      </Helmet>

      <header className="mb-10 text-center max-w-3xl mx-auto">
        <div className="badge border-amber-500/20 text-amber-500 bg-amber-500/5 mb-3 uppercase tracking-widest text-[9px] font-bold">
          Acharya Profile
        </div>
        <h1 className="text-3xl md:text-5xl font-bold font-headings text-sacred-gradient mb-4">
          Shri Harirae Ji Mahaprabhu
        </h1>
        <p className="text-white/60 text-sm leading-relaxed">
          The great philosopher-saint of the Pushtimarg tradition, commentator of dynamic Varta literature, and compiler of Vaishnava history.
        </p>
      </header>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 items-stretch mb-12">
        
        <div className="lg:col-span-2 space-y-6 text-left">
          <section className="glass-card p-6 rounded-3xl border border-white/5 space-y-4">
            <h2 className="text-lg font-bold text-minimal-gold flex items-center gap-2">
              <Sparkles size={18} className="text-primary" />
              Life and Appearance
            </h2>
            <p className="text-xs text-white/70 leading-relaxed">
              Shri Harirae Ji Mahaprabhu (1612–1715 AD) was one of the most prominent acharyas in the disciplic lineage of Shri Vallabhacharya, within the Pushtimarg (path of grace) tradition. Born in Gokul, he was blessed with deep spiritual insight from childhood. 
            </p>
            <p className="text-xs text-white/70 leading-relaxed">
              He is celebrated for his absolute dedication to the service of Lord Shrinathji and is considered an embodiment of the spiritual mood of service (Bhao). He lived a long life of over a century, which he dedicated entirely to composing commentaries, writing devotional treatises, and traveling across India to establish libraries and ashrams.
            </p>
          </section>

          <section className="glass-card p-6 rounded-3xl border border-white/5 space-y-4">
            <h2 className="text-lg font-bold text-minimal-gold flex items-center gap-2">
              <BookOpen size={18} className="text-primary" />
              Literary Contributions & Varta Literature
            </h2>
            <p className="text-xs text-white/70 leading-relaxed">
              Shri Harirae Ji is historically famous for compiling and commenting on the **Varta Literature**—specifically the *Chaurasi Vaishnavan Ki Varta* (Chronicles of 84 Vaishnavas) and *Do Sau Vaishnavan Ki Varta* (Chronicles of 252 Vaishnavas). These texts form the bedrock of historical Vaishnava biography in India, detailing the lives, struggles, and devotional realizations of Vallabhacharya’s and Vitthalnath’s disciples.
            </p>
            <p className="text-xs text-white/70 leading-relaxed">
              Beyond Vartas, he wrote the *Siksha Patra* (letters of instruction)—41 letters containing detailed instructions on daily sadhana, mental control, and Vaishnava behavior. His Sanskrit commentary on Vallabhacharya’s work, *Siddhanta Muktavali*, remains a canonical guide for understanding the philosophy of Shuddhadvaita (pure non-dualism).
            </p>
          </section>
        </div>

        
        <div className="space-y-6 text-left">
          <div className="glass-card p-6 rounded-3xl border border-white/5 space-y-4 bg-white/[0.015]">
            <h3 className="font-bold text-sm text-minimal-gold uppercase tracking-wider flex items-center gap-1.5">
              <Landmark size={14} className="text-primary" />
              Quick Reference
            </h3>
            <div className="space-y-3 text-xs">
              <div className="py-2 border-b border-white/5">
                <span className="text-[9px] uppercase tracking-wider text-white/35 block">Tradition</span>
                <span className="font-bold text-white/80 mt-0.5 block">Pushtimarg (Vallabha)</span>
              </div>
              <div className="py-2 border-b border-white/5">
                <span className="text-[9px] uppercase tracking-wider text-white/35 block">Appearance Era</span>
                <span className="font-bold text-white/80 mt-0.5 block">1612–1715 AD (Vrindavan / Gokul)</span>
              </div>
              <div className="py-2 border-b border-white/5">
                <span className="text-[9px] uppercase tracking-wider text-white/35 block">Key Masterpieces</span>
                <span className="font-bold text-white/80 mt-0.5 block">Varta Commentaries, Siksha Patra</span>
              </div>
              <div className="py-2">
                <span className="text-[9px] uppercase tracking-wider text-white/35 block">Primary Sentiment</span>
                <span className="font-bold text-white/80 mt-0.5 block">Raganuga Bhakti (Pure Devotional Sentiment)</span>
              </div>
            </div>
          </div>

          <div className="glass-card p-6 rounded-3xl border border-white/5 bg-amber-500/[0.02] border-amber-500/10 space-y-3">
            <h3 className="font-bold text-xs text-primary uppercase tracking-wider flex items-center gap-1">
              <Award size={14} />
              Spiritual Legacy
            </h3>
            <p className="text-[11px] text-white/60 leading-relaxed font-light">
              "Shri Harirae Ji demonstrated that the history of devotees is as sacred as the pastimes of God Himself. His Vartas preserved the records of common men who attained divine ecstasy."
            </p>
          </div>
        </div>
      </div>

      
      <section className="glass-card p-8 rounded-3xl border border-white/5 text-left max-w-4xl mx-auto mb-12">
        <h2 className="text-xl font-bold text-minimal-gold mb-6 flex items-center gap-2">
          <BookOpen size={20} className="text-primary" />
          Frequently Asked Questions
        </h2>
        <div className="space-y-6">
          <div className="border-b border-white/5 pb-4 space-y-2">
            <h3 className="font-bold text-sm text-white/90">What is the significance of "Chaurasi Vaishnavan Ki Varta"?</h3>
            <p className="text-xs text-white/60 leading-relaxed">
              Written or compiled originally by Gokulnath and commented upon by Harirae Ji, this chronicle tells the biographical and devotional stories of the 84 direct disciples of Shri Vallabhacharya. It is written in early Braj Bhasha and highlights the personal relationship between the seeker and God.
            </p>
          </div>
          <div className="space-y-2">
            <h3 className="font-bold text-sm text-white/90">How did Harirae Ji contribute to Vrindavan literature?</h3>
            <p className="text-xs text-white/60 leading-relaxed">
              Harirae Ji helped organize manuscripts and wrote extensive commentaries bridging the intellectual Vedanta theories of Shuddhadvaita with the sweet devotional poems (padas) composed by the Ashtachap poets of Braj, making them accessible to general practitioners.
            </p>
          </div>
        </div>
      </section>

      <InternalLinks exclude={['/who-is-harirae-ji']} count={4} />
      <SEOFooter />
    </div>
  );
};

export default HariraeJiPage;
