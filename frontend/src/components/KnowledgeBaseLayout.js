import React, { useState, useEffect, useRef, useCallback } from 'react';
import { Link, useLocation, useNavigate, Outlet } from 'react-router-dom';
import { useSettings } from '../contexts/SettingsContext';
import { categories, articles } from '../utils/kbArticles';
import { 
  BookOpen, Search, Settings, ChevronDown, ChevronUp, 
  ChevronRight, ChevronLeft, Type, Globe, Menu, X, 
  Award, Heart, Sparkles, MapPin
} from 'lucide-react';

const KnowledgeBaseLayout = () => {
  const { settings } = useSettings();
  const location = useLocation();
  const navigate = useNavigate();

  const isHindiRoute = location.pathname.startsWith('/hi');
  const isPookiz = settings.layoutMode === 'pookiz';

  // State
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [expandedCategories, setExpandedCategories] = useState({
    philosophy: true,
    traditions: true,
    concepts: true,
    guides: true
  });
  const [showSettings, setShowSettings] = useState(false);
  const [headings, setHeadings] = useState([]);
  const [activeHeadingId, setActiveHeadingId] = useState('');

  // Reading settings state (persisted in localStorage)
  const [kbSidebarWidth, setKbSidebarWidth] = useState(() => {
    const saved = localStorage.getItem('pookiz_kb_sidebar_width');
    return saved ? parseInt(saved, 10) : 256;
  });
  const [isKbResizing, setIsKbResizing] = useState(false);
  const resizeRef = useRef({ startX: 0, startWidth: 0 });

  const startKbResizing = useCallback((e) => {
    setIsKbResizing(true);
    resizeRef.current = {
      startX: e.clientX,
      startWidth: kbSidebarWidth
    };
    e.preventDefault();
  }, [kbSidebarWidth]);

  const stopKbResizing = useCallback(() => {
    setIsKbResizing(false);
    const sidebarEl = document.getElementById('kb-category-sidebar');
    if (sidebarEl) {
      const styleWidth = sidebarEl.style.getPropertyValue('--kb-sidebar-width');
      if (styleWidth) {
        const finalWidth = parseInt(styleWidth, 10);
        setKbSidebarWidth(finalWidth);
        localStorage.setItem('pookiz_kb_sidebar_width', String(finalWidth));
      }
    }
  }, []);

  const resizeKb = useCallback((e) => {
    if (isKbResizing) {
      const { startX, startWidth } = resizeRef.current;
      const deltaX = e.clientX - startX;
      const newWidth = Math.max(180, Math.min(380, startWidth + deltaX));
      
      const sidebarEl = document.getElementById('kb-category-sidebar');
      if (sidebarEl) {
        sidebarEl.style.setProperty('--kb-sidebar-width', `${newWidth}px`);
      }
    }
  }, [isKbResizing]);

  useEffect(() => {
    if (isKbResizing) {
      window.addEventListener('mousemove', resizeKb);
      window.addEventListener('mouseup', stopKbResizing);
    }
    return () => {
      window.removeEventListener('mousemove', resizeKb);
      window.removeEventListener('mouseup', stopKbResizing);
    };
  }, [isKbResizing, resizeKb, stopKbResizing]);
  const [fontSize, setFontSize] = useState(() => {
    return localStorage.getItem('vrindopnishad_read_font_size') || 'md'; // sm, md, lg, xl
  });
  const [fontFamily, setFontFamily] = useState(() => {
    return localStorage.getItem('vrindopnishad_read_font_family') || 'serif'; // serif, sans
  });
  const [lineHeight, setLineHeight] = useState(() => {
    return localStorage.getItem('vrindopnishad_read_line_height') || 'normal'; // cozy, normal, relaxed
  });

  const settingsRef = useRef(null);

  // Sync reading settings to local storage
  useEffect(() => {
    localStorage.setItem('vrindopnishad_read_font_size', fontSize);
  }, [fontSize]);

  useEffect(() => {
    localStorage.setItem('vrindopnishad_read_font_family', fontFamily);
  }, [fontFamily]);

  useEffect(() => {
    localStorage.setItem('vrindopnishad_read_line_height', lineHeight);
  }, [lineHeight]);

  // Click outside listener to close settings dropdown
  useEffect(() => {
    const handleClickOutside = (e) => {
      if (settingsRef.current && !settingsRef.current.contains(e.target)) {
        setShowSettings(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  // Extract headings from the article dynamically for table of contents
  useEffect(() => {
    const timer = setTimeout(() => {
      const h2Elements = document.querySelectorAll('.prose-content h2, article h2, section h2, .glass-card h2');
      const headingList = Array.from(h2Elements).map((el, index) => {
        if (!el.id) {
          el.id = `heading-${index}`;
        }
        return {
          id: el.id,
          text: el.innerText
        };
      });
      setHeadings(headingList);
      if (headingList.length > 0) {
        setActiveHeadingId(headingList[0].id);
      } else {
        setActiveHeadingId('');
      }
    }, 450); // 450ms delay for route fade-in & lazy load mount

    return () => clearTimeout(timer);
  }, [location.pathname]);

  // Scroll spy to highlight active heading on scroll
  useEffect(() => {
    if (headings.length === 0) return;

    const handleScroll = () => {
      const scrollPosition = window.scrollY + 160; // Offset for header/top spacing
      
      // Find the current heading in view
      let currentActive = headings[0].id;
      for (const heading of headings) {
        const el = document.getElementById(heading.id);
        if (el && el.getBoundingClientRect().top + window.scrollY <= scrollPosition) {
          currentActive = heading.id;
        }
      }
      setActiveHeadingId(currentActive);
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, [headings]);

  // Determine active article from path
  const getActiveSlug = () => {
    const parts = location.pathname.split('/');
    const lastPart = parts[parts.length - 1];
    // If it's a known slug, return it
    if (articles.some(art => art.slug === lastPart)) {
      return lastPart;
    }
    return null;
  };

  const activeSlug = getActiveSlug();
  const activeArticleIndex = articles.findIndex(art => art.slug === activeSlug);
  const currentArticle = activeArticleIndex !== -1 ? articles[activeArticleIndex] : null;

  // Toggle categories expansion
  const toggleCategory = (catId) => {
    setExpandedCategories(prev => ({
      ...prev,
      [catId]: !prev[catId]
    }));
  };

  // Switch languages but keep the current article open
  const handleLanguageSwitch = (targetHindi) => {
    const currentPath = location.pathname;
    let newPath = '';

    if (targetHindi) {
      if (!currentPath.startsWith('/hi')) {
        newPath = currentPath === '/' ? '/hi' : `/hi${currentPath}`;
      } else {
        newPath = currentPath;
      }
    } else {
      if (currentPath.startsWith('/hi')) {
        newPath = currentPath.substring(3) || '/';
      } else {
        newPath = currentPath;
      }
    }
    navigate(newPath);
  };

  // Find next/previous article
  const prevArticle = activeArticleIndex > 0 ? articles[activeArticleIndex - 1] : null;
  const nextArticle = activeArticleIndex !== -1 && activeArticleIndex < articles.length - 1 ? articles[activeArticleIndex + 1] : null;

  // Search filtering for sidebar
  const filteredArticles = articles.filter(art => {
    const title = isHindiRoute ? art.titleHi : art.titleEn;
    const desc = isHindiRoute ? art.descHi : art.descEn;
    return title.toLowerCase().includes(searchQuery.toLowerCase()) || 
           desc.toLowerCase().includes(searchQuery.toLowerCase()) ||
           art.slug.toLowerCase().includes(searchQuery.toLowerCase());
  });

  // Group filtered articles by category
  const groupedArticles = {
    philosophy: filteredArticles.filter(art => art.category === 'philosophy'),
    traditions: filteredArticles.filter(art => art.category === 'traditions'),
    concepts: filteredArticles.filter(art => art.category === 'concepts'),
    guides: filteredArticles.filter(art => art.category === 'guides')
  };

  const getCategoryLabel = (catId) => {
    const cat = categories.find(c => c.id === catId);
    return isHindiRoute ? cat?.labelHi : cat?.labelEn;
  };

  const getCategoryIcon = (catId) => {
    switch (catId) {
      case 'philosophy': return <Award size={14} className="text-amber-400 shrink-0" />;
      case 'traditions': return <Heart size={14} className="text-rose-400 shrink-0" />;
      case 'concepts': return <Sparkles size={14} className="text-purple-400 shrink-0" />;
      case 'guides': return <MapPin size={14} className="text-emerald-400 shrink-0" />;
      default: return <BookOpen size={14} className="text-blue-400 shrink-0" />;
    }
  };

  // CSS classes mapped dynamically based on reading customizer
  const getReadingClasses = () => {
    let classes = '';
    
    // Font family
    if (fontFamily === 'serif') {
      classes += ' font-serif ';
    } else {
      classes += ' font-sans ';
    }

    // Font size
    if (fontSize === 'sm') {
      classes += ' text-xs md:text-sm ';
    } else if (fontSize === 'md') {
      classes += ' text-sm md:text-base ';
    } else if (fontSize === 'lg') {
      classes += ' text-base md:text-lg ';
    } else if (fontSize === 'xl') {
      classes += ' text-lg md:text-xl ';
    }

    // Line height
    if (lineHeight === 'cozy') {
      classes += ' leading-snug ';
    } else if (lineHeight === 'normal') {
      classes += ' leading-relaxed ';
    } else if (lineHeight === 'relaxed') {
      classes += ' leading-loose ';
    }

    return classes;
  };

  // Theme-based layout wrapper classes
  const panelBg = isPookiz ? 'bg-[#121215] border-white/5 text-[#f4f4f5]' : 'bg-black/30 backdrop-blur-md border-white/10 text-white';
  const sidebarBg = isPookiz ? 'bg-[#09090b] border-white/5' : 'bg-[#000]/10 backdrop-blur-lg border-white/10';
  const activeLinkStyle = isPookiz 
    ? 'bg-purple-500/10 text-purple-300 border-l-2 border-purple-500 font-medium' 
    : 'bg-amber-400/10 text-amber-300 border-l-2 border-amber-400 font-medium';
  const normalLinkStyle = 'text-zinc-400 hover:text-zinc-200 hover:bg-white/[0.02] border-l border-white/5';

  return (
    <div className={`flex flex-col lg:flex-row ${isPookiz ? 'gap-4' : 'gap-6'} w-full ${isPookiz ? 'min-h-[calc(100vh-80px)]' : 'min-h-[70vh]'} animate-fade-in`}>
      {/* Mobile Toggle Button */}
      <div className="lg:hidden flex items-center justify-between p-3 bg-white/[0.02] border border-white/5 rounded-2xl">
        <button 
          onClick={() => setSidebarOpen(true)}
          className="flex items-center gap-2 text-xs font-semibold text-zinc-300 hover:text-white"
        >
          <Menu size={16} />
          {isHindiRoute ? 'ज्ञान कोष अनुक्रमणिका' : 'Wiki Directory'}
        </button>

        <div className="flex items-center gap-2">
          {/* Quick Lang Switch */}
          <button 
            onClick={() => handleLanguageSwitch(!isHindiRoute)}
            className="flex items-center gap-1.5 px-3 py-1 rounded-xl bg-white/[0.04] border border-white/10 text-[10px] font-bold tracking-wide uppercase hover:bg-white/10 transition-colors"
          >
            <Globe size={11} />
            <span>{isHindiRoute ? 'English' : 'हिंदी'}</span>
          </button>
        </div>
      </div>

      <aside 
        id="kb-category-sidebar"
        style={{ '--kb-sidebar-width': `${kbSidebarWidth}px` }}
        className={`${
          isPookiz 
            ? `fixed inset-y-0 left-0 w-80 max-w-[85vw] ${sidebarBg} z-[500] lg:translate-x-0 lg:w-[var(--kb-sidebar-width)] lg:z-10 lg:bg-[#121215]/40 lg:border lg:border-white/5 lg:rounded-2xl lg:sticky lg:top-4 lg:h-[calc(100vh-100px)] flex flex-col relative`
            : `fixed inset-y-0 left-0 w-80 max-w-[85vw] ${sidebarBg} border-r z-[500] lg:sticky lg:top-24 lg:translate-x-0 lg:w-[var(--kb-sidebar-width)] lg:z-10 lg:bg-transparent lg:border-r-0 lg:border-none flex flex-col h-screen lg:h-[calc(100vh-140px)] relative`
        } transform ${isKbResizing ? 'transition-none !transition-none' : 'transition-transform duration-300 lg:transition-none lg:!transition-none'} ${
          sidebarOpen ? 'translate-x-0' : '-translate-x-full lg:block'
        }`}
      >
        <div className={`w-full h-full flex flex-col ${isPookiz ? 'p-5 lg:p-3.5 overflow-y-auto custom-scrollbar' : 'p-5 lg:p-0'}`}>
          <div className="flex items-center justify-between lg:hidden mb-6">
            <span className="font-bold text-sm text-white uppercase tracking-wider flex items-center gap-2">
              <BookOpen size={16} className="text-purple-400" />
              {isHindiRoute ? 'ज्ञान कोष' : 'Wiki Directory'}
            </span>
            <button onClick={() => setSidebarOpen(false)} className="text-zinc-400 hover:text-white p-1 hover:bg-white/5 rounded-lg">
              <X size={20} />
            </button>
          </div>

          {/* Search Field */}
          <div className="relative mb-5 shrink-0">
            <Search size={14} className="absolute left-3 top-3 text-zinc-500" />
            <input 
              type="text"
              placeholder={isHindiRoute ? "ज्ञान कोष में खोजें..." : "Filter articles..."}
              className="w-full bg-white/[0.03] border border-white/5 rounded-xl py-2 pl-9 pr-4 text-xs placeholder:text-zinc-600 focus:outline-none focus:border-purple-500/50 text-white font-light"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>

          {/* Tree List */}
          <div className="flex-1 overflow-y-auto space-y-4 pr-1 scrollbar-thin">
            {/* Main Link back to Hub */}
            <Link 
              to={isHindiRoute ? "/hi/knowledge-base" : "/knowledge-base"}
              onClick={() => setSidebarOpen(false)}
              className={`flex items-center gap-2 px-3 py-2 rounded-xl text-xs font-semibold tracking-wide transition-all ${
                !activeSlug 
                  ? isPookiz ? 'bg-purple-500/10 text-purple-300 font-bold' : 'bg-amber-400/10 text-amber-300 font-bold'
                  : 'text-zinc-400 hover:text-white hover:bg-white/5'
              }`}
            >
              <BookOpen size={14} />
              <span>{isHindiRoute ? 'ज्ञान कोष मुखपृष्ठ' : 'Knowledge Base Home'}</span>
            </Link>

            <div className="h-[1px] bg-white/5 my-2"></div>

            {Object.keys(groupedArticles).map(catId => {
              const catArticles = groupedArticles[catId];
              if (catArticles.length === 0) return null;
              const isExpanded = expandedCategories[catId];

              return (
                <div key={catId} className="space-y-1">
                  <button 
                    onClick={() => toggleCategory(catId)}
                    className="w-full flex items-center justify-between py-1.5 px-2 hover:bg-white/[0.02] rounded-lg transition-colors text-left"
                  >
                    <span className="flex items-center gap-2 text-[10px] font-bold uppercase tracking-wider text-zinc-400">
                      {getCategoryIcon(catId)}
                      <span>{getCategoryLabel(catId)}</span>
                    </span>
                    {isExpanded ? <ChevronUp size={12} className="text-zinc-500" /> : <ChevronDown size={12} className="text-zinc-500" />}
                  </button>

                  {isExpanded && (
                    <div className="pl-3.5 space-y-0.5">
                      {catArticles.map(art => {
                        const isActive = art.slug === activeSlug;
                        const title = isHindiRoute ? art.titleHi : art.titleEn;
                        return (
                          <Link
                            key={art.slug}
                            to={isHindiRoute ? `/hi/${art.slug}` : `/${art.slug}`}
                            onClick={() => setSidebarOpen(false)}
                            className={`block py-1.5 pl-3 pr-2 text-xs transition-all ${
                              isActive ? activeLinkStyle : normalLinkStyle
                            }`}
                          >
                            <div className="truncate">{title}</div>
                          </Link>
                        );
                      })}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </div>

        {/* Resize handle */}
        <div 
          onMouseDown={startKbResizing}
          className="hidden lg:block absolute top-0 -right-1 bottom-0 w-3 cursor-col-resize z-50 group"
        >
          <div className={`w-0.5 h-full mx-auto transition-colors duration-200 ${
            isKbResizing ? 'bg-purple-500/80' : 'bg-transparent group-hover:bg-purple-500/40'
          }`} />
        </div>
      </aside>

      {/* Screen Backdrop for mobile sidebar */}
      {sidebarOpen && (
        <div 
          onClick={() => setSidebarOpen(false)}
          className="fixed inset-0 bg-black/80 backdrop-blur-sm z-[490] lg:hidden"
        ></div>
      )}

      {/* Main Content Pane + Right Sidebar Container */}
      <div className={`flex-1 flex flex-col xl:flex-row ${isPookiz ? 'gap-4' : 'gap-6'} min-w-0`}>
        {/* Main Content Pane */}
        <div className="flex-1 flex flex-col min-w-0">
          {/* Controls Toolbar */}
          <div className={`flex items-center justify-between ${isPookiz ? 'p-2.5 md:p-3 rounded-t-2xl' : 'p-3 md:p-4 rounded-t-3xl'} border-t border-x border-white/5 ${panelBg} gap-4`}>
            {/* Left: Breadcrumbs */}
            <div className="flex items-center gap-1.5 text-[10px] md:text-xs text-zinc-500 truncate">
              <Link to={isHindiRoute ? "/hi" : "/"} className="hover:text-white">
                {isHindiRoute ? "डैशबोर्ड" : "Dashboard"}
              </Link>
              <ChevronRight size={10} />
              <Link to={isHindiRoute ? "/hi/knowledge-base" : "/knowledge-base"} className="hover:text-white">
                {isHindiRoute ? "ज्ञान कोष" : "Knowledge Base"}
              </Link>
              {currentArticle && (
                <>
                  <ChevronRight size={10} />
                  <span className="text-zinc-400 font-medium truncate">
                    {isHindiRoute ? currentArticle.titleHi : currentArticle.titleEn}
                  </span>
                </>
              )}
            </div>

            {/* Right: Settings, Lang Toggle */}
            <div className="flex items-center gap-2 shrink-0">
              {/* Lang switcher */}
              <div className="flex items-center bg-white/[0.02] border border-white/5 rounded-xl p-0.5">
                <button 
                  onClick={() => handleLanguageSwitch(false)}
                  className={`px-2 py-1 rounded-lg text-[10px] font-bold tracking-wide uppercase transition-all ${
                    !isHindiRoute 
                      ? isPookiz ? 'bg-purple-500/20 text-purple-300' : 'bg-amber-400/20 text-amber-300'
                      : 'text-zinc-500 hover:text-zinc-300'
                  }`}
                >
                  EN
                </button>
                <button 
                  onClick={() => handleLanguageSwitch(true)}
                  className={`px-2 py-1 rounded-lg text-[10px] font-bold tracking-wide uppercase transition-all ${
                    isHindiRoute 
                      ? isPookiz ? 'bg-purple-500/20 text-purple-300' : 'bg-amber-400/20 text-amber-300'
                      : 'text-zinc-500 hover:text-zinc-300'
                  }`}
                >
                  हिन्दी
                </button>
              </div>

              {/* Typography Customizer Dropdown */}
              <div className="relative" ref={settingsRef}>
                <button 
                  onClick={() => setShowSettings(!showSettings)}
                  className="p-2 rounded-xl bg-white/[0.02] hover:bg-white/[0.06] border border-white/5 text-zinc-400 hover:text-white transition-colors"
                  title="Reading Settings"
                >
                  <Type size={14} />
                </button>

                {showSettings && (
                  <div className="absolute right-0 mt-2 w-56 rounded-2xl bg-[#121215] border border-white/10 shadow-2xl p-4 z-[999] animate-fade-in text-left">
                    <h4 className="text-xs font-bold text-white uppercase tracking-wider mb-3 flex items-center gap-1.5">
                      <Settings size={12} className="text-purple-400" />
                      <span>Reading Layout</span>
                    </h4>

                    {/* Font Family Option */}
                    <div className="space-y-1.5 mb-4">
                      <span className="text-[10px] text-zinc-500 uppercase font-bold tracking-wide block">Typography</span>
                      <div className="grid grid-cols-2 gap-1.5">
                        <button 
                          onClick={() => setFontFamily('serif')}
                          className={`py-1.5 rounded-lg text-xs font-serif border transition-all ${
                            fontFamily === 'serif' 
                              ? 'border-purple-500/50 bg-purple-500/10 text-purple-300' 
                              : 'border-white/5 bg-white/[0.02] text-zinc-400 hover:text-white'
                          }`}
                        >
                          Scripture (Serif)
                        </button>
                        <button 
                          onClick={() => setFontFamily('sans')}
                          className={`py-1.5 rounded-lg text-xs font-sans border transition-all ${
                            fontFamily === 'sans' 
                              ? 'border-purple-500/50 bg-purple-500/10 text-purple-300' 
                              : 'border-white/5 bg-white/[0.02] text-zinc-400 hover:text-white'
                          }`}
                        >
                          Modern (Sans)
                        </button>
                      </div>
                    </div>

                    {/* Font Size Option */}
                    <div className="space-y-1.5 mb-4">
                      <span className="text-[10px] text-zinc-500 uppercase font-bold tracking-wide block">Text Scale</span>
                      <div className="grid grid-cols-4 gap-1">
                        {['sm', 'md', 'lg', 'xl'].map((sz) => (
                          <button 
                            key={sz}
                            onClick={() => setFontSize(sz)}
                            className={`py-1.5 rounded-lg text-xs border uppercase tracking-wider transition-all ${
                              fontSize === sz 
                                ? 'border-purple-500/50 bg-purple-500/10 text-purple-300' 
                                : 'border-white/5 bg-white/[0.02] text-zinc-400 hover:text-white'
                            }`}
                          >
                            {sz}
                          </button>
                        ))}
                      </div>
                    </div>

                    {/* Line Spacing Option */}
                    <div className="space-y-1.5">
                      <span className="text-[10px] text-zinc-500 uppercase font-bold tracking-wide block">Line Spacing</span>
                      <div className="grid grid-cols-3 gap-1">
                        {['cozy', 'normal', 'relaxed'].map((space) => (
                          <button 
                            key={space}
                            onClick={() => setLineHeight(space)}
                            className={`py-1 rounded-lg text-[10px] border capitalize transition-all ${
                              lineHeight === space 
                                ? 'border-purple-500/50 bg-purple-500/10 text-purple-300' 
                                : 'border-white/5 bg-white/[0.02] text-zinc-400 hover:text-white'
                            }`}
                          >
                            {space}
                          </button>
                        ))}
                      </div>
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Content Pane Core */}
          <div className={`flex-1 ${isPookiz ? 'p-4 md:p-5 rounded-b-2xl' : 'p-5 md:p-8 rounded-b-3xl'} border-x border-b border-white/5 ${panelBg} shadow-xl`}>
            {/* Custom scoped container with reader choices applied */}
            <div className={getReadingClasses()}>
              <Outlet />
            </div>

            {/* Sequential Next/Prev footer */}
            {currentArticle && (
              <div className="mt-12 pt-6 border-t border-white/5 flex items-center justify-between gap-4">
                {prevArticle ? (
                  <Link 
                    to={isHindiRoute ? `/hi/${prevArticle.slug}` : `/${prevArticle.slug}`}
                    className="flex items-center gap-2 text-zinc-400 hover:text-white text-xs md:text-sm font-medium transition-colors"
                  >
                    <ChevronLeft size={16} />
                    <div className="text-left">
                      <span className="text-[10px] text-zinc-600 uppercase block tracking-wider font-bold">Previous</span>
                      <span>{isHindiRoute ? prevArticle.titleHi : prevArticle.titleEn}</span>
                    </div>
                  </Link>
                ) : (
                  <div />
                )}

                {nextArticle ? (
                  <Link 
                    to={isHindiRoute ? `/hi/${nextArticle.slug}` : `/${nextArticle.slug}`}
                    className="flex items-center gap-2 text-zinc-400 hover:text-white text-xs md:text-sm font-medium transition-colors text-right"
                  >
                    <div className="text-right">
                      <span className="text-[10px] text-zinc-600 uppercase block tracking-wider font-bold">Next</span>
                      <span>{isHindiRoute ? nextArticle.titleHi : nextArticle.titleEn}</span>
                    </div>
                    <ChevronRight size={16} />
                  </Link>
                ) : (
                  <div />
                )}
              </div>
            )}
          </div>
        </div>

        {/* Right Sidebar: Table of Contents (visible only on desktop wide screen) */}
        {currentArticle && headings.length > 0 && (
          <aside className="hidden xl:block w-56 shrink-0 sticky top-[100px] self-start space-y-4">
            <div className={`p-4 rounded-2xl border border-white/5 ${isPookiz ? 'bg-[#121215]' : 'bg-black/20 backdrop-blur-md'}`}>
              <h4 className="text-[10px] font-bold text-zinc-500 uppercase tracking-widest mb-3">
                {isHindiRoute ? 'इस पृष्ठ पर' : 'On This Page'}
              </h4>
              <nav className="space-y-2">
                {headings.map((h) => (
                  <a 
                    key={h.id}
                    href={`#${h.id}`}
                    onClick={(e) => {
                      e.preventDefault();
                      const el = document.getElementById(h.id);
                      if (el) {
                        const yOffset = -140; // Offset for sticky header
                        const y = el.getBoundingClientRect().top + window.pageYOffset + yOffset;
                        window.scrollTo({ top: y, behavior: 'smooth' });
                        setActiveHeadingId(h.id);
                      }
                    }}
                    className={`block text-[11px] leading-relaxed transition-all truncate text-left ${
                      activeHeadingId === h.id 
                        ? isPookiz ? 'text-purple-400 font-bold translate-x-1' : 'text-amber-400 font-bold translate-x-1'
                        : 'text-zinc-500 hover:text-zinc-300'
                    }`}
                  >
                    {h.text}
                  </a>
                ))}
              </nav>
            </div>
          </aside>
        )}
      </div>
    </div>
  );
};

export default KnowledgeBaseLayout;
