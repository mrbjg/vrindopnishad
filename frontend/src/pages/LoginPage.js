import React, { useState, useContext, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { AuthContext } from '../App';
import { auth } from '../firebase';
import { signInWithEmailAndPassword } from 'firebase/auth';
import Loader from '../components/Loader';
import { Mail, Lock, LogIn, ArrowLeft } from 'lucide-react';

const LoginPage = () => {
  const { user } = useContext(AuthContext);
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    if (user) {
      navigate('/');
    }
  }, [user, navigate]);

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      await signInWithEmailAndPassword(auth, email, password);
      navigate('/');
    } catch (err) {
      console.error('Login error:', err);
      setError('Invalid email or password. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="animate-fade-in flex items-center justify-center py-12">
      <div className="glass-card w-full max-w-md p-8 md:p-12">
        <div className="text-center mb-10">
           <Link to="/" className="inline-flex items-center gap-2 text-white/40 hover:text-white mb-6 transition-colors">
             <ArrowLeft size={16} />
             Back to Home
           </Link>
           <div className="text-4xl mb-4">ॐ</div>
           <h1 className="text-3xl font-bold mb-2">Devotee Login</h1>
           <p className="text-white/40">Access your sacred digital library</p>
        </div>

        <form onSubmit={handleLogin} className="space-y-6">
          <div className="space-y-2">
            <label className="text-xs uppercase tracking-widest text-white/40 ml-1">Email Address</label>
            <div className="relative">
              <Mail className="absolute left-4 top-1/2 -translate-y-1/2 text-white/20" size={18} />
              <input 
                type="email" 
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full h-12 bg-white/5 border border-white/10 rounded-2xl pl-12 pr-6 outline-none focus:border-primary/50 transition-colors"
                placeholder="email@example.com"
                required
              />
            </div>
          </div>

          <div className="space-y-2">
            <label className="text-xs uppercase tracking-widest text-white/40 ml-1">Password</label>
            <div className="relative">
              <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-white/20" size={18} />
              <input 
                type="password" 
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full h-12 bg-white/5 border border-white/10 rounded-2xl pl-12 pr-6 outline-none focus:border-primary/50 transition-colors"
                placeholder="••••••••"
                required
              />
            </div>
          </div>

          {error && (
            <div className="text-red-400 text-sm bg-red-400/10 p-3 rounded-xl border border-red-400/20 flex items-center gap-2">
               <span>⚠️</span> {error}
            </div>
          )}

          <button 
            type="submit" 
            disabled={loading}
            className="btn-premium w-full h-13 justify-center text-base"
          >
            {loading ? 'Entering...' : (
              <>
                Sign In
                <LogIn size={20} />
              </>
            )}
          </button>
        </form>

        <div className="mt-10 pt-6 border-t border-white/5 text-center">
            <p className="text-sm text-white/30">
                Authorized Personnel? <Link to="/admin-old/login" className="text-primary hover:underline">Admin Portal</Link>
            </p>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;
