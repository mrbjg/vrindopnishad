import React, { useContext } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { AuthContext } from '../App';
import { 
  Home, 
  BookOpen, 
  Scroll, 
  Music, 
  FileText, 
  LayoutDashboard, 
  LogOut
} from 'lucide-react';
import VLogo from '../assets/VLogo.png';
import GlobalAudioPlayer from './GlobalAudioPlayer';

const Layout = ({ children }) => {
  const { isAdmin, user, logout } = useContext(AuthContext);
  const location = useLocation();

  const isActive = (path) => location.pathname === path;
  const isCategoryActive = (category) => location.pathname === `/category/${category}`;

  const isAuthPage = location.pathname === '/login' || location.pathname === '/admin-old/login';

  return (
    <div className="min-h-screen relative text-white">
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
              <img src={VLogo} alt="Logo" className="app-logo hover:scale-110 transition-transform duration-500" />
            </Link>
            <span className="app-title hidden md:block">वृंदोपनिषद्</span>
          </div>

          <div className="flex items-center gap-6">
            <nav className="hidden lg:flex items-center gap-6">
              <Link to="/" className={`nav-link text-sm font-semibold tracking-wide transition-all ${isActive('/') ? 'text-primary' : 'text-white/50 hover:text-white'}`}>
                Home
              </Link>
              <Link to="/content" className={`nav-link text-sm font-semibold tracking-wide transition-all ${isActive('/content') ? 'text-primary' : 'text-white/50 hover:text-white'}`}>
                Sanctuary Library
              </Link>
            </nav>

            <div className="flex items-center gap-4">
              {user ? (
                <div className="flex items-center gap-3 bg-white/5 backdrop-blur-md border border-white/10 p-1.5 pr-4 rounded-full hover:bg-white/10 hover:border-white/20 transition-all cursor-pointer group">
                  {/* Avatar Section */}
                  <div className="w-8 h-8 rounded-full overflow-hidden flex-shrink-0 border border-white/20 shadow-inner bg-gradient-to-br from-primary/40 to-primary/10 flex items-center justify-center">
                    {user.photoURL ? (
                      <img src={user.photoURL} alt="User" className="w-full h-full object-cover" />
                    ) : (
                      <span className="text-xs font-bold text-white uppercase tracking-wider">
                        {(user.displayName || user.email || 'V')[0]}
                      </span>
                    )}
                  </div>
                  
                  {/* User Name Section */}
                  <div className="flex flex-col">
                    <span className="text-[10px] uppercase tracking-widest text-white/30 font-bold leading-none mb-0.5">Devotee</span>
                    <span className="text-[13px] font-bold truncate max-w-[100px] leading-none">
                      {user.displayName || (user.email?.split('@')[0].match(/^[a-zA-Z]/) ? user.email?.split('@')[0] : 'Member')}
                    </span>
                  </div>

                  {/* Divider */}
                  <div className="w-[1px] h-4 bg-white/10 mx-1"></div>
                  
                  {/* Logout Button */}
                  <button 
                    onClick={(e) => {
                      e.stopPropagation();
                      logout();
                    }} 
                    className="text-white/20 hover:text-red-400 hover:scale-110 active:scale-95 transition-all p-1"
                    title="Logout"
                  >
                    <LogOut size={16} />
                  </button>
                </div>
              ) : (
                <Link to="/login" className="btn-premium py-2 px-6 text-sm shadow-xl shadow-primary/20">
                  Enter Sanctuary
                </Link>
              )}
              
              {isAdmin && (
                 <Link to="/admin-old/dashboard" className="p-2.5 bg-white/5 border border-white/10 rounded-full hover:bg-primary/20 hover:border-primary/40 transition-all">
                   <LayoutDashboard size={20} className="text-primary-light" />
                 </Link>
              )}
            </div>
          </div>
        </header>
      )}

      {/* Floating Vertical Sidebar */}
      {!isAuthPage && (
        <aside className="sidebar animate-fade-in-left">
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
        <div className="md:hidden fixed bottom-6 left-6 right-6 h-16 glass rounded-full z-[1000] flex items-center justify-around px-4 border border-white/10 shadow-[0_20px_50px_rgba(0,0,0,0.5)] animate-fade-in-up">
          <Link to="/" className={`p-2 rounded-full transition-all ${isActive('/') ? 'text-primary scale-125' : 'text-white/30'}`}>
            <Home size={24} />
          </Link>
          <Link to="/content" className={`p-2 rounded-full transition-all ${isActive('/content') ? 'text-primary scale-125' : 'text-white/30'}`}>
            <BookOpen size={24} />
          </Link>
          <Link to="/category/shloka" className={`p-2 rounded-full transition-all ${isCategoryActive('shloka') ? 'text-primary scale-125' : 'text-white/30'}`}>
            <Scroll size={24} />
          </Link>
          <Link to="/category/strotra" className={`p-2 rounded-full transition-all ${isCategoryActive('strotra') ? 'text-primary scale-125' : 'text-white/30'}`}>
            <Music size={24} />
          </Link>
        </div>
      )}
      {/* Global Audio Player */}
      <GlobalAudioPlayer />
    </div>
  );
};

export default Layout;
