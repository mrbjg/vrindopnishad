'use client';

import React from 'react';
import { Link } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { Compass, Heart, MapPin, Book, ArrowRight, Globe } from 'lucide-react';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';

const BrajRasikHeritage = () => {
  const pageUrl = `${SITE_URL}/braj-rasik-heritage`;
  const title = 'Braj Rasik Heritage — The Sacred Legacy of Vrindavan | Sant-Vaani';
  const description = 'Explore the profound heritage of Braj Rasiks. Read about the life of saints, sacred bhajans, and the divine dham of Vrindavan. Sant-Vaani brings you authentic Braj Ras content.';

  return (
    <div className="animate-fade-in max-w-4xl mx-auto">
      <Helmet>
        <title>{title}</title>
        <meta name="description" content={description} />
        <link rel="canonical" href={pageUrl} />
        
        
        <meta name="keywords" content="braj rasik, brajrasik, braj ras, vrindavan heritage, braj saints, barsana, radha krishna bhajans, sankirtan, rasik sant, premanand ji, hit harivansh, shree bhatt, vrindopnishad, sant vaani" />
        
        <meta property="og:title" content={title} />
        <meta property="og:description" content={description} />
        <meta property="og:url" content={pageUrl} />
        <meta property="og:type" content="article" />
        
        <script type="application/ld+json">{JSON.stringify(generateArticleSchema(title, description, pageUrl))}</script>
        <script type="application/ld+json">{JSON.stringify(generateBreadcrumbSchema([
          { name: 'Home', path: '/' },
          { name: 'Braj Rasik Heritage', path: '/braj-rasik-heritage' }
        ]))}</script>
      </Helmet>

      <article className="py-12 px-4 md:px-0">
        <header className="text-center mb-16">
          <div className="badge border-amber-400/30 text-amber-400/80 bg-amber-400/5 mb-6">Heritage & Legacy</div>
          <h1 className="text-5xl md:text-7xl font-bold mb-6 text-white leading-tight tracking-tight">
            ब्रज रसिक विरासत
          </h1>
          <p className="text-2xl md:text-3xl text-primary font-medium mb-8">Braj Rasik Heritage</p>
          <div className="h-1 w-24 bg-gradient-to-r from-transparent via-primary to-transparent mx-auto"></div>
        </header>

        <section className="prose-content">
          <div className="glass-card p-8 mb-12 border-l-4 border-l-primary">
            <p className="text-xl text-white/90 leading-relaxed italic">
              "The soil of Braj is not merely earth; it is the essence of divine love, trodden by the feet of Rasik saints who saw nothing but the eternal play of Priya-Priyatam."
            </p>
          </div>

          <h2 className="text-3xl font-bold mb-6 text-white/90 flex items-center gap-3">
            <Globe className="text-primary" /> What is Braj Rasik Heritage?
          </h2>
          <p className="text-white/70 leading-relaxed mb-8 text-lg">
            Braj Rasik Heritage (ब्रज रसिक विरासत) refers to the vast spiritual, cultural, and literary legacy left behind by the saints (Rasiks) of the Braj region. This heritage is the cornerstone of the Bhakti movement, emphasizing the intimate, spontaneous love for Shri Radha Krishna. At <strong>Sant-Vaani (Vrindopnishad)</strong>, we are committed to preserving this legacy alongside platforms like BrajRasik.org, ensuring that the nectar of Braj reaches every seeker.
          </p>

          <div className="grid md:grid-cols-2 gap-8 mb-16">
            <div className="glass-card p-6 hover:border-primary/40 transition-all group">
              <div className="w-12 h-12 rounded-full bg-rose-400/10 flex items-center justify-center text-rose-400 mb-4 group-hover:scale-110 transition-transform">
                <Heart size={24} />
              </div>
              <h3 className="text-xl font-bold mb-2">Rasik Saints — रसिक संत</h3>
              <p className="text-white/60 text-sm mb-4">Discover the life and teachings of saints like Hit Harivansh Mahaprabhu, Swami Haridas, and Shri Bhatt.</p>
              <Link to="/category/saint" className="text-primary text-sm flex items-center gap-1 font-medium">
                Explore Saints <ArrowRight size={14} />
              </Link>
            </div>

            <div className="glass-card p-6 hover:border-primary/40 transition-all group">
              <div className="w-12 h-12 rounded-full bg-sky-400/10 flex items-center justify-center text-sky-400 mb-4 group-hover:scale-110 transition-transform">
                <Compass size={24} />
              </div>
              <h3 className="text-xl font-bold mb-2">Sacred Sankirtan — संकीर्तन</h3>
              <p className="text-white/60 text-sm mb-4">Dive into the divine lyrics of padas and bhajans that have echoed in the groves of Vrindavan for centuries.</p>
              <Link to="/category/sankirtan" className="text-primary text-sm flex items-center gap-1 font-medium">
                Read Lyrics <ArrowRight size={14} />
              </Link>
            </div>

            <div className="glass-card p-6 hover:border-primary/40 transition-all group">
              <div className="w-12 h-12 rounded-full bg-emerald-400/10 flex items-center justify-center text-emerald-400 mb-4 group-hover:scale-110 transition-transform">
                <MapPin size={24} />
              </div>
              <h3 className="text-xl font-bold mb-2">Braj Dham — ब्रज धाम</h3>
              <p className="text-white/60 text-sm mb-4">Information about the 84-kos Braj Parikrama, Barsana, Nandgaon, and the hidden places of pastimes.</p>
              <Link to="/category/dham" className="text-primary text-sm flex items-center gap-1 font-medium">
                Visit Places <ArrowRight size={14} />
              </Link>
            </div>

            <div className="glass-card p-6 hover:border-primary/40 transition-all group">
              <div className="w-12 h-12 rounded-full bg-amber-400/10 flex items-center justify-center text-amber-400 mb-4 group-hover:scale-110 transition-transform">
                <Book size={24} />
              </div>
              <h3 className="text-xl font-bold mb-2">Literature — साहित्य</h3>
              <p className="text-white/60 text-sm mb-4">Access authentic texts from the various Sampradayas of Braj, including Nimbarka, Gaudiya, and Radhavallabh.</p>
              <Link to="/category/literature" className="text-primary text-sm flex items-center gap-1 font-medium">
                Browse Books <ArrowRight size={14} />
              </Link>
            </div>
          </div>

          <h2 className="text-3xl font-bold mb-6 text-white/90">The Significance of Braj Ras</h2>
          <p className="text-white/70 leading-relaxed mb-6">
            Braj Ras is not an intellectual concept; it is an experience of the heart. The literature of the Rasiks provides a map to this experience. By listing our content with Braj Rasik resources, we aim to provide a multi-dimensional perspective on this divine tradition. While BrajRasik.org provides a wonderful archive, <strong>Sant-Vaani (Vrindopnishad)</strong> focuses on the daily <em>Paath</em> (recitation) and meditative aspects of these texts.
          </p>

          <div className="glass-card p-8 mb-12 bg-gradient-to-br from-primary/5 to-transparent">
            <h3 className="text-2xl font-bold mb-4 text-white">How to Engage with Braj Heritage</h3>
            <ul className="space-y-4">
              <li className="flex gap-3 text-white/70">
                <div className="w-6 h-6 rounded-full bg-primary/20 flex items-center justify-center text-primary shrink-0 mt-1">1</div>
                <div><strong>Daily Paath:</strong> Set aside time to read one pada or biography daily to stay connected to the spiritual energy of Braj.</div>
              </li>
              <li className="flex gap-3 text-white/70">
                <div className="w-6 h-6 rounded-full bg-primary/20 flex items-center justify-center text-primary shrink-0 mt-1">2</div>
                <div><strong>Contemplation:</strong> Reflect on the meanings of the Sanskrit and Braj Bhasha verses provided with Hindi translations.</div>
              </li>
              <li className="flex gap-3 text-white/70">
                <div className="w-6 h-6 rounded-full bg-primary/20 flex items-center justify-center text-primary shrink-0 mt-1">3</div>
                <div><strong>Sharing:</strong> Spread the wisdom of Rasik saints with your family and community to keep the heritage alive.</div>
              </li>
            </ul>
          </div>
        </section>

        <div className="mt-16">
          <InternalLinks exclude={['/braj-rasik-heritage']} count={4} />
        </div>
      </article>
      <SEOFooter />
    </div>
  );
};

export default BrajRasikHeritage;
