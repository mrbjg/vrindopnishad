import React from 'react';
import { useLocation } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import InternalLinks from '../../components/InternalLinks';
import SEOFooter from '../../components/SEOFooter';
import { Landmark, BookOpen, Sparkles, Award } from 'lucide-react';

const RadhavallabhVsGaudiya = () => {
  const location = useLocation();
  const isHindiRoute = location.pathname.startsWith('/hi');
  const pageUrl = `${SITE_URL}${isHindiRoute ? '/hi' : ''}/radhavallabh-vs-gaudiya-sampradaya`;
  
  const title = isHindiRoute 
    ? 'राधावल्लभ बनाम गौड़ीय संप्रदाय — दर्शन, आचार्य एवं अंतर'
    : 'Radha Vallabh vs Gaudiya Sampradaya — Philosophy, Founders & Differences';
  
  const description = isHindiRoute
    ? 'राधावल्लभ और गौड़ीय संप्रदाय के बीच प्रमुख दार्शनिक अंतर समझें। हित हरिवंश महाप्रभु और चैतन्य महाप्रभु के सिद्धांतों का तुलनात्मक अध्ययन।'
    : 'Understand the key philosophical differences between Radha Vallabh and Gaudiya Sampradaya. Compare Hit Harivansh and Chaitanya Mahaprabhu\'s teachings.';

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
          { name: isHindiRoute ? 'राधावल्लभ बनाम गौड़ीय' : 'Radha Vallabh vs Gaudiya', path: '/radhavallabh-vs-gaudiya-sampradaya' }
        ]))}</script>
      </Helmet>

      <header className="mb-10 text-center max-w-3xl mx-auto">
        <div className="badge border-amber-500/20 text-amber-500 bg-amber-500/5 mb-3 uppercase tracking-widest text-[9px] font-bold">
          {isHindiRoute ? "सम्प्रदाय तुलना" : "Sectarian Comparison"}
        </div>
        <h1 className="text-3xl md:text-5xl font-bold font-headings text-sacred-gradient mb-4">
          {isHindiRoute ? "राधावल्लभ बनाम गौड़ीय संप्रदाय" : "Radhavallabh vs Gaudiya Sampradaya"}
        </h1>
        <p className="text-white/60 text-sm leading-relaxed">
          {isHindiRoute 
            ? "ब्रज रसिक दर्शन के दो प्रमुख स्तम्भों का विस्तृत तुलनात्मक विश्लेषण एवं आध्यात्मिक रहस्य।"
            : "A detailed comparative analysis of the two dominant streams of aesthetic devotion (Rasa) in Vrindavan."}
        </p>
      </header>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 items-stretch mb-12">
        {/* Main Content (col-span-2) */}
        <div className="lg:col-span-2 space-y-6 text-left">
          <section className="glass-card p-6 rounded-3xl border border-white/5 space-y-4">
            <h2 className="text-lg font-bold text-minimal-gold flex items-center gap-2">
              <Landmark size={18} className="text-primary" />
              {isHindiRoute ? "1. ऐतिहासिक पृष्ठभूमि एवं प्रवर्तक" : "1. Historical Roots & Founders"}
            </h2>
            <p className="text-xs text-white/70 leading-relaxed">
              {isHindiRoute ? (
                <>
                  गौड़ीय सम्प्रदाय का प्राकट्य 16वीं शताब्दी में <strong>श्रीमन् महाप्रभु चैतन्य देव</strong> (1486–1534 ई.) के बंगाल से आगमन के साथ हुआ। चैतन्य महाप्रभु ने रूप गोस्वामी, सनातन गोस्वामी और जीव गोस्वामी जैसे छह गोस्वामियों को वृंदावन भेजकर लुप्त लीला स्थलों को प्रकट करने और भक्ति दर्शन का ग्रंथन करने का आदेश दिया।
                  <br /><br />
                  इसके विपरीत, <strong>राधावल्लभ सम्प्रदाय</strong> की स्थापना <strong>गोस्वामी हित हरिवंश महाप्रभु</strong> (1502–1552 ई.) द्वारा की गई, जिन्हें श्री कृष्ण की वंशी का अवतार माना जाता है। उन्होंने वृंदावन के मदन टेर स्थल पर राधावल्लभ लाल जी के विग्रह को विराजमान कर संवत 1591 में इस सम्प्रदाय की उपासना प्रणाली आरम्भ की।
                </>
              ) : (
                <>
                  The <strong>Gaudiya Sampradaya</strong> traces its modern renaissance to <strong>Sri Chaitanya Mahaprabhu</strong> (1486–1534 AD) in Bengal. Chaitanya Mahaprabhu instructed the Six Goswamis (headed by Rupa and Sanatana) to excavate the holy places of Vrindavan and write scriptural treatises establishing Achintya-Bheda-Abheda philosophy.
                  <br /><br />
                  The <strong>Radhavallabh Sampradaya</strong> was established by <strong>Goswami Hit Harivansh Mahaprabhu</strong> (1502–1552 AD), revered as the embodiment of Krishna's divine flute. He manifested the deity of Shri Radhavallabh Lal Ji in Vrindavan, centering the entire tradition on spontaneous love rather than conventional Vedic rituals.
                </>
              )}
            </p>
          </section>

          <section className="glass-card p-6 rounded-3xl border border-white/5 space-y-4">
            <h2 className="text-lg font-bold text-minimal-gold flex items-center gap-2">
              <Sparkles size={18} className="text-primary" />
              {isHindiRoute ? "2. दार्शनिक मत: श्री राधा का स्वरूप" : "2. Theological Focus: The Position of Shri Radha"}
            </h2>
            <p className="text-xs text-white/70 leading-relaxed">
              {isHindiRoute ? (
                <>
                  गौड़ीय दर्शन में श्री राधा को भगवान कृष्ण की 'ह्लादिनी शक्ति' (परम आनंद देने वाली शक्ति) माना जाता है। यहाँ कृष्ण परम पुरुष या शक्तिमान हैं, और श्री राधा उनकी मूल शक्ति हैं। दोनों एक होते हुए भी लीला विलास के लिए दो रूपों में प्रकट हैं।
                  <br /><br />
                  राधावल्लभ सम्प्रदाय में यह दृष्टिकोण पूर्णतः <strong>राधा-प्रधान</strong> है। यहाँ श्री राधा केवल शक्ति नहीं हैं, बल्कि वे ही मूल परम सत्ता (सर्वोपरि सत्ता) हैं। कृष्ण उनकी प्रसन्नता के लिए सदैव तत्पर रहते हैं और उनका अनुगमन करते हैं। हित हरिवंश जी ने श्री राधा के चरणों के आश्रय को ही जीवन का एकमात्र ध्येय माना है।
                </>
              ) : (
                <>
                  In Gaudiya theology, Shri Radha is established as the <em>Hladini Shakti</em> (pleasure-giving energy) of Lord Krishna, who is the ultimate energetic source (Shaktiman). They are non-different, yet eternally separate to taste the bliss of pastimes.
                  <br /><br />
                  In the Radhavallabh tradition, the theology is radically <strong>Radha-centric</strong>. Shri Radha is not merely the potency; She is the supreme, sovereign ruler of Vrindavan. Lord Krishna is considered Her absolute servant, dedicated solely to Her pleasure. The supreme goal is shelter under Srimati Radharani's lotus feet (Radha-charan-pradhan).
                </>
              )}
            </p>
          </section>

          <section className="glass-card p-6 rounded-3xl border border-white/5 space-y-4">
            <h2 className="text-lg font-bold text-minimal-gold flex items-center gap-2">
              <BookOpen size={18} className="text-primary" />
              {isHindiRoute ? "3. लीला अवधारणा और साधना पद्धति" : "3. Lila Concept & Sadhana Method"}
            </h2>
            <p className="text-xs text-white/70 leading-relaxed">
              {isHindiRoute ? (
                <>
                  गौड़ीय सम्प्रदाय में <strong>मंजरी भाव</strong> की साधना मुख्य है, जहाँ साधक श्री राधा की युवा सखियों (मंजरियों) का अनुकरण कर उनकी सेवा करता है। यहाँ लीला में मिलन और विरह (वियोग) दोनों भावों को अत्यंत महत्वपूर्ण स्थान प्राप्त है।
                  <br /><br />
                  राधावल्लभ सम्प्रदाय में साधना <strong>सहचरी भाव</strong> पर आधारित है, और यहाँ केवल <strong>नित्य विहार</strong> (अखंड मिलन) की उपासना होती है। यहाँ विरह या वियोग का सर्वथा निषेध है। यमुना तट की कुंजों में श्री राधा कृष्ण बिना किसी बाधा या वियोग के क्षण-क्षण नव-नूतन रसमयी लीलाओं में मग्न रहते हैं।
                </>
              ) : (
                <>
                  Gaudiya Vaishnavism champions <strong>Manjari Bhava</strong>, where devotees meditate on serving under the principal sakhis as tiny maidservants. The pastimes involve both union and separation (viraha/vipralambha), which is considered the highest peak of love.
                  <br /><br />
                  Radhavallabh sadhana revolves around <strong>Sahachari Bhava</strong> and is focused exclusively on <strong>Nitya Vihar</strong>—continuous, uninterrupted union in the bowers of Nikunj. There is absolutely no place for separation (viraha) in this sentiment, as union is refreshed every single millisecond through mutual fascination.
                </>
              )}
            </p>
          </section>
        </div>

        {/* Sidebar Info (col-span-1) */}
        <div className="space-y-6 text-left">
          <div className="glass-card p-6 rounded-3xl border border-white/5 space-y-4 bg-white/[0.015]">
            <h3 className="font-bold text-sm text-minimal-gold uppercase tracking-wider flex items-center gap-1.5">
              <Landmark size={14} className="text-primary" />
              {isHindiRoute ? "तुलनात्मक सार" : "Comparison Summary"}
            </h3>
            <div className="space-y-3 text-xs">
              <div className="py-2 border-b border-white/5">
                <span className="text-[9px] uppercase tracking-wider text-white/35 block">{isHindiRoute ? "गौड़ीय सम्प्रदाय" : "Gaudiya Sampradaya"}</span>
                <ul className="list-disc pl-4 text-white/80 mt-1 space-y-1">
                  <li>{isHindiRoute ? "प्रवर्तक: चैतन्य महाप्रभु" : "Founder: Sri Chaitanya"}</li>
                  <li>{isHindiRoute ? "मूल भाव: मंजरी भाव" : "Sentiment: Manjari Bhava"}</li>
                  <li>{isHindiRoute ? "लीला स्वरूप: विरह एवं मिलन दोनों" : "Lila: Both Separation & Union"}</li>
                  <li>{isHindiRoute ? "सर्वोच्च सत्ता: कृष्ण (शक्तिमान)" : "Supreme: Krishna (Source)"}</li>
                </ul>
              </div>
              <div className="py-2">
                <span className="text-[9px] uppercase tracking-wider text-white/35 block">{isHindiRoute ? "राधावल्लभ सम्प्रदाय" : "Radhavallabh Sampradaya"}</span>
                <ul className="list-disc pl-4 text-white/80 mt-1 space-y-1">
                  <li>{isHindiRoute ? "प्रवर्तक: हित हरिवंश महाप्रभु" : "Founder: Hit Harivansh"}</li>
                  <li>{isHindiRoute ? "मूल भाव: सहचरी भाव" : "Sentiment: Sahachari Bhava"}</li>
                  <li>{isHindiRoute ? "लीला स्वरूप: केवल नित्य विहार (मिलन)" : "Lila: Nitya Vihar (Only Union)"}</li>
                  <li>{isHindiRoute ? "सर्वोच्च सत्ता: श्री राधा" : "Supreme: Srimati Radha"}</li>
                </ul>
              </div>
            </div>
          </div>

          <div className="glass-card p-6 rounded-3xl border border-white/5 bg-amber-500/[0.02] border-amber-500/10 space-y-3">
            <h3 className="font-bold text-xs text-primary uppercase tracking-wider flex items-center gap-1">
              <Award size={14} />
              {isHindiRoute ? "सद्भाव संदेश" : "Sectarian Harmony"}
            </h3>
            <p className="text-[11px] text-white/60 leading-relaxed font-light">
              {isHindiRoute 
                ? "\"दार्शनिक रूप से भेद होने पर भी, दोनों ही संप्रदाय वृंदावन के निस्वार्थ प्रेम दर्शन (ब्रज रस) का पोषण करते हैं और रसिक संतों का परस्पर गहरा आदर रहा है।\""
                : "\"Despite structural differences, both traditions are beautiful streams watering the same single soil of Vrindavan Rasa. Rasisks of both sampradayas historically shared deep mutual respect.\""}
            </p>
          </div>
        </div>
      </div>

      {/* FAQ Section */}
      <section className="glass-card p-8 rounded-3xl border border-white/5 text-left max-w-4xl mx-auto mb-12">
        <h2 className="text-xl font-bold text-minimal-gold mb-6 flex items-center gap-2">
          <BookOpen size={20} className="text-primary" />
          {isHindiRoute ? "अक्सर पूछे जाने वाले प्रश्न" : "Frequently Asked Questions"}
        </h2>
        <div className="space-y-6">
          <div className="border-b border-white/5 pb-4 space-y-2">
            <h3 className="font-bold text-sm text-white/90">
              {isHindiRoute ? "मंजरी भाव और सहचरी भाव में क्या अंतर है?" : "What is the difference between Manjari and Sahachari Bhava?"}
            </h3>
            <p className="text-xs text-white/60 leading-relaxed">
              {isHindiRoute 
                ? "मंजरी भाव में साधक अत्यंत छोटी दासी के रूप में केवल श्री राधा की सेवा करता है और कृष्ण की ओर नहीं देखता। सहचरी भाव में साधक युगल सरकार (दोनों) की परस्पर रसमय क्रीड़ा को सखी रूप में सजाता है और नित्य कुंज क्रीड़ा में सहभागी बनता है।"
                : "In Manjari Bhava, the devotee meditates as a young maidservant serving Srimati Radharani exclusively. In Sahachari Bhava, the devotee functions as a companion sakhi arranging the arbors and witnessing the mutual loving play of both Radha and Krishna."}
            </p>
          </div>
          <div className="space-y-2">
            <h3 className="font-bold text-sm text-white/90">
              {isHindiRoute ? "क्या हित हरिवंश महाप्रभु और चैतन्य महाप्रभु मिले थे?" : "Did Sri Chaitanya and Hit Harivansh Mahaprabhu meet?"}
            </h3>
            <p className="text-xs text-white/60 leading-relaxed">
              {isHindiRoute 
                ? "इतिहास में दोनों के प्रत्यक्ष मिलन का कोई ठोस प्रमाण नहीं है, परंतु उनके समकालीन अनुयायियों और संतों में गहरा संवाद था। हित हरिवंश जी ने चैतन्य महाप्रभु के अनुयायियों जैसे प्रबोधानंद सरस्वती जी के साथ मिलकर वृंदावन रस का गान किया।"
                : "While there is no historical record of a direct meeting, their contemporary disciples and saints shared deep dialogs. Hit Harivansh Mahaprabhu worked closely with figures like Prabodhananda Sarasvati, establishing Vrindavan as the global heart of Rasa."}
            </p>
          </div>
        </div>
      </section>

      <InternalLinks exclude={['/radhavallabh-vs-gaudiya-sampradaya']} count={4} />
      <SEOFooter />
    </div>
  );
};

export default RadhavallabhVsGaudiya;
