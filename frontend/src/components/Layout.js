import React, { useContext } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { AuthContext } from '../App';
import { useTheme } from '../contexts/ThemeContext';
import { 
  Home, 
  BookOpen, 
  Scroll, 
  Music, 
  FileText, 
  LayoutDashboard, 
  LogOut,
  Settings
} from 'lucide-react';
import GlobalAudioPlayer from './GlobalAudioPlayer';
import SettingsModal from './SettingsModal';

const Layout = ({ children }) => {
  const { isDark } = useTheme();
  const { isAdmin, user, logout } = useContext(AuthContext);
  const [isSettingsOpen, setIsSettingsOpen] = React.useState(false);
  const location = useLocation();

  const isActive = (path) => location.pathname === path;
  const isCategoryActive = (category) => location.pathname === `/category/${category}`;

  const isAuthPage = location.pathname === '/login' || location.pathname === '/admin-old/login';

  return (
    <div className="min-h-screen relative text-foreground">
      {/* Celestial Background */}
      <div className="celestial-bg">
        <div className="stars"></div>
        <div className="shooting-star" style={{ top: '30%', left: '40%' }}></div>
        <div className="nebula"></div>
      </div>

      {/* App Header */}
      {!isAuthPage && (
        <header className="app-header animate-fade-in-down">
          <div className="logo-container">
            <Link to="/">
              <img 
                src={isDark ? '/official-logo-dark.svg' : '/official-logo.svg'} 
                alt="Vrindopnishad Logo" 
                className="app-logo hover:scale-110 transition-transform duration-500" 
              />
            </Link>
            <span className="app-title hidden md:block">वृंदोपनिषद्</span>
          </div>

          <div className="flex items-center gap-6">
            <nav className="hidden lg:flex items-center gap-6">
              <Link to="/" className={`header-nav-link ${isActive('/') ? 'active' : ''}`}>
                Home
              </Link>
              <Link to="/content" className={`header-nav-link ${isActive('/content') ? 'active' : ''}`}>
                Sanctuary Library
              </Link>
            </nav>

            <div className="flex items-center gap-4">
              {/* Standalone Settings Button */}
              <button 
                onClick={() => setIsSettingsOpen(true)}
                className="header-control-btn"
                title="Settings"
              >
                <Settings size={20} className="w-[18px] h-[18px] sm:w-[20px] sm:h-[20px]" />
              </button>

              {user ? (
                <div className="header-profile-pill">
                  {/* Avatar Section */}
                  <div className="header-profile-avatar">
                    {user.photoURL ? (
                      <img 
                        src={user.photoURL} 
                        alt="User" 
                        className="w-full h-full object-cover"
                        onError={(e) => {
                          e.target.style.display = 'none';
                          // Show the sibling span
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
                  
                  {/* User Name Section - Hidden on Mobile for clean look */}
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
                <Link to="/login" className="btn-sacred-gold py-2.5 px-8 text-sm uppercase tracking-widest shadow-2xl">
                  Enter Sanctuary
                </Link>
              )}
              
              {isAdmin && (
                 <Link to="/admin-old/dashboard" className="header-control-btn" title="Dashboard">
                   <LayoutDashboard size={20} className="text-amber-300" />
                 </Link>
              )}
            </div>
          </div>
        </header>
      )}

      {/* Floating Vertical Sidebar */}
      {!isAuthPage && (
        <aside className="sidebar">
          <Link to="/" className={`side-item ${isActive('/') ? 'active' : ''}`} title="Home">
            <Home size={22} />
          </Link>
          <Link to="/content" className={`side-item ${isActive('/content') ? 'active' : ''}`} title="All Content">
            <BookOpen size={22} />
          </Link>
          <div className="w-8 h-[1px] bg-white/10 my-2"></div>
          <Link to="/category/shloka" className={`side-item ${isCategoryActive('shloka') ? 'active' : ''}`} title="Shlokas">
            <Scroll size={22} />
          </Link>
          <Link to="/category/strotra" className={`side-item ${isCategoryActive('strotra') ? 'active' : ''}`} title="Strotras">
            <Music size={22} />
          </Link>
          <Link to="/category/poem" className={`side-item ${isCategoryActive('poem') ? 'active' : ''}`} title="Poems">
            <FileText size={22} />
          </Link>
        </aside>
      )}

      {/* Main Content Area */}
      <main className={`${isAuthPage ? 'pt-0 pl-0' : 'pl-0 md:pl-28 pt-24 pb-12'}`}>
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
    </div>
  );
};

export default Layout;
