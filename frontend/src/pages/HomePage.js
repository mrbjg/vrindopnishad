import React, { useState, useEffect, useContext, useMemo } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { Edit2, Sun, Sunrise, Sunset, Share2 } from 'lucide-react';
import { Helmet } from 'react-helmet-async';
import { ApiContext, AuthContext } from '../App';
import { supabase } from '../lib/supabase';
import { db } from '../firebase';
import { doc, getDoc, setDoc, onSnapshot } from 'firebase/firestore';
import { extractRelations } from '../utils/relations';
import { shareVerseCard } from '../utils/shareCard';

import { useSettings } from '../contexts/SettingsContext';
import PookizDashboardView from '../components/PookizDashboardView';


import AtmosphereCustomizer from '../components/home/AtmosphereCustomizer';
import BrajCalendar from '../components/home/BrajCalendar';
import DailySwadhyaya from '../components/home/DailySwadhyaya';
import ChantSanctuary from '../components/home/ChantSanctuary';
import LibraryShowcase from '../components/home/LibraryShowcase';
import SaintsSpotlight from '../components/home/SaintsSpotlight';
import PilgrimageHub from '../components/home/PilgrimageHub';
import LatestVersesFeed from '../components/home/LatestVersesFeed';
import RagasIndex from '../components/home/RagasIndex';


const PreviewDrawer = React.lazy(() => import('../components/home/PreviewDrawer'));

const isSupabase = process.env.REACT_APP_DATABASE_PROVIDER === 'supabase';

const DAILY_SHLOKAS = [
  {
    source: "श्रीमद्भगवद्गीता २.४७",
    sanskrit: "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन ।\nमा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि ॥",
    hindi: "तुम्हारा अधिकार केवल कर्म करने पर है, उसके फलों पर कभी नहीं। इसलिए कर्म के फलों की चिंता मत करो।",
    english: "You have a right to perform your prescribed duties, but you are not entitled to the fruits of your actions.",
    breakdown: [
      { sanskrit: "कर्मणि", meaning: "in duty" },
      { sanskrit: "एव", meaning: "only" },
      { sanskrit: "अधिकारः", meaning: "right" },
      { sanskrit: "ते", meaning: "your" },
      { sanskrit: "मा", meaning: "not" },
      { sanskrit: "फलेषु", meaning: "in results" },
      { sanskrit: "कदाचन", meaning: "ever" }
    ],
    takeaway: "Focus completely on your actions and efforts, rather than worrying about the outcome. Keep a calm and steady mind."
  },
  {
    source: "श्रीमद्भगवद्गीता १८.६६",
    sanskrit: "सर्वधर्मान्परित्यज्य मामेकं शरणं व्रज ।\nअहं त्वां सर्वपापेभ्यो मोक्षयिष्यामि मा शुचः ॥",
    hindi: "सभी धर्मों का त्याग करके केवल मेरी शरण में आओ। मैं तुम्हें सभी पापों से मुक्त कर दूंगा, शोक मत करो।",
    english: "Abandon all varieties of religion and just surrender unto Me. I shall deliver you from all sinful reactions. Do not fear.",
    breakdown: [
      { sanskrit: "सर्वधर्मान्", meaning: "all duties" },
      { sanskrit: "परित्यज्य", meaning: "abandoning" },
      { sanskrit: "माम्", meaning: "Me" },
      { sanskrit: "एकम्", meaning: "alone" },
      { sanskrit: "शरणम्", meaning: "refuge" },
      { sanskrit: "व्रज", meaning: "surrender" }
    ],
    takeaway: "Surrender your fears and worries to the divine. When you let go of your anxiety, you find absolute peace and guidance."
  },
  {
    source: "श्रीमद्भगवद्गीता ४.७",
    sanskrit: "यदा यदा हि धर्मस्य ग्लानिर्भवति भारत ।\nअभ्युत्थानमधर्मस्य तदात्मानं सृजाम्यहम् ॥",
    hindi: "हे भारत! जब-जब धर्म की हानि होती है और अधर्म बढ़ता है, तब-तब मैं अवतार लेता हूँ।",
    english: "Whenever there is a decline in righteousness and an increase in unrighteousness, I manifest Myself on earth.",
    breakdown: [
      { sanskrit: "यदा यदा", meaning: "whenever" },
      { sanskrit: "हि", meaning: "surely" },
      { sanskrit: "धर्मस्य", meaning: "righteousness" },
      { sanskrit: "ग्लानिः", meaning: "decline" },
      { sanskrit: "भारत", meaning: "O Bharat" }
    ],
    takeaway: "Trust that goodness and truth will always prevail in the end. Look inward to find the strength to stand for truth."
  }
];


const getInitials = (name) => {
  if (!name) return 'V';
  let clean = name.replace(/^(Shri|Swami|Sri|Shree|श्री|स्वामी|श्रीमद्)\s+/i, '').trim();
  if (!clean.length) clean = name;
  const first = clean.charAt(0);
  return first.match(/[a-zA-Z]/) ? first.toUpperCase() : first;
};

const HomePage = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const isHi = location.pathname.startsWith('/hi');
  const { apiService } = useContext(ApiContext);
  const { user } = useContext(AuthContext);

  const [allItems, setAllItems] = useState([]);
  const [saints, setSaints] = useState([]);
  const [books, setBooks] = useState([]);
  const [ragas, setRagas] = useState([]);
  const [loading, setLoading] = useState(true);

  
  const [isCompleted, setIsCompleted] = useState(false);
  const [streak, setStreak] = useState(0);
  const [particles, setParticles] = useState([]);

  
  const [calendarData, setCalendarData] = useState(() => {
    try {
      const saved = localStorage.getItem('vrindopnishad_calendar_data');
      return saved ? JSON.parse(saved) : {
        tithiEn: "Ekadashi (Shukla)",
        tithiHi: "एकादशी (शुक्ल पक्ष)",
        seasonEn: "Grishma Ritu (Summer)",
        seasonHi: "ग्रीष्म ऋतु (Summer)",
        lilaEn: "Madhyāhna (Radha Kund)",
        lilaHi: "मध्याह्न लीला (राधा कुण्ड)",
        festivalEn: "Nirjala Ekadashi (in 3 Days)",
        festivalHi: "निर्जला एकादशी (3 दिन में)"
      };
    } catch (e) {
      return {
        tithiEn: "Ekadashi (Shukla)",
        tithiHi: "एकादशी (शुक्ल पक्ष)",
        seasonEn: "Grishma Ritu (Summer)",
        seasonHi: "ग्रीष्म ऋतु (Summer)",
        lilaEn: "Madhyāhna (Radha Kund)",
        lilaHi: "मध्याह्न लीला (राधा कुण्ड)",
        festivalEn: "Nirjala Ekadashi (in 3 Days)",
        festivalHi: "निर्जला एकादशी (3 दिन में)"
      };
    }
  });

  
  const [selectedItem, setSelectedItem] = useState(null);
  const [previewType, setPreviewType] = useState(null);

  const openPreview = (item, type) => {
    setSelectedItem(item);
    setPreviewType(type);
  };

  const closePreview = () => {
    setSelectedItem(null);
    setPreviewType(null);
  };

  const { settings, updateSetting } = useSettings();
  const [isEditingName, setIsEditingName] = useState(false);
  const [tempName, setTempName] = useState(settings.devoteeName || '');

  
  useEffect(() => {
    setTempName(settings.devoteeName || '');
  }, [settings.devoteeName]);

  const saveToSupabase = async (updatedFields) => {
    if (!user) return;
    if (isSupabase) {
      try {
        const { error } = await supabase
          .from('users_sadhana')
          .upsert({
            id: user.uid,
            ...updatedFields,
            updated_at: new Date().toISOString()
          });
        if (error) throw error;
      } catch (e) {
        console.warn("Failed to save to Supabase:", e);
      }
    } else {
      try {
        await setDoc(doc(db, 'users_sadhana', user.uid), {
          ...updatedFields,
          updated_at: new Date().toISOString()
        }, { merge: true });
      } catch (e) {
        console.warn("Failed to save sadhana to Firestore:", e);
      }
    }
  };

  const handleUpdateJapaCount = async (val) => {
    setJapaCount(val);
    localStorage.setItem('vrindopnishad_japa_count', val.toString());
    window.dispatchEvent(new Event('storage'));

    if (user) {
      await saveToSupabase({ japa_count: val });
    }
  };

  const getGreeting = () => {
    const hrs = new Date().getHours();
    if (hrs >= 4 && hrs < 12) {
      return {
        en: "Have a blessed morning swadhyaya and japa session.",
        hi: "आपका आज का सुबह का स्वाध्याय और जाप मंगलमय हो।",
        greetingEn: "Good Morning",
        greetingHi: "सुप्रभात",
        icon: <Sunrise size={16} className="text-amber-400 shrink-0" />
      };
    } else if (hrs >= 12 && hrs < 17) {
      return {
        en: "Take a peaceful moment in the sanctuary.",
        hi: "इस शांत क्षण में प्रभु स्मरण करें।",
        greetingEn: "Good Afternoon",
        greetingHi: "शुभ दोपहर",
        icon: <Sun size={16} className="text-amber-500 shrink-0" />
      };
    } else {
      return {
        en: "End your day with holy chanting and wisdom.",
        hi: "भगवान नाम और ज्ञान के साथ दिन पूर्ण करें।",
        greetingEn: "Good Evening",
        greetingHi: "शुभ संध्या",
        icon: <Sunset size={16} className="text-orange-400 shrink-0" />
      };
    }
  };

  const currentGreeting = useMemo(() => getGreeting(), []);

  useEffect(() => {
    const todayStr = new Date().toDateString();
    const lastCompleted = localStorage.getItem('last_swadhyaya_date');
    const currentStreak = parseInt(localStorage.getItem('swadhyaya_streak') || '0', 10);

    if (lastCompleted === todayStr) {
      setIsCompleted(true);
    }
    setStreak(currentStreak);
  }, []);

  const handleComplete = async () => {
    if (isCompleted) return;

    const todayStr = new Date().toDateString();
    const yesterdayStr = new Date(Date.now() - 86400000).toDateString();
    const lastCompleted = localStorage.getItem('last_swadhyaya_date');
    let newStreak = streak;

    if (lastCompleted === yesterdayStr) {
      newStreak += 1;
    } else if (lastCompleted !== todayStr) {
      newStreak = 1;
    }

    localStorage.setItem('last_swadhyaya_date', todayStr);
    localStorage.setItem('swadhyaya_streak', newStreak.toString());
    setIsCompleted(true);
    setStreak(newStreak);

    if (user) {
      await saveToSupabase({
        swadhyaya_streak: newStreak,
        last_swadhyaya_date: todayStr
      });
    }

    
    const newParticles = Array.from({ length: 24 }).map((_, i) => ({
      id: i,
      x: (Math.random() - 0.5) * 140,
      y: (Math.random() - 0.5) * 80,
      color: ['var(--primary-color)', '#a78bfa', '#fb923c', '#047857', '#cbd5e1'][Math.floor(Math.random() * 5)],
      scale: Math.random() * 0.7 + 0.3
    }));
    setParticles(newParticles);
    setTimeout(() => setParticles([]), 1000);
  };

  const [japaCount, setJapaCount] = useState(0);

  
  useEffect(() => {
    if (!user) return;

    let active = true;
    let unsubscribe = () => {};

    if (isSupabase) {
      const syncUserSadhana = async () => {
        try {
          const { data, error } = await supabase
            .from('users_sadhana')
            .select('*')
            .eq('id', user.uid)
            .maybeSingle();

          if (error) throw error;

          if (data) {
            if (!active) return;
            if (data.japa_count !== undefined) {
              setJapaCount(data.japa_count);
              localStorage.setItem('vrindopnishad_japa_count', data.japa_count.toString());
            }
            if (data.swadhyaya_streak !== undefined) {
              setStreak(data.swadhyaya_streak);
              localStorage.setItem('swadhyaya_streak', data.swadhyaya_streak.toString());
            }
            if (data.last_swadhyaya_date !== undefined) {
              localStorage.setItem('last_swadhyaya_date', data.last_swadhyaya_date);
              if (data.last_swadhyaya_date === new Date().toDateString()) {
                setIsCompleted(true);
              } else {
                setIsCompleted(false);
              }
            }
            if (data.calendar) {
              setCalendarData(data.calendar);
              localStorage.setItem('vrindopnishad_calendar_data', JSON.stringify(data.calendar));
            }
          } else {
            const initialCalendar = {
              tithiEn: "Ekadashi (Shukla)",
              tithiHi: "एकादशी (शुक्ल पक्ष)",
              seasonEn: "Grishma Ritu (Summer)",
              seasonHi: "ग्रीष्म ऋतु (Summer)",
              lilaEn: "Madhyāhna (Radha Kund)",
              lilaHi: "मध्याह्न लीला (राधा कुण्ड)",
              festivalEn: "Nirjala Ekadashi (in 3 Days)",
              festivalHi: "निर्जला एकादशी (3 दिन में)"
            };

            await supabase.from('users_sadhana').insert({
              id: user.uid,
              japa_count: japaCount,
              swadhyaya_streak: streak,
              last_swadhyaya_date: localStorage.getItem('last_swadhyaya_date') || '',
              calendar: calendarData || initialCalendar,
              updated_at: new Date().toISOString()
            });
          }
        } catch (err) {
          console.warn("Failed to initialize or sync sadhana from Supabase:", err);
        }
      };

      syncUserSadhana();

      const channel = supabase
        .channel(`public:users_sadhana:id=eq.${user.uid}`)
        .on('postgres_changes', {
          event: '*',
          schema: 'public',
          table: 'users_sadhana',
          filter: `id=eq.${user.uid}`
        }, (payload) => {
          if (!active) return;
          const data = payload.new;
          if (data) {
            if (data.japa_count !== undefined) {
              setJapaCount(data.japa_count);
              localStorage.setItem('vrindopnishad_japa_count', data.japa_count.toString());
            }
            if (data.swadhyaya_streak !== undefined) {
              setStreak(data.swadhyaya_streak);
              localStorage.setItem('swadhyaya_streak', data.swadhyaya_streak.toString());
            }
            if (data.last_swadhyaya_date !== undefined) {
              localStorage.setItem('last_swadhyaya_date', data.last_swadhyaya_date);
              if (data.last_swadhyaya_date === new Date().toDateString()) {
                setIsCompleted(true);
              } else {
                setIsCompleted(false);
              }
            }
            if (data.calendar) {
              setCalendarData(data.calendar);
              localStorage.setItem('vrindopnishad_calendar_data', JSON.stringify(data.calendar));
            }
          }
        })
        .subscribe();

      unsubscribe = () => {
        supabase.removeChannel(channel);
      };
    } else {
      const syncUserSadhanaFirestore = async () => {
        try {
          const docSnap = await getDoc(doc(db, 'users_sadhana', user.uid));
          if (docSnap.exists()) {
            const data = docSnap.data();
            if (!active) return;
            if (data.japa_count !== undefined) {
              setJapaCount(data.japa_count);
              localStorage.setItem('vrindopnishad_japa_count', data.japa_count.toString());
            }
            if (data.swadhyaya_streak !== undefined) {
              setStreak(data.swadhyaya_streak);
              localStorage.setItem('swadhyaya_streak', data.swadhyaya_streak.toString());
            }
            if (data.last_swadhyaya_date !== undefined) {
              localStorage.setItem('last_swadhyaya_date', data.last_swadhyaya_date);
              if (data.last_swadhyaya_date === new Date().toDateString()) {
                setIsCompleted(true);
              } else {
                setIsCompleted(false);
              }
            }
            if (data.calendar) {
              setCalendarData(data.calendar);
              localStorage.setItem('vrindopnishad_calendar_data', JSON.stringify(data.calendar));
            }
          } else {
            const initialCalendar = {
              tithiEn: "Ekadashi (Shukla)",
              tithiHi: "एकादशी (शुक्ल पक्ष)",
              seasonEn: "Grishma Ritu (Summer)",
              seasonHi: "ग्रीष्म ऋतु (Summer)",
              lilaEn: "Madhyāhna (Radha Kund)",
              lilaHi: "मध्याह्न लीला (राधा कुण्ड)",
              festivalEn: "Nirjala Ekadashi (in 3 Days)",
              festivalHi: "निर्जला एकादशी (3 दिन में)"
            };

            await setDoc(doc(db, 'users_sadhana', user.uid), {
              japa_count: japaCount,
              swadhyaya_streak: streak,
              last_swadhyaya_date: localStorage.getItem('last_swadhyaya_date') || '',
              calendar: calendarData || initialCalendar,
              updated_at: new Date().toISOString()
            });
          }
        } catch (err) {
          console.warn("Failed to initialize or sync sadhana from Firestore:", err);
        }
      };

      syncUserSadhanaFirestore();

      const unsubSnap = onSnapshot(doc(db, 'users_sadhana', user.uid), (docSnap) => {
        if (!active) return;
        if (docSnap.exists()) {
          const data = docSnap.data();
          if (data.japa_count !== undefined) {
            setJapaCount(data.japa_count);
            localStorage.setItem('vrindopnishad_japa_count', data.japa_count.toString());
          }
          if (data.swadhyaya_streak !== undefined) {
            setStreak(data.swadhyaya_streak);
            localStorage.setItem('swadhyaya_streak', data.swadhyaya_streak.toString());
          }
          if (data.last_swadhyaya_date !== undefined) {
            localStorage.setItem('last_swadhyaya_date', data.last_swadhyaya_date);
            if (data.last_swadhyaya_date === new Date().toDateString()) {
              setIsCompleted(true);
            } else {
              setIsCompleted(false);
            }
          }
          if (data.calendar) {
            setCalendarData(data.calendar);
            localStorage.setItem('vrindopnishad_calendar_data', JSON.stringify(data.calendar));
          }
        }
      });

      unsubscribe = unsubSnap;
    }

    return () => {
      active = false;
      unsubscribe();
    };
  }, [user]);

  
  useEffect(() => {
    try {
      const saved = localStorage.getItem('vrindopnishad_calendar_data');
      if (saved) {
        setCalendarData(JSON.parse(saved));
      }
    } catch (e) {
      console.warn(e);
    }
  }, []);

  const handleSaveCalendar = async (newCalendarData) => {
    if (user) {
      await saveToSupabase({
        calendar: newCalendarData
      });
      setCalendarData(newCalendarData);
    } else {
      setCalendarData(newCalendarData);
      try {
        localStorage.setItem('vrindopnishad_calendar_data', JSON.stringify(newCalendarData));
      } catch (e) {
        console.warn(e);
      }
    }
  };

  useEffect(() => {
    try {
      const saved = localStorage.getItem('vrindopnishad_japa_count');
      if (saved) setJapaCount(parseInt(saved, 10));
    } catch (e) {
      console.warn(e);
    }

    const handleStorageChange = () => {
      try {
        const updated = localStorage.getItem('vrindopnishad_japa_count');
        if (updated) setJapaCount(parseInt(updated, 10));
      } catch (e) {
        console.warn(e);
      }
    };

    window.addEventListener('storage', handleStorageChange);
    const interval = setInterval(handleStorageChange, 1000);

    return () => {
      window.removeEventListener('storage', handleStorageChange);
      clearInterval(interval);
    };
  }, []);

  const dailyGoal = settings.dailyGoal || 432;
  const percentComplete = Math.min(100, Math.round((japaCount / dailyGoal) * 100));
  const rounds = Math.floor(japaCount / 108);

  useEffect(() => {
    let active = true;
    const load = async () => {
      try {
        const items = await apiService.getAllContent(null, 10000);
        const rel = extractRelations(items);
        if (active) {
          setAllItems(items);
          setSaints(rel.sants);
          setBooks(rel.books);
          setRagas(rel.ragas);
          setLoading(false);
        }
      } catch (e) {
        console.error('HomePage load:', e);
        if (active) setLoading(false);
      }
    };
    load();
    return () => { active = false; };
  }, [apiService]);

  const latestVerses = useMemo(() => allItems.filter(i => i.category?.toLowerCase() !== 'saint').slice(0, 6), [allItems]);

  const aajKaPad = useMemo(() => {
    if (!allItems || allItems.length === 0) return null;
    const verses = allItems.filter(i => i.category?.toLowerCase() !== 'saint');
    if (verses.length === 0) return null;

    let matched = null;
    if (calendarData) {
      const keywords = [
        calendarData.festivalEn,
        calendarData.festivalHi,
        calendarData.lilaEn,
        calendarData.lilaHi,
        calendarData.tithiEn,
        calendarData.tithiHi
      ].filter(Boolean).map(k => k.toLowerCase());

      for (const keyword of keywords) {
        if (keyword.length > 3) {
          const cleanKeyword = keyword.replace(/ekadashi/gi, 'एकादशी').replace(/gopashtami/gi, 'गोपाष्टमी').trim();
          const match = verses.find(v => 
            (v.title && v.title.toLowerCase().includes(cleanKeyword)) ||
            (v.title && v.title.toLowerCase().includes(keyword)) ||
            (v.description && v.description.toLowerCase().includes(keyword)) ||
            (v.hindi_text && v.hindi_text.toLowerCase().includes(keyword))
          );
          if (match) {
            matched = match;
            break;
          }
        }
      }
    }

    if (!matched) {
      const today = new Date();
      const hash = (today.getFullYear() * 37) + (today.getMonth() * 19) + today.getDate();
      matched = verses[hash % verses.length];
    }

    return matched;
  }, [allItems, calendarData]);

  const dailyShloka = DAILY_SHLOKAS[new Date().getDate() % DAILY_SHLOKAS.length];

  
  const categoryStats = useMemo(() => {
    const counts = { shloka: 0, strotra: 0, poem: 0, raga: ragas.length };
    allItems.forEach(item => {
      const cat = item.category?.toLowerCase();
      if (counts[cat] !== undefined) {
        counts[cat]++;
      }
    });
    return counts;
  }, [allItems, ragas]);

  
  if (loading) {
    return (
      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 text-left min-h-screen">
        
        <div className="flex justify-between items-center mb-10">
          <div className="skeleton w-48 h-8 rounded-lg" />
          <div className="skeleton w-24 h-6 rounded-full" />
        </div>

        
        <div className="grid grid-cols-1 lg:grid-cols-4 gap-8 items-start mb-16">
          
          <div className="skeleton-card p-6 h-[440px] flex flex-col justify-between">
            <div>
              <div className="skeleton w-32 h-5 mb-6" />
              <div className="space-y-4">
                {[...Array(4)].map((_, i) => (
                  <div key={i} className="flex justify-between items-center py-2 border-b border-white/5">
                    <div className="skeleton w-24 h-4" />
                    <div className="skeleton w-16 h-4" />
                  </div>
                ))}
              </div>
            </div>
            <div className="skeleton w-full h-10 rounded-xl" />
          </div>

          
          <div className="skeleton-card lg:col-span-2 p-8 h-[440px] flex flex-col justify-between">
            <div>
              <div className="flex gap-3 mb-6">
                <div className="skeleton w-20 h-8 rounded-full" />
                <div className="skeleton w-20 h-8 rounded-full" />
                <div className="skeleton w-20 h-8 rounded-full" />
              </div>
              <div className="space-y-4 my-8">
                <div className="skeleton skeleton-title w-3/4" />
                <div className="skeleton skeleton-text w-full" />
                <div className="skeleton skeleton-text w-full" />
                <div className="skeleton skeleton-text w-5/6" />
              </div>
            </div>
            <div className="flex justify-between items-center pt-4 border-t border-white/5">
              <div className="flex gap-4">
                <div className="skeleton w-10 h-10 rounded-full" />
                <div className="skeleton w-10 h-10 rounded-full" />
              </div>
              <div className="skeleton w-28 h-8 rounded-full" />
            </div>
          </div>

          
          <div className="skeleton-card p-6 h-[440px] flex flex-col justify-between items-center text-center">
            <div className="w-full">
              <div className="skeleton w-36 h-5 mx-auto mb-8" />
              <div className="skeleton w-32 h-32 rounded-full mx-auto mb-6 flex items-center justify-center">
                <div className="w-24 h-24 rounded-full bg-black/10 dark:bg-white/5" />
              </div>
            </div>
            <div className="w-full space-y-3">
              <div className="skeleton w-3/4 h-4 mx-auto" />
              <div className="skeleton w-full h-2.5 rounded-full" />
              <div className="skeleton w-full h-12 rounded-xl mt-4" />
            </div>
          </div>
        </div>

        
        <div className="py-8 border-t border-white/5 mb-16">
          <div className="skeleton w-40 h-6 mb-8" />
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
            {[...Array(4)].map((_, i) => (
              <div key={i} className="skeleton-card p-4 h-24 flex items-center gap-4">
                <div className="skeleton w-10 h-10 rounded-full shrink-0" />
                <div className="space-y-2 w-full">
                  <div className="skeleton w-16 h-4" />
                  <div className="skeleton w-10 h-3" />
                </div>
              </div>
            ))}
          </div>
        </div>

        
        <div className="py-8 border-t border-white/5">
          <div className="skeleton w-44 h-6 mb-8" />
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="skeleton-card p-6 h-72 flex flex-col justify-between">
                <div>
                  <div className="flex justify-between items-center mb-4">
                    <div className="skeleton w-20 h-5 rounded-full" />
                    <div className="skeleton w-16 h-4" />
                  </div>
                  <div className="skeleton skeleton-title w-3/4 mb-4" />
                  <div className="space-y-2">
                    <div className="skeleton skeleton-text w-full" />
                    <div className="skeleton skeleton-text w-full" />
                    <div className="skeleton skeleton-text w-4/5" />
                  </div>
                </div>
                <div className="pt-4 border-t border-white/5 flex gap-2">
                  <div className="skeleton w-16 h-4 rounded" />
                  <div className="skeleton w-20 h-4 rounded" />
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  if (settings.layoutMode === 'pookiz') {
    return (
      <PookizDashboardView
        isHi={isHi}
        saints={saints}
        books={books}
        ragas={ragas}
        dailyShloka={dailyShloka}
        japaCount={japaCount}
        handleUpdateJapaCount={handleUpdateJapaCount}
        streak={streak}
        handleComplete={handleComplete}
        isCompleted={isCompleted}
        settings={settings}
        updateSetting={updateSetting}
        user={user}
      />
    );
  }

  return (
    <div className="relative overflow-hidden animate-fade-in font-sans min-h-screen">
      
      <Helmet>
        <title>Vrindopnishad Paath — वृंदोपनिषद् पाठ | Sacred Shlokas, Strotras &amp; Devotional Poetry</title>
        <meta name="description" content="Vrindopnishad Paath (वृंदोपनिषद् पाठ) — Read and listen to authentic sacred Sanskrit shlokas, devotional strotras, spiritual poetry &amp; Vedic wisdom from Vrindavan saints. Free online paath in Hindi, Sanskrit &amp; English." />
        <meta name="keywords" content="vrindopnishad, vrindopnishad paath, वृंदोपनिषद्, वृंदोपनिषद् पाठ, vrindopnishad path, vrindopnishad app, sant vaani, sacred shlokas, sanskrit shlokas, strotras, devotional poetry, bhagavad gita, vedic wisdom, vrindavan, bhakti, श्लोक, स्तोत्र, rasik sant, braj rasik, brajrasik, radha krishna, premanand ji maharaj, barsana, nandgaav, govardhan, rasik vaani, रसिक वाणी" />
        <link rel="canonical" href="https://path.vrindopnishad.in/" />
        <meta name="geo.region" content="IN" />
        <meta name="geo.placename" content="Vrindavan, India" />
        <meta name="content-language" content="hi, en, sa" />
        <meta property="og:type" content="website" />
        <meta property="og:url" content="https://path.vrindopnishad.in/" />
        <meta property="og:site_name" content="Vrindopnishad — वृंदोपनिषद्" />
        <meta property="og:title" content="Vrindopnishad Paath — वृंदोपनिषद् पाठ | Sacred Digital Sanctuary" />
        <meta property="og:description" content="Read sacred Sanskrit shlokas, Rasik Sant vaani, strotras &amp; Vedic wisdom online." />
        <meta property="og:image" content="https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png" />
        <meta property="og:locale" content="hi_IN" />
        <meta property="og:locale:alternate" content="en_IN" />
        <meta name="twitter:card" content="summary_large_image" />
        <meta name="twitter:title" content="Vrindopnishad Paath — वृंदोपनिषद् पाठ" />
        <meta name="twitter:description" content="Read sacred Sanskrit shlokas, Rasik Sant vaani &amp; Vedic wisdom online." />
        <meta name="twitter:image" content="https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png" />
        <script type="application/ld+json">{JSON.stringify({
          "@context": "https://schema.org", "@type": "CollectionPage",
          "name": "Vrindopnishad Paath — वृंदोपनिषद् पाठ",
          "alternateName": ["Vrindopnishad", "वृंदोपनिषद्", "Sant Vaani"],
          "description": "Largest digital collection of sacred Sanskrit shlokas, strotras, Rasik Sant vaani, and Vedic wisdom from Vrindavan.",
          "url": "https://path.vrindopnishad.in", "inLanguage": ["hi", "en", "sa"],
          "publisher": { "@type": "Organization", "name": "Vrindopnishad", "logo": { "@type": "ImageObject", "url": "https://vrindopnishad.in/Vrindopnishad%20Web/class/logo/v-logo.png" } },
          "mainEntity": {
            "@type": "ItemList", "itemListElement": [
              { "@type": "ListItem", "position": 1, "name": "Rasik Sant Vaani", "url": "https://path.vrindopnishad.in/saints" },
              { "@type": "ListItem", "position": 2, "name": "Sacred Granthas", "url": "https://path.vrindopnishad.in/books" },
              { "@type": "ListItem", "position": 3, "name": "Classical Ragas", "url": "https://path.vrindopnishad.in/ragas" },
              { "@type": "ListItem", "position": 4, "name": "Sacred Verses", "url": "https://path.vrindopnishad.in/content" }
            ]
          }
        })}</script>
      </Helmet>

      
      <div className="home-theme-glow-ambient top-[-250px] left-[-200px] md:w-[800px] md:h-[800px]"
        style={{ background: `radial-gradient(circle, rgba(var(--primary-rgb), 0.03) 0%, rgba(var(--primary-rgb), 0.005) 50%, transparent 70%)` }} />

      <div className="home-theme-glow-ambient bottom-[20%] right-[-200px] md:w-[700px] md:h-[700px]"
        style={{ background: `radial-gradient(circle, rgba(var(--primary-rgb), 0.015) 0%, transparent 70%)` }} />

      <div className="relative z-10 max-w-6xl mx-auto px-4 py-4 animate-fade-in space-y-12 pt-6">

        
        <div className="space-y-6">
          
          <div className="glass-card !p-4 sm:!p-5 rounded-3xl border border-primary/10 flex flex-col sm:flex-row justify-between items-center gap-4 text-left shadow-lg select-none">
            <div className="flex items-center gap-4 w-full sm:w-auto">
              <div className="w-12 h-12 rounded-full bg-primary/10 border border-primary/20 flex items-center justify-center text-primary font-bold text-xl uppercase shrink-0">
                {getInitials(settings.devoteeName || 'Seeker')}
              </div>
              <div className="min-w-0 flex-1">
                <div className="flex items-center gap-2">
                  <span className="flex items-center gap-1">
                    {currentGreeting.icon}
                    <span className="text-[10px] uppercase tracking-[0.2em] text-white/50 font-bold">
                      {isHi ? currentGreeting.greetingHi : currentGreeting.greetingEn}
                    </span>
                  </span>
                </div>
                <div className="flex items-center gap-2 mt-1">
                  {isEditingName ? (
                    <div className="flex items-center gap-2 w-full max-w-sm">
                      <input
                        type="text"
                        value={tempName}
                        onChange={(e) => setTempName(e.target.value)}
                        placeholder={isHi ? "अपना नाम लिखें..." : "Spiritual Name..."}
                        className="bg-white/5 border border-white/10 rounded-xl px-3 py-1.5 text-xs text-white outline-none focus:border-primary/50 w-full"
                        autoFocus
                        onKeyDown={(e) => {
                          if (e.key === 'Enter') {
                            updateSetting('devoteeName', tempName);
                            setIsEditingName(false);
                          } else if (e.key === 'Escape') {
                            setTempName(settings.devoteeName || '');
                            setIsEditingName(false);
                          }
                        }}
                      />
                      <button
                        onClick={() => {
                          updateSetting('devoteeName', tempName);
                          setIsEditingName(false);
                        }}
                        className="bg-primary/20 hover:bg-primary/40 text-primary border border-primary/30 rounded-xl px-3 py-1.5 text-[10px] font-bold transition-all shrink-0"
                      >
                        {isHi ? "सहेजें" : "Save"}
                      </button>
                      <button
                        onClick={() => {
                          setTempName(settings.devoteeName || '');
                          setIsEditingName(false);
                        }}
                        className="text-white/40 hover:text-white text-[10px] shrink-0"
                      >
                        {isHi ? "रद्द करें" : "Cancel"}
                      </button>
                    </div>
                  ) : (
                    <div className="flex items-center gap-2">
                      <h1 className="text-base md:text-lg font-bold font-headings text-minimal-gold leading-tight">
                        {isHi
                          ? `राधे राधे, ${settings.devoteeName || 'साधक'}`
                          : `Radhe Radhe, ${settings.devoteeName || 'Sadhak'}`}
                      </h1>
                      <button
                        onClick={() => setIsEditingName(true)}
                        className="text-white/35 hover:text-primary transition-colors p-1"
                        title={isHi ? "नाम बदलें" : "Edit Name"}
                      >
                        <Edit2 size={12} />
                      </button>
                    </div>
                  )}
                </div>
                <p className="text-xs text-white/50 mt-1 font-light leading-relaxed animate-fade-in">
                  {isHi ? currentGreeting.hi : currentGreeting.en}
                </p>
              </div>
            </div>

            <div className="flex items-center gap-3 shrink-0 w-full sm:w-auto justify-between sm:justify-end border-t sm:border-t-0 border-white/5 pt-3 sm:pt-0">
              <div className="text-left sm:text-right">
                <span className="text-[9px] uppercase tracking-wider text-white/35 block">Atmosphere</span>
                <span className="text-xs font-bold text-primary block mt-0.5 capitalize">{settings.theme} Preset</span>
              </div>
              <div className="h-8 w-[1px] bg-white/5 hidden sm:block" />
              <div className="text-left sm:text-right">
                <span className="text-[9px] uppercase tracking-wider text-white/35 block">Daily Goal</span>
                <span className="text-xs font-bold text-white/80 block mt-0.5">{settings.dailyGoal / 108} Malas</span>
              </div>
            </div>
          </div>

          
          <AtmosphereCustomizer
            isHi={isHi}
            theme={settings.theme}
            updateSetting={updateSetting}
          />
        </div>

        
        <div className="grid grid-cols-1 lg:grid-cols-4 gap-6 max-w-6xl mx-auto items-stretch">
          
          <div className="lg:col-span-1 h-full">
            <BrajCalendar
              isHi={isHi}
              calendarData={calendarData}
              onSaveCalendar={handleSaveCalendar}
            />
          </div>

          
          <div className="lg:col-span-2 h-full flex flex-col">
            <DailySwadhyaya
              isHi={isHi}
              dailyShloka={dailyShloka}
              streak={streak}
              isCompleted={isCompleted}
              handleComplete={handleComplete}
              particles={particles}
            />
          </div>

          
          <div className="lg:col-span-1 h-full">
            <ChantSanctuary
              isHi={isHi}
              japaCount={japaCount}
              handleUpdateJapaCount={handleUpdateJapaCount}
              dailyGoal={dailyGoal}
              percentComplete={percentComplete}
              rounds={rounds}
            />
          </div>
        </div>

        {/* Aaj ka Pad section */}
        {aajKaPad && (
          <div className="max-w-6xl mx-auto w-full my-8">
            <div className="glass-card p-6 md:p-8 relative overflow-hidden group border border-white/5 hover:border-primary/20 transition-all rounded-3xl bg-gradient-to-br from-white/[0.02] to-transparent text-left">
              <div className="absolute top-0 right-0 p-8 opacity-[0.03] text-9xl font-serif pointer-events-none text-primary">ॐ</div>
              
              <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-6 border-b border-white/5 pb-4">
                <div>
                  <span className="text-[10px] uppercase tracking-[0.25em] text-primary font-bold block mb-1">
                    {isHi ? "दैनिक रस प्रसाद" : "Today's Sacred Nectar"}
                  </span>
                  <h2 className="text-2xl font-bold font-headings text-minimal-gold">
                    {isHi ? "आज का पद" : "Aaj Ka Pad"}
                  </h2>
                </div>
                
                <div className="flex items-center gap-3">
                  <button
                    onClick={() => shareVerseCard(aajKaPad, isHi)}
                    className="flex items-center gap-2 px-4 py-2 rounded-full border border-white/10 hover:border-white/20 bg-white/5 text-white/70 hover:text-white transition-all text-xs font-semibold"
                    title={isHi ? "कार्ड शेयर करें" : "Share Card"}
                  >
                    <Share2 size={13} />
                    <span>{isHi ? "साझा करें" : "Share Card"}</span>
                  </button>
                  <Link
                    to={isHi ? `/hi/content/${aajKaPad.slug || aajKaPad.id}` : `/content/${aajKaPad.slug || aajKaPad.id}`}
                    className="btn-premium px-5 py-2 text-xs"
                  >
                    {isHi ? "पूर्ण पाठ पढ़ें" : "Read Full"}
                  </Link>
                </div>
              </div>

              <div className="text-center py-4">
                {aajKaPad.author && (
                  <span className="text-xs uppercase tracking-widest text-primary/80 font-bold block mb-4">
                    {aajKaPad.author}
                  </span>
                )}
                
                <div 
                  className="font-headings text-lg md:text-2xl leading-relaxed text-white/95 max-w-3xl mx-auto hindi-text"
                  style={{ whiteSpace: 'pre-line' }}
                >
                  {(aajKaPad.sanskrit_text || aajKaPad.hindi_text || aajKaPad.english_translation || "")
                    .split('\n')
                    .slice(0, 4)
                    .join('\n')}
                  {(aajKaPad.sanskrit_text || aajKaPad.hindi_text || "").split('\n').length > 4 ? "\n..." : ""}
                </div>
              </div>
            </div>
          </div>
        )}

        
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          {[
            { to: '/category/shloka', name: isHi ? 'वैदिक श्लोक' : 'Sacred Shlokas', label: 'Vedic', count: categoryStats.shloka, color: 'from-amber-500/20 to-yellow-600/5', border: 'border-amber-500/20', text: 'text-amber-400' },
            { to: '/category/strotra', name: isHi ? 'भक्ति स्तोत्र' : 'Divine Strotras', label: 'Devotional', count: categoryStats.strotra, color: 'from-sky-500/20 to-blue-600/5', border: 'border-sky-500/20', text: 'text-sky-400' },
            { to: '/category/poem', name: isHi ? 'संत कविताएँ' : 'Spiritual Poetry', label: 'Poems', count: categoryStats.poem, color: 'from-emerald-500/20 to-teal-600/5', border: 'border-emerald-500/20', text: 'text-emerald-400' },
            { to: '/ragas', name: isHi ? 'शास्त्रीय राग' : 'Sankirtan Ragas', label: 'Melodies', count: categoryStats.raga, color: 'from-rose-500/20 to-red-600/5', border: 'border-rose-500/20', text: 'text-rose-400' }
          ].map(c => (
            <Link key={c.to} to={c.to}
              className={`p-5 rounded-2xl bg-gradient-to-br ${c.color} border ${c.border} flex flex-col justify-between h-28 hover:scale-[1.02] transition-all group touch-manipulation`}>
              <span className={`text-[10px] font-bold uppercase tracking-widest ${c.text}`}>{c.label}</span>
              <div>
                <h3 className="font-bold text-sm text-white/90 group-hover:text-primary transition-colors truncate">{c.name}</h3>
                <span className="text-[10px] text-white/35 mt-0.5 block font-light">{c.count} {c.count === 1 ? 'item' : 'items'} loaded</span>
              </div>
            </Link>
          ))}
        </div>

        
        <LibraryShowcase
          isHi={isHi}
          books={books}
          navigate={navigate}
        />

        
        <SaintsSpotlight
          isHi={isHi}
          saints={saints}
          navigate={navigate}
        />

        
        <PilgrimageHub
          isHi={isHi}
          navigate={navigate}
        />

        
        <LatestVersesFeed
          isHi={isHi}
          latestVerses={latestVerses}
          navigate={navigate}
        />

        
        <RagasIndex
          isHi={isHi}
          ragas={ragas}
          navigate={navigate}
        />

        
        <div className="py-8 max-w-4xl mx-auto border-t border-white/5 text-center text-xs text-white/35 leading-relaxed font-light space-y-4 select-none">
          <p>
            <strong className="text-white/55 font-bold">Vrindopnishad Paath (वृंदोपनिषद् पाठ)</strong> online sanctuary: Engage daily with authentic Vedic Sanskrit Shlokas (श्लोक), devotional hymns (Strotras / स्तोत्र), and spiritual poetry from Braj Dham saints including Premanand Ji Maharaj, Swami Haridas, Hit Harivansh, and other Braj rasiks. Access complete Hindi भावार्थ translations, English meanings, and classical Raga notations for devotional chanting and swadhyaya.
          </p>
          <p>
            वृंदोपनिषद् पाठ: रस उपासना और ब्रज रसिक संतों की वाणी का एक पवित्र डिजिटल संग्रह। हमारा उद्देश्य संस्कृत ग्रंथों, स्तोत्रों, और कविताओं के अमूल्य ज्ञान को सुगम और सुंदर रूप में जिज्ञासुओं तक पहुँचाना है।
          </p>
          <div className="flex flex-wrap justify-center gap-2 pt-2">
            {['vrindopnishad', 'vrindopnishad paath', 'वृंदोपनिषद्', 'श्लोक', 'स्तोत्र', 'रसिक वाणी', 'radha krishna', 'premanand ji', 'vrindavan', 'classical ragas', 'bhagavad gita'].map(tag => (
              <span key={tag} className="px-2.5 py-0.5 rounded-full border border-white/5 text-white/30 text-[9px] font-light">#{tag}</span>
            ))}
          </div>
        </div>

      </div>

      
      {selectedItem && (
        <React.Suspense fallback={null}>
          <PreviewDrawer
            isHi={isHi}
            selectedItem={selectedItem}
            previewType={previewType}
            closePreview={closePreview}
            books={books}
            onNavigatePreview={openPreview}
          />
        </React.Suspense>
      )}
    </div>
  );
};

export default HomePage;
