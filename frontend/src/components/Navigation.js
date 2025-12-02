import React, { useContext } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { AuthContext } from '../App';

const Navigation = () => {
  const { isAdmin, logout } = useContext(AuthContext);
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/');
  };

  return (
    <nav className="navbar">
      <div className="nav-container">
        <Link to="/" className="nav-logo" data-testid="nav-logo">
          ॐ Vrindopnishad
        </Link>
        <div className="nav-links">
          <Link to="/" className="nav-link" data-testid="nav-home">Home</Link>
          <Link to="/content" className="nav-link" data-testid="nav-content">Content</Link>
          <Link to="/category/shloka" className="nav-link" data-testid="nav-shlokas">Shlokas</Link>
          <Link to="/category/strotra" className="nav-link" data-testid="nav-strotras">Strotras</Link>
          <Link to="/category/poem" className="nav-link" data-testid="nav-poems">Poems</Link>
          {isAdmin ? (
            <>
              <Link to="/admin/dashboard" className="nav-link" data-testid="nav-admin">Dashboard</Link>
              <button
                onClick={handleLogout}
                className="btn btn-secondary"
                style={{ padding: '0.5rem 1rem' }}
                data-testid="logout-btn"
              >
                Logout
              </button>
            </>
          ) : (
            <Link to="/admin/login" className="btn btn-secondary" style={{ padding: '0.5rem 1rem' }} data-testid="nav-login">
              Admin Login
            </Link>
          )}
        </div>
      </div>
    </nav>
  );
};

export default Navigation;
