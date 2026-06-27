'use client';

import React, { useState, useEffect, useMemo, useRef, useContext } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { AuthContext, ApiContext } from '../contexts/ClientProviders';
import { useTheme } from '../contexts/ThemeContext';
import { useSettings } from '../contexts/SettingsContext';
import { extractRelations } from '../utils/relations';
import { articles } from '../utils/kbArticles';
import { hinglishMatch } from '../utils/hinglishSearch';
import { GLOSSARY_TERMS } from '../data/glossaryTerms';
import { FESTIVALS_DATA } from '../data/festivalsData';
import {
  Home,
  Compass,
  Sparkle,
  Waves,
  Feather,
  LayoutDashboard,
  LogOut,
  Settings,
  Search,
  X,
  User,
  BookOpen,
  Bookmark
} from 'lucide-react';
import GlobalAudioPlayer from './GlobalAudioPlayer';
import SettingsModal from './SettingsModal';
import ThemeOnboardingModal from './ThemeOnboardingModal';
import CelestialParticles from './CelestialParticles';
import PookizLayout from './PookizLayout';
import PageSkeleton from './ui/PageSkeleton';
import SkipLink from './seo/SkipLink';
import ReadingProgress from './seo/ReadingProgress';

let hasLayoutMounted = false;

export const LayoutContext = React.createContext(false);

const LayoutInner = ({ children }) => {
  const { isDark } = useTheme();
  const { settings } = useSettings();
  const { isAdmin, user, logout } = useContext(AuthContext);
  const { apiService, transition } = useContext(ApiContext);
  const [isSettingsOpen, setIsSettingsOpen] = React.useState(false);
  const location = useLocation();
  const navigate = useNavigate();

  const isHiRoute = location.pathname.startsWith('/hi');
  const isActive = (path) => {
    const localizedPath = isHiRoute ? (path === '/' ? '/hi' : `/hi${path}`) : path;
    return location.pathname === localizedPath;
  };
  const isCategoryActive = (category) => {
    const path = `/category/${category}`;
    const localizedPath = isHiRoute ? `/hi${path}` : path;
    return location.pathname === localizedPath;
  };
  const isAuthPage = location.pathname === '/login' || location.pathname === '/hi/login' || location.pathname === '/admin-old/login';

  const isKbRoute = useMemo(() => {
    return location.pathname.includes('/knowledge-base') ||
      articles.some(art => location.pathname.includes(art.slug));
  }, [location.pathname]);

  
  const [searchQuery, setSearchQuery] = useState('');
  const [searchFilter, setSearchFilter] = useState('all'); 
  const [searchFocused, setSearchFocused] = useState(false);
  const [searchData, setSearchData] = useState({ sants: [], books: [], ragas: [], verses: [] });
  const [dataLoaded, setDataLoaded] = useState(false);
  const [loadingSearchData, setLoadingSearchData] = useState(false);

  
  const [chantCount, setChantCount] = useState(0);

  
  useEffect(() => {
    hasLayoutMounted = true;
    try {
      const savedCount = localStorage.getItem('vrindopnishad_japa_count');
      if (savedCount) {
        setChantCount(parseInt(savedCount, 10));
      }
    } catch (e) {
      console.warn('Failed to load japa count:', e);
    }
  }, []);

  
  const playTempleBell = () => {
    try {
      const AudioContext = window.AudioContext || window.webkitAudioContext;
      if (!AudioContext) return;
      const ctx = new AudioContext();
      const now = ctx.currentTime;

      
      const osc1 = ctx.createOscillator();
      const gain1 = ctx.createGain();
      osc1.frequency.setValueAtTime(659.25, now);
      gain1.gain.setValueAtTime(0.12, now);
      gain1.gain.exponentialRampToValueAtTime(0.0001, now + 1.8);
      osc1.connect(gain1);
      gain1.connect(ctx.destination);
      osc1.start();
      osc1.stop(now + 1.8);

      
      const osc2 = ctx.createOscillator();
      const gain2 = ctx.createGain();
      osc2.frequency.setValueAtTime(1318.5, now);
      gain2.gain.setValueAtTime(0.06, now);
      gain2.gain.exponentialRampToValueAtTime(0.0001, now + 1.2);
      osc2.connect(gain2);
      gain2.connect(ctx.destination);
      osc2.start();
      osc2.stop(now + 1.2);
    } catch (e) {
      console.warn('Audio synthesis blocked by browser auto-play security', e);
    }
  };

  const handleChant = (e) => {
    e.stopPropagation();
    const newCount = chantCount + 1;
    setChantCount(newCount);
    try {
      localStorage.setItem('vrindopnishad_japa_count', newCount);
    } catch (err) { }

    
    playTempleBell();

    
    const rect = e.currentTarget.getBoundingClientRect();
    const x = e.clientX || (rect.left + rect.width / 2);
    const y = e.clientY || rect.top;

    const floatText = document.createElement('span');
    const divineNames = ['🌸 Radhe!', '✨ Radhe Radhe!', '🌸 Radhe Shyam!', '✨ Radhe!'];
    floatText.innerText = divineNames[newCount % divineNames.length];

    
    const randomX = (Math.random() - 0.5) * 60; 
    const randomRot = (Math.random() - 0.5) * 30; 

    floatText.className = 'fixed pointer-events-none text-xs font-bold font-headings z-[5000] floating-chant-text';
    floatText.style.left = `${x - 20}px`;
    floatText.style.top = `${y - 20}px`;
    floatText.style.setProperty('--float-x', `${randomX}px`);
    floatText.style.setProperty('--float-rot', `${randomRot}deg`);

    document.body.appendChild(floatText);

    setTimeout(() => {
      floatText.remove();
    }, 1000);
  };

  const searchRef = useRef(null);

  
  const handleSearchFocus = async () => {
    setSearchFocused(true);
    if (dataLoaded || loadingSearchData) return;
    setLoadingSearchData(true);
    try {
      const items = await apiService.getAllContent(null, 10000);
      const rel = extractRelations(items);
      setSearchData({
        sants: rel.sants || [],
        books: rel.books || [],
        ragas: rel.ragas || [],
        verses: items.filter(v => v.category?.toLowerCase() !== 'saint') || []
      });
      setDataLoaded(true);
    } catch (e) {
      console.error('Failed to load global search data:', e);
    } finally {
      setLoadingSearchData(false);
    }
  };

  
  useEffect(() => {
    const handleClick = (e) => {
      if (searchRef.current && !searchRef.current.contains(e.target)) {
        setSearchFocused(false);
      }
    };
    document.addEventListener('mousedown', handleClick);
    return () => document.removeEventListener('mousedown', handleClick);
  }, []);

  
  const filteredResults = useMemo(() => {
    if (!searchQuery.trim() || searchQuery.trim().length < 2 || !dataLoaded) {
      return { sants: [], books: [], ragas: [], verses: [], festivals: [], glossary: [] };
    }
    const q = searchQuery.toLowerCase().trim();
    const showAll = searchFilter === 'all';

    return {
      sants: (showAll || searchFilter === 'saint')
        ? searchData.sants.filter(s => hinglishMatch(s, q)).slice(0, 4)
        : [],
      books: (showAll || searchFilter === 'book')
        ? searchData.books.filter(b => hinglishMatch(b, q)).slice(0, 4)
        : [],
      ragas: (showAll || searchFilter === 'raga')
        ? searchData.ragas.filter(r => hinglishMatch(r, q)).slice(0, 4)
        : [],
      verses: (showAll || searchFilter === 'verse')
        ? searchData.verses.filter(v => hinglishMatch(v, q)).slice(0, 6)
        : [],
      festivals: (showAll || searchFilter === 'festival')
        ? Object.values(FESTIVALS_DATA).filter(f => 
            f.name.toLowerCase().includes(q) || 
            f.hindiName.includes(q) || 
            f.description.toLowerCase().includes(q)
          ).slice(0, 4)
        : [],
      glossary: (showAll || searchFilter === 'glossary')
        ? GLOSSARY_TERMS.filter(t => 
            t.term.toLowerCase().includes(q) || 
            t.devanagari.includes(q) || 
            t.definition.toLowerCase().includes(q)
          ).slice(0, 4)
        : [],
    };
  }, [searchQuery, searchFilter, searchData, dataLoaded]);

  
  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && searchQuery.trim().length > 0) {
      setSearchFocused(false);
      const queryParam = `q=${encodeURIComponent(searchQuery)}`;
      const filterParam = searchFilter !== 'all' ? `&category=${searchFilter}` : '';
      navigate(isHiRoute ? `/hi/content?${queryParam}${filterParam}` : `/content?${queryParam}${filterParam}`);
    }
  };

  const hideHeaderSearch = [
    '/content', '/saints', '/granthas', '/ragas',
    '/hi/content', '/hi/saints', '/hi/granthas', '/hi/ragas'
  ].includes(location.pathname);

  
  if (settings.layoutMode === 'pookiz') {
    return <PookizLayout>{children}</PookizLayout>;
  }

  return (
    <div className={`min-h-screen relative text-foreground ${hideHeaderSearch ? 'layout-no-header-search' : ''} ${isKbRoute ? 'lg:h-screen lg:min-h-0 lg:overflow-hidden' : ''}`}>
      <SkipLink />
      <ReadingProgress />
      
      

      
      {!isAuthPage && (
        <header className={`app-header ${!hasLayoutMounted ? 'animate-fade-in-down' : ''} flex flex-col md:flex-row md:items-center justify-between px-4 sm:px-6 py-2.5 md:py-3 gap-2.5 md:gap-0`}>
          <div className="flex items-center justify-between w-full md:w-auto">
            <div className="logo-container flex items-center gap-2 shrink-0">
              <Link to={isHiRoute ? "/hi" : "/"}>
                <img
                  src={isDark ? '/official-logo-dark.svg' : '/official-logo.svg'}
                  alt="Vrindopnishad Logo"
                  className="app-logo hover:scale-110 transition-transform duration-500"
                />
              </Link>
              <span className="app-title hidden lg:block text-minimal-gold font-headings text-lg">वृंदोपनिषद्</span>
            </div>

            
            <div className="flex md:hidden items-center gap-2">
              
              <button
                onClick={handleChant}
                className="header-chant-btn py-1 px-2.5 text-[9px] leading-none shrink-0"
                title={isHiRoute ? "राधे राधे जाप करें" : "Chant Radhe Radhe"}
              >
                <span className="text-xs mr-0.5">📿</span>
                <span>{isHiRoute ? "जाप" : "Chant"}: <span className="chant-number">{chantCount}</span></span>
              </button>

              
              <button
                onClick={() => setIsSettingsOpen(true)}
                className="header-control-btn shrink-0 w-8 h-8"
                title="Settings"
                aria-label="Open Settings Panel"
              >
                <Settings size={15} className="w-[15px] h-[15px]" />
              </button>

              {user ? (
                <div className="header-profile-pill shrink-0 py-0.5 px-1 bg-white/5 border border-white/5 rounded-full flex items-center gap-1">
                  <div className="header-profile-avatar w-6 h-6">
                    {user.photoURL ? (
                      <img
                        src={user.photoURL}
                        alt="User"
                        className="w-full h-full object-cover"
                        onError={(e) => {
                          e.target.style.display = 'none';
                          if (e.target.nextSibling) {
                            e.target.nextSibling.style.display = 'flex';
                          }
                        }}
                      />
                    ) : null}
                    <span
                      className={`text-[9px] font-bold uppercase flex items-center justify-center w-full h-full ${user.photoURL ? 'hidden' : 'flex'}`}
                    >
                      {(settings.devoteeName || user.displayName || user.email || 'V')[0]}
                    </span>
                  </div>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      logout();
                    }}
                    className="text-white/40 hover:text-white p-0.5"
                    title="Logout"
                  >
                    <LogOut size={12} />
                  </button>
                </div>
              ) : settings.devoteeName ? (
                <div
                  onClick={() => setIsSettingsOpen(true)}
                  className="header-control-btn shrink-0 w-8 h-8 flex items-center justify-center bg-primary/10 border border-primary/20 text-primary"
                >
                  <span className="text-[10px] font-bold uppercase">{(settings.devoteeName || 'G')[0]}</span>
                </div>
              ) : (
                <Link to={isHiRoute ? "/hi/login" : "/login"} className="header-control-btn shrink-0 w-8 h-8" title="Devotee Sign In">
                  <User size={15} className="w-[15px] h-[15px] text-white/70" />
                </Link>
              )}
            </div>
          </div>

          
          {!hideHeaderSearch && (
            <div className="relative w-full md:flex-1 md:max-w-sm md:max-w-md md:mx-6" ref={searchRef}>
              <div className="flex items-center bg-white/[0.04] border border-white/10 rounded-full pl-3 pr-2 h-9 text-xs md:text-sm focus-within:border-primary/50 focus-within:bg-white/[0.07] transition-all">
                <Search className="text-white/30 mr-1.5 shrink-0" size={14} />
                <input
                  type="text"
                  placeholder={isHiRoute ? "खोजें..." : "Search..."}
                  className="w-full bg-transparent outline-none pr-2 text-white/95 placeholder:text-white/35 h-full text-xs font-light"
                  value={searchQuery}
                  onFocus={handleSearchFocus}
                  onKeyDown={handleKeyDown}
                  onChange={(e) => setSearchQuery(e.target.value)}
                />

                
                <select
                  value={searchFilter}
                  onChange={(e) => setSearchFilter(e.target.value)}
                  className="bg-white/5 hover:bg-white/10 border border-white/5 hover:border-white/10 rounded-full text-[9px] md:text-[10px] text-white/70 py-0.5 px-2 outline-none cursor-pointer shrink-0 transition-colors mr-1"
                >
                  <option value="all" className="bg-[#121215] text-white/80">{isHiRoute ? "सभी" : "All"}</option>
                  <option value="saint" className="bg-[#121215] text-white/80">{isHiRoute ? "सन्त" : "Saints"}</option>
                  <option value="book" className="bg-[#121215] text-white/80">{isHiRoute ? "ग्रन्थ" : "Granthas"}</option>
                  <option value="raga" className="bg-[#121215] text-white/80">{isHiRoute ? "राग" : "Ragas"}</option>
                  <option value="verse" className="bg-[#121215] text-white/80">{isHiRoute ? "वाणी" : "Verses"}</option>
                  <option value="festival" className="bg-[#121215] text-white/80">{isHiRoute ? "उत्सव" : "Festivals"}</option>
                  <option value="glossary" className="bg-[#121215] text-white/80">{isHiRoute ? "शब्दावली" : "Glossary"}</option>
                </select>

                {searchQuery && (
                  <button onClick={() => setSearchQuery('')} className="text-white/40 hover:text-white p-0.5 shrink-0">
                    <X size={12} />
                  </button>
                )}
              </div>

              
              {searchFocused && searchQuery.trim().length >= 2 && (
                <div className="absolute top-full left-0 right-0 mt-2 bg-[#121216]/95 border border-white/10 rounded-2xl shadow-2xl backdrop-blur-md z-[3000] overflow-y-auto max-h-[50vh] p-3 text-left">
                  {loadingSearchData ? (
                    <p className="text-[10px] text-white/30 py-4 text-center animate-pulse">Loading search realm...</p>
                  ) : !filteredResults.sants.length && !filteredResults.books.length && !filteredResults.ragas.length && !filteredResults.verses.length ? (
                    <p className="text-[10px] text-white/30 py-4 text-center">No matches found.</p>
                  ) : (
                    <div className="space-y-4">
                      {filteredResults.sants.length > 0 && (
                        <div>
                          <h4 className="text-[9px] uppercase tracking-widest text-primary font-bold mb-1.5">Saints / रसिक सन्त</h4>
                          <div className="grid grid-cols-1 gap-1">
                            {filteredResults.sants.map(s => (
                              <Link key={s.cleanName} to={isHiRoute ? `/hi/saints/${s.slug}` : `/saints/${s.slug}`} onClick={() => setSearchFocused(false)}
                                className="flex items-center gap-2 p-1.5 rounded-lg hover:bg-white/5 transition-colors text-[11px] font-medium text-white/90">
                                <span className="w-5 h-5 rounded-full bg-amber-500/10 flex items-center justify-center text-amber-500 text-[9px] font-bold">{s.cleanName.charAt(0)}</span>
                                <span className="truncate">{s.name}</span>
                              </Link>
                            ))}
                          </div>
                        </div>
                      )}
                      {filteredResults.books.length > 0 && (
                        <div>
                          <h4 className="text-[9px] uppercase tracking-widest text-primary font-bold mb-1.5">Granthas / ग्रन्थ</h4>
                          <div className="grid grid-cols-1 gap-1">
                            {filteredResults.books.map(b => (
                              <Link key={b.name} to={isHiRoute ? `/hi/granthas/${b.slug}` : `/granthas/${b.slug}`} onClick={() => setSearchFocused(false)}
                                className="flex items-center justify-between p-1.5 rounded-lg hover:bg-white/5 transition-colors text-[11px] font-medium text-white/90">
                                <span className="truncate">{b.name}</span>
                                <span className="text-[9px] text-white/30 font-light">{b.author}</span>
                              </Link>
                            ))}
                          </div>
                        </div>
                      )}
                      {filteredResults.ragas.length > 0 && (
                        <div>
                          <h4 className="text-[9px] uppercase tracking-widest text-primary font-bold mb-1.5">Ragas / राग</h4>
                          <div className="grid grid-cols-1 gap-1">
                            {filteredResults.ragas.map(r => (
                              <Link key={r.name} to={isHiRoute ? `/hi/ragas/${r.slug}` : `/ragas/${r.slug}`} onClick={() => setSearchFocused(false)}
                                className="flex items-center justify-between p-1.5 rounded-lg hover:bg-white/5 transition-colors text-[11px] font-medium text-white/90">
                                <span className="truncate">{r.name}</span>
                                <span className="text-[9px] text-white/30 font-light">{r.hinglishName}</span>
                              </Link>
                            ))}
                          </div>
                        </div>
                      )}
                      {filteredResults.verses.length > 0 && (
                        <div>
                          <h4 className="text-[9px] uppercase tracking-widest text-primary font-bold mb-1.5">Verses / वाणी-पद</h4>
                          <div className="grid grid-cols-1 gap-1">
                            {filteredResults.verses.map(v => {
                              const isLyrics = v.category === 'poem' || v.category === 'lyrics';
                              const prefix = isLyrics ? '/lyrics/' : '/content/';
                              return (
                                <Link key={v.id} to={isHiRoute ? `/hi${prefix}${v.slug || v.id}` : `${prefix}${v.slug || v.id}`} onClick={() => setSearchFocused(false)}
                                  className="block p-1.5 rounded-lg hover:bg-white/5 transition-colors text-[11px] text-white/85 truncate">
                                  <span className="font-semibold block">{v.title}</span>
                                  <p className="text-[9px] text-white/30 truncate mt-0.5">{v.hindi_text || v.english_translation || v.description}</p>
                                </Link>
                              );
                            })}
                          </div>
                        </div>
                      )}
                      {filteredResults.festivals && filteredResults.festivals.length > 0 && (
                        <div>
                          <h4 className="text-[9px] uppercase tracking-widest text-primary font-bold mb-1.5">Festivals / उत्सव</h4>
                          <div className="grid grid-cols-1 gap-1">
                            {filteredResults.festivals.map(f => (
                              <Link key={f.slug} to={isHiRoute ? `/hi/festivals/${f.slug}` : `/festivals/${f.slug}`} onClick={() => setSearchFocused(false)}
                                className="flex items-center justify-between p-1.5 rounded-lg hover:bg-white/5 transition-colors text-[11px] font-medium text-white/90">
                                <span className="truncate">{isHiRoute ? f.hindiName : f.name}</span>
                                <span className="text-[9px] text-white/30 font-light">{f.timeline.split(' ')[0]}</span>
                              </Link>
                            ))}
                          </div>
                        </div>
                      )}
                      {filteredResults.glossary && filteredResults.glossary.length > 0 && (
                        <div>
                          <h4 className="text-[9px] uppercase tracking-widest text-primary font-bold mb-1.5">Glossary / शब्दावली</h4>
                          <div className="grid grid-cols-1 gap-1">
                            {filteredResults.glossary.map(t => (
                              <Link key={t.slug} to={isHiRoute ? `/hi/glossary/${t.slug}` : `/glossary/${t.slug}`} onClick={() => setSearchFocused(false)}
                                className="flex items-center justify-between p-1.5 rounded-lg hover:bg-white/5 transition-colors text-[11px] font-medium text-white/90">
                                <span className="truncate">{isHiRoute ? t.devanagari : t.term}</span>
                                <span className="text-[9px] text-white/30 font-light truncate max-w-[150px]">{t.definition}</span>
                              </Link>
                            ))}
                          </div>
                        </div>
                      )}
                    </div>
                  )}
                </div>
              )}
            </div>
          )}

          
          <div className="hidden md:flex items-center gap-4">
            <nav className="hidden lg:flex items-center gap-1.5 xl:gap-3">
              <Link to={isHiRoute ? "/hi" : "/"} className={`header-nav-link text-xs xl:text-sm ${isActive('/') ? 'active' : ''}`}>
                {isHiRoute ? "मुख्य" : "Home"}
              </Link>
              <Link to={isHiRoute ? "/hi/saints" : "/saints"} className={`header-nav-link text-xs xl:text-sm ${isActive('/saints') ? 'active' : ''}`}>
                {isHiRoute ? "सन्त" : "Saints"}
              </Link>
              <Link to={isHiRoute ? "/hi/granthas" : "/granthas"} className={`header-nav-link text-xs xl:text-sm ${isActive('/granthas') ? 'active' : ''}`}>
                {isHiRoute ? "ग्रन्थ" : "Books"}
              </Link>
              <Link to={isHiRoute ? "/hi/ragas" : "/ragas"} className={`header-nav-link text-xs xl:text-sm ${isActive('/ragas') ? 'active' : ''}`}>
                {isHiRoute ? "राग" : "Ragas"}
              </Link>
              <Link to={isHiRoute ? "/hi/category/shloka" : "/category/shloka"} className={`header-nav-link text-xs xl:text-sm ${isCategoryActive('shloka') ? 'active' : ''}`}>
                {isHiRoute ? "श्लोक" : "Shlokas"}
              </Link>
              <Link to={isHiRoute ? "/hi/category/strotra" : "/category/strotra"} className={`header-nav-link text-xs xl:text-sm ${isCategoryActive('strotra') ? 'active' : ''}`}>
                {isHiRoute ? "स्तोत्र" : "Strotras"}
              </Link>
              <Link to={isHiRoute ? "/hi/category/poem" : "/category/poem"} className={`header-nav-link text-xs xl:text-sm ${isCategoryActive('poem') ? 'active' : ''}`}>
                {isHiRoute ? "कविता" : "Poems"}
              </Link>
            </nav>

            <div className="flex items-center gap-2 sm:gap-3">
              
              <button
                onClick={handleChant}
                className="header-chant-btn py-1.5 px-3.5 text-[10px] sm:text-xs leading-none shrink-0"
                title={isHiRoute ? "राधे राधे जाप करें" : "Chant Radhe Radhe"}
              >
                <span className="text-[11px] sm:text-sm leading-none mr-0.5">📿</span>
                <span>{isHiRoute ? "जाप" : "Chants"}: <span className="chant-number">{chantCount}</span></span>
              </button>

              
              <button
                onClick={() => setIsSettingsOpen(true)}
                className="header-control-btn shrink-0"
                title="Settings"
                aria-label="Open Settings Panel"
              >
                <Settings size={18} className="w-[16px] h-[16px] sm:w-[18px] sm:h-[18px]" />
              </button>

              {user ? (
                <div className="header-profile-pill shrink-0">
                  
                  <div className="header-profile-avatar">
                    {user.photoURL ? (
                      <img
                        src={user.photoURL}
                        alt="User"
                        className="w-full h-full object-cover"
                        onError={(e) => {
                          e.target.style.display = 'none';
                          if (e.target.nextSibling) {
                            e.target.nextSibling.style.display = 'flex';
                          }
                        }}
                      />
                    ) : null}
                    <span
                      className={`text-xs font-bold uppercase tracking-wider flex items-center justify-center w-full h-full ${user.photoURL ? 'hidden' : 'flex'}`}
                    >
                      {(settings.devoteeName || user.displayName || user.email || 'V')[0]}
                    </span>
                  </div>

                  
                  <div className="hidden sm:flex flex-col">
                    <span className="header-profile-label">Devotee</span>
                    <span className="header-profile-name">
                      {settings.devoteeName || user.displayName || (user.email?.split('@')[0].match(/^[a-zA-Z]/) ? user.email?.split('@')[0] : 'Member')}
                    </span>
                  </div>

                  
                  <div className="header-profile-divider"></div>

                  
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      logout();
                    }}
                    className="header-profile-logout"
                    title="Logout"
                  >
                    <LogOut size={18} className="sm:w-[16px] sm:h-[16px]" />
                  </button>
                </div>
              ) : settings.devoteeName ? (
                <div
                  onClick={() => setIsSettingsOpen(true)}
                  className="header-profile-pill cursor-pointer"
                >
                  <div className="header-profile-avatar bg-primary/10 border border-primary/20 text-primary flex items-center justify-center font-bold text-xs uppercase">
                    {(settings.devoteeName || 'V')[0]}
                  </div>
                  <div className="hidden sm:flex flex-col text-left">
                    <span className="header-profile-label">Guest Sadhak</span>
                    <span className="header-profile-name">{settings.devoteeName}</span>
                  </div>
                </div>
              ) : (
                <Link to={isHiRoute ? "/hi/login" : "/login"} className="header-control-btn shrink-0" title="Devotee Sign In">
                  <User size={18} className="w-[16px] h-[16px] sm:w-[18px] sm:h-[18px] text-white/70" />
                </Link>
              )}

              {isAdmin && (
                <Link to="/admin-old/dashboard" className="header-control-btn shrink-0" title="Dashboard">
                  <LayoutDashboard size={18} className="text-amber-300 w-[16px] h-[16px] sm:w-[18px] sm:h-[18px]" />
                </Link>
              )}
            </div>
          </div>
        </header>
      )}

      
      {!isAuthPage && (
        <aside className={`sidebar-dock-minimal ${!hasLayoutMounted ? 'animate-fade-in' : ''}`}>
          <Link to={isHiRoute ? "/hi" : "/"} className={`dock-item-minimal ${isActive('/') ? 'active' : ''}`} title="Home">
            <Home size={22} />
            <span className="dock-tooltip-minimal">Home Sanctuary</span>
          </Link>
          <Link to={isHiRoute ? "/hi/content" : "/content"} className={`dock-item-minimal ${isActive('/content') ? 'active' : ''}`} title="All Content">
            <Compass size={22} />
            <span className="dock-tooltip-minimal">Sanctuary Library</span>
          </Link>
          <Link to={isHiRoute ? "/hi/knowledge-base" : "/knowledge-base"} className={`dock-item-minimal ${location.pathname.includes('/knowledge-base') ? 'active' : ''}`} title="Knowledge Base">
            <BookOpen size={22} />
            <span className="dock-tooltip-minimal">{isHiRoute ? "ज्ञान कोष" : "Knowledge Base"}</span>
          </Link>
          <Link to={isHiRoute ? "/hi/bookmarks" : "/bookmarks"} className={`dock-item-minimal ${location.pathname.includes('/bookmarks') ? 'active' : ''}`} title="Bookmarks">
            <Bookmark size={22} />
            <span className="dock-tooltip-minimal">{isHiRoute ? "मेरी पाठ सूची" : "My Bookmarks"}</span>
          </Link>
          <div className="w-8 h-[1px] bg-white/10 my-1"></div>
          <Link to={isHiRoute ? "/hi/category/shloka" : "/category/shloka"} className={`dock-item-minimal ${isCategoryActive('shloka') ? 'active' : ''}`} title="Shlokas">
            <Sparkle size={22} />
            <span className="dock-tooltip-minimal">Sacred Shlokas</span>
          </Link>
          <Link to={isHiRoute ? "/hi/category/strotra" : "/category/strotra"} className={`dock-item-minimal ${isCategoryActive('strotra') ? 'active' : ''}`} title="Strotras">
            <Waves size={22} />
            <span className="dock-tooltip-minimal">Devotional Strotras</span>
          </Link>
          <Link to={isHiRoute ? "/hi/category/poem" : "/category/poem"} className={`dock-item-minimal ${isCategoryActive('poem') ? 'active' : ''}`} title="Poems">
            <Feather size={22} />
            <span className="dock-tooltip-minimal">Spiritual Poetry</span>
          </Link>
        </aside>
      )}

      
      {!isAuthPage && (
        <div className="lg:hidden flex items-center gap-2 overflow-x-auto px-4 py-2 header-sub-bar border-b scrollbar-hide fixed top-[112px] md:top-[80px] left-0 right-0 z-[999] h-10">
          <Link to={isHiRoute ? "/hi/saints" : "/saints"} className={`px-3 py-1 rounded-full text-[10px] font-medium transition-all ${isActive('/saints') ? 'bg-amber-500/20 text-amber-400 border border-amber-500/30' : 'bg-white/5 text-white/60 border border-white/5'}`}>
            {isHiRoute ? "सन्त" : "Saints"}
          </Link>
          <Link to={isHiRoute ? "/hi/granthas" : "/granthas"} className={`px-3 py-1 rounded-full text-[10px] font-medium transition-all ${isActive('/granthas') ? 'bg-amber-500/20 text-amber-400 border border-amber-500/30' : 'bg-white/5 text-white/60 border border-white/5'}`}>
            {isHiRoute ? "ग्रन्थ" : "Books"}
          </Link>
          <Link to={isHiRoute ? "/hi/ragas" : "/ragas"} className={`px-3 py-1 rounded-full text-[10px] font-medium transition-all ${isActive('/ragas') ? 'bg-amber-500/20 text-amber-400 border border-amber-500/30' : 'bg-white/5 text-white/60 border border-white/5'}`}>
            {isHiRoute ? "राग" : "Ragas"}
          </Link>
          <Link to={isHiRoute ? "/hi/category/shloka" : "/category/shloka"} className={`px-3 py-1 rounded-full text-[10px] font-medium transition-all ${isCategoryActive('shloka') ? 'bg-amber-500/20 text-amber-400 border border-amber-500/30' : 'bg-white/5 text-white/60 border border-white/5'}`}>
            {isHiRoute ? "श्लोक" : "Shlokas"}
          </Link>
          <Link to={isHiRoute ? "/hi/category/strotra" : "/category/strotra"} className={`px-3 py-1 rounded-full text-[10px] font-medium transition-all ${isCategoryActive('strotra') ? 'bg-amber-500/20 text-amber-400 border border-amber-500/30' : 'bg-white/5 text-white/60 border border-white/5'}`}>
            {isHiRoute ? "स्तोत्र" : "Strotras"}
          </Link>
          <Link to={isHiRoute ? "/hi/category/poem" : "/category/poem"} className={`px-3 py-1 rounded-full text-[10px] font-medium transition-all ${isCategoryActive('poem') ? 'bg-amber-500/20 text-amber-400 border border-amber-500/30' : 'bg-white/5 text-white/60 border border-white/5'}`}>
            {isHiRoute ? "कविता" : "Poems"}
          </Link>
        </div>
      )}

      
      <main id="main-content" className={`${isAuthPage ? 'pt-0 pl-0' : `${isKbRoute ? 'pl-0 md:pl-[88px] lg:h-screen lg:pt-20 lg:pb-0 lg:overflow-hidden' : 'pl-0 md:pl-28'} pt-[152px] md:pt-[120px] lg:pt-20 pb-36 md:pb-12`}`}>
        <div className={`${isAuthPage ? 'w-full min-h-screen flex items-center justify-center' : 'w-full px-4 md:px-6'} ${isKbRoute ? 'lg:h-full lg:px-6 lg:pb-4' : ''}`}>
          {transition ? (
            <div className="min-h-[60vh] flex flex-col justify-start py-8 animate-pulse">
              <PageSkeleton variant={transition.variant} />
            </div>
          ) : children}
        </div>
      </main>

      
      {!isAuthPage && (
        <div className="mobile-bottom-nav">
          <Link to={isHiRoute ? "/hi" : "/"} className={`mobile-nav-item ${isActive('/') ? 'active' : ''}`} title="Home">
            <Home size={24} />
          </Link>
          <Link to={isHiRoute ? "/hi/content" : "/content"} className={`mobile-nav-item ${isActive('/content') ? 'active' : ''}`} title="All Content">
            <Compass size={24} />
          </Link>
          <Link to={isHiRoute ? "/hi/category/shloka" : "/category/shloka"} className={`mobile-nav-item ${isCategoryActive('shloka') ? 'active' : ''}`} title="Shlokas">
            <Sparkle size={24} />
          </Link>
          <Link to={isHiRoute ? "/hi/category/strotra" : "/category/strotra"} className={`mobile-nav-item ${isCategoryActive('strotra') ? 'active' : ''}`} title="Strotras">
            <Waves size={24} />
          </Link>
          <Link to={isHiRoute ? "/hi/bookmarks" : "/bookmarks"} className={`mobile-nav-item ${location.pathname.includes('/bookmarks') ? 'active' : ''}`} title="Bookmarks">
            <Bookmark size={24} />
          </Link>
        </div>
      )}
      
      <GlobalAudioPlayer />

      
      <SettingsModal
        isOpen={isSettingsOpen}
        onClose={() => setIsSettingsOpen(false)}
      />

      
      <ThemeOnboardingModal />
    </div>
  );
};

const Layout = ({ children }) => {
  const isNested = useContext(LayoutContext);
  if (isNested) {
    return <>{children}</>;
  }
  return (
    <LayoutContext.Provider value={true}>
      <LayoutInner>{children}</LayoutInner>
    </LayoutContext.Provider>
  );
};

export default Layout;
