'use client';

import React, { useState, useContext, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { AuthContext } from '../contexts/ClientProviders';
import { apiService } from '../services/api';
import { Shield, Lock, LogIn, ArrowLeft } from 'lucide-react';

const AdminLoginPage = () => {
  const { login, isAdmin } = useContext(AuthContext);
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    if (isAdmin) {
      navigate('/admin-old/dashboard');
    }
  }, [isAdmin, navigate]);

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      if (process.env.REACT_APP_DEMO_MODE === 'true') {
        login('demo-token');
        navigate('/admin-old/dashboard');
        return;
      }

      const user = await apiService.login(email, password);
      if (user && (user.email === 'admin@vrindopnishad.com' || user.email === 'admin@vrindavaani.com')) {
        navigate('/admin-old/dashboard');
      } else {
        if (typeof user === 'string') {
          login(user);
          navigate('/admin-old/dashboard');
        } else {
          setError('Access denied: User is not an administrator.');
        }
      }
    } catch (err) {
      setError('Invalid admin credentials.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="animate-fade-in flex items-center justify-center py-12">
      <div className="glass-card w-full max-w-md p-8 md:p-12 border-t-4 border-t-red-500/30">
        <div className="text-center mb-10">
           <Link to="/" className="inline-flex items-center gap-2 text-white/40 hover:text-white mb-6 transition-colors">
             <ArrowLeft size={16} />
             Back to Home
           </Link>
           <div className="w-16 h-16 bg-red-500/10 rounded-full flex items-center justify-center mx-auto mb-4 text-red-500">
             <Shield size={32} />
           </div>
           <h1 className="text-3xl font-bold mb-2">Admin Portal</h1>
           <p className="text-white/40">Secure access for content moderators</p>
        </div>

        <form onSubmit={handleLogin} className="space-y-6">
          <div className="space-y-2">
            <label className="text-xs uppercase tracking-widest text-white/40 ml-1">Admin Email</label>
            <input 
              type="email" 
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full h-12 bg-white/5 border border-white/10 rounded-2xl px-6 outline-none focus:border-red-500/30 transition-colors"
              placeholder="admin@vrindopnishad.com"
              required
            />
          </div>

          <div className="space-y-2">
            <label className="text-xs uppercase tracking-widest text-white/40 ml-1">Secure Password</label>
            <div className="relative">
              <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-white/20" size={18} />
              <input 
                type="password" 
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full h-12 bg-white/5 border border-white/10 rounded-2xl pl-12 pr-6 outline-none focus:border-red-500/30 transition-colors"
                placeholder="••••••••"
                required
              />
            </div>
          </div>

          {error && (
            <div className="text-red-400 text-sm bg-red-400/10 p-3 rounded-xl border border-red-400/20">
               {error}
            </div>
          )}

          <button 
            type="submit" 
            disabled={loading}
            className="w-full h-13 bg-red-500/80 hover:bg-red-500 text-white rounded-2xl font-bold flex items-center justify-center gap-2 transition-all hover:scale-[1.02]"
          >
            {loading ? 'Verifying...' : (
              <>
                Unlock Dashboard
                <LogIn size={20} />
              </>
            )}
          </button>
        </form>
      </div>
    </div>
  );
};

export default AdminLoginPage;
