import React, { useState, useEffect, useMemo, useRef, useContext } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { AuthContext, ApiContext } from '../App';
import { useTheme } from '../contexts/ThemeContext';
import { extractRelations } from '../utils/relations';
import { 
  Home, 
  BookOpen, 
  Scroll, 
  Music, 
  FileText, 
  LayoutDashboard, 
  LogOut,
  Settings,
  Search,
  X,
  User
} from 'lucide-react';
import GlobalAudioPlayer from './GlobalAudioPlayer';
import SettingsModal from './SettingsModal';
import ThemeOnboardingModal from './ThemeOnboardingModal';
import CelestialParticles from './CelestialParticles';

const Layout = ({ children }) => {
  const { isDark } = useTheme();
  const { isAdmin, user, logout } = useContext(AuthContext);
  const { apiService } = useContext(ApiContext);
  const [isSettingsOpen, setIsSettingsOpen] = React.useState(false);
  const location = useLocation();
  const navigate = useNavigate();

  const isActive = (path) => location.pathname === path;
  const isCategoryActive = (category) => location.pathname === `/category/${category}`;
  const isAuthPage = location.pathname === '/login' || location.pathname === '/admin-old/login';
  const isHiRoute = location.pathname.startsWith('/hi');

  // Search & Filter state
  const [searchQuery, setSearchQuery] = useState('');
  const [searchFilter, setSearchFilter] = useState('all'); // 'all', 'saint', 'book', 'raga', 'verse'
  const [searchFocused, setSearchFocused] = useState(false);
  const [searchData, setSearchData] = useState({ sants: [], books: [], ragas: [], verses: [] });
  const [dataLoaded, setDataLoaded] = useState(false);
  const [loadingSearchData, setLoadingSearchData] = useState(false);

  // Japa Chant state
  const [chantCount, setChantCount] = useState(0);

  // Load chants count from localStorage on mount
  useEffect(() => {
    try {
      const savedCount = localStorage.getItem('vrindopnishad_japa_count');
      if (savedCount) {
        setChantCount(parseInt(savedCount, 10));
      }
    } catch (e) {
      console.warn('Failed to load japa count:', e);
    }
  }, []);

  // Programmatic rich temple bell sound synthesizer using Web Audio API
  const playTempleBell = () => {
    try {
      const AudioContext = window.AudioContext || window.webkitAudioContext;
      if (!AudioContext) return;
      const ctx = new AudioContext();
      const now = ctx.currentTime;
      
      // Warm E5 note (fundamental)
      const osc1 = ctx.createOscillator();
      const gain1 = ctx.createGain();
      osc1.frequency.setValueAtTime(659.25, now);
      gain1.gain.setValueAtTime(0.12, now);
      gain1.gain.exponentialRampToValueAtTime(0.0001, now + 1.8);
      osc1.connect(gain1);
      gain1.connect(ctx.destination);
      osc1.start();
      osc1.stop(now + 1.8);
      
      // Rich E6 octave overtone
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
    } catch (err) {}
    
    // Play bell sound
    playTempleBell();
    
    // Trigger floating +1 Radhe! animation at cursor/click coordinates
    const rect = e.currentTarget.getBoundingClientRect();
    const x = e.clientX || (rect.left + rect.width / 2);
    const y = e.clientY || rect.top;
    
    const floatText = document.createElement('span');
    const divineNames = ['🌸 Radhe!', '✨ Radhe Radhe!', '🌸 Radhe Shyam!', '✨ Radhe!'];
    floatText.innerText = divineNames[newCount % divineNames.length];
    floatText.className = 'fixed pointer-events-none text-xs font-bold text-amber-300 font-headings z-[5000] animate-float-fade-up';
    floatText.style.left = `${x - 20}px`;
    floatText.style.top = `${y - 20}px`;
    document.body.appendChild(floatText);
    
    setTimeout(() => {
      floatText.remove();
    }, 900);
  };

  const searchRef = useRef(null);

  // Lazy load search items only when search input is focused
  const handleSearchFocus = async () => {
    setSearchFocused(true);
    if (dataLoaded || loadingSearchData) return;
    setLoadingSearchData(true);
    try {
      const cached = localStorage.getItem('vrindopnishad_all_content_cache');
      let items = [];
      if (cached) {
        items = JSON.parse(cached);
      } else {
        items = await apiService.getAllContent(null, 10000);
      }
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

  // Close search suggestions on click outside
  useEffect(() => {
    const handleClick = (e) => {
      if (searchRef.current && !searchRef.current.contains(e.target)) {
        setSearchFocused(false);
      }
    };
    document.addEventListener('mousedown', handleClick);
    return () => document.removeEventListener('mousedown', handleClick);
  }, []);

  // Filter search queries dynamically
  const filteredResults = useMemo(() => {
    if (!searchQuery.trim() || searchQuery.trim().length < 2 || !dataLoaded) {
      return { sants: [], books: [], ragas: [], verses: [] };
    }
    const q = searchQuery.toLowerCase().trim();
    const showAll = searchFilter === 'all';

    return {
      sants: (showAll || searchFilter === 'saint') 
        ? searchData.sants.filter(s => s.name?.toLowerCase().includes(q) || s.hinglishName?.toLowerCase().includes(q)).slice(0, 4) 
        : [],
      books: (showAll || searchFilter === 'book') 
        ? searchData.books.filter(b => b.name?.toLowerCase().includes(q) || (b.author && b.author.toLowerCase().includes(q))).slice(0, 4) 
        : [],
      ragas: (showAll || searchFilter === 'raga') 
        ? searchData.ragas.filter(r => r.name?.toLowerCase().includes(q) || r.hinglishName?.toLowerCase().includes(q)).slice(0, 4) 
        : [],
      verses: (showAll || searchFilter === 'verse') 
        ? searchData.verses.filter(v => 
            v.title?.toLowerCase().includes(q) || 
            v.sanskrit_text?.toLowerCase().includes(q) ||
            v.hindi_text?.toLowerCase().includes(q) || 
            v.english_translation?.toLowerCase().includes(q)
          ).slice(0, 6) 
        : [],
    };
  }, [searchQuery, searchFilter, searchData, dataLoaded]);

  // Navigate to ContentListPage on enter key
  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && searchQuery.trim().length > 0) {
      setSearchFocused(false);
      const queryParam = `q=${encodeURIComponent(searchQuery)}`;
      const filterParam = searchFilter !== 'all' ? `&category=${searchFilter}` : '';
      navigate(isHiRoute ? `/hi/content?${queryParam}${filterParam}` : `/content?${queryParam}${filterParam}`);
    }
  };

  return (
    <div className="min-h-screen relative text-foreground">
      {/* Celestial Background */}
      <div className="celestial-bg">
        <div className="stars"></div>
        <div className="nebula"></div>
        <CelestialParticles />
      </div>

      {/* App Header */}
      {!isAuthPage && (
        <header className="app-header animate-fade-in-down flex flex-col md:flex-row md:items-center justify-between px-4 sm:px-6 py-2.5 md:py-3 gap-2.5 md:gap-0">
          <div className="flex items-center justify-between w-full md:w-auto">
            <div className="logo-container flex items-center gap-2 shrink-0">
              <Link to="/">
                <img 
                  src={isDark ? '/official-logo-dark.svg' : '/official-logo.svg'} 
                  alt="Vrindopnishad Logo" 
                  className="app-logo hover:scale-110 transition-transform duration-500" 
                />
              </Link>
              <span className="app-title hidden lg:block text-minimal-gold font-headings text-lg">वृंदोपनिषद्</span>
            </div>

            {/* Mobile Actions Container (visible only on mobile viewports) */}
            <div className="flex md:hidden items-center gap-2">
              {/* Mobile Japa Chant Button */}
              <button 
                onClick={handleChant}
                className="relative flex items-center gap-1 bg-gradient-to-r from-amber-500/20 to-orange-500/20 active:from-amber-500/35 active:to-orange-500/35 border border-amber-500/30 rounded-full py-1 px-2.5 text-[9px] font-semibold text-amber-300 transition-all select-none cursor-pointer"
                title={isHiRoute ? "राधे राधे जाप करें" : "Chant Radhe Radhe"}
              >
                <span className="text-xs">📿</span>
                <span>{isHiRoute ? "जाप" : "Chant"}: <span className="font-bold text-white font-mono">{chantCount}</span></span>
              </button>

              {/* Standalone Settings Button */}
              <button 
                onClick={() => setIsSettingsOpen(true)}
                className="header-control-btn shrink-0 w-8 h-8"
                title="Settings"
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
                      {(user.displayName || user.email || 'V')[0]}
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
              ) : (
                <Link to="/login" className="header-control-btn shrink-0 w-8 h-8" title="Devotee Sign In">
                  <User size={15} className="w-[15px] h-[15px] text-white/70" />
                </Link>
              )}
            </div>
          </div>

          {/* Global Search & Filter bar */}
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
              
              {/* Category Filter Select */}
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
              </select>

              {searchQuery && (
                <button onClick={() => setSearchQuery('')} className="text-white/40 hover:text-white p-0.5 shrink-0">
                  <X size={12} />
                </button>
              )}
            </div>

            {/* Suggestions Overlay Dropdown */}
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
                            <Link key={s.cleanName} to={isHiRoute ? `/hi/saint/${s.slug}` : `/saint/${s.slug}`} onClick={() => setSearchFocused(false)}
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
                            <Link key={b.name} to={isHiRoute ? `/hi/book/${b.slug}` : `/book/${b.slug}`} onClick={() => setSearchFocused(false)}
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
                            <Link key={r.name} to={isHiRoute ? `/hi/raga/${r.slug}` : `/raga/${r.slug}`} onClick={() => setSearchFocused(false)}
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
                          {filteredResults.verses.map(v => (
                            <Link key={v.id} to={isHiRoute ? `/hi/content/${v.slug || v.id}` : `/content/${v.slug || v.id}`} onClick={() => setSearchFocused(false)}
                              className="block p-1.5 rounded-lg hover:bg-white/5 transition-colors text-[11px] text-white/85 truncate">
                              <span className="font-semibold block">{v.title}</span>
                              <p className="text-[9px] text-white/30 truncate mt-0.5">{v.hindi_text || v.english_translation || v.description}</p>
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

          {/* Desktop Navigation & Actions (hidden on mobile viewports) */}
          <div className="hidden md:flex items-center gap-4">
            <nav className="hidden lg:flex items-center gap-1.5 xl:gap-3">
              <Link to="/" className={`header-nav-link text-xs xl:text-sm ${isActive('/') ? 'active' : ''}`}>
                {isHiRoute ? "मुख्य" : "Home"}
              </Link>
              <Link to="/saints" className={`header-nav-link text-xs xl:text-sm ${isActive('/saints') ? 'active' : ''}`}>
                {isHiRoute ? "सन्त" : "Saints"}
              </Link>
              <Link to="/books" className={`header-nav-link text-xs xl:text-sm ${isActive('/books') ? 'active' : ''}`}>
                {isHiRoute ? "ग्रन्थ" : "Books"}
              </Link>
              <Link to="/ragas" className={`header-nav-link text-xs xl:text-sm ${isActive('/ragas') ? 'active' : ''}`}>
                {isHiRoute ? "राग" : "Ragas"}
              </Link>
              <Link to="/category/shloka" className={`header-nav-link text-xs xl:text-sm ${isCategoryActive('shloka') ? 'active' : ''}`}>
                {isHiRoute ? "श्लोक" : "Shlokas"}
              </Link>
              <Link to="/category/strotra" className={`header-nav-link text-xs xl:text-sm ${isCategoryActive('strotra') ? 'active' : ''}`}>
                {isHiRoute ? "स्तोत्र" : "Strotras"}
              </Link>
              <Link to="/category/poem" className={`header-nav-link text-xs xl:text-sm ${isCategoryActive('poem') ? 'active' : ''}`}>
                {isHiRoute ? "कविता" : "Poems"}
              </Link>
            </nav>

            <div className="flex items-center gap-2 sm:gap-3">
              {/* Desktop Japa Chant Button */}
              <button 
                onClick={handleChant}
                className="relative flex items-center gap-1 bg-gradient-to-r from-amber-500/20 to-orange-500/20 hover:from-amber-500/35 hover:to-orange-500/35 border border-amber-500/30 rounded-full py-1.5 px-3 sm:px-4 text-[10px] sm:text-xs font-semibold text-amber-300 transition-all duration-300 hover:scale-[1.05] active:scale-[0.97] hover:shadow-lg hover:shadow-amber-500/5 cursor-pointer select-none"
                title={isHiRoute ? "राधे राधे जाप करें" : "Chant Radhe Radhe"}
              >
                <span className="text-[11px] sm:text-sm leading-none">📿</span>
                <span>{isHiRoute ? "जाप" : "Chants"}: <span className="font-bold text-white font-mono">{chantCount}</span></span>
              </button>

              {/* Standalone Settings Button */}
              <button 
                onClick={() => setIsSettingsOpen(true)}
                className="header-control-btn shrink-0"
                title="Settings"
              >
                <Settings size={18} className="w-[16px] h-[16px] sm:w-[18px] sm:h-[18px]" />
              </button>

              {user ? (
                <div className="header-profile-pill shrink-0">
                  {/* Avatar Section */}
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
                      {(user.displayName || user.email || 'V')[0]}
                    </span>
                  </div>
                  
                  {/* User Name Section */}
                  <div className="hidden sm:flex flex-col">
                    <span className="header-profile-label">Devotee</span>
                    <span className="header-profile-name">
                      {user.displayName || (user.email?.split('@')[0].match(/^[a-zA-Z]/) ? user.email?.split('@')[0] : 'Member')}
                    </span>
                  </div>

                  {/* Divider */}
                  <div className="header-profile-divider"></div>
                  
                  {/* Logout Button */}
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
              ) : (
                <Link to="/login" className="header-control-btn shrink-0" title="Devotee Sign In">
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

      {/* Floating Vertical Sidebar Dock */}
      {!isAuthPage && (
        <aside className="sidebar-dock-minimal animate-fade-in-left">
          <Link to="/" className={`dock-item-minimal ${isActive('/') ? 'active' : ''}`} title="Home">
            <Home size={22} />
            <span className="dock-tooltip-minimal">Home Sanctuary</span>
          </Link>
          <Link to="/content" className={`dock-item-minimal ${isActive('/content') ? 'active' : ''}`} title="All Content">
            <BookOpen size={22} />
            <span className="dock-tooltip-minimal">Sanctuary Library</span>
          </Link>
          <div className="w-8 h-[1px] bg-white/10 my-1"></div>
          <Link to="/category/shloka" className={`dock-item-minimal ${isCategoryActive('shloka') ? 'active' : ''}`} title="Shlokas">
            <Scroll size={22} />
            <span className="dock-tooltip-minimal">Sacred Shlokas</span>
          </Link>
          <Link to="/category/strotra" className={`dock-item-minimal ${isCategoryActive('strotra') ? 'active' : ''}`} title="Strotras">
            <Music size={22} />
            <span className="dock-tooltip-minimal">Devotional Strotras</span>
          </Link>
          <Link to="/category/poem" className={`dock-item-minimal ${isCategoryActive('poem') ? 'active' : ''}`} title="Poems">
            <FileText size={22} />
            <span className="dock-tooltip-minimal">Spiritual Poetry</span>
          </Link>
        </aside>
      )}

      {/* Mobile/Tablet Category Quick Links (sticky sub-bar, hidden on desktop) */}
      {!isAuthPage && (
        <div className="lg:hidden flex items-center gap-2 overflow-x-auto px-4 py-2 header-sub-bar border-b scrollbar-hide fixed top-[112px] md:top-[80px] left-0 right-0 z-[999] h-10">
          <Link to="/saints" className={`px-3 py-1 rounded-full text-[10px] font-medium transition-all ${isActive('/saints') ? 'bg-amber-500/20 text-amber-400 border border-amber-500/30' : 'bg-white/5 text-white/60 border border-white/5'}`}>
            {isHiRoute ? "सन्त" : "Saints"}
          </Link>
          <Link to="/books" className={`px-3 py-1 rounded-full text-[10px] font-medium transition-all ${isActive('/books') ? 'bg-amber-500/20 text-amber-400 border border-amber-500/30' : 'bg-white/5 text-white/60 border border-white/5'}`}>
            {isHiRoute ? "ग्रन्थ" : "Books"}
          </Link>
          <Link to="/ragas" className={`px-3 py-1 rounded-full text-[10px] font-medium transition-all ${isActive('/ragas') ? 'bg-amber-500/20 text-amber-400 border border-amber-500/30' : 'bg-white/5 text-white/60 border border-white/5'}`}>
            {isHiRoute ? "राग" : "Ragas"}
          </Link>
          <Link to="/category/shloka" className={`px-3 py-1 rounded-full text-[10px] font-medium transition-all ${isCategoryActive('shloka') ? 'bg-amber-500/20 text-amber-400 border border-amber-500/30' : 'bg-white/5 text-white/60 border border-white/5'}`}>
            {isHiRoute ? "श्लोक" : "Shlokas"}
          </Link>
          <Link to="/category/strotra" className={`px-3 py-1 rounded-full text-[10px] font-medium transition-all ${isCategoryActive('strotra') ? 'bg-amber-500/20 text-amber-400 border border-amber-500/30' : 'bg-white/5 text-white/60 border border-white/5'}`}>
            {isHiRoute ? "स्तोत्र" : "Strotras"}
          </Link>
          <Link to="/category/poem" className={`px-3 py-1 rounded-full text-[10px] font-medium transition-all ${isCategoryActive('poem') ? 'bg-amber-500/20 text-amber-400 border border-amber-500/30' : 'bg-white/5 text-white/60 border border-white/5'}`}>
            {isHiRoute ? "कविता" : "Poems"}
          </Link>
        </div>
      )}

      {/* Main Content Area */}
      <main className={`${isAuthPage ? 'pt-0 pl-0' : 'pl-0 md:pl-32 pt-[152px] md:pt-[120px] lg:pt-24 pb-12'}`}>
        <div className={`${isAuthPage ? 'w-full min-h-screen flex items-center justify-center' : 'max-w-7xl mx-auto px-6'}`}>
          {children}
        </div>
      </main>

      {/* Mobile Bottom Nav */}
      {!isAuthPage && (
        <div className="mobile-bottom-nav">
          <Link to="/" className={`mobile-nav-item ${isActive('/') ? 'active' : ''}`} title="Home">
            <Home size={24} />
          </Link>
          <Link to="/content" className={`mobile-nav-item ${isActive('/content') ? 'active' : ''}`} title="All Content">
            <BookOpen size={24} />
          </Link>
          <Link to="/category/shloka" className={`mobile-nav-item ${isCategoryActive('shloka') ? 'active' : ''}`} title="Shlokas">
            <Scroll size={24} />
          </Link>
          <Link to="/category/strotra" className={`mobile-nav-item ${isCategoryActive('strotra') ? 'active' : ''}`} title="Strotras">
            <Music size={24} />
          </Link>
        </div>
      )}
      {/* Global Audio Player */}
      <GlobalAudioPlayer />

      {/* Settings Modal */}
      <SettingsModal 
        isOpen={isSettingsOpen} 
        onClose={() => setIsSettingsOpen(false)} 
      />

      {/* Theme Onboarding Modal */}
      <ThemeOnboardingModal />
    </div>
  );
};

export default Layout;
