import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { 
  Search, Plus, Trash2, Volume2, Play, Pause, 
  Check, X, VolumeX, Info, BookOpen, Sparkles, Feather
} from 'lucide-react';

const getStorageKey = (currentUser) => {
  return currentUser ? `vrindopnishad_reflections_${currentUser.uid || currentUser.email}` : 'vrindopnishad_reflections';
};

const getInitialReflections = (currentUser, hindiMode) => {
  try {
    const key = getStorageKey(currentUser);
    const saved = localStorage.getItem(key);
    if (saved) return JSON.parse(saved);
  } catch (e) {}

  return [
    { 
      id: 1, 
      text: hindiMode 
        ? 'सुबह जप करते समय तानपुरा सिंथेसाइज़र सुनते हुए गहरा ध्यान अनुभव किया।' 
        : 'Experienced deep focus during morning Japa while listening to the Tanpura synthesizer.', 
      date: '05/27/2026' 
    },
    { 
      id: 2, 
      text: hindiMode 
        ? 'श्रीमद्भगवद्गीता के श्लोक २.४७ पर विचार किया। केवल प्रयास पर ध्यान केंद्रित करना आवश्यक है, परिणामों पर नहीं।' 
        : 'Contemplated Shloka 2.47 from Bhagavad Gita. Essential to focus only on effort, not results.', 
      date: '05/26/2026' 
    }
  ];
};

const PookizDashboardView = ({
  isHi,
  saints = [],
  books = [],
  ragas = [],
  dailyShloka,
  japaCount,
  handleUpdateJapaCount,
  streak,
  handleComplete,
  isCompleted,
  isPlaying,
  handleChantAudio,
  isTanpuraPlaying,
  toggleTanpura,
  dailyGoal,
  percentComplete,
  rounds,
  currentGreeting,
  settings,
  updateSetting,
  user
}) => {
  
  const [activeTab, setActiveTab] = useState('moderationAudit'); 

  
  const [saintSearchQuery, setSaintSearchQuery] = useState('');
  const [bookSearchQuery, setBookSearchQuery] = useState('');



  
  const [readingShelf, setReadingShelf] = useState(() => {
    try {
      const saved = localStorage.getItem('vrindopnishad_reading_shelf');
      if (saved) return JSON.parse(saved);
    } catch (e) {}
    
    return [
      { id: '1', name: 'Sri Radha Sudhanidhi', author: 'Shri Hith Harivansh Mahaprabhu', target: '2 verses/day', progress: 12, addedAt: '05/26/2026' },
      { id: '2', name: 'Sri Hit Chaurasi Ji', author: 'Shri Hith Harivansh Mahaprabhu', target: '4 verses/day', progress: 45, addedAt: '05/26/2026' }
    ];
  });

  
  const [selectedBookSlug, setSelectedBookSlug] = useState('');
  const [dailyTargetVerses, setDailyTargetVerses] = useState('2');

  const getDevoteeName = () => {
    if (settings && settings.devoteeName) return settings.devoteeName;
    if (user) {
      if (user.displayName) return user.displayName;
      if (user.email) return user.email.split('@')[0];
    }
    return isHi ? 'साधक' : 'Devotee';
  };

  const getDevoteeInitial = () => {
    const name = getDevoteeName();
    return name ? name.charAt(0).toUpperCase() : 'D';
  };

  
  const [reflections, setReflections] = useState(() => getInitialReflections(user, isHi));
  const [newReflectionText, setNewReflectionText] = useState('');

  
  useEffect(() => {
    setReflections(getInitialReflections(user, isHi));
  }, [user, isHi]);

  
  const [broadcasts] = useState([
    { id: 1, title: 'Braj Parikrama Guide Uploaded', msg: 'Explore the complete guide for Vrindavan parikrama, timing and sacred spots in the library.', time: 'Just now' }
  ]);

  
  const [auditingSaint, setAuditingSaint] = useState(null);

  
  const [toastMessage, setToastMessage] = useState(null);
  const triggerToast = (msg) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 4000);
  };

  
  const [swadhyayaSubTab, setSwadhyayaSubTab] = useState('verse');

  
  const handleAddToShelf = (e) => {
    e.preventDefault();
    if (!selectedBookSlug) {
      triggerToast(isHi ? 'कृपया एक ग्रन्थ चुनें।' : 'Please select a scripture book.');
      return;
    }
    
    const selectedBook = books.find(b => b.slug === selectedBookSlug);
    if (!selectedBook) return;

    if (readingShelf.some(item => item.name === selectedBook.name)) {
      triggerToast(isHi ? 'ग्रन्थ पहले से ही आपके स्वाध्याय शेल्फ में है।' : 'Book is already on your reading shelf.');
      return;
    }

    const newItem = {
      id: Date.now().toString(),
      name: selectedBook.name,
      author: selectedBook.author || 'Rasik Sant',
      target: `${dailyTargetVerses} ${isHi ? 'श्लोक/दिन' : 'verses/day'}`,
      progress: 0,
      addedAt: new Date().toLocaleDateString('en-US', {
        month: '2-digit',
        day: '2-digit',
        year: 'numeric'
      })
    };

    const updated = [...readingShelf, newItem];
    setReadingShelf(updated);
    localStorage.setItem('vrindopnishad_reading_shelf', JSON.stringify(updated));
    triggerToast(isHi ? `"${selectedBook.name}" शेल्फ में जोड़ा गया!` : `Added "${selectedBook.name}" to shelf!`);
    setSelectedBookSlug('');
  };

  
  const handleRemoveFromShelf = (id, name) => {
    const updated = readingShelf.filter(item => item.id !== id);
    setReadingShelf(updated);
    localStorage.setItem('vrindopnishad_reading_shelf', JSON.stringify(updated));
    triggerToast(isHi ? `"${name}" शेल्फ से हटाया गया।` : `Removed "${name}" from reading shelf.`);
  };

  
  const handleAddReflection = (e) => {
    e.preventDefault();
    if (!newReflectionText.trim()) return;

    const newRef = {
      id: Date.now(),
      text: newReflectionText.trim(),
      date: new Date().toLocaleDateString('en-US', {
        month: '2-digit',
        day: '2-digit',
        year: 'numeric'
      })
    };

    const updated = [newRef, ...reflections];
    setReflections(updated);
    localStorage.setItem(getStorageKey(user), JSON.stringify(updated));
    triggerToast(isHi ? 'अनुभूति डायरी में प्रविष्टि अंकित की गई।' : 'Reflection added to your journal.');
    setNewReflectionText('');
  };



  
  const filteredSaints = saints.filter(s => 
    s.name.toLowerCase().includes(saintSearchQuery.toLowerCase()) ||
    (s.hinglishName && s.hinglishName.toLowerCase().includes(saintSearchQuery.toLowerCase())) ||
    (s.biography && s.biography.sampraday && s.biography.sampraday.toLowerCase().includes(saintSearchQuery.toLowerCase()))
  );

  const filteredBooksShelf = readingShelf.filter(b => 
    b.name.toLowerCase().includes(bookSearchQuery.toLowerCase()) ||
    b.author.toLowerCase().includes(bookSearchQuery.toLowerCase())
  );

  const getEra = (saint) => {
    if (!saint.biography || !saint.biography.text) return 'Medieval Era';
    const text = saint.biography.text;
    if (text.includes('१६') || text.includes('16')) return '16th Century';
    if (text.includes('१७') || text.includes('17')) return '17th Century';
    if (text.includes('१८') || text.includes('18')) return '18th Century';
    if (text.includes('१५') || text.includes('15')) return '15th Century';
    return '16th Century';
  };

  return (
    <div className="space-y-8 animate-fade-in text-left select-none relative">
      
      
      {toastMessage && (
        <div className="fixed top-18 right-6 bg-purple-600/95 backdrop-blur border border-purple-400 text-white px-4 py-3 rounded-2xl shadow-2xl z-[5000] flex items-center gap-2 text-xs font-semibold animate-scale-in">
          <Info size={16} />
          <span>{toastMessage}</span>
          <button onClick={() => setToastMessage(null)} className="ml-2 hover:text-zinc-200">
            <X size={14} />
          </button>
        </div>
      )}

      
      {broadcasts.length > 0 && (
        <div className="bg-[#1c1917] border border-[#f59e0b]/20 p-3 rounded-2xl flex items-start gap-3 text-xs shadow-md">
          <Sparkles className="text-[#f59e0b] shrink-0 mt-0.5" size={15} />
          <div>
            <span className="font-bold text-[#f59e0b] uppercase tracking-wide mr-2">[{isHi ? 'सूचना' : 'Notice'}] {broadcasts[0].title}:</span>
            <span className="text-zinc-300 font-light">{broadcasts[0].msg}</span>
          </div>
        </div>
      )}

      
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-white/5 pb-4 mb-2">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-white font-headings">
            {isHi ? 'ब्रज साधना व निर्देशिका सेवा' : 'Braj Sadhana & Wiki Portal'}
          </h1>
          <p className="text-zinc-400 text-xs mt-1 max-w-2xl leading-relaxed">
            {isHi 
              ? 'दैनिक नाम जप संख्या अंकित करें, वाणी ग्रन्थ स्वाध्याय करें, एवं ब्रज के रसिक सन्तों के जीवन चरित्र व विकी का अवलोकन करें।' 
              : 'Track daily Japa chanting counts, study Swadhyaya verses, manage your scripture shelf, and explore Vrindavan saints biographies.'}
          </p>
        </div>

        
        <div className="flex items-center gap-2 overflow-x-auto scrollbar-hide py-1 shrink-0">
          {[
            { id: 'moderationAudit', label: isHi ? 'साधना व स्वाध्याय' : 'Sadhana & Swadhyaya' },
            { id: 'userDirectory', label: isHi ? 'रसिक सन्त' : 'Rasik Saints' },
            { id: 'universities', label: isHi ? 'ग्रन्थ शेल्फ' : 'Scripture Shelf' },
            { id: 'broadcasts', label: isHi ? 'सत्संग सूचना' : 'Satsang Announcements' },
            { id: 'feedback', label: isHi ? 'साधना डायरी' : 'Sadhana Journal' }
          ].map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`px-3.5 py-1.5 rounded-full text-xs font-semibold tracking-wide transition-all border whitespace-nowrap ${
                activeTab === tab.id
                  ? 'bg-purple-600 border-transparent text-white shadow-lg'
                  : 'bg-white/5 text-zinc-400 hover:text-white border-white/10'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      
      
      
      {activeTab === 'userDirectory' && (
        <div className="bg-[#121215] border border-white/5 rounded-2xl p-4 md:p-5 shadow-xl animate-scale-in">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
            <div>
              <h2 className="text-lg font-bold text-white flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-purple-400 animate-pulse"></span>
                {isHi ? 'रसिक सन्त निर्देशिका (जीवनी व वाणी)' : 'Rasik Saints Directory (Biographies & Vaani)'}
              </h2>
              <p className="text-zinc-500 text-xs mt-0.5">
                {isHi ? 'सम्प्रदाय, काल एवं रचित पदों के अनुसार सन्त जीवनी का अनुशीलन करें।' : 'Search and browse saint disciplic lineages, historical eras, and recorded verses.'}
              </p>
            </div>
            
            
            <div className="relative w-full sm:w-64">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-400" size={14} />
              <input
                type="text"
                placeholder={isHi ? "सन्त नाम खोजें..." : "Search user profile names..."}
                className="w-full bg-white text-zinc-950 border border-zinc-200 rounded-xl pl-9 pr-4 py-2 text-xs placeholder:text-zinc-400 outline-none focus:ring-1 focus:ring-zinc-400 transition-colors font-medium"
                value={saintSearchQuery}
                onChange={(e) => setSaintSearchQuery(e.target.value)}
              />
            </div>
          </div>

          
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="border-b border-white/5 text-[10px] text-zinc-500 font-bold uppercase tracking-wider">
                  <th className="pb-3 px-2">{isHi ? 'सन्त' : 'SAINT'}</th>
                  <th className="pb-3 px-2">{isHi ? 'सम्प्रदाय' : 'SAMPRADAYA'}</th>
                  <th className="pb-3 px-2">{isHi ? 'काल' : 'ERA'}</th>
                  <th className="pb-3 px-2">{isHi ? 'कुल श्लोक/पद' : 'METRICS'}</th>
                  <th className="pb-3 px-2">{isHi ? 'जन्म स्थान' : 'BIRTH TOWN'}</th>
                  <th className="pb-3 px-2 text-right">{isHi ? 'विवरण' : 'EXPLORE'}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-white/5">
                {filteredSaints.length === 0 ? (
                  <tr>
                    <td colSpan="6" className="py-8 text-center text-xs text-zinc-600">{isHi ? 'डाटाबेस में कोई सन्त नहीं मिले।' : 'No saints found in database.'}</td>
                  </tr>
                ) : (
                  filteredSaints.slice(0, 15).map((sant) => {
                    const initials = (isHi ? sant.name : sant.hinglishName || 'V').charAt(0);
                    const era = getEra(sant);
                    const locationName = sant.biography?.birthPlace || 'Braj Mandal';
                    const sect = sant.biography?.sampraday || 'Rasik Parampara';
                    
                    return (
                       <tr key={sant.cleanName} className="text-xs text-zinc-300 hover:bg-white/[0.01] transition-colors">
                        <td className="py-3.5 px-2">
                          <div className="flex items-center gap-3">
                            <div className="w-8 h-8 rounded-full bg-purple-500/10 border border-purple-500/20 flex items-center justify-center font-bold text-purple-400 uppercase text-[10px]">
                              {initials}
                            </div>
                            <div>
                              <span className="font-semibold text-white block">{sant.name}</span>
                              <span className="text-[10px] text-zinc-500 block">@{sant.cleanName}</span>
                            </div>
                          </div>
                        </td>
                        <td className="py-3.5 px-2 text-zinc-400 font-light">{sect}</td>
                        <td className="py-3.5 px-2 font-mono text-[11px]">{era}</td>
                        <td className="py-3.5 px-2">
                          <span className="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-amber-950/20 text-amber-300 border border-amber-500/30">
                            {sant.verses.length} {isHi ? 'पद' : 'verses'}
                          </span>
                        </td>
                        <td className="py-3.5 px-2 text-zinc-500">{locationName}</td>
                        <td className="py-3.5 px-2 text-right">
                          <div className="flex items-center justify-end gap-2">
                            <button
                              onClick={() => setAuditingSaint(sant)}
                              className="bg-black hover:bg-zinc-900 text-white border border-white/20 rounded-full px-3 py-1 font-semibold text-[10px] whitespace-nowrap transition-colors"
                            >
                              {isHi ? 'जीवनी' : 'Read Bio'}
                            </button>
                            <Link
                              to={isHi ? `/hi/saint/${sant.slug}` : `/saint/${sant.slug}`}
                              className="bg-white hover:bg-zinc-200 text-zinc-950 rounded-full px-3 py-1.5 font-bold text-[10px] whitespace-nowrap transition-all"
                            >
                              {isHi ? 'वाणी देखें' : 'Explore Vaani'}
                            </Link>
                          </div>
                        </td>
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      
      {activeTab === 'universities' && (
        <div className="space-y-4">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 items-stretch">
            
            
            <div className="bg-[#121215] border border-white/5 rounded-2xl p-4 md:p-5 shadow-xl flex flex-col justify-between">
              <div>
                <h2 className="text-base font-bold text-white flex items-center gap-2 mb-1">
                  <Plus size={18} className="text-purple-400" />
                  {isHi ? 'स्वाध्याय शेल्फ में ग्रन्थ जोड़ें' : 'Add scripture to Reading Shelf'}
                </h2>
                <p className="text-zinc-500 text-xs mb-6">
                  {isHi ? 'एक ग्रन्थ का चयन करें और दैनिक अध्ययन लक्ष्य निर्धारित करें।' : 'Choose a sacred book and specify your daily study target.'}
                </p>

                <form onSubmit={handleAddToShelf} className="space-y-5">
                  <div>
                    <label className="block text-[10px] font-bold uppercase tracking-wider text-zinc-500 mb-1.5">
                      {isHi ? 'वाणी ग्रन्थ चुनें' : 'Select scripture book'}
                    </label>
                    <select
                      className="w-full bg-[#18181c] border border-white/5 rounded-xl px-4 py-2.5 text-xs text-white outline-none cursor-pointer focus:border-purple-500/50"
                      value={selectedBookSlug}
                      onChange={(e) => setSelectedBookSlug(e.target.value)}
                    >
                      <option value="">{isHi ? '-- ग्रन्थ चुनें --' : '-- Choose a book --'}</option>
                      {books.map(b => (
                        <option key={b.slug} value={b.slug}>{b.name} ({b.author || 'Rasik Sant'})</option>
                      ))}
                    </select>
                  </div>

                  <div>
                    <label className="block text-[10px] font-bold uppercase tracking-wider text-zinc-500 mb-1.5">
                      {isHi ? 'दैनिक स्वाध्याय लक्ष्य (श्लोक/पद)' : 'Daily target (Verses)'}
                    </label>
                    <select
                      className="w-full bg-[#18181c] border border-white/5 rounded-xl px-4 py-2.5 text-xs text-white outline-none cursor-pointer focus:border-purple-500/50"
                      value={dailyTargetVerses}
                      onChange={(e) => setDailyTargetVerses(e.target.value)}
                    >
                      <option value="1">1 {isHi ? 'श्लोक/दिन' : 'verse/day'}</option>
                      <option value="2">2 {isHi ? 'श्लोक/दिन (अनुशंसित)' : 'verses/day (Recommended)'}</option>
                      <option value="4">4 {isHi ? 'श्लोक/दिन' : 'verses/day'}</option>
                      <option value="8">8 {isHi ? 'श्लोक/दिन' : 'verses/day'}</option>
                    </select>
                  </div>

                  <button
                    type="submit"
                    className="w-full bg-white text-zinc-950 hover:bg-zinc-200 transition-all font-bold text-xs py-2.5 rounded-full shadow-md mt-4"
                  >
                    {isHi ? 'ग्रन्थ जोड़े' : 'Add Scripture'}
                  </button>
                </form>
              </div>
            </div>

            
            <div className="bg-[#121215] border border-white/5 rounded-2xl p-4 md:p-5 shadow-xl flex flex-col justify-between">
              <div>
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
                  <div>
                    <h2 className="text-lg font-bold text-white">{isHi ? 'सक्रिय ग्रन्थ स्वाध्याय शेल्फ' : 'Active Granthas Shelf'}</h2>
                    <p className="text-zinc-500 text-xs mt-0.5">
                      {isHi ? 'आपके दैनिक अध्ययन नियम की सक्रिय पुस्तकें।' : 'Scripture books currently in your daily study list.'}
                    </p>
                  </div>
                  <div className="relative w-44">
                    <Search className="absolute left-2.5 top-1/2 -translate-y-1/2 text-zinc-400" size={12} />
                    <input
                      type="text"
                      placeholder={isHi ? "फ़िल्टर करें..." : "Filter shelf..."}
                      className="w-full bg-white text-zinc-950 border border-zinc-200 rounded-lg pl-8 pr-3 py-1.5 text-[11px] placeholder:text-zinc-400 outline-none font-medium"
                      value={bookSearchQuery}
                      onChange={(e) => setBookSearchQuery(e.target.value)}
                    />
                  </div>
                </div>

                <div className="overflow-x-auto">
                  <table className="w-full text-left border-collapse">
                    <thead>
                      <tr className="border-b border-white/5 text-[9px] text-zinc-500 font-bold uppercase tracking-wider">
                        <th className="pb-2 px-2">{isHi ? 'प्रतीक' : 'LOGO'}</th>
                        <th className="pb-2 px-2">{isHi ? 'ग्रन्थ' : 'NAME'}</th>
                        <th className="pb-2 px-2">{isHi ? 'रचनाकार' : 'AUTHOR'}</th>
                        <th className="pb-2 px-2">{isHi ? 'स्वाध्याय लक्ष्य' : 'DAILY TARGET'}</th>
                        <th className="pb-2 px-2 text-right">{isHi ? 'कार्य' : 'ACTIONS'}</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-white/5">
                      {filteredBooksShelf.length === 0 ? (
                        <tr>
                          <td colSpan="5" className="py-6 text-center text-xs text-zinc-600">
                            {isHi ? 'स्वाध्याय शेल्फ खाली है।' : 'No scriptures on reading shelf.'}
                          </td>
                        </tr>
                      ) : (
                        filteredBooksShelf.map((item) => (
                          <tr key={item.id} className="text-xs text-zinc-300">
                            <td className="py-3 px-2">
                              <div className="w-6 h-6 rounded-full bg-purple-500/10 border border-purple-500/20 flex items-center justify-center text-[10px] text-purple-400">
                                <BookOpen size={12} />
                              </div>
                            </td>
                            <td className="py-3 px-2 font-semibold text-white">{item.name}</td>
                            <td className="py-3 px-2 text-zinc-500 font-light">{item.author}</td>
                            <td className="py-3 px-2">
                              <span className="px-2 py-0.5 rounded-full text-[9px] font-semibold bg-amber-500/10 text-amber-400 border border-amber-500/20">
                                {item.target}
                              </span>
                            </td>
                            <td className="py-3 px-2 text-right">
                              <button
                                onClick={() => handleRemoveFromShelf(item.id, item.name)}
                                className="text-rose-500 hover:text-rose-400 p-1.5 rounded-lg hover:bg-rose-500/10 transition-colors"
                              >
                                <Trash2 size={14} />
                              </button>
                            </td>
                          </tr>
                        ))
                      )}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          </div>

          
          <div className="bg-[#121215] border border-white/5 rounded-2xl p-4 md:p-5 shadow-xl">
            <h2 className="text-base font-bold text-white mb-1">{isHi ? 'पुस्तकालय से ग्रन्थ संस्तुति' : 'Library Recommendations'}</h2>
            <p className="text-zinc-500 text-xs mb-4">
              {isHi ? 'अपने सक्रिय स्वाध्याय शेल्फ में पुस्तक जोड़ने के लिए "Add to Shelf" पर क्लिक करें।' : 'Click "Add to Shelf" to instantly pin a grantha to your active shelf.'}
            </p>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {books.slice(0, 4).map((b) => (
                <div key={b.slug} className="bg-[#18181c] border border-white/5 p-4 rounded-xl flex flex-col justify-between gap-4">
                  <div>
                    <div className="flex justify-between items-start">
                      <span className="font-semibold text-white text-xs">{b.name}</span>
                      <span className="text-[10px] text-zinc-500 font-light">@{b.slug}</span>
                    </div>
                    <p className="text-[11px] text-zinc-400 mt-2 leading-relaxed">
                      {isHi 
                        ? `रचनाकार: ${b.author || 'ब्रज रसिक सन्त'}। इस ग्रन्थ में ${b.verses?.length || 0} श्लोक संगृहीत हैं।`
                        : `Written by ${b.author || 'Braj Rasik Sant'}. Contains ${b.verses?.length || 0} verses.`}
                    </p>
                  </div>

                  <div className="flex items-center gap-2 justify-end">
                    <button
                      onClick={() => {
                        const newTarget = {
                          id: Date.now().toString(),
                          name: b.name,
                          author: b.author || 'Braj Rasik Sant',
                          target: `2 ${isHi ? 'श्लोक/दिन' : 'verses/day'}`,
                          progress: 0,
                          addedAt: new Date().toLocaleDateString()
                        };
                        const updated = [...readingShelf, newTarget];
                        setReadingShelf(updated);
                        localStorage.setItem('vrindopnishad_reading_shelf', JSON.stringify(updated));
                        triggerToast(isHi ? `"${b.name}" शेल्फ में जोड़ा गया!` : `Added "${b.name}" to shelf!`);
                      }}
                      className="bg-white hover:bg-zinc-200 text-zinc-950 px-3 py-1.5 rounded-full text-[10px] font-bold transition-all"
                    >
                      {isHi ? 'शेल्फ में जोड़ें' : 'Add to Shelf'}
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      
      {activeTab === 'moderationAudit' && (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 items-stretch">
          
          
          <div className="lg:col-span-2 bg-[#121215] border border-white/5 rounded-2xl p-4 md:p-5 shadow-xl flex flex-col justify-between">
            <div>
              <div className="flex items-center justify-between border-b border-white/5 pb-3 mb-4">
                <div>
                  <h2 className="text-base font-bold text-white flex items-center gap-2">
                    <span className="w-2.5 h-2.5 rounded-full bg-purple-500 animate-ping"></span>
                    {isHi ? 'दैनिक श्लोक स्वाध्याय' : 'Daily Shloka Swadhyaya'}
                  </h2>
                  <p className="text-zinc-500 text-xs mt-0.5">
                    {isHi ? 'सस्वर श्लोक पाठ, अर्थ, एवं शब्दार्थ का अनुशीलन करें।' : 'Read, translate, and audit sacred Sanskrit shlokas.'}
                  </p>
                </div>
                <span className="text-[10px] font-bold text-purple-400 bg-purple-500/10 border border-purple-500/20 px-2 py-0.5 rounded-lg uppercase tracking-wider">
                  {dailyShloka.source}
                </span>
              </div>

              
              <div className="flex bg-[#18181c] p-1 rounded-xl gap-1 mb-6 max-w-xs">
                {[
                  { id: 'verse', label: isHi ? 'श्लोक' : 'Verse' },
                  { id: 'translation', label: isHi ? 'अनुवाद' : 'Translation' },
                  { id: 'breakdown', label: isHi ? 'शब्दार्थ' : 'Word Meanings' }
                ].map((st) => (
                  <button
                    key={st.id}
                    onClick={() => setSwadhyayaSubTab(st.id)}
                    className={`flex-1 py-1 rounded-lg text-[10px] font-semibold tracking-wide transition-all ${
                      swadhyayaSubTab === st.id
                        ? 'bg-zinc-800 text-white shadow-inner'
                        : 'text-zinc-400 hover:text-white'
                    }`}
                  >
                    {st.label}
                  </button>
                ))}
              </div>

              
              <div className="min-h-[160px] flex items-center justify-center p-4 bg-[#18181c]/50 rounded-2xl border border-white/5 mb-6 text-center select-text">
                {swadhyayaSubTab === 'verse' && (
                  <p className="font-headings text-lg md:text-xl text-amber-200/90 leading-loose whitespace-pre-line font-medium">
                    {dailyShloka.sanskrit}
                  </p>
                )}

                {swadhyayaSubTab === 'translation' && (
                  <div className="space-y-4">
                    <p className="text-xs text-zinc-400 uppercase tracking-widest font-bold">{isHi ? 'हिन्दी अनुवाद' : 'Hindi Translation'}</p>
                    <p className="text-sm text-zinc-200 leading-relaxed max-w-xl">{dailyShloka.hindi}</p>
                    <div className="w-8 h-[1px] bg-white/10 mx-auto my-1"></div>
                    <p className="text-xs text-zinc-400 uppercase tracking-widest font-bold">{isHi ? 'अंग्रेजी अनुवाद' : 'English Translation'}</p>
                    <p className="text-xs text-zinc-300 italic leading-relaxed max-w-xl">"{dailyShloka.english}"</p>
                  </div>
                )}

                {swadhyayaSubTab === 'breakdown' && (
                  <div className="grid grid-cols-2 sm:grid-cols-3 gap-3 w-full text-left max-w-lg mx-auto">
                    {dailyShloka.breakdown.map((item, idx) => (
                      <div key={idx} className="bg-[#1c1c22]/50 p-2 rounded-xl border border-white/5">
                        <span className="font-semibold text-amber-200 text-xs block font-headings">{item.sanskrit}</span>
                        <span className="text-[10px] text-zinc-400 mt-0.5 block">{item.meaning}</span>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>

            
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pt-4 border-t border-white/5">
              <div className="flex items-center gap-2">
                <button
                  onClick={handleChantAudio}
                  className={`w-9 h-9 rounded-full flex items-center justify-center transition-colors border ${
                    isPlaying 
                      ? 'bg-purple-600/20 border-purple-500/40 text-purple-400' 
                      : 'bg-white/5 border-white/5 hover:bg-white/10 text-zinc-300'
                  }`}
                  title={isHi ? "श्लोक पाठ सुनिए" : "Listen to chanting voice"}
                >
                  {isPlaying ? <VolumeX size={15} /> : <Volume2 size={15} />}
                </button>
                <span className="text-[10px] text-zinc-500">{isHi ? "पाठ सुनें" : "Listen Chant"}</span>
              </div>

              <button
                disabled={isCompleted}
                onClick={handleComplete}
                className={`px-4 py-2 rounded-full text-xs font-bold transition-all shadow-md flex items-center gap-1.5 ${
                  isCompleted
                    ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 cursor-default'
                    : 'bg-white hover:bg-zinc-200 text-zinc-950 active:scale-95'
                }`}
              >
                {isCompleted ? <Check size={14} /> : null}
                {isCompleted ? (isHi ? 'स्वाध्याय पूर्ण' : 'Completed') : (isHi ? 'पूर्ण अंकित करें' : 'Mark Completed')}
              </button>
            </div>
          </div>

          
          <div className="bg-[#121215] border border-white/5 rounded-2xl p-4 md:p-5 shadow-xl flex flex-col justify-between">
            <div className="text-center">
              <div className="flex items-center justify-between border-b border-white/5 pb-3 mb-4 text-left">
                <div>
                  <h2 className="text-base font-bold text-white">{isHi ? 'नाम जप साधक सेवा' : 'Japa Tracker'}</h2>
                  <p className="text-zinc-500 text-xs mt-0.5">{isHi ? 'दैनिक नाम जप का नियम बनाये रखें।' : 'Maintain your sacred streak.'}</p>
                </div>
              </div>

              
              <div className="relative w-36 h-36 mx-auto mb-6 flex items-center justify-center">
                <svg className="w-full h-full transform -rotate-90">
                  <circle
                    cx="72"
                    cy="72"
                    r="64"
                    stroke="rgba(255,255,255,0.03)"
                    strokeWidth="8"
                    fill="transparent"
                  />
                  <circle
                    cx="72"
                    cy="72"
                    r="64"
                    stroke="#a78bfa"
                    strokeWidth="8"
                    fill="transparent"
                    strokeDasharray={402}
                    strokeDashoffset={402 - (402 * percentComplete) / 100}
                    strokeLinecap="round"
                    className="transition-all duration-500"
                  />
                </svg>
                <div className="absolute inset-0 flex flex-col items-center justify-center">
                  <span className="text-2xl font-bold text-white tracking-tight">{japaCount}</span>
                  <span className="text-[9px] uppercase tracking-wider text-zinc-500 mt-1">{isHi ? 'लक्ष्य' : 'Goal'}: {dailyGoal}</span>
                </div>
              </div>

              
              <div className="grid grid-cols-2 gap-2 mb-6">
                <div className="bg-[#18181c] p-2 rounded-xl border border-white/5">
                  <span className="text-[10px] text-zinc-500 block">{isHi ? 'क्रमबद्धता' : 'Streak'}</span>
                  <span className="text-sm font-bold text-white mt-0.5 block">{streak} {isHi ? 'दिन' : 'Days'} 🔥</span>
                </div>
                <div className="bg-[#18181c] p-2 rounded-xl border border-white/5">
                  <span className="text-[10px] text-zinc-500 block">{isHi ? 'माला चक्र' : 'Mala Rounds'}</span>
                  <span className="text-sm font-bold text-white mt-0.5 block">{rounds} / {dailyGoal/108}</span>
                </div>
              </div>
            </div>

            
            <div className="space-y-3">
              <button
                onClick={(e) => {
                  const newCount = japaCount + 1;
                  handleUpdateJapaCount(newCount);
                  const floatText = document.createElement('span');
                  floatText.innerText = '🌸 Radhe!';
                  floatText.className = 'fixed pointer-events-none text-xs font-bold z-[5000] floating-chant-text text-purple-300';
                  floatText.style.left = `${e.clientX - 20}px`;
                  floatText.style.top = `${e.clientY - 20}px`;
                  document.body.appendChild(floatText);
                  setTimeout(() => floatText.remove(), 1000);
                }}
                className="w-full bg-white hover:bg-zinc-200 text-zinc-950 font-bold text-xs py-3 rounded-full transition-all shadow flex items-center justify-center gap-2 active:scale-98"
              >
                <span>📿 {isHi ? 'राधे राधे जाप!' : 'Chant Radhe!'}</span>
              </button>

              <div className="flex gap-2">
                <button
                  onClick={toggleTanpura}
                  className={`flex-1 font-semibold text-[10px] py-2 rounded-full border transition-all flex items-center justify-center gap-1.5 ${
                    isTanpuraPlaying
                      ? 'bg-purple-500/20 border-purple-500/40 text-purple-400'
                      : 'bg-black border-white/20 hover:bg-zinc-900 text-white'
                  }`}
                >
                  {isTanpuraPlaying ? <Pause size={12} /> : <Play size={12} />}
                  {isTanpuraPlaying ? (isHi ? 'तानपुरा बंद' : 'Stop Tanpura') : (isHi ? 'तानपुरा ध्वनि' : 'Tanpura Synth')}
                </button>

                <button
                  onClick={() => {
                    if (window.confirm(isHi ? 'जाप संख्या शून्य करें?' : 'Reset Japa Count?')) {
                      handleUpdateJapaCount(0);
                      triggerToast(isHi ? 'जाप संख्या शून्य की गई।' : 'Japa count reset.');
                    }
                  }}
                  className="px-3 text-[10px] bg-rose-500/10 hover:bg-rose-500/20 text-rose-400 border border-rose-500/20 rounded-full transition-colors"
                >
                  {isHi ? 'रीसेट' : 'Reset'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      
      {activeTab === 'broadcasts' && (
        <div className="space-y-4">
          <div className="bg-[#121215] border border-white/5 rounded-2xl p-4 md:p-5 shadow-xl">
            <h2 className="text-base font-bold text-white flex items-center gap-2 mb-1">
              <Sparkles size={18} className="text-[#f59e0b]" />
              {isHi ? 'सत्संग उद्घोषणा व सूचनाएं' : 'Satsang Announcements & Updates'}
            </h2>
            <p className="text-zinc-500 text-xs mb-6">
              {isHi ? 'वृन्दावन धाम से नवीन सत्संग, पर्व, एकादशी व्रत एवं आध्यात्मिक संदेशों की सूचनाएं।' : 'Stay updated with upcoming Ekadashi fast timings, satsang schedules, and spiritual notices from Vrindavan Dham.'}
            </p>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {[
                { 
                  id: 1, 
                  category: isHi ? 'एकादशी' : 'EKADASHI', 
                  title: isHi ? 'निर्जला एकादशी व्रत नियम व समय' : 'Nirjala Ekadashi Timings', 
                  msg: isHi 
                    ? 'ज्येष्ठ शुक्ल पक्ष की निर्जला एकादशी तिथि का व्रत पुण्य काल। जल के बिना पूर्ण उपवास रखें।' 
                    : 'The sacred fast of Nirjala Ekadashi falls on the upcoming fortnight. Observe complete fast without water for spiritual purification.', 
                  time: '2 hours ago', 
                  tagColor: 'bg-emerald-500/15 text-emerald-400 border-emerald-500/30' 
                },
                { 
                  id: 2, 
                  category: isHi ? 'सत्संग' : 'SATSANG', 
                  title: isHi ? 'नित्य निकुंज विहार वाणी व्याख्या' : 'Daily Nitya Vihar Discourse', 
                  msg: isHi 
                    ? 'वृन्दावन में कल सुबह ७:०० बजे से श्री हित चौरासी जी पदों की व्याख्या सत्संग किया जाएगा।' 
                    : 'Tomorrow morning at 7:00 AM, a discourse on Sri Hit Chaurasi Ji verses will take place at Vrindavan.', 
                  time: 'Yesterday', 
                  tagColor: 'bg-purple-500/15 text-purple-400 border-purple-500/30' 
                },
                { 
                  id: 3, 
                  category: isHi ? 'पुस्तकालय' : 'LIBRARY', 
                  title: isHi ? 'नवीन वाणी ग्रन्थ: रसकली व केलिमाल' : 'New Scriptures Added: Kelimal', 
                  msg: isHi 
                    ? 'स्वामी हरिदास जी महाराज विरचित केलिमाल ग्रन्थ के १५० से अधिक पदों को शब्दार्थ सहित जोड़ा गया है।' 
                    : 'Over 150 verses of Kelimal by Swami Haridas Ji Maharaj have been uploaded to the library with full translation and word meanings.', 
                  time: '3 days ago', 
                  tagColor: 'bg-amber-500/15 text-amber-400 border-amber-500/30' 
                }
              ].map(b => (
                <div key={b.id} className="bg-[#18181c] border border-white/5 p-5 rounded-2xl flex flex-col justify-between gap-4">
                  <div>
                    <div className="flex justify-between items-center mb-3">
                      <span className={`px-2 py-0.5 rounded-full text-[9px] font-bold uppercase tracking-wider border ${b.tagColor}`}>
                        {b.category}
                      </span>
                      <span className="text-[9px] text-zinc-600 font-mono">{b.time}</span>
                    </div>
                    <h4 className="font-bold text-white text-sm mb-2">{b.title}</h4>
                    <p className="text-zinc-400 text-xs font-light leading-relaxed">{b.msg}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      
      {activeTab === 'feedback' && (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 items-start">
          
          
          <div className="lg:col-span-1 bg-[#121215] border border-white/5 rounded-2xl p-4 md:p-5 shadow-xl">
            <h2 className="text-base font-bold text-white flex items-center gap-2 mb-1">
              <Feather size={16} className="text-purple-400" />
              {isHi ? 'साधना अनुभूति व विचार' : 'Sadhana Reflection'}
            </h2>
            <p className="text-zinc-500 text-xs mb-6">
              {isHi ? 'दैनंदिन नाम जप अनुभव, रसोपासना विचार या प्रश्न लिखें।' : 'Write down your daily realizations, chant feelings, or questions.'}
            </p>

            <form onSubmit={handleAddReflection} className="space-y-4">
              <div>
                <label className="block text-[10px] font-bold uppercase tracking-wider text-zinc-500 mb-1.5">
                  {isHi ? 'साधना डायरी प्रविष्टि' : 'Journal Entry / Reflection'}
                </label>
                <textarea
                  rows="5"
                  placeholder={isHi ? "आज नाम जप करते हुए मुझे यह भाव..." : "Today, during swadhyaya, I realized..."}
                  className="w-full bg-[#18181c] border border-white/5 rounded-xl px-4 py-2.5 text-xs text-white placeholder:text-zinc-600 outline-none focus:border-purple-500/50 resize-none font-light"
                  value={newReflectionText}
                  onChange={(e) => setNewReflectionText(e.target.value)}
                ></textarea>
              </div>

              <button
                type="submit"
                className="w-full bg-white text-zinc-950 hover:bg-zinc-200 transition-all font-bold text-xs py-2.5 rounded-full shadow-md"
              >
                {isHi ? 'विचार अंकित करें' : 'Log Reflection'}
              </button>
            </form>
          </div>

          
          <div className="lg:col-span-2 bg-[#121215] border border-white/5 rounded-2xl p-4 md:p-5 shadow-xl">
            <h2 className="text-base font-bold text-white mb-1">{isHi ? 'दैनिक साधक अनुभूति डायरी' : 'Devotee Sadhana Journal'}</h2>
            <p className="text-zinc-500 text-xs mb-6">
              {isHi ? 'आपके व्यक्तिगत साधना काल के अनुभूतियों का तिथि-वार संग्रह।' : 'Chronological logs of your personal spiritual realizations.'}
            </p>

            <div className="space-y-4 max-h-[50vh] overflow-y-auto pr-2 custom-scrollbar">
              {reflections.length === 0 ? (
                <p className="text-xs text-zinc-600 py-12 text-center italic">{isHi ? 'डायरी में कोई विचार नहीं है।' : 'No journal entries written yet.'}</p>
              ) : (
                reflections.map((ref) => (
                  <div key={ref.id} className="bg-[#18181c] border border-white/5 p-4 rounded-xl flex items-start gap-4">
                    <div className="w-8 h-8 rounded-full bg-purple-500/10 border border-purple-500/20 flex items-center justify-center font-bold text-purple-400 text-xs shrink-0">
                      {getDevoteeInitial()}
                    </div>
                    <div className="flex-1 min-w-0 flex flex-col">
                      <div className="flex items-center justify-between gap-4">
                        <span className="font-semibold text-white text-xs">{getDevoteeName()}</span>
                        <span className="text-[10px] text-zinc-600">{ref.date}</span>
                      </div>
                      <p className="text-xs text-zinc-300 mt-2 leading-relaxed font-light">"{ref.text}"</p>
                      
                      <div className="flex items-center gap-2 mt-4 pt-3 border-t border-white/5">
                        <button 
                          onClick={() => {
                            if (window.confirm(isHi ? 'इस प्रविष्टि को हटाएं?' : 'Delete this entry?')) {
                              const updated = reflections.filter(r => r.id !== ref.id);
                              setReflections(updated);
                              localStorage.setItem(getStorageKey(user), JSON.stringify(updated));
                              triggerToast(isHi ? 'प्रविष्टि हटाई गई।' : 'Entry deleted.');
                            }
                          }}
                          className="text-[10px] font-semibold text-rose-400 hover:text-rose-300 flex items-center gap-1 hover:bg-rose-500/10 px-2.5 py-1 rounded transition-colors"
                        >
                          <Trash2 size={12} /> {isHi ? 'प्रविष्टि हटाएं' : 'Delete Entry'}
                        </button>
                      </div>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      )}



      
      {auditingSaint && (
        <div className="fixed inset-0 z-[6000] flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-black/85 backdrop-blur-sm animate-fade-in" onClick={() => setAuditingSaint(null)}></div>

          <div className="bg-[#121215] border border-white/5 w-full max-w-2xl rounded-[1.5rem] relative z-10 p-6 shadow-2xl flex flex-col max-h-[85vh] animate-scale-in text-left">
            <div className="flex items-center justify-between border-b border-white/5 pb-4 mb-4">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-purple-500/10 border border-purple-500/20 flex items-center justify-center font-bold text-purple-400 text-lg uppercase">
                  {(isHi ? auditingSaint.name : auditingSaint.hinglishName || 'V').charAt(0)}
                </div>
                <div>
                  <h3 className="text-lg font-bold text-white">{auditingSaint.name} ({auditingSaint.hinglishName})</h3>
                  <span className="text-[10px] text-zinc-500 uppercase tracking-wider font-semibold block mt-0.5">
                    {auditingSaint.biography?.sampraday || 'Braj Rasik'} • {getEra(auditingSaint)}
                  </span>
                </div>
              </div>
              <button onClick={() => setAuditingSaint(null)} className="text-zinc-400 hover:text-white p-1 hover:bg-white/5 rounded-lg">
                <X size={20} />
              </button>
            </div>

            
            <div className="flex-1 overflow-y-auto space-y-5 pr-1 py-2 max-h-[50vh] custom-scrollbar select-text">
              <div>
                <span className="text-[10px] font-bold uppercase tracking-wider text-zinc-500 block mb-2">{isHi ? 'जीवन परिचय' : 'Biography'}</span>
                <p className="text-xs text-zinc-300 leading-relaxed font-light whitespace-pre-line bg-[#18181c] p-4 rounded-xl border border-white/5">
                  {auditingSaint.biography?.text || 'No biography text currently loaded. Biography translation is being updated.'}
                </p>
              </div>

              {auditingSaint.books && auditingSaint.books.length > 0 && (
                <div>
                  <span className="text-[10px] font-bold uppercase tracking-wider text-zinc-500 block mb-2">{isHi ? 'रचित ग्रन्थ' : 'Authored Granthas'}</span>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                    {auditingSaint.books.map(bName => (
                      <div key={bName} className="bg-[#18181c] border border-white/5 px-3 py-2 rounded-lg text-xs text-white font-medium flex items-center gap-2">
                        <BookOpen size={12} className="text-purple-400" />
                        <span>{bName}</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              <div>
                <span className="text-[10px] font-bold uppercase tracking-wider text-zinc-500 block mb-2">
                  {isHi ? `कुल श्लोक/पद (${auditingSaint.verses.length})` : `Verses Info (${auditingSaint.verses.length} total)`}
                </span>
                <p className="text-xs text-zinc-400 font-light leading-relaxed">
                  {isHi 
                    ? `इस रसिक सन्त के ${auditingSaint.verses.length} पद वर्तमान में इस डिजिटल ग्रन्थागार में संगृहीत हैं। आप पुस्तकालय अथवा खोज खण्ड में जाकर इन पदों को पढ़, सुन एवं सीख सकते हैं।`
                    : `This devotee saint has recorded ${auditingSaint.verses.length} verses inside the digital database. You can read, search, and listen to all verses in the sanctuary library under Groups or Search.`}
                </p>
              </div>
            </div>

            
            <div className="border-t border-white/5 pt-4 mt-4 flex items-center justify-between gap-4">
              <span className="text-[10px] text-zinc-600">{isHi ? 'ब्रज रसिक परम्परा' : 'Braj Rasik Tradition'}</span>
              <div className="flex gap-2">
                <Link
                  to={isHi ? `/hi/saint/${auditingSaint.slug}` : `/saint/${auditingSaint.slug}`}
                  onClick={() => setAuditingSaint(null)}
                  className="bg-white hover:bg-zinc-200 text-zinc-950 px-4 py-1.5 rounded-full font-bold text-xs transition-all"
                >
                  {isHi ? 'सन्त वाणी देखें' : 'Explore Sant Vaani'}
                </Link>
                <button
                  onClick={() => setAuditingSaint(null)}
                  className="bg-black hover:bg-zinc-900 text-white border border-white/20 px-3 py-1.5 rounded-full font-bold text-xs transition-all"
                >
                  {isHi ? 'बंद करें' : 'Close'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default PookizDashboardView;
