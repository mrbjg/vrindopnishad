'use client';

import React, { useState, useEffect, useRef, useCallback } from 'react';
import { Link, useLocation, useNavigate, Outlet } from 'react-router-dom';
import { useSettings, isLightTheme } from '../contexts/SettingsContext';
import { categories, articles } from '../utils/kbArticles';
import { 
  BookOpen, Search, Settings, ChevronDown, ChevronUp, 
  ChevronRight, ChevronLeft, Type, Globe, Menu, X, 
  Award, Heart, Sparkles, MapPin
} from 'lucide-react';

const KnowledgeBaseLayout = ({ children }) => {
  const { settings } = useSettings();
  const location = useLocation();
  const navigate = useNavigate();

  const isHindiRoute = location.pathname.startsWith('/hi');
  const isPookiz = settings.layoutMode === 'pookiz';

  
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

  
  const [kbSidebarWidth, setKbSidebarWidth] = useState(() => {
    if (typeof window !== 'undefined') {
      const saved = localStorage.getItem('pookiz_kb_sidebar_width');
      const width = saved ? parseInt(saved, 10) : 360;
      return width < 320 ? 360 : width;
    }
    return 360;
  });
  const [isKbResizing, setIsKbResizing] = useState(false);
  const resizeRef = useRef({ startX: 0, startWidth: 0 });
  const contentScrollRef = useRef(null);

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
      const newWidth = Math.max(300, Math.min(500, startWidth + deltaX));
      
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
    if (typeof window !== 'undefined') {
      return localStorage.getItem('vrindopnishad_read_font_size') || 'md'; 
    }
    return 'md';
  });
  const [fontFamily, setFontFamily] = useState(() => {
    if (typeof window !== 'undefined') {
      return localStorage.getItem('vrindopnishad_read_font_family') || 'serif'; 
    }
    return 'serif';
  });
  const [lineHeight, setLineHeight] = useState(() => {
    if (typeof window !== 'undefined') {
      return localStorage.getItem('vrindopnishad_read_line_height') || 'normal'; 
    }
    return 'normal';
  });

  const settingsRef = useRef(null);

  
  useEffect(() => {
    localStorage.setItem('vrindopnishad_read_font_size', fontSize);
  }, [fontSize]);

  useEffect(() => {
    localStorage.setItem('vrindopnishad_read_font_family', fontFamily);
  }, [fontFamily]);

  useEffect(() => {
    localStorage.setItem('vrindopnishad_read_line_height', lineHeight);
  }, [lineHeight]);

  
  useEffect(() => {
    const handleClickOutside = (e) => {
      if (settingsRef.current && !settingsRef.current.contains(e.target)) {
        setShowSettings(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  
  useEffect(() => {
    window.googleTranslateElementInit = () => {
      new window.google.translate.TranslateElement({
        pageLanguage: 'en',
        includedLanguages: 'en,hi',
        layout: window.google.translate.TranslateElement.InlineLayout.SIMPLE,
        autoDisplay: false
      }, 'google_translate_element');
    };

    if (!document.getElementById('google-translate-script')) {
      const script = document.createElement('script');
      script.id = 'google-translate-script';
      script.src = '//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit';
      script.async = true;
      document.body.appendChild(script);
    }
  }, []);

  
  useEffect(() => {
    const targetLang = isHindiRoute ? 'hi' : 'en';
    
    const setGoogTransCookie = (lang) => {
      const domain = window.location.hostname;
      document.cookie = `googtrans=/en/${lang}; path=/;`;
      document.cookie = `googtrans=/en/${lang}; path=/; domain=.${domain};`;
      document.cookie = `googtrans=/en/${lang}; path=/; domain=${domain};`;
    };

    setGoogTransCookie(targetLang);

    const triggerTranslation = () => {
      const selectEl = document.querySelector('.goog-te-combo');
      if (selectEl) {
        if (selectEl.value !== targetLang) {
          selectEl.value = targetLang;
          selectEl.dispatchEvent(new Event('change'));
        }
        return true;
      }
      return false;
    };

    if (!triggerTranslation()) {
      const interval = setInterval(() => {
        if (triggerTranslation()) {
          clearInterval(interval);
        }
      }, 150);
      
      const timeout = setTimeout(() => {
        clearInterval(interval);
      }, 5000);
      
      return () => {
        clearInterval(interval);
        clearTimeout(timeout);
      };
    }
  }, [isHindiRoute]);

  
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
    }, 450); 

    return () => clearTimeout(timer);
  }, [location.pathname]);

  
  useEffect(() => {
    
    const isMobile = window.matchMedia('(max-width: 1023px)').matches || 
                     ('ontouchstart' in window) || 
                     (navigator.maxTouchPoints > 0);
    if (isMobile) return;
    if (headings.length === 0) return;

    let ticking = false;

    const handleScroll = () => {
      if (!ticking) {
        window.requestAnimationFrame(() => {
          const scrollThreshold = 160; 
          let currentActive = headings[0].id;
          
          for (const heading of headings) {
            const el = document.getElementById(heading.id);
            if (el) {
              const rect = el.getBoundingClientRect();
              if (rect.top <= scrollThreshold) {
                currentActive = heading.id;
              }
            }
          }
          
          setActiveHeadingId(prev => {
            if (prev !== currentActive) {
              return currentActive;
            }
            return prev;
          });
          
          ticking = false;
        });
        ticking = true;
      }
    };

    const container = contentScrollRef.current;
    if (container) {
      container.addEventListener('scroll', handleScroll, { passive: true });
    }
    window.addEventListener('scroll', handleScroll, { passive: true });

    return () => {
      if (container) {
        container.removeEventListener('scroll', handleScroll);
      }
      window.removeEventListener('scroll', handleScroll);
    };
  }, [headings]);

  
  const getActiveSlug = () => {
    const parts = location.pathname.split('/');
    const lastPart = parts[parts.length - 1];
    
    if (articles.some(art => art.slug === lastPart)) {
      return lastPart;
    }
    return null;
  };

  const activeSlug = getActiveSlug();
  const activeArticleIndex = articles.findIndex(art => art.slug === activeSlug);
  const currentArticle = activeArticleIndex !== -1 ? articles[activeArticleIndex] : null;

  
  const toggleCategory = (catId) => {
    setExpandedCategories(prev => ({
      ...prev,
      [catId]: !prev[catId]
    }));
  };

  
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

  
  const prevArticle = activeArticleIndex > 0 ? articles[activeArticleIndex - 1] : null;
  const nextArticle = activeArticleIndex !== -1 && activeArticleIndex < articles.length - 1 ? articles[activeArticleIndex + 1] : null;

  
  const filteredArticles = articles.filter(art => {
    const title = isHindiRoute ? art.titleHi : art.titleEn;
    const desc = isHindiRoute ? art.descHi : art.descEn;
    return title.toLowerCase().includes(searchQuery.toLowerCase()) || 
           desc.toLowerCase().includes(searchQuery.toLowerCase()) ||
           art.slug.toLowerCase().includes(searchQuery.toLowerCase());
  });

  
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

  
  const getReadingClasses = () => {
    let classes = '';
    
    
    if (fontFamily === 'serif') {
      classes += ' font-serif ';
    } else {
      classes += ' font-sans ';
    }

    
    if (fontSize === 'sm') {
      classes += ' text-xs md:text-sm ';
    } else if (fontSize === 'md') {
      classes += ' text-sm md:text-base ';
    } else if (fontSize === 'lg') {
      classes += ' text-base md:text-lg ';
    } else if (fontSize === 'xl') {
      classes += ' text-lg md:text-xl ';
    }

    
    if (lineHeight === 'cozy') {
      classes += ' leading-snug ';
    } else if (lineHeight === 'normal') {
      classes += ' leading-relaxed ';
    } else if (lineHeight === 'relaxed') {
      classes += ' leading-loose ';
    }

    return classes;
  };

  
  const isLight = isLightTheme(settings.theme);

  const panelBg = isPookiz 
    ? (isLight ? 'bg-[#fbf9f4] border-black/10 text-[#1c1917]' : 'bg-[#121215] border-white/5 text-[#f4f4f5]') 
    : 'bg-[var(--glass-bg)] backdrop-blur-xl border-[var(--glass-border)] text-[var(--text-color)]';
    
  const sidebarBg = isPookiz 
    ? (isLight ? 'bg-[#f5f2eb] border-black/10' : 'bg-[#09090b] border-white/5') 
    : 'bg-[var(--glass-bg)] backdrop-blur-xl border-[var(--glass-border)]';

  const activeLinkStyle = isPookiz 
    ? (isLight ? 'bg-purple-500/10 text-purple-700 border-l-2 border-purple-500 font-semibold' : 'bg-purple-500/10 text-purple-300 border-l-2 border-purple-500 font-medium')
    : 'bg-[rgba(var(--primary-rgb),0.1)] text-[color:var(--primary-color)] border-l-2 border-[color:var(--primary-color)] font-bold shadow-[inset_4px_0_12px_rgba(var(--primary-rgb),0.03)]';
    
  const normalLinkStyle = isPookiz
    ? (isLight ? 'text-stone-500 hover:text-stone-900 hover:bg-stone-100/50' : 'text-zinc-400 hover:text-white hover:bg-white/5')
    : 'text-[var(--text-color)]/60 hover:text-[var(--text-color)] hover:bg-[var(--text-color)]/[0.03] border-l border-[var(--glass-border)]';

  const getBtnClass = (active) => {
    if (active) {
      return isPookiz
        ? (isLight ? 'border-purple-500 bg-purple-50 text-purple-700 font-bold' : 'border-purple-500/50 bg-purple-500/10 text-purple-300 font-medium')
        : 'border-[color:var(--primary-color)] bg-[rgba(var(--primary-rgb),0.08)] text-[color:var(--primary-color)] font-semibold';
    } else {
      return isPookiz
        ? (isLight ? 'border-stone-200 bg-stone-50 text-stone-500 hover:text-stone-900 hover:bg-stone-100' : 'border-white/5 bg-white/[0.02] text-zinc-400 hover:text-white')
        : 'border-[var(--glass-border)] bg-[var(--text-color)]/[0.02] text-[var(--text-color)]/60 hover:text-[var(--text-color)] hover:bg-[var(--text-color)]/[0.05]';
    }
  };

  return (
    <div className={`flex flex-col lg:flex-row ${isPookiz ? 'gap-4' : 'gap-6'} w-full ${isPookiz ? 'min-h-[calc(100vh-80px)]' : 'lg:h-full lg:overflow-hidden'} animate-fade-in`}>
      
      <div id="google_translate_element" style={{ display: 'none' }}></div>
      
      
      <div className="lg:hidden flex items-center justify-between p-3 bg-[var(--glass-bg)] border border-[var(--glass-border)] rounded-2xl">
        <button 
          onClick={() => setSidebarOpen(true)}
          className="flex items-center gap-2 text-xs font-semibold text-[var(--text-color)]/80 hover:text-[var(--text-color)]"
        >
          <Menu size={16} />
          {isHindiRoute ? 'ज्ञान कोष अनुक्रमणिका' : 'Wiki Directory'}
        </button>

        <div className="flex items-center gap-2">
          
          <button 
            onClick={() => handleLanguageSwitch(!isHindiRoute)}
            className="flex items-center gap-1.5 px-3 py-1 rounded-xl bg-[var(--text-color)]/[0.04] border border-[var(--glass-border)] text-[10px] font-bold tracking-wide uppercase hover:bg-[var(--text-color)]/[0.08] text-[var(--text-color)]/80 hover:text-[var(--text-color)] transition-colors"
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
            ? `fixed inset-y-0 left-0 w-80 max-w-[85vw] ${sidebarBg} z-[500] lg:translate-x-0 lg:w-[var(--kb-sidebar-width)] lg:z-10 ${isLight ? 'lg:bg-[#f5f2eb]/40' : 'lg:bg-[#121215]/40'} lg:border lg:border-white/5 lg:rounded-2xl lg:sticky lg:top-4 lg:h-[calc(100vh-100px)] flex flex-col`
            : `fixed inset-y-0 left-0 w-80 max-w-[85vw] ${sidebarBg} border-r z-[500] lg:relative lg:translate-x-0 lg:w-[var(--kb-sidebar-width)] lg:z-10 lg:bg-[var(--glass-bg)] lg:backdrop-blur-xl lg:border lg:border-[var(--glass-border)] lg:rounded-2xl flex flex-col h-screen lg:h-full`
        } transform ${isKbResizing ? 'transition-none !transition-none' : 'transition-transform duration-300 lg:transition-none lg:!transition-none'} ${
          sidebarOpen ? 'translate-x-0' : '-translate-x-full lg:block'
        }`}
      >
        <div className={`w-full h-full flex flex-col lg:rounded-2xl ${isPookiz ? 'p-5 lg:p-3.5 overflow-y-auto custom-scrollbar' : 'p-5 lg:p-4 lg:pr-2 lg:overflow-hidden'}`}>
          <div className="flex items-center justify-between lg:hidden mb-6">
            <span className="font-bold text-sm text-[var(--text-color)] uppercase tracking-wider flex items-center gap-2">
              <BookOpen size={16} className="text-[color:var(--primary-color)]" />
              {isHindiRoute ? 'ज्ञान कोष' : 'Wiki Directory'}
            </span>
            <button onClick={() => setSidebarOpen(false)} className="text-[var(--text-color)]/60 hover:text-[var(--text-color)] p-1 hover:bg-[var(--text-color)]/5 rounded-lg">
              <X size={20} />
            </button>
          </div>

          
          <div className="relative mb-5 shrink-0">
            <Search size={14} className="absolute left-3 top-3 text-[var(--text-color)]/40" />
            <input 
              type="text"
              placeholder={isHindiRoute ? "ज्ञान कोष में खोजें..." : "Filter articles..."}
              className="w-full bg-[var(--text-color)]/[0.03] border border-[var(--glass-border)] rounded-xl py-2 pl-9 pr-4 text-xs placeholder:text-[var(--text-color)]/40 focus:outline-none focus:border-[rgba(var(--primary-rgb),0.5)] text-[var(--text-color)] font-light"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>

          
          <div className="flex-1 overflow-y-auto space-y-4 pr-1 scrollbar-thin">
            
            <Link 
              to={isHindiRoute ? "/hi/knowledge-base" : "/knowledge-base"}
              onClick={() => setSidebarOpen(false)}
              className={`flex items-center gap-2 px-3 py-2 rounded-xl text-xs font-semibold tracking-wide transition-all ${
                !activeSlug 
                  ? 'bg-[rgba(var(--primary-rgb),0.12)] text-[color:var(--primary-color)] font-bold'
                  : 'text-[var(--text-color)]/60 hover:text-[var(--text-color)] hover:bg-[var(--text-color)]/[0.04]'
              }`}
            >
              <BookOpen size={14} />
              <span>{isHindiRoute ? 'ज्ञान कोष मुखपृष्ठ' : 'Knowledge Base Home'}</span>
            </Link>

            <div className="h-[1px] bg-[var(--glass-border)] my-2"></div>

            {Object.keys(groupedArticles).map(catId => {
              const catArticles = groupedArticles[catId];
              if (catArticles.length === 0) return null;
              const isExpanded = expandedCategories[catId];

              return (
                <div key={catId} className="space-y-1">
                  <button 
                    onClick={() => toggleCategory(catId)}
                    className="w-full flex items-center justify-between py-1.5 px-2 hover:bg-[var(--text-color)]/[0.03] rounded-lg transition-colors text-left"
                  >
                    <span className="flex items-center gap-2 text-[10px] font-bold uppercase tracking-wider text-[var(--text-color)]/60">
                      {getCategoryIcon(catId)}
                      <span>{getCategoryLabel(catId)}</span>
                    </span>
                    {isExpanded ? <ChevronUp size={12} className="text-[var(--text-color)]/50" /> : <ChevronDown size={12} className="text-[var(--text-color)]/50" />}
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

        
        <div 
          onMouseDown={startKbResizing}
          className="hidden lg:block absolute top-0 -right-1 bottom-0 w-3 cursor-col-resize z-50 group"
        >
          <div className={`w-0.5 h-full mx-auto transition-colors duration-200 ${
            isKbResizing ? 'bg-[color:var(--primary-color)]' : 'bg-transparent group-hover:bg-[color:var(--primary-color)]/40'
          }`} />
        </div>
      </aside>

      
      {sidebarOpen && (
        <div 
          onClick={() => setSidebarOpen(false)}
          className="fixed inset-0 bg-black/80 backdrop-blur-sm z-[490] lg:hidden"
        ></div>
      )}

      
      <div className={`flex-1 flex flex-col xl:flex-row ${isPookiz ? 'gap-4' : 'gap-6'} min-w-0 lg:h-full lg:overflow-hidden`}>
        
        <div className="flex-1 flex flex-col min-w-0 lg:h-full lg:overflow-hidden">
          
          <div className={`relative z-10 flex items-center justify-between p-3 md:p-4 rounded-none lg:rounded-t-3xl border-b border-[var(--glass-border)] lg:border-t lg:border-x lg:border-b-0 ${
            isPookiz 
              ? (isLight 
                  ? 'bg-transparent border-black/10 lg:bg-[#fbf9f4] lg:border-black/10 text-[#1c1917]' 
                  : 'bg-transparent border-white/5 lg:bg-[#121215] lg:border-white/5 text-[#f4f4f5]') 
              : 'bg-transparent border-[var(--glass-border)] lg:bg-[var(--glass-bg)] lg:border-[var(--glass-border)] text-[var(--text-color)] backdrop-blur-none lg:backdrop-blur-xl'
          } gap-4`}>
            
            <div className="flex items-center gap-1.5 text-[10px] md:text-xs text-[var(--text-color)]/50 truncate">
              <Link to={isHindiRoute ? "/hi" : "/"} className="hover:text-[var(--text-color)]">
                {isHindiRoute ? "डैशबोर्ड" : "Dashboard"}
              </Link>
              <ChevronRight size={10} />
              <Link to={isHindiRoute ? "/hi/knowledge-base" : "/knowledge-base"} className="hover:text-[var(--text-color)]">
                {isHindiRoute ? "ज्ञान कोष" : "Knowledge Base"}
              </Link>
              {currentArticle && (
                <>
                  <ChevronRight size={10} />
                  <span className="text-[var(--text-color)]/80 font-medium truncate">
                    {isHindiRoute ? currentArticle.titleHi : currentArticle.titleEn}
                  </span>
                </>
              )}
            </div>

            
            <div className="flex items-center gap-2 shrink-0">
              
              <div className="flex items-center bg-[var(--text-color)]/[0.03] border border-[var(--glass-border)] rounded-full p-0.5">
                <button 
                  onClick={() => handleLanguageSwitch(false)}
                  className={`px-2 py-1 rounded-full text-[10px] font-bold tracking-wide uppercase transition-all ${
                    !isHindiRoute 
                      ? 'bg-[rgba(var(--primary-rgb),0.15)] text-[color:var(--primary-color)]'
                      : 'text-[var(--text-color)]/50 hover:text-[var(--text-color)]'
                  }`}
                >
                  EN
                </button>
                <button 
                  onClick={() => handleLanguageSwitch(true)}
                  className={`px-2 py-1 rounded-full text-[10px] font-bold tracking-wide uppercase transition-all ${
                    isHindiRoute 
                      ? 'bg-[rgba(var(--primary-rgb),0.15)] text-[color:var(--primary-color)]'
                      : 'text-[var(--text-color)]/50 hover:text-[var(--text-color)]'
                  }`}
                >
                  हिन्दी
                </button>
              </div>

              
              <div className="relative" ref={settingsRef}>
                <button 
                  onClick={() => setShowSettings(!showSettings)}
                  className="p-2 rounded-xl bg-[var(--text-color)]/[0.03] hover:bg-[var(--text-color)]/[0.08] border border-[var(--glass-border)] text-[var(--text-color)]/60 hover:text-[var(--text-color)] transition-colors"
                  title="Reading Settings"
                >
                  <Type size={14} />
                </button>

                {showSettings && (
                  <div className={`absolute right-0 mt-2 w-56 rounded-2xl border shadow-2xl p-4 z-[999] animate-fade-in text-left bg-[var(--glass-bg)] border-[var(--glass-border)] text-[var(--text-color)] backdrop-blur-xl`}>
                    <h4 className="text-xs font-bold uppercase tracking-wider mb-3 flex items-center gap-1.5">
                      <Settings size={12} className="text-[color:var(--primary-color)]" />
                      <span>Reading Layout</span>
                    </h4>

                    
                    <div className="space-y-1.5 mb-4">
                      <span className="text-[10px] text-[var(--text-color)]/50 uppercase font-bold tracking-wide block">Typography</span>
                      <div className="grid grid-cols-2 gap-1.5">
                        <button 
                          onClick={() => setFontFamily('serif')}
                          className={`py-1.5 rounded-lg text-xs font-serif border transition-all ${getBtnClass(fontFamily === 'serif')}`}
                        >
                          Scripture (Serif)
                        </button>
                        <button 
                          onClick={() => setFontFamily('sans')}
                          className={`py-1.5 rounded-lg text-xs font-sans border transition-all ${getBtnClass(fontFamily === 'sans')}`}
                        >
                          Modern (Sans)
                        </button>
                      </div>
                    </div>

                    
                    <div className="space-y-1.5 mb-4">
                      <span className="text-[10px] text-[var(--text-color)]/50 uppercase font-bold tracking-wide block">Text Scale</span>
                      <div className="grid grid-cols-4 gap-1">
                        {['sm', 'md', 'lg', 'xl'].map((sz) => (
                          <button 
                            key={sz}
                            onClick={() => setFontSize(sz)}
                            className={`py-1.5 rounded-lg text-xs border uppercase tracking-wider transition-all ${getBtnClass(fontSize === sz)}`}
                          >
                            {sz}
                          </button>
                        ))}
                      </div>
                    </div>

                    
                    <div className="space-y-1.5">
                      <span className="text-[10px] text-[var(--text-color)]/50 uppercase font-bold tracking-wide block">Line Spacing</span>
                      <div className="grid grid-cols-3 gap-1">
                        {['cozy', 'normal', 'relaxed'].map((space) => (
                          <button 
                            key={space}
                            onClick={() => setLineHeight(space)}
                            className={`py-1 rounded-lg text-[10px] border capitalize transition-all ${getBtnClass(lineHeight === space)}`}
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

          
          <div 
            ref={contentScrollRef} 
            id="kb-classic-content-container" 
            className={`flex-1 p-0 lg:p-8 rounded-none lg:rounded-b-3xl border-0 lg:border-x lg:border-b lg:border-[var(--glass-border)] ${
              isPookiz 
                ? (isLight 
                    ? 'bg-transparent lg:bg-[#fbf9f4] lg:border-black/10 text-[#1c1917]' 
                    : 'bg-transparent lg:bg-[#121215] lg:border-white/5 text-[#f4f4f5]') 
                : 'bg-transparent lg:bg-[var(--glass-bg)] lg:border-[var(--glass-border)] text-[var(--text-color)] lg:backdrop-blur-xl lg:shadow-xl'
            } lg:overflow-y-auto custom-scrollbar`}
          >
            
            <div className={getReadingClasses()}>
              {children || <Outlet />}
            </div>

            
            {currentArticle && (
              <div className="mt-12 pt-6 border-t border-[var(--glass-border)] flex items-center justify-between gap-4">
                {prevArticle ? (
                  <Link 
                    to={isHindiRoute ? `/hi/${prevArticle.slug}` : `/${prevArticle.slug}`}
                    className="flex items-center gap-2 text-[var(--text-color)]/60 hover:text-[var(--text-color)] text-xs md:text-sm font-medium transition-colors"
                  >
                    <ChevronLeft size={16} />
                    <div className="text-left">
                      <span className="text-[10px] text-[var(--text-color)]/40 uppercase block tracking-wider font-bold">Previous</span>
                      <span>{isHindiRoute ? prevArticle.titleHi : prevArticle.titleEn}</span>
                    </div>
                  </Link>
                ) : (
                  <div />
                )}

                {nextArticle ? (
                  <Link 
                    to={isHindiRoute ? `/hi/${nextArticle.slug}` : `/${nextArticle.slug}`}
                    className="flex items-center gap-2 text-[var(--text-color)]/60 hover:text-[var(--text-color)] text-xs md:text-sm font-medium transition-colors text-right"
                  >
                    <div className="text-right">
                      <span className="text-[10px] text-[var(--text-color)]/40 uppercase block tracking-wider font-bold">Next</span>
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

        
        {currentArticle && headings.length > 0 && (
          <aside className="hidden xl:block w-56 shrink-0 lg:h-full lg:py-2 space-y-4">
            <div className={`p-4 rounded-2xl border border-[var(--glass-border)] ${panelBg} max-h-full overflow-y-auto custom-scrollbar`}>
              <h4 className="text-[10px] font-bold text-[var(--text-color)]/50 uppercase tracking-widest mb-3">
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
                        const container = contentScrollRef.current;
                        if (container) {
                          const containerRect = container.getBoundingClientRect();
                          const elRect = el.getBoundingClientRect();
                          const relativeTop = elRect.top - containerRect.top + container.scrollTop;
                          container.scrollTo({
                            top: relativeTop - 24,
                            behavior: 'smooth'
                          });
                        } else {
                          const yOffset = -140; 
                          const y = el.getBoundingClientRect().top + window.pageYOffset + yOffset;
                          window.scrollTo({ top: y, behavior: 'smooth' });
                        }
                        setActiveHeadingId(h.id);
                      }
                    }}
                    className={`block text-[11px] leading-relaxed transition-all truncate text-left ${
                      activeHeadingId === h.id 
                        ? 'text-[color:var(--primary-color)] font-bold translate-x-1'
                        : 'text-[var(--text-color)]/50 hover:text-[var(--text-color)]/80'
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
