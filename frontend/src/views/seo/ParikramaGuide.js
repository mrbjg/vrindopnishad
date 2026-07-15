'use client';

import React from 'react';
import { useLocation } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';
import { Compass, Clock, MapPin, Landmark, BookOpen, AlertCircle } from 'lucide-react';

const ParikramaGuide = () => {
  const location = useLocation();
  const isHindiRoute = location.pathname.startsWith('/hi');
  const pageUrl = `${SITE_URL}${isHindiRoute ? '/hi' : ''}/vrindavan-parikrama-guide`;
  
  const title = isHindiRoute 
    ? 'वृंदावन परिक्रमा मार्गदर्शिका — मार्ग, प्रमुख घाट एवं महत्व'
    : 'Vrindavan Parikrama Guide — Route, Holy Ghats & Spiritual Rules';
  
  const description = isHindiRoute
    ? 'वृंदावन की पवित्र परिक्रमा (लगभग 10 किमी) का संपूर्ण विवरण। परिक्रमा का समय, प्रारंभ बिंदु, मुख्य घाट और दर्शन स्थल।'
    : 'Complete guide to the sacred Vrindavan Parikrama circumambulation (~10km). Learn about the route, starting points, holy temples, and spiritual rules.';

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
        <script type="application/ld+json">{JSON.stringify(generateBreadcrumbSchema([
          { name: 'Home', path: '/' },
          { name: isHindiRoute ? 'परिक्रमा मार्गदर्शिका' : 'Parikrama Guide', path: '/vrindavan-parikrama-guide' }
        ]))}</script>
      </Helmet>

      <header className="mb-10 text-center max-w-3xl mx-auto">
        <div className="badge border-amber-500/20 text-amber-500 bg-amber-500/5 mb-3 uppercase tracking-widest text-[9px] font-bold">
          {isHindiRoute ? "तीर्थ यात्रा" : "Pilgrimage Utility"}
        </div>
        <h1 className="text-3xl md:text-5xl font-bold font-headings text-sacred-gradient mb-4">
          {isHindiRoute ? "वृंदावन परिक्रमा मार्गदर्शिका" : "Vrindavan Parikrama Guide"}
        </h1>
        <p className="text-white/60 text-sm leading-relaxed">
          {isHindiRoute 
            ? "ब्रजमंडल के हृदय स्थल वृंदावन की पावन पंचकोसीय (10 किमी) परिक्रमा का आध्यात्मिक एवं व्यावहारिक परिचय।"
            : "A complete manual detailing the route, major shrines, and sacred history of the 10-kilometer circumambulation."}
        </p>
      </header>

      
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-10 text-left select-none">
        <div className="glass-card p-4 rounded-2xl border border-white/5 bg-white/[0.01]">
          <div className="text-amber-500 mb-2 flex items-center gap-1.5">
            <Compass size={16} />
            <span className="text-[10px] uppercase tracking-wider text-white/40 font-bold">{isHindiRoute ? "दूरी" : "Total Distance"}</span>
          </div>
          <span className="text-lg font-bold text-white/90">~10 Kilometers</span>
          <p className="text-[9px] text-white/40 mt-1">{isHindiRoute ? "पंचकोसीय परिक्रमा" : "Five-kos path"}</p>
        </div>

        <div className="glass-card p-4 rounded-2xl border border-white/5 bg-white/[0.01]">
          <div className="text-sky-400 mb-2 flex items-center gap-1.5">
            <Clock size={16} />
            <span className="text-[10px] uppercase tracking-wider text-white/40 font-bold">{isHindiRoute ? "समय" : "Duration"}</span>
          </div>
          <span className="text-lg font-bold text-white/90">2.5 - 4 Hours</span>
          <p className="text-[9px] text-white/40 mt-1">{isHindiRoute ? "सामान्य चाल से" : "At normal walking pace"}</p>
        </div>

        <div className="glass-card p-4 rounded-2xl border border-white/5 bg-white/[0.01]">
          <div className="text-emerald-400 mb-2 flex items-center gap-1.5">
            <MapPin size={16} />
            <span className="text-[10px] uppercase tracking-wider text-white/40 font-bold">{isHindiRoute ? "प्रारंभ" : "Starting Point"}</span>
          </div>
          <span className="text-lg font-bold text-white/90">Any Ghat / Temple</span>
          <p className="text-[9px] text-white/40 mt-1">{isHindiRoute ? "यमुना तट सर्वश्रेष्ठ" : "Yamuna banks preferred"}</p>
        </div>

        <div className="glass-card p-4 rounded-2xl border border-white/5 bg-white/[0.01]">
          <div className="text-indigo-400 mb-2 flex items-center gap-1.5">
            <Landmark size={16} />
            <span className="text-[10px] uppercase tracking-wider text-white/40 font-bold">{isHindiRoute ? "मुख्य पड़ाव" : "Key Stops"}</span>
          </div>
          <span className="text-lg font-bold text-white/90">12+ Holy Sites</span>
          <p className="text-[9px] text-white/40 mt-1">{isHindiRoute ? "घाट एवं मंदिर" : "Temples & Ghats"}</p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 items-stretch mb-12 text-left">
        
        <div className="lg:col-span-2 space-y-6">
          <section className="glass-card p-6 rounded-3xl border border-white/5 space-y-4">
            <h2 className="text-lg font-bold text-minimal-gold flex items-center gap-2">
              <BookOpen size={18} className="text-primary" />
              {isHindiRoute ? "1. परिक्रमा का आध्यात्मिक महत्व" : "1. Spiritual Significance of Parikrama"}
            </h2>
            <p className="text-xs text-white/70 leading-relaxed font-light">
              {isHindiRoute ? (
                <>
                  वैष्णव शास्त्रों के अनुसार, वृंदावन की भूमि साक्षात् श्री राधा कृष्ण का स्वरूप है। यहाँ का कंकड़-कंकड़ पारस मणि के समान दिव्य है। वृंदावन की परिक्रमा करना सम्पूर्ण ब्रह्मांड की परिक्रमा करने से भी श्रेष्ठ माना गया है।
                  <br /><br />
                  संतों का कहना है कि जब हम वृंदावन की परिक्रमा करते हैं, तो हमारे शरीर के सूक्ष्म पाप नष्ट हो जाते हैं और हृदय में वृन्दावन भक्ति का प्राकट्य होता है। स्वामी हरिदास और हित हरिवंश महाप्रभु जैसे महान संतों ने भी इस परिक्रमा मार्ग के रज (धूल) की अतुलनीय महिमा गाई है।
                </>
              ) : (
                <>
                  In Vaishnava cosmology, Vrindavan is not merely a geographic location on earth but the manifest center of the spiritual universe. The dust of Vrindavan (Braj Raj) is considered transcendental and wish-fulfilling, sanctified by the footprints of Shri Radha and Lord Krishna.
                  <br /><br />
                  Performing the Parikrama (circumambulation) is a practice of physical and mental submission to the divine. Devotees believe that circling the holy town of Vrindavan cleanses accumulated karma and grants entrance into the eternal arbors of Nikunj.
                </>
              )}
            </p>
          </section>

          <section className="glass-card p-6 rounded-3xl border border-white/5 space-y-4">
            <h2 className="text-lg font-bold text-minimal-gold flex items-center gap-2">
              <MapPin size={18} className="text-primary" />
              {isHindiRoute ? "2. परिक्रमा मार्ग और प्रमुख दर्शन स्थल" : "2. The Route & Prominent Milestones"}
            </h2>
            <p className="text-xs text-white/70 leading-relaxed font-light">
              {isHindiRoute ? (
                <>
                  यद्यपि आप परिक्रमा कहीं से भी प्रारम्भ कर सकते हैं, अधिकांश भक्त <strong>इस्कॉन मंदिर</strong>, <strong>यमुना नदी के किनारे केशी घाट</strong> या <strong>मदन मोहन मंदिर</strong> से आरम्भ करते हैं।
                  <br /><br />
                  मार्ग के मुख्य पड़ाव:
                  <ul className="list-disc pl-5 mt-2 space-y-1">
                    <li><strong>केशी घाट (Keshi Ghat):</strong> यमुना जी का प्राचीन घाट जहाँ आरती की जाती है।</li>
                    <li><strong>मदन मोहन मंदिर (Madan Mohan Temple):</strong> पहाड़ी पर स्थित वृंदावन का सबसे पुराना ऐतिहासिक शिखर मंदिर।</li>
                    <li><strong>काली दह (Kaliya Dah):</strong> वह पवित्र घाट जहाँ कदम्ब वृक्ष से कूदकर भगवान कृष्ण ने कालिया नाग को नाथा था।</li>
                    <li><strong>इमली तला (Imli Tala):</strong> चैतन्य महाप्रभु की ध्यान स्थली, जहाँ स्थित इमली वृक्ष राधा-कृष्ण काल से मौजूद है।</li>
                  </ul>
                </>
              ) : (
                <>
                  While the Parikrama can be started at any point, most pilgrims prefer to begin at the banks of the Yamuna River (such as <strong>Keshi Ghat</strong>), the historical <strong>Madan Mohan Temple</strong>, or near <strong>ISKCON temple</strong>.
                  <br /><br />
                  Key Landmarks along the path:
                  <ul className="list-disc pl-5 mt-2 space-y-1">
                    <li><strong>Keshi Ghat:</strong> The famous steps leading into the Yamuna River, where Krishna bathed after defeating the Keshi horse demon.</li>
                    <li><strong>Madan Mohan Temple:</strong> Situated on a red-sandstone hillock, this is the oldest surviving temple structure in Vrindavan, built by Sanatana Goswami.</li>
                    <li><strong>Kaliya Dah:</strong> The ancient bend of the river where Krishna leaped into the toxic waters to conquer the Kaliya serpent.</li>
                    <li><strong>Imli Tala (Tamarind Tree):</strong> The auspicious site where Sri Chaitanya Mahaprabhu sat in deep contemplation under a tamarind tree dating back to the Dwapara Yuga.</li>
                  </ul>
                </>
              )}
            </p>
          </section>
        </div>

        
        <div className="space-y-6">
          <div className="glass-card p-6 rounded-3xl border border-white/5 space-y-4 bg-white/[0.015]">
            <h3 className="font-bold text-sm text-minimal-gold uppercase tracking-wider flex items-center gap-1.5">
              <AlertCircle size={14} className="text-primary" />
              {isHindiRoute ? "साधना नियम (Rules)" : "Spiritual Etiquette"}
            </h3>
            <div className="space-y-3 text-xs text-white/70">
              <div className="py-2 border-b border-white/5">
                <strong>{isHindiRoute ? "नंगे पैर चलें" : "Walk Barefoot:"}</strong>
                <p className="text-[10px] text-white/50 mt-0.5">{isHindiRoute ? "ब्रज रज के सीधे स्पर्श के लिए नंगे पैर चलना श्रेष्ठ है।" : "Highly recommended to touch the sacred dust directly with your feet."}</p>
              </div>
              <div className="py-2 border-b border-white/5">
                <strong>{isHindiRoute ? "नाम जप" : "Japa & Chanting:"}</strong>
                <p className="text-[10px] text-white/50 mt-0.5">{isHindiRoute ? "पूरी यात्रा के दौरान राधे-राधे या हरे कृष्ण महामंत्र का जप करें।" : "Keep the tongue occupied chanting the holy names of Radha and Krishna."}</p>
              </div>
              <div className="py-2">
                <strong>{isHindiRoute ? "सम्मान करें" : "Respect & Charity:"}</strong>
                <p className="text-[10px] text-white/50 mt-0.5">{isHindiRoute ? "मार्ग में गौ माता, संतों और साथी यात्रियों का आदर करें।" : "Offer respect to local sadhus, feed the cows, and maintain silence."}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      
      <section className="glass-card p-8 rounded-3xl border border-white/5 text-left max-w-4xl mx-auto mb-12">
        <h2 className="text-xl font-bold text-minimal-gold mb-6 flex items-center gap-2">
          <BookOpen size={20} className="text-primary" />
          {isHindiRoute ? "अक्सर पूछे जाने वाले प्रश्न" : "Frequently Asked Questions"}
        </h2>
        <div className="space-y-6">
          <div className="border-b border-white/5 pb-4 space-y-2">
            <h3 className="font-bold text-sm text-white/90">
              {isHindiRoute ? "क्या परिक्रमा रात में भी की जा सकती है?" : "Can we perform Vrindavan Parikrama at night?"}
            </h3>
            <p className="text-xs text-white/60 leading-relaxed">
              {isHindiRoute 
                ? "हाँ, एकादशी और पूर्णिमा के दिनों में हजारों श्रद्धालु रात में परिक्रमा करते हैं क्योंकि तब मौसम सुहावना होता है। हालांकि सुरक्षा कारणों से एकांत स्थानों पर समूह में चलना ही श्रेयस्कर है।"
                : "Yes, during Ekadashi and Purnima, thousands of devotees circumambulate at night. It is cooler and highly peaceful, though it is advised to walk in groups on darker stretches."}
            </p>
          </div>
          <div className="space-y-2">
            <h3 className="font-bold text-sm text-white/90">
              {isHindiRoute ? "वृंदावन परिक्रमा के लिए सबसे सर्वोत्तम दिन कौन सा है?" : "Which is the best day to perform Vrindavan Parikrama?"}
            </h3>
            <p className="text-xs text-white/60 leading-relaxed">
              {isHindiRoute 
                ? "दैनिक रूप से कभी भी की जा सकती है, किंतु एकादशी (विशेष रूप से देवउठनी या निर्जला), अक्षय तृतीया, गुरु पूर्णिमा और जन्माष्टमी के पावन पर्वों पर परिक्रमा करना अनंत गुणा फलदायी माना गया है।"
                : "Every day is highly auspicious, but performing Parikrama on Ekadashi, Akshay Tritiya, Guru Purnima, or Janmashtami is considered extremely beneficial, drawing vast crowds."}
            </p>
          </div>
        </div>
      </section>

      <InternalLinks exclude={['/vrindavan-parikrama-guide']} count={4} />
      <SEOFooter />
    </div>
  );
};

export default ParikramaGuide;
