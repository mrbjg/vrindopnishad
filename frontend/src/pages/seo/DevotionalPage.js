import React from 'react';
import { Link } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';

const DevotionalPage = () => {
  const pageUrl = `${SITE_URL}/devotion`;
  const title = 'Devotional Explanation — Understanding Bhakti Through Vrindopnishad';
  const description = 'Explore the Bhakti tradition through Vrindopnishad. Learn about nine forms of devotion, Radha-Krishna worship, kirtan, and devotional practices from Vrindavan.';

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
        <script type="application/ld+json">{JSON.stringify(generateBreadcrumbSchema([{ name: 'Home', path: '/' }, { name: 'Devotion', path: '/devotion' }]))}</script>
      </Helmet>

      <article className="py-12">
        <header className="mb-12">
          <div className="badge border-pink-400/30 text-pink-400/80 bg-pink-400/5 mb-4">Bhakti</div>
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-white leading-tight">Understanding Devotion Through Vrindopnishad</h1>
          <p className="text-lg text-white/60 leading-relaxed">The path of Bhakti — divine love as the supreme spiritual practice.</p>
        </header>

        <section className="prose-content">
          <h2 className="text-2xl font-bold mb-4 text-white/90">What is Bhakti?</h2>
          <p className="text-white/70 leading-relaxed mb-6">Bhakti (भक्ति) is the Sanskrit term for devotional love directed toward the divine. Far from being mere emotional sentiment, Bhakti is understood in the Vedic tradition as the most natural and powerful expression of the soul's inherent relationship with God. The Bhagavata Purana describes Bhakti as the direct method (abhidheya) for achieving life's ultimate goal — pure, unalloyed love for the Supreme. In the <Link to="/philosophy" className="text-primary hover:underline">philosophical framework</Link> of Vrindopnishad, Bhakti is both the practice and the perfection — the path and the destination are one.</p>
          <p className="text-white/70 leading-relaxed mb-6">The <Link to="/origin" className="text-primary hover:underline">Vrindavan tradition</Link> from which Vrindopnishad draws its inspiration has developed the most elaborate and sophisticated understanding of Bhakti in all of Indian spirituality. The great acharyas of this tradition — Rupa Goswami, Sanatana Goswami, Jiva Goswami, and others — produced extensive philosophical works analyzing the nature, stages, and varieties of devotional love with the precision of scientists and the sensitivity of poets.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Navadha Bhakti — The Nine Forms of Devotion</h2>
          <p className="text-white/70 leading-relaxed mb-6">The Bhagavata Purana outlines nine primary forms of devotional practice, known as Navadha Bhakti. These nine forms represent a comprehensive system of spiritual engagement that accommodates the full range of human temperaments and capacities.</p>
          <p className="text-white/70 leading-relaxed mb-6"><strong className="text-white/80">Shravanam</strong> (hearing) — listening to the names, qualities, and pastimes of the divine. <strong className="text-white/80">Kirtanam</strong> (chanting) — singing or reciting the glories of God. <strong className="text-white/80">Smaranam</strong> (remembering) — constantly keeping the divine in mind. <strong className="text-white/80">Pada-sevanam</strong> (serving the lotus feet) — acts of humble service. <strong className="text-white/80">Archanam</strong> (worship) — formal worship through rituals and offerings. <strong className="text-white/80">Vandanam</strong> (prayer) — offering heartfelt prayers. <strong className="text-white/80">Dasyam</strong> (servitude) — cultivating an attitude of divine service. <strong className="text-white/80">Sakhyam</strong> (friendship) — relating to God as an intimate friend. <strong className="text-white/80">Atma-nivedanam</strong> (complete surrender) — offering one's entire being to the divine.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Radha-Krishna Devotion</h2>
          <p className="text-white/70 leading-relaxed mb-6">At the heart of Vrindopnishad's devotional content lies the tradition of Radha-Krishna worship — the celebration of the divine love between Radha and Krishna as the supreme expression of spiritual reality. In the <Link to="/meaning" className="text-primary hover:underline">deeper meaning</Link> of Vrindavan theology, Radha represents the supreme Shakti (divine energy) — the personification of the highest love and devotion. Krishna represents the supreme Purusha (consciousness). Their eternal romance is not a human love story but a cosmic drama revealing the ultimate nature of the relationship between the individual soul and the Supreme.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Kirtan — The Devotional Practice</h2>
          <p className="text-white/70 leading-relaxed mb-6">Among the nine forms of devotion, kirtan (congregational chanting) holds a special place in the Vrindavan tradition. Sri Chaitanya Mahaprabhu, the 16th-century saint who is revered as an incarnation of Krishna, declared kirtan to be the most effective spiritual practice for the current age (Kali Yuga). The strotras and devotional hymns preserved on Vrindopnishad form the textual basis for this kirtan tradition, providing the words and melodies through which devotees express their love for the divine.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Devotion in Daily Life</h2>
          <p className="text-white/70 leading-relaxed mb-6">The <Link to="/teachings" className="text-primary hover:underline">teachings of Vrindopnishad</Link> emphasize that devotion is not confined to temples or special occasions but can permeate every aspect of daily life. Cooking becomes an offering when food is prepared with devotional intent. Work becomes service when performed with consciousness of the divine. Relationships become sacred when infused with the understanding that every being is a spark of the divine consciousness.</p>

          <h2 className="text-2xl font-bold mb-4 text-white/90">Beginning Your Devotional Journey</h2>
          <p className="text-white/70 leading-relaxed mb-8">Whether you are new to Bhakti or a seasoned practitioner, Vrindopnishad offers resources for deepening your devotional life. Start with the <Link to="/guide" className="text-primary hover:underline">complete guide</Link> for a structured introduction, explore the <Link to="/content" className="text-primary hover:underline">content library</Link> for sacred texts, or read the <Link to="/faq" className="text-primary hover:underline">frequently asked questions</Link> for practical guidance. The <Link to="/importance" className="text-primary hover:underline">importance of devotional practice</Link> in navigating modern life cannot be overstated.</p>
        </section>

        <InternalLinks exclude={['/devotion']} count={4} />
      </article>
      <SEOFooter />
    </div>
  );
};

export default DevotionalPage;
