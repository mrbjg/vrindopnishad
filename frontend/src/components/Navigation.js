import React, { useContext, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { AuthContext } from '../App';
import { Home, BookOpen, Scroll, Music, FileText, LayoutDashboard, LogIn, LogOut } from 'lucide-react';

import VLogo from '../assets/VLogo.png';

const Navigation = () => {
  const { isAdmin, logout } = useContext(AuthContext);
  const navigate = useNavigate();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const handleLogout = () => {
    logout();
    navigate('/');
    setMobileMenuOpen(false);
  };

  const closeMobileMenu = () => {
    setMobileMenuOpen(false);
  };

  return (
    <nav className="navbar">
      <div className="nav-container">
        <Link to="/" className="nav-logo" data-testid="nav-logo" onClick={closeMobileMenu}>
          <img src={VLogo} alt="Vrindopnishad Logo" className="nav-logo-img" />
        </Link>

        {/* Animated Hamburger Menu Toggle */}
        <label
          className={`hamburger-menu ${mobileMenuOpen ? 'open' : ''}`}
          data-testid="mobile-menu-toggle"
        >
          <input
            type="checkbox"
            checked={mobileMenuOpen}
            onChange={() => setMobileMenuOpen(!mobileMenuOpen)}
          />
          <span></span>
          <span></span>
          <span></span>
        </label>

        {/* Navigation links */}
        <div className={`nav-links ${mobileMenuOpen ? 'mobile-open' : ''}`}>
          <Link to="/" className="nav-link" data-testid="nav-home" onClick={closeMobileMenu}>
            <Home size={20} />
            <span>Home</span>
          </Link>
          <Link to="/content" className="nav-link" data-testid="nav-content" onClick={closeMobileMenu}>
            <BookOpen size={20} />
            <span>Content</span>
          </Link>
          <Link to="/category/shloka" className="nav-link" data-testid="nav-shlokas" onClick={closeMobileMenu}>
            <Scroll size={20} />
            <span>Shlokas</span>
          </Link>
          <Link to="/category/strotra" className="nav-link" data-testid="nav-strotras" onClick={closeMobileMenu}>
            <Music size={20} />
            <span>Strotras</span>
          </Link>
          <Link to="/category/poem" className="nav-link" data-testid="nav-poems" onClick={closeMobileMenu}>
            <FileText size={20} />
            <span>Poems</span>
          </Link>
          {isAdmin ? (
            <>
              <Link to="/admin/dashboard" className="nav-link" data-testid="nav-admin" onClick={closeMobileMenu}>
                <LayoutDashboard size={20} />
                <span>Dashboard</span>
              </Link>
              <button
                onClick={handleLogout}
                className="nav-link nav-btn"
                data-testid="logout-btn"
              >
                <LogOut size={20} />
                <span>Logout</span>
              </button>
            </>
          ) : (
            <Link to="/admin/login" className="nav-link nav-highlight" data-testid="nav-login" onClick={closeMobileMenu}>
              <LogIn size={20} />
              <span>Admin</span>
            </Link>
          )}
        </div>
      </div>
    </nav>
  );
};

export default Navigation;
