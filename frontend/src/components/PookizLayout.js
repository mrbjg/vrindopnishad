import React, { useState, useContext, useEffect, useCallback } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { AuthContext } from '../App';
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
    return localStorage.getItem('pookiz_sidebar_collapsed') === 'true';
  });

  const toggleSidebar = () => {
    const nextState = !isSidebarCollapsed;
    setIsSidebarCollapsed(nextState);
    localStorage.setItem('pookiz_sidebar_collapsed', String(nextState));
  };

  const [sidebarWidth, setSidebarWidth] = useState(() => {
    const saved = localStorage.getItem('pookiz_sidebar_width');
    return saved ? parseInt(saved, 10) : 240;
  });
  const [isResizing, setIsResizing] = useState(false);

  const startResizing = useCallback((e) => {
    setIsResizing(true);
    e.preventDefault();
  }, []);

  const stopResizing = useCallback(() => {
    setIsResizing(false);
  }, []);

  const resize = useCallback((e) => {
    if (isResizing) {
      const newWidth = Math.max(180, Math.min(380, e.clientX));
      setSidebarWidth(newWidth);
      localStorage.setItem('pookiz_sidebar_width', String(newWidth));
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
      isActive: isActive('/saint')
    },
    {
      label: isHiRoute ? 'वाणी ग्रन्थ' : 'Scriptures',
      path: isHiRoute ? '/hi/books' : '/books',
      icon: <MessageSquare size={18} />,
      isActive: isActive('/book')
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

  // SVG Pookiz Mascot Logo
  const PookizLogo = () => (
    <svg width="28" height="28" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" className="shrink-0 animate-pulse-slow">
      <circle cx="12" cy="12" r="10" fill="#a78bfa" />
      {/* Eyes */}
      <ellipse cx="9" cy="11.5" rx="1.2" ry="1.8" fill="#1e1b4b" />
      <ellipse cx="15" cy="11.5" rx="1.2" ry="1.8" fill="#1e1b4b" />
      {/* Cheek blush */}
      <circle cx="7" cy="13.5" r="1" fill="#f43f5e" opacity="0.6" />
      <circle cx="17" cy="13.5" r="1" fill="#f43f5e" opacity="0.6" />
      {/* Smile */}
      <path d="M10.5 14.5C11 15.2 13 15.2 13.5 14.5" stroke="#1e1b4b" strokeWidth="1.2" strokeLinecap="round" />
    </svg>
  );

  const devoteeName = settings.devoteeName || (isHiRoute ? 'श्री राधा दास' : 'Radha Das');
  const devoteeLocation = isHiRoute ? 'श्री धाम वृन्दावन' : 'Sri Dham Vrindavan';

  return (
    <div className="h-screen bg-black text-[#f4f4f5] flex font-sans antialiased overflow-hidden selection:bg-purple-500/30 selection:text-purple-200">
      
      <aside 
        style={isSidebarCollapsed ? {} : { width: `${sidebarWidth}px` }}
        className={`hidden lg:flex bg-black border-r border-white/5 flex-col h-full shrink-0 relative ${isSidebarCollapsed ? 'w-20' : ''} ${isResizing ? 'select-none' : 'transition-all duration-300 ease-in-out'}`}
      >
        <div className={`w-full h-full flex flex-col justify-between overflow-y-auto custom-scrollbar ${isSidebarCollapsed ? 'p-3' : 'p-4'}`}>
          <div className="space-y-6">
            {/* Top Logo and settings */}
            <div className={`flex items-center justify-between px-2 py-1.5 ${isSidebarCollapsed ? 'flex-col gap-4' : 'flex-row'}`}>
              <Link to={isHiRoute ? "/hi" : "/"} className="flex items-center gap-3 group" title={isSidebarCollapsed ? "Pookiz Home" : undefined}>
                <PookizLogo />
                {!isSidebarCollapsed && (
                  <span className="font-bold text-lg tracking-wide text-white group-hover:text-purple-300 transition-colors">Pookiz</span>
                )}
              </Link>
              <button 
                onClick={() => setIsSettingsOpen(true)}
                className="text-zinc-400 hover:text-white p-1.5 rounded-lg hover:bg-white/5 transition-colors"
                title="Sanctuary Settings"
              >
                <Settings size={18} />
              </button>
            </div>

            {/* Navigation Links */}
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

          {/* Bottom Profile Section */}
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

            {/* Mini Profile Dropdown Menu */}
            {isProfileMenuOpen && (
              <div className={`absolute bottom-full mb-2 bg-[#121215] border border-white/5 rounded-2xl shadow-xl p-1.5 z-[100] animate-fade-in text-left ${
                isSidebarCollapsed ? 'w-44 left-0' : 'left-0 right-0'
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
          </div>
        </div>

        {/* Collapse toggle button on sideline */}
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

        {/* Resize handle */}
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

      {/* Sidebar - Mobile Slider Overlay */}
      {isMobileMenuOpen && (
        <div className="fixed inset-0 z-[1000] lg:hidden">
          {/* Backdrop */}
          <div 
            className="absolute inset-0 bg-black/80 backdrop-blur-sm"
            onClick={() => setIsMobileMenuOpen(false)}
          ></div>
          {/* Sidebar Drawer */}
          <aside className="absolute top-0 bottom-0 left-0 w-64 bg-black border-r border-white/5 flex flex-col justify-between p-4 animate-fade-in-left">
            <div className="space-y-6">
              <div className="flex items-center justify-between px-2 py-1.5">
                <div className="flex items-center gap-3">
                  <PookizLogo />
                  <span className="font-bold text-lg tracking-wide text-white">Pookiz</span>
                </div>
                <button 
                  onClick={() => setIsMobileMenuOpen(false)}
                  className="text-zinc-400 hover:text-white p-1 rounded-lg hover:bg-white/5"
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

            {/* Mobile Sidebar Footer */}
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

      {/* Main Area */}
      <div className="flex-1 flex flex-col min-w-0 h-full overflow-hidden">
        
        {/* Mobile Sticky Header */}
        <header className="lg:hidden h-14 border-b border-white/5 bg-black/80 backdrop-blur-md px-4 flex items-center justify-between sticky top-0 z-40">
          <div className="flex items-center gap-3">
            <button 
              onClick={() => setIsMobileMenuOpen(true)}
              className="text-zinc-400 hover:text-white p-1 rounded-lg hover:bg-white/5 transition-colors"
            >
              <Menu size={20} />
            </button>
            <span className="font-bold text-sm tracking-wide text-white">Pookiz</span>
          </div>

          <div className="flex items-center gap-2">
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

        {/* Scrollable Content Container */}
        <main className="flex-1 p-3 md:p-4 w-full pb-16 overflow-y-auto custom-scrollbar">
          {children}
        </main>
      </div>

      {/* Settings Modal */}
      <SettingsModal 
        isOpen={isSettingsOpen} 
        onClose={() => setIsSettingsOpen(false)} 
      />

      {/* Embedded Global Audio Player */}
      <GlobalAudioPlayer />
    </div>
  );
};

export default PookizLayout;
