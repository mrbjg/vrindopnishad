'use client';

import React, { useState, useEffect, useContext } from 'react';
import { ApiContext } from '../contexts/ClientProviders';
import { Flame, CheckCircle2, Award, Calendar, Search, BookOpen, Music, Sparkles } from 'lucide-react';
import { Helmet } from 'react-helmet-async';
import { Link } from '../lib/router-compat';
import PageSkeleton from '../components/ui/PageSkeleton';

const DailyPracticePage = () => {
  const { apiService } = useContext(ApiContext);
  const [prayers, setPrayers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');
  
  // Daily check-off and streak tracking states
  const [completedToday, setCompletedToday] = useState({});
  const [streak, setStreak] = useState(0);
  const [lastCompletedDate, setLastCompletedDate] = useState('');

  // 1. Fetch daily practice items (tagged 'daily-practice')
  useEffect(() => {
    let active = true;
    const fetchPrayers = async () => {
      try {
        const allContent = await apiService.getAllContent(null, 2000);
        // Filter for items containing 'daily-practice' in tags
        const filtered = allContent.filter(item => 
          item.tags && item.tags.includes('daily-practice')
        );
        
        if (active) {
          setPrayers(filtered);
        }
      } catch (err) {
        console.error('Failed to load daily practice prayers:', err);
      } finally {
        if (active) setLoading(false);
      }
    };

    fetchPrayers();
    return () => { active = false; };
  }, [apiService]);

  // 2. Load streak and completions from Cache (localStorage)
  useEffect(() => {
    try {
      const todayStr = new Date().toISOString().split('T')[0];
      const savedCompletions = localStorage.getItem('vrindopnishad_daily_completions');
      const savedStreak = localStorage.getItem('vrindopnishad_practice_streak');
      const savedLastDate = localStorage.getItem('vrindopnishad_last_practice_date');

      if (savedCompletions) {
        const parsed = JSON.parse(savedCompletions);
        // Only keep completions if they are from today, otherwise reset today's check-offs
        if (parsed.date === todayStr) {
          setCompletedToday(parsed.items || {});
        } else {
          // If date changed, check if streak is preserved (was completed yesterday)
          const yesterday = new Date();
          yesterday.setDate(yesterday.getDate() - 1);
          const yesterdayStr = yesterday.toISOString().split('T')[0];
          
          if (savedLastDate !== todayStr && savedLastDate !== yesterdayStr) {
            // Streak broken
            setStreak(0);
            localStorage.setItem('vrindopnishad_practice_streak', '0');
          }
        }
      }

      if (savedStreak) {
        setStreak(parseInt(savedStreak, 10));
      }
      if (savedLastDate) {
        setLastCompletedDate(savedLastDate);
      }
    } catch (e) {
      console.warn('Failed to load daily practice cache data:', e);
    }
  }, []);

  // 3. Toggle Completion handler
  const toggleComplete = (slug) => {
    const todayStr = new Date().toISOString().split('T')[0];
    const newCompletions = { ...completedToday, [slug]: !completedToday[slug] };
    setCompletedToday(newCompletions);

    try {
      // Save completions to Cache
      localStorage.setItem('vrindopnishad_daily_completions', JSON.stringify({
        date: todayStr,
        items: newCompletions
      }));

      // Calculate streak updates
      const newlyCompleted = newCompletions[slug];
      let newStreak = streak;

      if (newlyCompleted) {
        // If it's the first completion of today, increment streak
        const hasAnyCompletedToday = Object.values(completedToday).some(v => v);
        if (!hasAnyCompletedToday) {
          const yesterday = new Date();
          yesterday.setDate(yesterday.getDate() - 1);
          const yesterdayStr = yesterday.toISOString().split('T')[0];

          if (lastCompletedDate === yesterdayStr || streak === 0) {
            newStreak = streak + 1;
          } else if (lastCompletedDate !== todayStr) {
            newStreak = 1; // reset streak to 1 if it was broken
          }
          setStreak(newStreak);
          setLastCompletedDate(todayStr);
          localStorage.setItem('vrindopnishad_practice_streak', newStreak.toString());
          localStorage.setItem('vrindopnishad_last_practice_date', todayStr);
          
          // Play a premium sound effect synthesised in browser
          playSuccessTone();
        }
      } else {
        // If deselected and nothing else is completed, keep streak but revert last date if needed
        const hasStillAnyCompletedToday = Object.values(newCompletions).some(v => v);
        if (!hasStillAnyCompletedToday) {
          // If they unchecked everything, reset streak increment of today
          if (streak > 0) {
            const reverted = Math.max(0, streak - 1);
            setStreak(reverted);
            localStorage.setItem('vrindopnishad_practice_streak', reverted.toString());
            setLastCompletedDate('');
            localStorage.removeItem('vrindopnishad_last_practice_date');
          }
        }
      }
    } catch (e) {
      console.error(e);
    }
  };

  // Browser synthesized audio tone for premium feedback
  const playSuccessTone = () => {
    try {
      const AudioContext = window.AudioContext || window.webkitAudioContext;
      if (!AudioContext) return;
      const ctx = new AudioContext();
      const now = ctx.currentTime;

      const osc = ctx.createOscillator();
      const gain = ctx.createGain();

      osc.type = 'sine';
      osc.frequency.setValueAtTime(659.25, now); // E5
      osc.frequency.setValueAtTime(783.99, now + 0.1); // G5
      osc.frequency.setValueAtTime(987.77, now + 0.25); // B5

      gain.gain.setValueAtTime(0.08, now);
      gain.gain.exponentialRampToValueAtTime(0.0001, now + 0.6);

      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start();
      osc.stop(now + 0.6);
    } catch (e) {}
  };

  // Filter prayers based on active tab and search query
  const filteredPrayers = prayers.filter(p => {
    const matchesSearch = 
      p.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      p.author.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (p.sanskrit_text && p.sanskrit_text.toLowerCase().includes(searchQuery.toLowerCase()));

    if (activeTab === 'all') return matchesSearch;
    if (activeTab === 'aarti') return matchesSearch && p.tags.includes('aarti');
    if (activeTab === 'chalisa') return matchesSearch && p.tags.includes('chalisa');
    if (activeTab === 'stuti') return matchesSearch && (p.tags.includes('stuti') || p.tags.includes('strotra'));
    return matchesSearch;
  });

  const pageTitle = "नित्य नियम - दैनिक साधना | Daily Spiritual Practice";
  const pageDescription = "दैनिक आरती, चालीसा, स्तुति और पूजा के पाठ। अपने दैनिक साधना नियम को ट्रैक करें और आध्यात्मिक विकास की ओर अग्रसर हों।";

  if (loading) {
    return (
      <div className="max-w-4xl mx-auto py-8">
        <PageSkeleton variant="list" />
      </div>
    );
  }

  return (
    <div className="max-w-5xl mx-auto py-6 md:py-10 px-2 sm:px-4">
      <Helmet>
        <title>{pageTitle}</title>
        <meta name="description" content={pageDescription} />
      </Helmet>

      {/* Header section with premium design */}
      <div className="text-center mb-10 md:mb-16 relative py-8 px-6 rounded-3xl overflow-hidden bg-white/[0.02] border border-white/5 shadow-2xl backdrop-blur-md">
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-72 h-72 bg-primary/10 rounded-full filter blur-[80px] pointer-events-none"></div>
        
        <div className="flex justify-center mb-4">
          <span className="p-3 bg-amber-500/10 rounded-2xl text-amber-400 border border-amber-500/20 shadow-lg shadow-amber-500/5 animate-pulse">
            <Sparkles size={28} />
          </span>
        </div>

        <h1 className="text-3xl md:text-5xl font-bold tracking-tight mb-4 text-sacred-gradient font-headings">
          नित्य नियम व साधना
        </h1>
        
        <p className="text-white/60 text-xs sm:text-sm max-w-2xl mx-auto font-light leading-relaxed">
          Daily Spiritual Practice Dashboard. Access your everyday Aarti, Chalisa, Stuti, and prayers. Maintain consistency, track your streak, and cultivate daily devotion.
        </p>

        {/* Streak Dashboard Card */}
        <div className="flex flex-wrap justify-center items-center gap-4 sm:gap-6 mt-8 pt-6 border-t border-white/5">
          <div className="flex items-center gap-3 bg-white/[0.03] border border-white/10 px-4 py-2.5 rounded-2xl">
            <Flame size={20} className={streak > 0 ? "text-orange-500 animate-bounce" : "text-white/30"} />
            <div className="text-left">
              <span className="text-[9px] uppercase tracking-wider text-white/40 block font-semibold">Current Streak</span>
              <span className="text-sm sm:text-base font-bold text-white">{streak} {streak === 1 ? 'Day' : 'Days'}</span>
            </div>
          </div>

          <div className="flex items-center gap-3 bg-white/[0.03] border border-white/10 px-4 py-2.5 rounded-2xl">
            <Calendar size={20} className="text-primary" />
            <div className="text-left">
              <span className="text-[9px] uppercase tracking-wider text-white/40 block font-semibold">Today's Progress</span>
              <span className="text-sm sm:text-base font-bold text-white">
                {Object.values(completedToday).filter(Boolean).length} / {prayers.length} Done
              </span>
            </div>
          </div>

          {streak > 2 && (
            <div className="flex items-center gap-2 bg-amber-500/10 border border-amber-500/20 px-3.5 py-2.5 rounded-2xl text-amber-300 text-xs font-semibold animate-pulse">
              <Award size={16} />
              <span>Devoted Sadhak Badge Active!</span>
            </div>
          )}
        </div>
      </div>

      {/* Control bar: Search and Filter Tabs */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6 mb-8 border-b border-white/5 pb-6">
        <div className="flex overflow-x-auto gap-2 py-1 scrollbar-hide shrink-0">
          {[
            { id: 'all', label: 'सभी पाठ', labelEn: 'All Prayers' },
            { id: 'aarti', label: 'आरती', labelEn: 'Aartis' },
            { id: 'chalisa', label: 'चालीसा', labelEn: 'Chalisas' },
            { id: 'stuti', label: 'स्तुति व स्तोत्र', labelEn: 'Stutis & Stotras' }
          ].map(tab => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`px-4 py-2 rounded-full text-xs font-medium transition-all shrink-0 border ${
                activeTab === tab.id
                  ? 'bg-primary/20 text-primary border-primary/40'
                  : 'bg-white/5 text-white/60 border-white/5 hover:bg-white/10'
              }`}
            >
              <span className="block text-center">{tab.label}</span>
              <span className="block text-[8px] opacity-40 text-center font-normal">{tab.labelEn}</span>
            </button>
          ))}
        </div>

        {/* Search input field */}
        <div className="relative w-full md:max-w-xs">
          <Search size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-white/30" />
          <input
            type="text"
            placeholder="साधना पाठ खोजें..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full bg-white/[0.03] border border-white/10 rounded-full py-2 pl-10 pr-4 text-xs text-white placeholder:text-white/30 outline-none focus:border-primary/50 transition-colors"
          />
        </div>
      </div>

      {/* Prayers Grid */}
      {filteredPrayers.length === 0 ? (
        <div className="text-center py-16 bg-white/[0.01] border border-white/5 rounded-3xl">
          <BookOpen size={40} className="mx-auto text-white/20 mb-3" />
          <p className="text-white/40 text-sm">कोई पाठ नहीं मिला।</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 md:gap-6">
          {filteredPrayers.map((prayer) => {
            const isCompleted = !!completedToday[prayer.slug];
            return (
              <div
                key={prayer.id}
                className={`relative group flex flex-col justify-between p-5 md:p-6 rounded-3xl border transition-all duration-300 ${
                  isCompleted
                    ? 'bg-primary/[0.03] border-primary/20 shadow-lg shadow-primary/[0.02]'
                    : 'bg-white/[0.01] border-white/5 hover:border-white/15 hover:bg-white/[0.03] shadow-md'
                }`}
              >
                {/* Completion Checkmark */}
                <button
                  onClick={() => toggleComplete(prayer.slug)}
                  className={`absolute top-4 right-4 flex items-center justify-center w-8 h-8 rounded-full border transition-all ${
                    isCompleted
                      ? 'bg-primary text-black border-primary'
                      : 'bg-white/5 border-white/10 hover:border-white/20 text-white/30 hover:text-white/70'
                  }`}
                  title={isCompleted ? "Completed" : "Mark as Completed"}
                >
                  <CheckCircle2 size={16} />
                </button>

                <div className="pr-10">
                  <div className="flex items-center gap-2.5 mb-3.5">
                    <span className="px-2.5 py-0.5 rounded-full text-[9px] uppercase tracking-wider font-semibold bg-white/5 text-white/60 border border-white/5">
                      {prayer.tags.includes('aarti') ? 'Aarti' : prayer.tags.includes('chalisa') ? 'Chalisa' : 'Stuti'}
                    </span>
                    <span className="text-[10px] text-white/40 font-light truncate">
                      {prayer.author}
                    </span>
                  </div>

                  <h3 className={`text-base md:text-lg font-bold tracking-tight mb-2 transition-colors ${
                    isCompleted ? 'text-primary' : 'text-white group-hover:text-primary/95'
                  }`}>
                    {prayer.title}
                  </h3>

                  <p className="text-white/50 text-[11px] sm:text-xs font-light leading-relaxed line-clamp-2 mb-6">
                    {prayer.description || prayer.english_translation}
                  </p>
                </div>

                <div className="flex items-center justify-between mt-auto pt-4 border-t border-t-white/5">
                  <Link
                    to={`/lyrics/${prayer.slug}`}
                    className="inline-flex items-center gap-2 text-xs font-medium text-primary hover:text-primary-light transition-colors"
                  >
                    <BookOpen size={14} />
                    <span>पाठ पढ़ें / Read</span>
                  </Link>

                  {prayer.audio_url && (
                    <span className="text-white/30 hover:text-white transition-colors cursor-pointer p-1">
                      <Music size={14} />
                    </span>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};

export default DailyPracticePage;
