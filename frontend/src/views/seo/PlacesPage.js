'use client';

import React, { useState } from 'react';
import { Helmet } from 'react-helmet-async';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';
import { Search, MapPin, Landmark, ExternalLink } from 'lucide-react';

const SACRED_PLACES = [
  {
    name: 'Nidhivan',
    devanagari: 'निधिवन',
    category: 'Vrindavan Groves',
    description: 'The ancient, mystical forest grove where Swami Haridas performed his intense bhajan, manifested the divine deity of Bankey Bihari Ji, and was blessed with direct visions of the Divine Couple. It is believed that Shri Radha and Krishna perform Ras Lila here every night, during which the trees become sakhis.',
    saintConnection: 'Swami Haridas',
    locationHint: 'Vrindavan center, close to Bankey Bihari temple.'
  },
  {
    name: 'Seva Kunj',
    devanagari: 'सेवा कुंज',
    category: 'Vrindavan Groves',
    description: 'Also known as Nikunjavana, this grove is historically linked with Goswami Hit Harivansh Mahaprabhu. It is the sacred site where Shri Krishna is said to massage the feet of Shri Radha and ornament Her hair. The site features the famous Lalita Kund and Nikunj Mandir.',
    saintConnection: 'Goswami Hit Harivansh Mahaprabhu',
    locationHint: 'Vrindavan, near the Yamuna river.'
  },
  {
    name: 'Radha Kund',
    devanagari: 'राधा कुण्ड',
    category: 'Sacred Lakes',
    description: 'The most sacred lake in the universe according to Gaudiya Vaishnava theology. Created by Srimati Radharani herself by digging the earth with her bangles, this water body represents the highest liquid form of Radha\'s divine love. It was rediscovered by Sri Chaitanya Mahaprabhu in 1515.',
    saintConnection: 'Raghunatha dasa Goswami & Chaitanya Mahaprabhu',
    locationHint: 'Radha Kund village, near Govardhan hill.'
  },
  {
    name: 'Shyam Kund',
    devanagari: 'श्याम कुण्ड',
    category: 'Sacred Lakes',
    description: 'The sacred lake created by Lord Krishna adjacent to Radha Kund. After slaying the demon Aristasura (who was in the form of a bull), Krishna struck His heel on the ground to manifest a large pond and bathed in it to purify Himself, calling all sacred rivers to enter the waters.',
    saintConnection: 'Sanatana Goswami & Rupa Goswami',
    locationHint: 'Immediately adjacent to Radha Kund.'
  },
  {
    name: 'Govardhan Hill',
    devanagari: 'गोवर्धन पर्वत',
    category: 'Holy Mountains',
    description: 'The sacred hill lifted by Lord Krishna on His little finger for seven days and seven nights to protect the residents of Braj from Indra\'s torrential rains. The hill is worshiped as a non-different form of Krishna Himself. Devotees perform a 21-kilometer circumambulation (Parikrama) around it.',
    saintConnection: 'Madhavendra Puri & Srila Rupa Goswami',
    locationHint: 'Govardhan town, 22km west of Mathura.'
  },
  {
    name: 'Barsana',
    devanagari: 'बरसाना',
    category: 'Towns',
    description: 'The majestic palace town located on a hilltop, celebrated as the birthplace and childhood home of Srimati Radharani. The main temple is the Shri Radha Rani Mandir (Lali Ji), situated on Bhanugarh hill. It is the center of the world-famous Lathmar Holi festival.',
    saintConnection: 'Narayan Bhatt & Sri Bhatta',
    locationHint: 'Braj region, 45km north-west of Mathura.'
  },
  {
    name: 'Nandgaon',
    devanagari: 'नंदगांव',
    category: 'Towns',
    description: 'The hilltop village where Nanda Maharaj, Yashoda, and Lord Krishna moved from Gokul to escape Kamsa\'s demons. The main temple on the hill, Nandisvara Temple, represents Lord Shiva who took the form of the hill to witness Krishna\'s childhood pastimes.',
    saintConnection: 'Sanatana Goswami & Rupa Goswami',
    locationHint: 'Braj region, 8km north of Barsana.'
  },
  {
    name: 'Raman Reti',
    devanagari: 'रमन रेती',
    category: 'Sacred Sands',
    description: 'A serene sanctuary in Gokul covered with soft, white sand where Lord Krishna and Balarama played cowherd pastimes with their friends. Today, it is an ashram where pilgrims roll in the sand to receive the dust of Krishna\'s lotus feet on their bodies.',
    saintConnection: 'Rasik Saint Swami Gyandas',
    locationHint: 'Gokul, banks of Yamuna river.'
  },
  {
    name: 'Bansi Vat',
    devanagari: 'बंशीवट',
    category: 'Vrindavan Groves',
    description: 'The ancient, sacred banyan tree on the banks of the Yamuna where Krishna blew His transcendental flute (Vamshi) to summon the Gopis from their homes to initiate the Maharaas Lila. It is considered a threshold of cosmic union.',
    saintConnection: 'Sri Gishapati Bhatt & Prabodhananda Sarasvati',
    locationHint: 'Vrindavan town, Yamuna bank.'
  },
  {
    name: 'Chir Ghat',
    devanagari: 'चीर घाट',
    category: 'Ghats',
    description: 'The sacred bank on the Yamuna river where Krishna performed the pastime of stealing the Gopis\' clothes (Vastra Haran) as they bathed, testing their absolute surrender and freeing them from the last vestiges of bodily identification.',
    saintConnection: 'Saints of the Nimbarka tradition',
    locationHint: 'Vrindavan town, Yamuna bank near Keshi Ghat.'
  },
  {
    name: 'Keshi Ghat',
    devanagari: 'केशी घाट',
    category: 'Ghats',
    description: 'The primary and most famous bathing ghat on the Yamuna river in Vrindavan. It is the historic place where Lord Krishna slayed the wild horse demon Keshi sent by Kamsa, and bathed to purify Himself. Thousands gather here daily for the beautiful sunset Yamuna Aarti.',
    saintConnection: 'Braj Rasik Saints & Pilgrims',
    locationHint: 'Vrindavan, bank of Yamuna river.'
  },
  {
    name: 'Kusum Sarovar',
    devanagari: 'कुसुम सरोवर',
    category: 'Sacred Lakes',
    description: 'A magnificent, historic 450-foot-long sandstone lake surrounded by royal cenotaphs (chhatris) built by Jawahar Singh of Bharatpur. In Radharani\'s pastimes, the Gopis collected exotic flowers (kusum) here to make garlands for Her, and it is a key stop along the Govardhan Parikrama.',
    saintConnection: 'Radha Rani & Her sakhis',
    locationHint: 'Govardhan Parikrama path, near Radha Kund.'
  },
  {
    name: 'Mansi Ganga',
    devanagari: 'मानसी गंगा',
    category: 'Sacred Lakes',
    description: 'A large sacred lake in the center of Govardhan town. When Nanda Maharaj and Yashoda wished to bathe in the holy Ganges, Krishna did not want them to travel far and manifested the Ganges here from His mind (Manas) so they could bathe locally.',
    saintConnection: 'Nanda Maharaj & Sri Krishna',
    locationHint: 'Center of Govardhan town.'
  },
  {
    name: 'Prem Mandir',
    devanagari: 'प्रेम मंदिर',
    category: 'Temples',
    description: 'The grand "Temple of Divine Love," a modern architectural marvel constructed of pure white Italian Carrara marble. It features elaborate carvings, musical fountains, and extensive dioramas depicting the leelas of Radha-Krishna and Ram-Sita.',
    saintConnection: 'Jagadguru Kripalu Parishat',
    locationHint: 'Vrindavan outskirts, Chatikara road.'
  },
  {
    name: 'Radha Raman Temple',
    devanagari: 'राधा रमण मंदिर',
    category: 'Temples',
    description: 'One of the seven prominent historical temples of Vrindavan. The self-manifested deity of Radha Raman Ji emerged from a Saligram Shila in 1542, answering the deep prayers of Gopal Bhatta Goswami. The temple contains no separate deity of Radha, but a crown representing Her presence.',
    saintConnection: 'Gopal Bhatta Goswami (Shad Goswami)',
    locationHint: 'Vrindavan center, near Nidhivan.'
  },
  {
    name: 'Bankey Bihari Temple',
    devanagari: 'बांके बिहारी मंदिर',
    category: 'Temples',
    description: 'The highly popular temple hosting the Bankey Bihari deity, who was manifested in Nidhivan by the intense musical devotion of Swami Haridas. The deity represents the combined form of Shri Radha and Shri Krishna, known for its dynamic charm (tribhanga posture).',
    saintConnection: 'Swami Haridas',
    locationHint: 'Vrindavan center, Bihari Pura.'
  },
  {
    name: 'Radha Vallabh Temple',
    devanagari: 'राधावल्लभ मंदिर',
    category: 'Temples',
    description: 'The central temple of the Radhavallabh sampradaya, where Srimati Radharani is worshiped as the supreme divinity. The deity of Radha Vallabh Ji was manifested by Goswami Hit Harivansh Mahaprabhu. The altar features a throne and a crown symbolizing Shri Radha alongside the deity.',
    saintConnection: 'Goswami Hit Harivansh Mahaprabhu',
    locationHint: 'Vrindavan center, near Gotam Nagar.'
  },
  {
    name: 'Kaliya Dah',
    devanagari: 'कालिया दह',
    category: 'Vrindavan Groves',
    description: 'The historic spot on the Yamuna river containing the ancient Kadamba tree from which Lord Krishna jumped into the poisonous waters of the Yamuna to subdue the multi-hooded serpent Kaliya, thereby purifying the river.',
    saintConnection: 'Sri Krishna & Kaliya Naag',
    locationHint: 'Vrindavan bank, near Chir Ghat.'
  }
];

const PlacesPage = () => {
  const pageUrl = `${SITE_URL}/places`;
  const title = 'Braj Dham Sacred Places — Guide to Holy Sites of Vrindavan';
  const description = 'A comprehensive spiritual guide to the holy places, sacred lakes, and mystical groves of Braj Dham and Vrindavan, with historical and saintly connections.';

  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('All');

  const categories = ['All', ...new Set(SACRED_PLACES.map(p => p.category))];

  const filteredPlaces = SACRED_PLACES.filter(p => {
    const matchesSearch = p.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          p.devanagari.includes(searchTerm) ||
                          p.description.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          p.saintConnection.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesCategory = selectedCategory === 'All' || p.category === selectedCategory;
    return matchesSearch && matchesCategory;
  });

  const placesSchema = {
    "@context": "https://schema.org",
    "@type": "ItemList",
    "name": "Sacred Places of Braj Dham and Vrindavan",
    "description": "A comprehensive spiritual guide to the holy places, sacred lakes, and mystical groves of Braj Dham and Vrindavan.",
    "url": pageUrl,
    "itemListElement": SACRED_PLACES.map((place, index) => ({
      "@type": "ListItem",
      "position": index + 1,
      "item": {
        "@type": "Landmark",
        "name": place.name,
        "alternateName": place.devanagari,
        "description": place.description,
        "address": {
          "@type": "PostalAddress",
          "addressLocality": place.locationHint || "Vrindavan",
          "addressRegion": "Uttar Pradesh",
          "addressCountry": "IN"
        }
      }
    }))
  };

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
        <script type="application/ld+json">{JSON.stringify(placesSchema)}</script>
        <script type="application/ld+json">{JSON.stringify(generateBreadcrumbSchema([{ name: 'Home', path: '/' }, { name: 'Sacred Places', path: '/places' }]))}</script>
      </Helmet>

      <header className="mb-10 text-center max-w-3xl mx-auto">
        <div className="badge border-amber-500/20 text-amber-500 bg-amber-500/5 mb-3 uppercase tracking-widest text-[9px] font-bold">
          Braj Dham Guide
        </div>
        <h1 className="text-3xl md:text-5xl font-bold font-headings text-sacred-gradient mb-4">
          Sacred Places of Braj
        </h1>
        <p className="text-white/60 text-sm leading-relaxed">
          Embark on a virtual pilgrimage to the sacred forest bowers, divine water bodies, and mystical towns where the eternal pastimes of the Divine Couple manifest.
        </p>
      </header>

      
      <div className="glass-card p-4 rounded-2xl border border-white/5 mb-8 flex flex-col md:flex-row gap-4 items-center justify-between">
        
        <div className="relative w-full md:w-80">
          <input
            type="text"
            placeholder="Search by place name, saint or details..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full bg-white/5 border border-white/10 rounded-xl py-2 pl-10 pr-4 text-xs text-white outline-none focus:border-primary/50 transition-all"
          />
          <Search size={14} className="absolute left-3.5 top-3 text-white/30" />
        </div>

        
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

      
      {filteredPlaces.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {filteredPlaces.map(p => (
            <div
              key={p.name}
              className="glass-card p-6 rounded-2xl border border-white/5 hover:border-primary/20 transition-all flex flex-col justify-between"
            >
              <div className="space-y-4">
                <div className="flex justify-between items-start border-b border-white/5 pb-3">
                  <div className="flex items-center gap-2">
                    <MapPin size={16} className="text-primary shrink-0" />
                    <div>
                      <h3 className="text-lg font-bold text-white/95 leading-tight">{p.name}</h3>
                      <span className="text-xs text-primary font-bold font-headings block mt-0.5">{p.devanagari}</span>
                    </div>
                  </div>
                  <span className="text-[9px] uppercase tracking-wider text-white/35 bg-white/5 px-2.5 py-0.5 rounded-md font-bold">
                    {p.category}
                  </span>
                </div>
                <p className="text-xs text-white/70 leading-relaxed font-light">{p.description}</p>
              </div>

              <div className="mt-6 pt-4 border-t border-white/5 space-y-2">
                {p.saintConnection && (
                  <div className="text-[10px] text-white/45 flex items-center gap-1.5">
                    <Landmark size={12} className="text-amber-500 shrink-0" />
                    <span><strong>Saint Connection:</strong> {p.saintConnection}</span>
                  </div>
                )}
                {p.locationHint && (
                  <div className="text-[10px] text-white/35 flex items-center gap-1.5 italic font-light">
                    <ExternalLink size={10} className="text-white/25 shrink-0" />
                    <span>Location: {p.locationHint}</span>
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div className="text-center py-20 glass-card rounded-2xl border border-white/5">
          <MapPin size={48} className="text-white/15 mx-auto mb-4" />
          <h3 className="text-lg font-bold text-white/70">No places located</h3>
          <p className="text-xs text-white/40 mt-1">Try adjusting your search query or filters.</p>
        </div>
      )}

      
      <section className="mt-16 bg-white/[0.015] border border-white/5 rounded-3xl p-8 max-w-4xl mx-auto text-left">
        <h2 className="text-lg font-bold text-minimal-gold mb-4 flex items-center gap-2">
          <Landmark size={18} className="text-primary" />
          The Secret Geography of Vrindavan
        </h2>
        <p className="text-xs text-white/60 leading-relaxed mb-4">
          In Vaishnava philosophy, the physical land of Braj (spanning ~84 Kos or 300 square kilometers) is not a mundane material location but the manifestation of the highest spiritual realm (Goloka) on earth. The groves, rivers, and dust of Vrindavan are considered conscious and filled with divine love (Bhakti).
        </p>
        <p className="text-xs text-white/60 leading-relaxed">
          Pilgrims and practitioners perform the <em>Govardhan Parikrama</em> or walk the sands of <em>Raman Reti</em> not merely as ritual but as a process of spiritual purification (bhajan). By studying the histories of these locations, seekers can connect the verses written by the saints to the exact physical spaces where they were composed.
        </p>
      </section>

      <InternalLinks exclude={['/places']} count={4} />
      <SEOFooter />
    </div>
  );
};

export default PlacesPage;
export { SACRED_PLACES };
