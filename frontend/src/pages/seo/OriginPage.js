import React from 'react';
import { Link } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';

const OriginPage = () => {
  const pageUrl = `${SITE_URL}/origin`;
  const title = 'Origin of Vrindopnishad — Historical Roots & Vrindavan Connection';
  const description = 'Discover the historical origins of Vrindopnishad, its deep connection to Vrindavan, and how ancient spiritual traditions inspired this digital sanctuary.';

  return (
    <div className="animate-fade-in max-w-4xl mx-auto">
      <Helmet>
        <title>{title}</title>
        <meta name="description" content={description} />
        <link rel="canonical" href={pageUrl} />
        <meta property="og:title" content={title} />
        <meta property="og:description" content={description} />
        <meta property="og:url" content={pageUrl} />
        <meta property="og:type" content="article" />
        <script type="application/ld+json">{JSON.stringify(generateArticleSchema(title, description, pageUrl))}</script>
        <script type="application/ld+json">{JSON.stringify(generateBreadcrumbSchema([{ name: 'Home', path: '/' }, { name: 'Origin', path: '/origin' }]))}</script>
      </Helmet>

      <article className="py-12">
        <header className="mb-12">
          <div className="badge border-emerald-400/30 text-emerald-400/80 bg-emerald-400/5 mb-4">History</div>
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-white leading-tight">Origin of Vrindopnishad</h1>
          <p className="text-lg text-white/60 leading-relaxed">Tracing the roots from ancient Vrindavan to the modern digital age.</p>
        </header>

        <section className="prose-content">
          <h2 className="text-2xl font-bold mb-4 text-white/90">The Sacred Geography of Vrindavan</h2>
          <p className="text-white/70 leading-relaxed mb-6">The origin of Vrindopnishad is inseparable from the sacred geography of Vrindavan (वृन्दावन), the ancient forest town on the banks of the Yamuna river in the Mathura district of Uttar Pradesh, India. Vrindavan is not merely a physical location — it is understood in Hindu theology as the eternal abode of Radha and Krishna, a transcendent realm that manifests on earth. For over five thousand years, this small town has been the epicenter of Bhakti (devotional) spirituality, attracting saints, poets, philosophers, and seekers from across the Indian subcontinent.</p>
          <p className="text-white/70 leading-relaxed mb-6">The literary traditions that Vrindopnishad preserves have their roots in this unique spiritual ecosystem. From the 16th century onwards, when the six Goswamis of Vrindavan — disciples of Sri Chaitanya Mahaprabhu — systematized the theology and practice of Radha-Krishna worship, Vrindavan became a powerhouse of spiritual literature. The Goswamis composed hundreds of texts in Sanskrit, covering everything from abstruse <Link to="/philosophy" className="text-primary hover:underline">philosophy</Link> to intimate devotional poetry. This literary explosion laid the foundation for the traditions that Vrindopnishad now digitally preserves.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">The Bhakti Movement Legacy</h2>
          <p className="text-white/70 leading-relaxed mb-6">The Bhakti movement, which swept across India from the 7th to 17th centuries, transformed Indian spirituality by democratizing access to the divine. Saints like Surdas, Meera Bai, Tulsidas, and Kabir composed devotional works in regional languages, making profound spiritual truths accessible to ordinary people rather than restricting them to Sanskrit-educated elites. This democratizing impulse is the spiritual ancestor of Vrindopnishad's own mission — using digital technology to make sacred knowledge universally accessible.</p>
          <p className="text-white/70 leading-relaxed mb-6">The <Link to="/teachings" className="text-primary hover:underline">teachings preserved on the platform</Link> reflect this rich heritage. The Bhakti poets understood that genuine spirituality is not the exclusive domain of scholars and renunciants but belongs to every human being who yearns for the divine. Their compositions — in Braj Bhasha, Avadhi, Rajasthani, and other regional languages — opened the gates of spiritual practice to millions. Vrindopnishad carries this torch forward into the digital age.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">From Oral Tradition to Digital Preservation</h2>
          <p className="text-white/70 leading-relaxed mb-6">For centuries, the spiritual literature of Vrindavan was transmitted primarily through oral tradition — from guru to shishya (teacher to student), from generation to generation. Devotional songs were learned by heart and sung in temple gatherings. Philosophical texts were studied in small circles of dedicated seekers. While this organic transmission ensured the vitality of the tradition, it also made it vulnerable to loss. As social structures changed and urbanization drew people away from traditional centers of learning, vast portions of this literary heritage faced the risk of being forgotten.</p>
          <p className="text-white/70 leading-relaxed mb-6">Vrindopnishad was born from the recognition that digital technology offers an unprecedented opportunity to preserve, organize, and share this endangered heritage. The platform's founders spent considerable time visiting temples, ashrams, and scholarly communities in Vrindavan, Barsana, Nandgaon, and Govardhan, collecting texts that existed only in handwritten manuscripts or the memories of aging scholars. This field work continues to inform the platform's growing collection. Understanding the <Link to="/meaning" className="text-primary hover:underline">deeper meaning</Link> of the project helps appreciate this preservation mission.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">The Digital Sanctuary Concept</h2>
          <p className="text-white/70 leading-relaxed mb-6">The concept of a "digital sanctuary" emerged from years of reflection on how technology could serve spiritual purposes without trivializing or commodifying sacred content. Unlike social media platforms where spiritual content competes with entertainment, advertising, and political discourse, Vrindopnishad provides a dedicated, distraction-free environment designed specifically for contemplative engagement with sacred texts. The <Link to="/devotion" className="text-primary hover:underline">devotional approach</Link> is central to this design philosophy.</p>
          <p className="text-white/70 leading-relaxed mb-6">The platform's aesthetic choices — the contemplative dark interface, the celestial visual motifs, the careful typography — all reflect the principle that the medium should honor and enhance the message. Just as a traditional temple is designed to create a transition from the mundane world to the sacred, Vrindopnishad's interface creates a digital threshold that signals to the user: you are entering a space of reverence and reflection.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Continuing the Tradition</h2>
          <p className="text-white/70 leading-relaxed mb-8">Vrindopnishad is both ancient and new — rooted in traditions stretching back millennia, yet expressed through cutting-edge technology. It stands as evidence that the eternal truths of Indian spirituality are not confined to any particular medium or era but are capable of finding expression in whatever forms best serve seekers of each generation. <Link to="/content" className="text-primary hover:underline">Explore the content library</Link> to experience this living tradition, or read about the <Link to="/importance" className="text-primary hover:underline">ongoing importance</Link> of this work.</p>
        </section>

        <InternalLinks exclude={['/origin']} count={4} />
      </article>
      <SEOFooter />
    </div>
  );
};

export default OriginPage;
