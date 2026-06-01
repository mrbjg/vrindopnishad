'use client';

import React, { useState, useContext, useEffect, useCallback, useRef } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { AuthContext } from '../contexts/ClientProviders';
import { useSettings } from '../contexts/SettingsContext';
import { 
  LayoutDashboard, 
  Users, 
  BookOpen, 
  Compass, 
  Music, 
  Shield, 
  Settings, 
  LogOut, 
  Menu, 
  X, 
  ChevronDown,
  MessageSquare,
  ChevronLeft,
  ChevronRight
} from 'lucide-react';
import SettingsModal from './SettingsModal';
import GlobalAudioPlayer from './GlobalAudioPlayer';

const PookizLayout = ({ children }) => {
  const { settings } = useSettings();
  const { isAdmin, logout } = useContext(AuthContext);
  const location = useLocation();
  const navigate = useNavigate();
  
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [isSettingsOpen, setIsSettingsOpen] = useState(false);
  const [isProfileMenuOpen, setIsProfileMenuOpen] = useState(false);
  const [isSidebarCollapsed, setIsSidebarCollapsed] = useState(() => {
    if (typeof window !== 'undefined') {
      return localStorage.getItem('pookiz_sidebar_collapsed') === 'true';
    }
    return false;
  });

  const [isCollapsing, setIsCollapsing] = useState(false);
  const resizeRef = useRef({ startX: 0, startWidth: 0 });

  const toggleSidebar = () => {
    setIsCollapsing(true);
    const nextState = !isSidebarCollapsed;
    setIsSidebarCollapsed(nextState);
    localStorage.setItem('pookiz_sidebar_collapsed', String(nextState));
    setTimeout(() => {
      setIsCollapsing(false);
    }, 300);
  };

  const [sidebarWidth, setSidebarWidth] = useState(() => {
    if (typeof window !== 'undefined') {
      const saved = localStorage.getItem('pookiz_sidebar_width');
      return saved ? parseInt(saved, 10) : 240;
    }
    return 240;
  });
  const [isResizing, setIsResizing] = useState(false);

  const startResizing = useCallback((e) => {
    setIsResizing(true);
    resizeRef.current = {
      startX: e.clientX,
      startWidth: sidebarWidth
    };
    e.preventDefault();
  }, [sidebarWidth]);

  const stopResizing = useCallback(() => {
    setIsResizing(false);
    const sidebarEl = document.getElementById('pookiz-main-sidebar');
    if (sidebarEl) {
      const styleWidth = sidebarEl.style.width;
      if (styleWidth) {
        const finalWidth = parseInt(styleWidth, 10);
        setSidebarWidth(finalWidth);
        localStorage.setItem('pookiz_sidebar_width', String(finalWidth));
      }
    }
  }, []);

  const resize = useCallback((e) => {
    if (isResizing) {
      const { startX, startWidth } = resizeRef.current;
      const deltaX = e.clientX - startX;
      const newWidth = Math.max(180, Math.min(380, startWidth + deltaX));
      
      const sidebarEl = document.getElementById('pookiz-main-sidebar');
      if (sidebarEl) {
        sidebarEl.style.width = `${newWidth}px`;
      }
    }
  }, [isResizing]);

  useEffect(() => {
    if (isResizing) {
      window.addEventListener('mousemove', resize);
      window.addEventListener('mouseup', stopResizing);
    }
    return () => {
      window.removeEventListener('mousemove', resize);
      window.removeEventListener('mouseup', stopResizing);
    };
  }, [isResizing, resize, stopResizing]);

  const isActive = (path) => {
    if (path === '/') {
      return location.pathname === '/' || location.pathname === '/hi';
    }
    return location.pathname.startsWith(path);
  };

  const isHiRoute = location.pathname.startsWith('/hi');

  const menuItems = [
    {
      label: isHiRoute ? 'डैशबोर्ड' : 'Dashboard',
      path: isHiRoute ? '/hi' : '/',
      icon: <LayoutDashboard size={18} />,
      isActive: isActive('/')
    },
    {
      label: isHiRoute ? 'रसिक सन्त' : 'Rasik Saints',
      path: isHiRoute ? '/hi/saints' : '/saints',
      icon: <Users size={18} />,
      isActive: isActive('/saints') || isActive('/hi/saints')
    },
    {
      label: isHiRoute ? 'वाणी ग्रन्थ' : 'Scriptures',
      path: isHiRoute ? '/hi/granthas' : '/granthas',
      icon: <MessageSquare size={18} />,
      isActive: isActive('/granthas') || isActive('/hi/granthas')
    },
    {
      label: isHiRoute ? 'ज्ञान कोष' : 'Knowledge Base',
      path: isHiRoute ? '/hi/knowledge-base' : '/knowledge-base',
      icon: <BookOpen size={18} />,
      isActive: isActive('/knowledge-base')
    },
    {
      label: isHiRoute ? 'पुस्तकालय' : 'Library',
      path: isHiRoute ? '/hi/content' : '/content',
      icon: <Compass size={18} />,
      isActive: isActive('/content')
    },
    {
      label: isHiRoute ? 'राग रागिनी' : 'Sacred Ragas',
      path: isHiRoute ? '/hi/ragas' : '/ragas',
      icon: <Music size={18} />,
      isActive: isActive('/raga')
    },
    {
      label: isHiRoute ? 'एडमिन' : 'Admin',
      path: isAdmin ? '/admin-old/dashboard' : (isHiRoute ? '/hi' : '/'),
      icon: <Shield size={18} />,
      isActive: isActive('/admin-old') || location.pathname.includes('/admin-old'),
      adminOnly: true
    }
  ];



  const devoteeName = settings.devoteeName || (isHiRoute ? 'श्री राधा दास' : 'Radha Das');
  const devoteeLocation = isHiRoute ? 'श्री धाम वृन्दावन' : 'Sri Dham Vrindavan';

  return (
    <div className="h-screen bg-black text-[#f4f4f5] flex font-sans antialiased overflow-hidden selection:bg-purple-500/30 selection:text-purple-200">
      
      <aside 
        id="pookiz-main-sidebar"
        style={isSidebarCollapsed ? {} : { width: `${sidebarWidth}px` }}
        className={`hidden lg:flex bg-black border-r border-white/5 flex-col h-full shrink-0 relative ${isSidebarCollapsed ? 'w-20' : ''} ${isResizing ? 'select-none transition-none' : isCollapsing ? 'transition-all duration-300 ease-in-out' : 'transition-none'}`}
      >
        <div className={`w-full h-full flex flex-col justify-between overflow-y-auto custom-scrollbar ${isSidebarCollapsed ? 'p-3' : 'p-4'}`}>
          <div className="space-y-6">
            {isSidebarCollapsed ? (
              <div className="flex flex-col items-center gap-4 w-full">
                <Link 
                  to={isHiRoute ? "/hi" : "/"} 
                  className="flex items-center justify-center w-12 h-12 rounded-xl hover:bg-white/5 transition-all" 
                  title={isHiRoute ? 'मुख्यपृष्ठ' : 'Home'}
                >
                  <img 
                    src="/official-logo-dark.svg" 
                    alt="Vrindopnishad Logo" 
                    className="w-7 h-7 object-contain hover:scale-110 transition-transform duration-500 shrink-0" 
                  />
                </Link>
                <button 
                  onClick={() => setIsSettingsOpen(true)}
                  className="text-zinc-400 hover:text-white rounded-xl hover:bg-white/5 transition-colors flex items-center justify-center w-12 h-12"
                  title={isHiRoute ? 'प्राथमिकताएं' : 'Preferences'}
                >
                  <Settings size={18} />
                </button>
              </div>
            ) : (
              <div className="flex flex-row items-center justify-between w-full px-2 py-1.5 gap-4 min-w-0">
                <Link 
                  to={isHiRoute ? "/hi" : "/"} 
                  className="flex items-center gap-3 group transition-all min-w-0"
                >
                  <img 
                    src="/official-logo-dark.svg" 
                    alt="Vrindopnishad Logo" 
                    className="w-7 h-7 object-contain hover:scale-110 transition-transform duration-500 shrink-0" 
                  />
                </Link>
                <button 
                  onClick={() => setIsSettingsOpen(true)}
                  className="text-zinc-400 hover:text-white rounded-xl hover:bg-white/5 transition-colors flex items-center justify-center p-1.5 shrink-0"
                  title={isHiRoute ? 'प्राथमिकताएं' : 'Preferences'}
                >
                  <Settings size={18} />
                </button>
              </div>
            )}

            
            <nav className="space-y-1">
              {menuItems.map((item, idx) => {
                if (item.adminOnly && !isAdmin) return null;
                return (
                  <Link
                    key={idx}
                    to={item.path}
                    title={isSidebarCollapsed ? item.label : undefined}
                    className={`flex items-center rounded-xl text-sm font-medium transition-all relative ${
                      isSidebarCollapsed ? 'justify-center p-3' : 'gap-3 px-3 py-2.5'
                    } ${
                      item.isActive 
                        ? 'bg-white/[0.04] text-white before:absolute before:left-0 before:top-2.5 before:bottom-2.5 before:w-0.5 before:bg-white before:rounded-r' 
                        : 'text-zinc-400 hover:text-zinc-200 hover:bg-white/[0.02]'
                    }`}
                  >
                    <span className={item.isActive ? 'text-white' : 'text-zinc-400'}>{item.icon}</span>
                    {!isSidebarCollapsed && <span>{item.label}</span>}
                  </Link>
                );
              })}
            </nav>
          </div>

          
          <div className="relative border-t border-white/5 pt-4">
            <div 
              onClick={() => setIsProfileMenuOpen(!isProfileMenuOpen)}
              className={`flex items-center rounded-xl hover:bg-white/5 cursor-pointer transition-colors select-none ${
                isSidebarCollapsed ? 'justify-center p-1.5' : 'justify-between p-2'
              }`}
              title={isSidebarCollapsed ? devoteeName : undefined}
            >
              <div className="flex items-center gap-3 min-w-0">
                <div className="w-9 h-9 rounded-full bg-purple-500/10 border border-purple-500/20 flex items-center justify-center text-purple-400 font-bold text-sm uppercase shrink-0">
                  {devoteeName.charAt(0)}
                </div>
                {!isSidebarCollapsed && (
                  <div className="min-w-0 text-left">
                    <span className="text-xs font-semibold text-white block truncate leading-none mb-1">{devoteeName}</span>
                    <span className="text-[10px] text-zinc-500 block truncate leading-none">{devoteeLocation}</span>
                  </div>
                )}
              </div>
              {!isSidebarCollapsed && (
                <ChevronDown size={14} className={`text-zinc-500 transition-transform ${isProfileMenuOpen ? 'rotate-180' : ''}`} />
              )}
            </div>
          </div>
        </div>

        
        {isProfileMenuOpen && (
          <div className={`absolute bg-[#121215] border border-white/5 rounded-2xl shadow-xl p-1.5 z-[100] animate-fade-in text-left ${
            isSidebarCollapsed ? 'w-44 left-3 bottom-[56px]' : 'left-4 right-4 bottom-[72px]'
          }`}>
            <button 
              onClick={() => {
                setIsProfileMenuOpen(false);
                setIsSettingsOpen(true);
              }}
              className="w-full flex items-center gap-2.5 px-3 py-2 rounded-lg text-xs font-medium text-zinc-300 hover:text-white hover:bg-white/5 transition-colors"
            >
              <Settings size={14} />
              <span>{isHiRoute ? 'प्राथमिकताएं' : 'Preferences'}</span>
            </button>
            <button 
              onClick={() => {
                setIsProfileMenuOpen(false);
                logout();
                navigate(isHiRoute ? '/hi' : '/');
              }}
              className="w-full flex items-center gap-2.5 px-3 py-2 rounded-lg text-xs font-medium text-red-400 hover:text-red-300 hover:bg-red-500/10 transition-colors"
            >
            <LogOut size={14} />
            <span>{isHiRoute ? 'लॉग आउट' : 'Sign Out'}</span>
          </button>
        </div>
      )}

      
        <button
          onClick={toggleSidebar}
          className="absolute top-20 -right-3 w-6 h-6 rounded-full bg-zinc-950 border border-white/10 hover:border-purple-500/40 hover:bg-zinc-900 flex items-center justify-center text-zinc-400 hover:text-white shadow-md z-[60] transition-all duration-200 group/collapse"
          title={isSidebarCollapsed ? (isHiRoute ? 'विस्तार करें' : 'Expand Sidebar') : (isHiRoute ? 'संकुचित करें' : 'Collapse Sidebar')}
        >
          {isSidebarCollapsed ? (
            <ChevronRight size={14} className="transition-transform group-hover/collapse:translate-x-[0.5px]" />
          ) : (
            <ChevronLeft size={14} className="transition-transform group-hover/collapse:-translate-x-[0.5px]" />
          )}
        </button>

        
        {!isSidebarCollapsed && (
          <div 
            onMouseDown={startResizing}
            className="absolute top-0 -right-1 bottom-0 w-3 cursor-col-resize z-50 group"
          >
            <div className={`w-0.5 h-full mx-auto transition-colors duration-200 ${
              isResizing ? 'bg-purple-500/80' : 'bg-transparent group-hover:bg-purple-500/40'
            }`} />
          </div>
        )}
      </aside>

      
      {isMobileMenuOpen && (
        <div className="fixed inset-0 z-[1000] lg:hidden">
          
          <div 
            className="absolute inset-0 bg-black/80 backdrop-blur-sm"
            onClick={() => setIsMobileMenuOpen(false)}
          ></div>
          
          <aside className="absolute top-0 bottom-0 left-0 w-64 bg-black border-r border-white/5 flex flex-col justify-between p-4 animate-fade-in-left">
            <div className="space-y-6">
              <div className="flex items-center justify-between px-2 py-1.5 gap-4">
                <div className="flex items-center gap-3 min-w-0">
                  <img 
                    src="/official-logo-dark.svg" 
                    alt="Vrindopnishad Logo" 
                    className="w-7 h-7 object-contain shrink-0" 
                  />
                </div>
                <button 
                  onClick={() => setIsMobileMenuOpen(false)}
                  className="text-zinc-400 hover:text-white p-1 rounded-lg hover:bg-white/5 shrink-0"
                >
                  <X size={18} />
                </button>
              </div>

              <nav className="space-y-1">
                {menuItems.map((item, idx) => {
                  if (item.adminOnly && !isAdmin) return null;
                  return (
                    <Link
                      key={idx}
                      to={item.path}
                      onClick={() => setIsMobileMenuOpen(false)}
                      className={`flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all relative ${
                        item.isActive 
                          ? 'bg-white/[0.04] text-white before:absolute before:left-0 before:top-2.5 before:bottom-2.5 before:w-0.5 before:bg-white before:rounded-r' 
                          : 'text-zinc-400 hover:text-zinc-200 hover:bg-white/[0.02]'
                      }`}
                    >
                      <span className={item.isActive ? 'text-white' : 'text-zinc-400'}>{item.icon}</span>
                      <span>{item.label}</span>
                    </Link>
                  );
                })}
              </nav>
            </div>

            
            <div className="border-t border-white/5 pt-4">
              <div className="flex items-center justify-between p-2 rounded-xl">
                <div className="flex items-center gap-3 min-w-0">
                  <div className="w-9 h-9 rounded-full bg-purple-500/10 border border-purple-500/20 flex items-center justify-center text-purple-400 font-bold text-sm uppercase shrink-0">
                    {devoteeName.charAt(0)}
                  </div>
                  <div className="min-w-0 text-left">
                    <span className="text-xs font-semibold text-white block truncate leading-none mb-1">{devoteeName}</span>
                    <span className="text-[10px] text-zinc-500 block truncate leading-none">{devoteeLocation}</span>
                  </div>
                </div>
                <button 
                  onClick={() => {
                    setIsMobileMenuOpen(false);
                    logout();
                    navigate(isHiRoute ? '/hi' : '/');
                  }}
                  className="text-zinc-500 hover:text-red-400 p-1.5 hover:bg-white/5 rounded-lg transition-colors"
                  title="Logout"
                >
                  <LogOut size={16} />
                </button>
              </div>
            </div>
          </aside>
        </div>
      )}

      
      <div className="flex-1 flex flex-col min-w-0 h-full overflow-hidden">
        
        
        <header className="lg:hidden h-14 border-b border-white/5 bg-black/80 backdrop-blur-md px-4 flex items-center justify-between sticky top-0 z-40 gap-4">
          <div className="flex items-center gap-3 min-w-0">
            <button 
              onClick={() => setIsMobileMenuOpen(true)}
              className="text-zinc-400 hover:text-white p-1 rounded-lg hover:bg-white/5 transition-colors shrink-0"
            >
              <Menu size={20} />
            </button>
            <span className="font-bold text-sm tracking-wide text-white truncate">
              {isHiRoute ? 'वृंदोपनिषद्' : 'Vrindopnishad'}
            </span>
          </div>

          <div className="flex items-center gap-2 shrink-0">
            <button 
              onClick={() => setIsSettingsOpen(true)}
              className="text-zinc-400 hover:text-white p-1.5 rounded-lg hover:bg-white/5 transition-colors"
            >
              <Settings size={18} />
            </button>
            <div className="w-7 h-7 rounded-full bg-purple-500/10 border border-purple-500/20 flex items-center justify-center text-purple-400 font-bold text-xs uppercase shrink-0">
              {devoteeName.charAt(0)}
            </div>
          </div>
        </header>

        
        <main 
          id="pookiz-main-scroll-container"
          className="flex-1 p-3 md:p-4 w-full pb-16 overflow-y-auto custom-scrollbar"
        >
          <div>
            {children}
          </div>
        </main>
      </div>

      
      <SettingsModal 
        isOpen={isSettingsOpen} 
        onClose={() => setIsSettingsOpen(false)} 
      />

      
      <GlobalAudioPlayer />
    </div>
  );
};

export default PookizLayout;
