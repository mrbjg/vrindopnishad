import React, { useState, useContext } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { API, AuthContext } from '../App';
import { useLoading } from '../contexts/LoadingContext';
import Navigation from '../components/Navigation';

const AdminLoginPage = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const { login } = useContext(AuthContext);
  const { showLoading, hideLoading } = useLoading();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    showLoading('Logging in...');

    try {
      const response = await axios.post(`${API}/auth/login`, { email, password });
      login(response.data.access_token);
      navigate('/admin/dashboard');
    } catch (err) {
      setError(err.response?.data?.detail || 'Login failed. Please check your credentials.');
    } finally {
      hideLoading();
    }
  };

  return (
    <div>
      <Navigation />
      <div className="container mt-5" style={{ maxWidth: '500px' }}>
        <div className="card" style={{ padding: '3rem' }}>
          <div className="text-center mb-4">
            <div className="om-symbol mb-3">ॐ</div>
            <h2 data-testid="admin-login-title">Admin Login</h2>
            <p style={{ color: '#666', marginTop: '0.5rem' }}>Access the content management panel</p>
          </div>

          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <label className="form-label">Email</label>
              <input
                type="email"
                className="form-input"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="admin@vrindopnishad.com"
                required
                data-testid="email-input"
              />
            </div>

            <div className="form-group">
              <label className="form-label">Password</label>
              <input
                type="password"
                className="form-input"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Enter your password"
                required
                data-testid="password-input"
              />
            </div>

            {error && (
              <div style={{ padding: '1rem', background: '#ffebee', borderRadius: '8px', color: '#c62828', marginBottom: '1rem' }} data-testid="error-message">
                {error}
              </div>
            )}

            <button
              type="submit"
              className="btn btn-primary"
              style={{ width: '100%' }}
              data-testid="login-btn"
            >
              Login
            </button>
          </form>

          <div className="mt-4 text-center" style={{ fontSize: '0.9rem', color: '#666' }}>
            <p>Default credentials:</p>
            <p>Email: admin@vrindopnishad.com</p>
            <p>Password: admin123</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AdminLoginPage;
