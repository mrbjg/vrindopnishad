import React from 'react';
import { Link } from 'react-router-dom';
import { Compass, Scroll, Music, FileText, ArrowRight, BookOpen, Heart, Star, Globe } from 'lucide-react';
import { Helmet } from 'react-helmet-async';

const HomePage = () => {
  return (
    <div className="animate-fade-in">
      <Helmet>
        <title>Vrindopnishad Paath — वृंदोपनिषद् पाठ | Sacred Shlokas, Strotras & Devotional Poetry</title>
        <meta name="description" content="Vrindopnishad Paath (वृंदोपनिषद् पाठ) — Read and listen to authentic sacred Sanskrit shlokas, devotional strotras, spiritual poetry & Vedic wisdom from Vrindavan saints. Free online paath of Bhagavad Gita, mantras & hymns in Hindi, Sanskrit & English." />
        <meta name="keywords" content="vrindopnishad, vrindopnishad paath, वृंदोपनिषद्, वृंदोपनिषद् पाठ, vrindopnishad path, vrindopnishad app, vrindopnishad.in, sant vaani, sacred shlokas, sanskrit shlokas, strotras, devotional poetry, bhagavad gita, vedic wisdom, vrindavan, भक्ति, श्लोक, स्तोत्र, कविता, वेद, उपनिषद, मंत्र, हिंदी भजन, radha krishna, premanand ji maharaj, barsana, nandgaav, govardhan, braj rasik, brajrasik, rasik sant" />
        <link rel="canonical" href="https://path.vrindopnishad.in/" />

        {/* Hindi-specific meta for Google India */}
        <meta name="geo.region" content="IN" />
        <meta name="geo.placename" content="Vrindavan, India" />
        <meta name="content-language" content="hi, en, sa" />

        {/* Open Graph */}
        <meta property="og:type" content="website" />
        <meta property="og:url" content="https://path.vrindopnishad.in/" />
        <meta property="og:site_name" content="Vrindopnishad — वृंदोपनिषद्" />
        <meta property="og:title" content="Vrindopnishad Paath — वृंदोपनिषद् पाठ | Sacred Digital Sanctuary" />
        <meta property="og:description" content="Read Vrindopnishad Paath online — sacred Sanskrit shlokas, strotras, devotional poetry & Vedic wisdom from Vrindavan saints. Free in Hindi, Sanskrit & English." />
        <meta property="og:image" content="https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png" />
        <meta property="og:locale" content="hi_IN" />
        <meta property="og:locale:alternate" content="en_IN" />

        {/* Twitter */}
        <meta name="twitter:card" content="summary_large_image" />
        <meta name="twitter:title" content="Vrindopnishad Paath — वृंदोपनिषद् पाठ" />
        <meta name="twitter:description" content="Read Vrindopnishad Paath online — sacred Sanskrit shlokas, strotras, devotional poetry & Vedic wisdom." />
        <meta name="twitter:image" content="https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png" />

        {/* JSON-LD: CollectionPage */}
        <script type="application/ld+json">{JSON.stringify({
          "@context": "https://schema.org",
          "@type": "CollectionPage",
          "name": "Vrindopnishad Paath — वृंदोपनिषद् पाठ",
          "alternateName": ["Vrindopnishad", "वृंदोपनिषद्", "Vrindopnishad Path", "Sant Vaani"],
          "description": "Read Vrindopnishad Paath online — the largest digital collection of sacred Sanskrit shlokas, strotras, devotional poetry, and Vedic wisdom from Vrindavan saints.",
          "url": "https://path.vrindopnishad.in",
          "inLanguage": ["hi", "en", "sa"],
          "about": [
            { "@type": "Thing", "name": "Vrindopnishad", "alternateName": "वृंदोपनिषद्" },
            { "@type": "Thing", "name": "Vedic Knowledge", "alternateName": "वैदिक ज्ञान" },
            { "@type": "Thing", "name": "Bhakti", "alternateName": "भक्ति" },
            { "@type": "Thing", "name": "Sanskrit Shlokas", "alternateName": "संस्कृत श्लोक" }
          ],
          "publisher": {
            "@type": "Organization",
            "name": "Vrindopnishad",
            "alternateName": "वृंदोपनिषद्",
            "logo": {
              "@type": "ImageObject",
              "url": "https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png"
            }
          },
          "mainEntity": {
            "@type": "ItemList",
            "itemListElement": [
              { "@type": "ListItem", "position": 1, "name": "Sacred Verses (Shlokas) — श्लोक", "url": "https://path.vrindopnishad.in/category/shloka" },
              { "@type": "ListItem", "position": 2, "name": "Strotras (Devotional Hymns) — स्तोत्र", "url": "https://path.vrindopnishad.in/category/strotra" },
              { "@type": "ListItem", "position": 3, "name": "Spiritual Poetry — आध्यात्मिक कविता", "url": "https://path.vrindopnishad.in/category/poem" }
            ]
          }
        })}</script>
      </Helmet>

      {/* Hero Section */}
      <div className="text-center py-12 md:py-24 max-w-4xl mx-auto">
        <div className="om-symbol text-[#fbbf24] text-4xl mb-6 opacity-80 animate-pulse">ॐ</div>
        <h1 className="text-5xl md:text-7xl font-bold mb-4 tracking-tight text-white drop-shadow-2xl">
          वृंदोपनिषद्
        </h1>
        <p className="text-xl md:text-2xl text-primary/80 font-medium mb-2">Vrindopnishad Paath</p>
        <p className="text-lg md:text-xl text-white/70 font-light max-w-2xl mx-auto leading-relaxed mb-12">
          पवित्र डिजिटल संग्रह — Sacred Digital Sanctuary for Shlokas, Strotras & Devotional Poetry from Vrindavan
        </p>

        <div className="flex flex-wrap justify-center gap-4">
          <Link to="/content" className="btn-premium">
            <Compass size={20} />
            Explore Paath
          </Link>
          <Link to="/category/shloka" className="px-8 py-3 rounded-full border border-white/20 hover:bg-white/5 transition-all flex items-center gap-2 font-medium">
            <Scroll size={20} className="text-primary" />
            Browse Shlokas
          </Link>
        </div>
      </div>

      {/* SEO Content Section — What is Vrindopnishad */}
      <div className="py-12 max-w-4xl mx-auto">
        <div className="glass-card p-8 md:p-12">
          <h2 className="text-2xl md:text-3xl font-bold mb-6 text-white/90">
            Vrindopnishad Paath — वृंदोपनिषद् पाठ क्या है?
          </h2>
          <p className="text-white/70 leading-relaxed mb-4">
            <strong className="text-white/85">Vrindopnishad</strong> (वृंदोपनिषद्) is the premier sacred digital sanctuary dedicated to preserving and sharing authentic spiritual and Vedic knowledge from the heart of Vrindavan. The word "Vrindopnishad" combines <em>Vrinda</em> (the sacred groves of Vrindavan, वृंदावन) and <em>Upanishad</em> (sacred knowledge, उपनिषद्), meaning "the sacred knowledge flowing from Vrindavan."
          </p>
          <p className="text-white/70 leading-relaxed mb-4">
            <strong className="text-white/85">Vrindopnishad Paath</strong> (वृंदोपनिषद् पाठ) refers to the practice of reading, reciting, and contemplating the sacred verses, shlokas (श्लोक), strotras (स्तोत्र), and devotional poetry (भक्ति कविता) curated on this platform. Whether you seek Bhagavad Gita verses, Vedic mantras, or devotional hymns from saints like Surdas, Meera Bai, and Premanand Ji Maharaj — Vrindopnishad provides the most authentic and comprehensive collection online.
          </p>
          <p className="text-white/70 leading-relaxed mb-6">
            हमारा उद्देश्य वेदों, उपनिषदों, भगवद्गीता, और वृंदावन की भक्ति परंपरा के पवित्र ज्ञान को डिजिटल रूप में संरक्षित करना है। यहाँ आप संस्कृत श्लोक, स्तोत्र, और आध्यात्मिक कविताएँ हिंदी, संस्कृत, और अंग्रेजी में पढ़ और सुन सकते हैं।
          </p>
          <div className="flex flex-wrap gap-3">
            <Link to="/what-is-vrindopnishad" className="text-primary hover:underline text-sm flex items-center gap-1">
              <BookOpen size={14} /> What is Vrindopnishad? →
            </Link>
            <Link to="/meaning" className="text-primary hover:underline text-sm flex items-center gap-1">
              <Star size={14} /> Meaning & Etymology →
            </Link>
            <Link to="/origin" className="text-primary hover:underline text-sm flex items-center gap-1">
              <Globe size={14} /> Historical Origins →
            </Link>
          </div>
        </div>
      </div>

      {/* Categories Grid */}
      <div className="py-12">
        <div className="flex items-center gap-4 mb-12">
          <div className="h-[1px] flex-1 bg-white/10"></div>
          <h2 className="text-2xl font-semibold opacity-60 uppercase tracking-widest">पाठ श्रेणियाँ — Categories</h2>
          <div className="h-[1px] flex-1 bg-white/10"></div>
        </div>

        <div className="content-grid font-sans">
          <Link to="/category/shloka" className="glass-card flex flex-col items-center text-center hover:border-amber-400/30 hover:shadow-2xl hover:shadow-amber-400/10 transition-all duration-500 group">
             <div className="w-16 h-16 rounded-full bg-amber-400/10 flex items-center justify-center text-amber-400 mb-6 shadow-inner ring-1 ring-amber-400/20 group-hover:scale-110 transition-transform duration-500">
               <Scroll size={32} />
             </div>
             <div className="badge border-amber-400/30 text-amber-400/80 bg-amber-400/5">वेद और उपनिषद</div>
             <h3 className="text-xl font-bold mb-4">Sacred Verses — श्लोक</h3>
             <p className="text-white/60 text-sm leading-relaxed">
               Dive into timeless Sanskrit shlokas from the Vedas, Upanishads, and Bhagavad Gita. Read Vrindopnishad paath of sacred verses with Hindi meaning.
             </p>
          </Link>

          <Link to="/category/strotra" className="glass-card flex flex-col items-center text-center hover:border-sky-400/30 hover:shadow-2xl hover:shadow-sky-400/10 transition-all duration-500 group">
             <div className="w-16 h-16 rounded-full bg-sky-400/10 flex items-center justify-center text-sky-400 mb-6 shadow-inner ring-1 ring-sky-400/20 group-hover:scale-110 transition-transform duration-500">
               <Music size={32} />
             </div>
             <div className="badge border-sky-400/30 text-sky-400/80 bg-sky-400/5">भक्ति स्तोत्र</div>
             <h3 className="text-xl font-bold mb-4">Strotras — स्तोत्र</h3>
             <p className="text-white/60 text-sm leading-relaxed">
               Experience the power of traditional devotional hymns and prayers. Listen and read strotras dedicated to Radha Krishna, Shiva, and Hanuman.
             </p>
          </Link>

          <Link to="/category/poem" className="glass-card flex flex-col items-center text-center hover:border-emerald-400/30 hover:shadow-2xl hover:shadow-emerald-400/10 transition-all duration-500 group">
             <div className="w-16 h-16 rounded-full bg-emerald-400/10 flex items-center justify-center text-emerald-400 mb-6 shadow-inner ring-1 ring-emerald-400/20 group-hover:scale-110 transition-transform duration-500">
               <FileText size={32} />
             </div>
             <div className="badge border-emerald-400/30 text-emerald-400/80 bg-emerald-400/5">आध्यात्मिक कविता</div>
             <h3 className="text-xl font-bold mb-4">Poems — कविताएँ</h3>
             <p className="text-white/60 text-sm leading-relaxed">
               Contemporary and classic spiritual poetry from Vrindavan saints — Surdas, Meera Bai, Kabir, and modern devotional poets.
             </p>
          </Link>
        </div>
      </div>

      {/* Braj Heritage Section */}
      <div className="py-12">
        <div className="flex items-center gap-4 mb-12">
          <div className="h-[1px] flex-1 bg-white/10"></div>
          <h2 className="text-2xl font-semibold opacity-60 uppercase tracking-widest text-primary">ब्रज रसिक विरासत — Braj Heritage</h2>
          <div className="h-[1px] flex-1 bg-white/10"></div>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
          <Link to="/category/sankirtan" className="glass-card flex flex-col items-center text-center hover:border-rose-400/30 hover:shadow-2xl hover:shadow-rose-400/10 transition-all duration-500 group">
             <div className="w-14 h-14 rounded-full bg-rose-400/10 flex items-center justify-center text-rose-400 mb-4 group-hover:scale-110 transition-transform">
               <Heart size={28} />
             </div>
             <h3 className="font-bold mb-1">Sankirtan</h3>
             <p className="text-white/50 text-xs px-2">Divine lyrics & bhajans</p>
          </Link>

          <Link to="/category/saint" className="glass-card flex flex-col items-center text-center hover:border-indigo-400/30 hover:shadow-2xl hover:shadow-indigo-400/10 transition-all duration-500 group">
             <div className="w-14 h-14 rounded-full bg-indigo-400/10 flex items-center justify-center text-indigo-400 mb-4 group-hover:scale-110 transition-transform">
               <Users size={28} />
             </div>
             <h3 className="font-bold mb-1">Rasik Saints</h3>
             <p className="text-white/50 text-xs px-2">Biographies of masters</p>
          </Link>

          <Link to="/category/dham" className="glass-card flex flex-col items-center text-center hover:border-orange-400/30 hover:shadow-2xl hover:shadow-orange-400/10 transition-all duration-500 group">
             <div className="w-14 h-14 rounded-full bg-orange-400/10 flex items-center justify-center text-orange-400 mb-4 group-hover:scale-110 transition-transform">
               <MapPin size={28} />
             </div>
             <h3 className="font-bold mb-1">Braj Dham</h3>
             <p className="text-white/50 text-xs px-2">Sacred places of Braj</p>
          </Link>

          <Link to="/category/literature" className="glass-card flex flex-col items-center text-center hover:border-violet-400/30 hover:shadow-2xl hover:shadow-violet-400/10 transition-all duration-500 group">
             <div className="w-14 h-14 rounded-full bg-violet-400/10 flex items-center justify-center text-violet-400 mb-4 group-hover:scale-110 transition-transform">
               <Book size={28} />
             </div>
             <h3 className="font-bold mb-1">Literature</h3>
             <p className="text-white/50 text-xs px-2">Authentic Rasik texts</p>
          </Link>
        </div>
        <div className="text-center mt-8">
          <Link to="/braj-rasik-heritage" className="text-primary hover:underline text-sm font-medium flex items-center justify-center gap-2">
            Learn more about Braj Rasik Heritage <ArrowRight size={14} />
          </Link>
        </div>
      </div>

      {/* Why Vrindopnishad Section */}
      <div className="py-12 max-w-4xl mx-auto">
        <h2 className="text-2xl md:text-3xl font-bold mb-8 text-center text-white/90">
          Why Read Vrindopnishad Paath Online?
        </h2>
        <div className="grid md:grid-cols-2 gap-6">
          <div className="glass-card p-6 flex gap-4">
            <div className="w-10 h-10 rounded-full bg-amber-400/10 flex items-center justify-center text-amber-400 shrink-0 mt-1">
              <BookOpen size={20} />
            </div>
            <div>
              <h3 className="font-bold text-white/90 mb-2">645+ Sacred Texts</h3>
              <p className="text-white/60 text-sm leading-relaxed">The largest curated collection of authentic Sanskrit shlokas, strotras, and devotional poetry from Vrindavan — all verified by Sanskrit scholars.</p>
            </div>
          </div>
          <div className="glass-card p-6 flex gap-4">
            <div className="w-10 h-10 rounded-full bg-sky-400/10 flex items-center justify-center text-sky-400 shrink-0 mt-1">
              <Globe size={20} />
            </div>
            <div>
              <h3 className="font-bold text-white/90 mb-2">Hindi, Sanskrit & English</h3>
              <p className="text-white/60 text-sm leading-relaxed">Every verse is available in original Sanskrit with Hindi transliteration and English translation — making Vedic wisdom accessible to everyone.</p>
            </div>
          </div>
          <div className="glass-card p-6 flex gap-4">
            <div className="w-10 h-10 rounded-full bg-emerald-400/10 flex items-center justify-center text-emerald-400 shrink-0 mt-1">
              <Music size={20} />
            </div>
            <div>
              <h3 className="font-bold text-white/90 mb-2">Audio Paath — सुनिए</h3>
              <p className="text-white/60 text-sm leading-relaxed">Listen to sacred verses with traditional chanting. Audio narrations bring the authentic sound of Vedic recitation to your device.</p>
            </div>
          </div>
          <div className="glass-card p-6 flex gap-4">
            <div className="w-10 h-10 rounded-full bg-rose-400/10 flex items-center justify-center text-rose-400 shrink-0 mt-1">
              <Heart size={20} />
            </div>
            <div>
              <h3 className="font-bold text-white/90 mb-2">100% Free — निःशुल्क</h3>
              <p className="text-white/60 text-sm leading-relaxed">Sacred knowledge belongs to everyone. Vrindopnishad is completely free — no subscriptions, no paywalls, no hidden costs.</p>
            </div>
          </div>
        </div>
      </div>

      {/* Knowledge Hub — internal links for crawlers */}
      <div className="py-12 max-w-4xl mx-auto">
        <h2 className="text-2xl md:text-3xl font-bold mb-8 text-center text-white/90">
          वृंदोपनिषद् ज्ञान केंद्र — Knowledge Hub
        </h2>
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
          <Link to="/what-is-vrindopnishad" className="glass-card p-5 hover:border-primary/30 transition-colors group">
            <h3 className="font-bold text-white/90 mb-1 group-hover:text-primary transition-colors">What is Vrindopnishad?</h3>
            <p className="text-white/50 text-sm">Complete introduction to the sacred digital sanctuary</p>
          </Link>
          <Link to="/meaning" className="glass-card p-5 hover:border-primary/30 transition-colors group">
            <h3 className="font-bold text-white/90 mb-1 group-hover:text-primary transition-colors">Meaning — अर्थ</h3>
            <p className="text-white/50 text-sm">Etymology and significance of Vrindopnishad</p>
          </Link>
          <Link to="/origin" className="glass-card p-5 hover:border-primary/30 transition-colors group">
            <h3 className="font-bold text-white/90 mb-1 group-hover:text-primary transition-colors">Origin — उत्पत्ति</h3>
            <p className="text-white/50 text-sm">Historical roots from Vrindavan to digital age</p>
          </Link>
          <Link to="/philosophy" className="glass-card p-5 hover:border-primary/30 transition-colors group">
            <h3 className="font-bold text-white/90 mb-1 group-hover:text-primary transition-colors">Philosophy — दर्शन</h3>
            <p className="text-white/50 text-sm">Vedantic wisdom and Bhakti principles</p>
          </Link>
          <Link to="/teachings" className="glass-card p-5 hover:border-primary/30 transition-colors group">
            <h3 className="font-bold text-white/90 mb-1 group-hover:text-primary transition-colors">Teachings — शिक्षाएँ</h3>
            <p className="text-white/50 text-sm">Core spiritual lessons and sacred wisdom</p>
          </Link>
          <Link to="/importance" className="glass-card p-5 hover:border-primary/30 transition-colors group">
            <h3 className="font-bold text-white/90 mb-1 group-hover:text-primary transition-colors">Importance — महत्व</h3>
            <p className="text-white/50 text-sm">Why Vedic wisdom matters today</p>
          </Link>
          <Link to="/devotion" className="glass-card p-5 hover:border-primary/30 transition-colors group">
            <h3 className="font-bold text-white/90 mb-1 group-hover:text-primary transition-colors">Devotion — भक्ति</h3>
            <p className="text-white/50 text-sm">Understanding Bhakti through Vrindopnishad</p>
          </Link>
          <Link to="/guide" className="glass-card p-5 hover:border-primary/30 transition-colors group">
            <h3 className="font-bold text-white/90 mb-1 group-hover:text-primary transition-colors">Guide — मार्गदर्शिका</h3>
            <p className="text-white/50 text-sm">Complete beginner's guide to the platform</p>
          </Link>
          <Link to="/faq" className="glass-card p-5 hover:border-primary/30 transition-colors group">
            <h3 className="font-bold text-white/90 mb-1 group-hover:text-primary transition-colors">FAQ — प्रश्नोत्तर</h3>
            <p className="text-white/50 text-sm">Frequently asked questions answered</p>
          </Link>
        </div>
      </div>

      {/* SEO Bottom Content */}
      <div className="py-12 max-w-4xl mx-auto">
        <div className="glass-card p-8 md:p-12">
          <h2 className="text-2xl font-bold mb-4 text-white/90">वृंदोपनिषद् पाठ — Vrindopnishad Paath Online</h2>
          <p className="text-white/70 leading-relaxed mb-4">
            Vrindopnishad Paath is the daily spiritual practice of reading sacred verses from the Vedas, Upanishads, Bhagavad Gita, and the devotional literature of Vrindavan. Our platform brings this ancient practice into the digital age, allowing seekers worldwide to engage with authentic spiritual texts anytime, anywhere.
          </p>
          <p className="text-white/70 leading-relaxed mb-4">
            वृंदोपनिषद् पाठ एक पवित्र आध्यात्मिक अभ्यास है जो वेदों, उपनिषदों, भगवद्गीता, और वृंदावन की भक्ति साहित्य के पवित्र श्लोकों को पढ़ने और सुनने की परंपरा है। हमारा मंच इस प्राचीन परंपरा को डिजिटल युग में लाता है, जिससे दुनिया भर के साधक कभी भी, कहीं भी प्रामाणिक आध्यात्मिक ग्रंथों से जुड़ सकें।
          </p>
          <p className="text-white/70 leading-relaxed mb-6">
            The collection includes sacred works from the great Vrindavan saints — Rupa Goswami, Sanatana Goswami, Surdas, Meera Bai, and contemporary spiritual masters like Premanand Ji Maharaj. From the sacred groves of Barsana and Nandgaon to the ghats of Govardhan, these texts carry the living spiritual energy of Vrindavan to your screen.
          </p>
          <div className="flex flex-wrap gap-2">
            {['vrindopnishad', 'vrindopnishad paath', 'वृंदोपनिषद्', 'श्लोक', 'स्तोत्र', 'भक्ति कविता', 'भगवद्गीता', 'वैदिक मंत्र', 'radha krishna', 'vrindavan', 'sanskrit shlokas'].map(tag => (
              <span key={tag} className="px-3 py-1 rounded-full border border-white/10 text-white/40 text-xs">{tag}</span>
            ))}
          </div>
        </div>
      </div>

      {/* Call to action */}
      <div className="mt-12 mb-8 p-8 md:p-16 glass-card text-center relative overflow-hidden group">
        <div className="absolute inset-0 bg-gradient-to-br from-primary/10 to-transparent opacity-50"></div>
        <div className="relative z-10">
          <h2 className="text-3xl font-bold mb-6">अपनी आध्यात्मिक यात्रा शुरू करें</h2>
          <p className="text-xl text-white/80 mb-2">Start Your Spiritual Journey</p>
          <p className="text-white/70 max-w-xl mx-auto mb-10 leading-relaxed">
             Immerse yourself in sacred texts with audio narrations, beautiful imagery, and deep spiritual insights. Read Vrindopnishad Paath daily for inner peace and divine wisdom.
          </p>
          <Link to="/content" className="btn-premium px-12 py-4">
             Enter Presence — पाठ पढ़ें
             <ArrowRight size={20} />
          </Link>
        </div>
      </div>
    </div>
  );
};

export default HomePage;
