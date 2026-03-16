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
  LogOut,
  User
} from 'lucide-react';
import VLogo from '../assets/VLogo.png';

const Layout = ({ children }) => {
  const { isAdmin, user, logout } = useContext(AuthContext);
  const location = useLocation();

  const isActive = (path) => location.pathname === path;
  const isCategoryActive = (category) => location.pathname === `/category/${category}`;

  return (
    <div className="min-h-screen relative text-white">
      {/* Celestial Background */}
      <div className="celestial-bg">
        <div className="stars"></div>
        <div className="nebula"></div>
      </div>

      {/* App Header */}
      <header className="app-header">
        <div className="logo-container">
          <Link to="/">
            <img src={VLogo} alt="Logo" className="app-logo" />
          </Link>
          <span className="app-title hidden md:block">वृंदोपनिषद्</span>
        </div>

        <div className="flex items-center gap-6">
          <nav className="hidden md:flex items-center gap-6">
            <Link to="/" className={`nav-link text-sm font-medium transition-colors ${isActive('/') ? 'text-primary' : 'text-white/60 hover:text-white'}`}>
              <div className="flex items-center gap-2">
                <Home size={18} />
                Home
              </div>
            </Link>
            <Link to="/content" className={`nav-link text-sm font-medium transition-colors ${isActive('/content') ? 'text-primary' : 'text-white/60 hover:text-white'}`}>
              <div className="flex items-center gap-2">
                <BookOpen size={18} />
                Content
              </div>
            </Link>
          </nav>

          <div className="flex items-center gap-4">
            {user ? (
              <div className="flex items-center gap-3 bg-white/5 border border-white/10 px-4 py-2 rounded-full">
                <User size={18} className="text-white/60" />
                <span className="text-sm font-medium">{user.displayName || user.email?.split('@')[0]}</span>
                <button onClick={logout} className="text-white/40 hover:text-white transition-colors">
                  <LogOut size={18} />
                </button>
              </div>
            ) : (
              <Link to="/login" className="btn-premium py-2 px-6 text-sm">
                Login
              </Link>
            )}
            
            {isAdmin && (
               <Link to="/admin-old/dashboard" className="p-2 bg-white/5 border border-white/10 rounded-full hover:bg-white/10 transition-colors">
                 <LayoutDashboard size={20} />
               </Link>
            )}
          </div>
        </div>
      </header>

      {/* Floating Vertical Sidebar */}
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

      {/* Main Content Area */}
      <main className="pl-0 md:pl-28 pt-24 pb-12">
        <div className="max-w-7xl mx-auto px-6">
          {children}
        </div>
      </main>

      {/* Mobile Bottom Nav */}
      <div className="md:hidden fixed bottom-6 left-6 right-6 h-16 glass rounded-full z-[1000] flex items-center justify-around px-4 border border-white/10 shadow-2xl">
        <Link to="/" className={`p-2 rounded-full ${isActive('/') ? 'text-primary' : 'text-white/40'}`}>
          <Home size={24} />
        </Link>
        <Link to="/content" className={`p-2 rounded-full ${isActive('/content') ? 'text-primary' : 'text-white/40'}`}>
          <BookOpen size={24} />
        </Link>
        <Link to="/category/shloka" className={`p-2 rounded-full ${isCategoryActive('shloka') ? 'text-primary' : 'text-white/40'}`}>
          <Scroll size={24} />
        </Link>
        <Link to="/category/strotra" className={`p-2 rounded-full ${isCategoryActive('strotra') ? 'text-primary' : 'text-white/40'}`}>
          <Music size={24} />
        </Link>
      </div>
    </div>
  );
};

export default Layout;
