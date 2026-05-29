import React, { useState, useContext, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { AuthContext } from '../App';
import { apiService } from '../services/api';
import { Mail, Lock, LogIn, ArrowLeft, UserPlus, Info, User } from 'lucide-react';

const LoginPage = () => {
  const { user } = useContext(AuthContext);
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [fullName, setFullName] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [isSignUp, setIsSignUp] = useState(false);
  const [message, setMessage] = useState({ type: '', text: '' });

  useEffect(() => {
    if (user) {
      navigate('/');
    }
  }, [user, navigate]);

  const handleAuth = async (e) => {
    e.preventDefault();
    setLoading(true);
    setMessage({ type: '', text: '' });

    try {
      if (isSignUp) {
        await apiService.signUp(email, password, fullName);
      } else {
        await apiService.login(email, password);
      }
      navigate('/');
    } catch (err) {
      console.error('Auth error:', err);
      let errorMsg = err.message || 'An error occurred. Please try again.';
      if (err.code === 'auth/user-not-found') errorMsg = 'No account found with this email.';
      if (err.code === 'auth/wrong-password') errorMsg = 'Incorrect password.';
      if (err.code === 'auth/email-already-in-use') errorMsg = 'Email already registered.';
      setMessage({ type: 'error', text: errorMsg });
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleLogin = async () => {
    setLoading(true);
    try {
      await apiService.signInWithGoogle();
      navigate('/');
    } catch (err) {
      console.error('Google login error:', err);
      setMessage({ type: 'error', text: 'Google Sign-in failed.' });
    } finally {
      setLoading(false);
    }
  };

  const handleForgotPassword = async () => {
    if (!email) {
      setMessage({ type: 'error', text: 'Please enter your email first.' });
      return;
    }
    try {
      await apiService.resetPassword(email);
      setMessage({ type: 'success', text: 'Reset email sent! Check your inbox.' });
    } catch (err) {
      setMessage({ type: 'error', text: 'Failed to send reset email.' });
    }
  };

  return (
    <div className="animate-fade-in flex items-center justify-center py-12 px-4 relative min-h-screen w-full overflow-hidden">
      
      <div className="glow-blob-1"></div>
      <div className="glow-blob-2"></div>
      
      
      <div className="login-ambient-halo"></div>

      <div className="login-card w-full max-w-md p-8 md:p-12 relative z-10 overflow-hidden">
        
        <div className="absolute top-0 right-0 w-32 h-32 bg-primary/10 blur-[60px] rounded-full -mr-16 -mt-16 pointer-events-none"></div>
        
        <div className="text-center mb-10 relative z-10">
           <Link to="/" className="login-back-link inline-flex items-center gap-2 mb-6 transition-all duration-300 hover:-translate-x-1">
             <ArrowLeft size={16} />
             Back to Home
           </Link>
           
           
           <div className="om-badge-container">
             <div className="om-geometric-ring"></div>
             <div className="om-geometric-ring-inner"></div>
             <div className="om-symbol-glowing">ॐ</div>
           </div>

           <h1 className="login-title text-3xl font-bold mb-2 tracking-tight">
             {isSignUp ? 'Begin Journey' : 'Devotee Login'}
           </h1>
           <p className="login-subtitle font-medium text-sm">
             {isSignUp ? 'Create your spiritual profile' : 'Access your sacred digital library'}
           </p>
        </div>

        {message.text && (
          <div className={`mb-6 p-4 rounded-2xl border flex items-center gap-3 animate-in fade-in slide-in-from-top-2 duration-300 ${
            message.type === 'error' 
              ? 'bg-red-500/10 border-red-500/20 text-red-500' 
              : 'bg-green-500/10 border-green-500/20 text-green-500'
          }`}>
             {message.type === 'error' ? <Info size={18} /> : <span>✨</span>}
             <span className="text-sm font-medium">{message.text}</span>
          </div>
        )}

        <form onSubmit={handleAuth} className="space-y-6 relative z-10">
          {isSignUp && (
            <div className="space-y-2 animate-in fade-in slide-in-from-left-4 duration-500">
              <label className="login-label text-xs uppercase tracking-[0.2em] ml-1 font-semibold">Full Name</label>
              <div className="premium-input-container flex items-center px-4 gap-3 group relative">
                <User className="premium-input-icon flex-shrink-0" size={18} />
                <input 
                  type="text" 
                  id="name"
                  name="name"
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  className="premium-input-field text-sm"
                  placeholder="Your Name"
                  autocomplete="name"
                  required={isSignUp}
                />
              </div>
            </div>
          )}

          <div className="space-y-2">
            <label className="login-label text-xs uppercase tracking-[0.2em] ml-1 font-semibold">Email Address</label>
            <div className="premium-input-container flex items-center px-4 gap-3 group relative">
              <Mail className="premium-input-icon flex-shrink-0" size={18} />
              <input 
                type="email" 
                id="email"
                name="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="premium-input-field text-sm"
                placeholder="name@example.com"
                autocomplete="username"
                required
              />
            </div>
          </div>

          <div className="space-y-2">
            <div className="flex justify-between items-center px-1">
              <label className="login-label text-xs uppercase tracking-[0.2em] font-semibold">Password</label>
              {!isSignUp && (
                <button 
                  type="button" 
                  onClick={handleForgotPassword}
                  className="text-[10px] uppercase tracking-wider text-primary/60 hover:text-primary transition-colors font-bold cursor-pointer"
                >
                  Forgot?
                </button>
              )}
            </div>
            <div className="premium-input-container flex items-center px-4 gap-3 group relative">
              <Lock className="premium-input-icon flex-shrink-0" size={18} />
              <input 
                type="password" 
                id={isSignUp ? "new-password" : "current-password"}
                name="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="premium-input-field text-sm"
                placeholder="••••••••"
                autocomplete={isSignUp ? "new-password" : "current-password"}
                required
              />
            </div>
          </div>

          <button 
            type="submit" 
            disabled={loading}
            className="shimmer-btn w-full h-12 flex items-center justify-center gap-3 text-sm cursor-pointer"
          >
            {loading ? (
              <div className="flex items-center gap-2">
                <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                <span>Processing...</span>
              </div>
            ) : (
              <>
                <span>{isSignUp ? 'Join Sanctuary' : 'Sign In'}</span>
                {isSignUp ? <UserPlus size={18} /> : <LogIn size={18} />}
              </>
            )}
          </button>
        </form>

        <div className="login-divider relative my-8 flex items-center gap-4">
          <div className="login-divider-line h-[1px] flex-1"></div>
          <div className="login-divider-text text-xs uppercase tracking-[0.3em] font-bold">OR</div>
          <div className="login-divider-line h-[1px] flex-1"></div>
        </div>

        <button 
          onClick={handleGoogleLogin}
          disabled={loading}
          className="login-google-btn w-full h-12 flex items-center justify-center gap-3 transition-all duration-300 active:scale-[0.98] mb-10 group cursor-pointer"
        >
          <svg className="w-5 h-5 group-hover:scale-110 group-hover:rotate-12 transition-all duration-300 shrink-0" viewBox="0 0 24 24" width="20" height="20" xmlns="http://www.w3.org/2000/svg">
            <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
            <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
            <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z" fill="#FBBC05"/>
            <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
          </svg>
          <span className="text-sm font-bold tracking-wider">Continue with Google</span>
        </button>

        <div className="login-footer pt-6 text-center relative z-10">
            <p className="text-sm font-medium text-foreground/55">
                {isSignUp ? 'Already have an account?' : "Don't have an account?"}
                <button 
                  onClick={() => setIsSignUp(!isSignUp)}
                  className="ml-2 text-primary hover:text-primary-light transition-colors font-bold cursor-pointer"
                >
                  {isSignUp ? 'Sign In' : 'Create One'}
                </button>
            </p>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;
