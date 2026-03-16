import React, { useState, useContext, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { AuthContext } from '../App';
import { auth } from '../firebase';
import { 
  signInWithEmailAndPassword, 
  createUserWithEmailAndPassword, 
  sendPasswordResetEmail,
  GoogleAuthProvider,
  signInWithPopup
} from 'firebase/auth';
import { Mail, Lock, LogIn, ArrowLeft, Chrome, UserPlus, Info } from 'lucide-react';

const LoginPage = () => {
  const { user } = useContext(AuthContext);
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
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
        await createUserWithEmailAndPassword(auth, email, password);
      } else {
        await signInWithEmailAndPassword(auth, email, password);
      }
      navigate('/');
    } catch (err) {
      console.error('Auth error:', err);
      let errorMsg = 'An error occurred. Please try again.';
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
      const provider = new GoogleAuthProvider();
      await signInWithPopup(auth, provider);
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
      await sendPasswordResetEmail(auth, email);
      setMessage({ type: 'success', text: 'Reset email sent! Check your inbox.' });
    } catch (err) {
      setMessage({ type: 'error', text: 'Failed to send reset email.' });
    }
  };

  return (
    <div className="animate-fade-in flex items-center justify-center py-12 px-4">
      <div className="glass-card w-full max-w-md p-8 md:p-12 relative overflow-hidden">
        {/* Decorative Background Elements */}
        <div className="absolute top-0 right-0 w-32 h-32 bg-primary/10 blur-[60px] rounded-full -mr-16 -mt-16 pointer-events-none"></div>
        
        <div className="text-center mb-10 relative z-10">
           <Link to="/" className="inline-flex items-center gap-2 text-white/40 hover:text-white mb-6 transition-all duration-300 hover:-translate-x-1">
             <ArrowLeft size={16} />
             Back to Home
           </Link>
           <div className="text-5xl mb-4 animate-bounce-slow">ॐ</div>
           <h1 className="text-3xl font-bold mb-2 tracking-tight">
             {isSignUp ? 'Begin Journey' : 'Devotee Login'}
           </h1>
           <p className="text-white/40 font-medium">
             {isSignUp ? 'Create your spiritual profile' : 'Access your sacred digital library'}
           </p>
        </div>

        {message.text && (
          <div className={`mb-6 p-4 rounded-2xl border flex items-center gap-3 animate-in fade-in slide-in-from-top-2 duration-300 ${
            message.type === 'error' 
              ? 'bg-red-500/10 border-red-500/20 text-red-400' 
              : 'bg-green-500/10 border-green-500/20 text-green-400'
          }`}>
             {message.type === 'error' ? <Info size={18} /> : <span>✨</span>}
             <span className="text-sm font-medium">{message.text}</span>
          </div>
        )}

        <form onSubmit={handleAuth} className="space-y-6 relative z-10">
          <div className="space-y-2">
            <label className="text-xs uppercase tracking-[0.2em] text-white/40 ml-1 font-semibold">Email Address</label>
            <div className="relative group">
              <Mail className="absolute left-4 top-1/2 -translate-y-1/2 text-white/20 group-focus-within:text-primary/60 transition-colors" size={18} />
              <input 
                type="email" 
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full h-13 bg-white/5 border border-white/10 rounded-2xl pl-12 pr-6 outline-none focus:border-primary/40 focus:bg-white/10 transition-all duration-300"
                placeholder="name@example.com"
                required
              />
            </div>
          </div>

          <div className="space-y-2">
            <div className="flex justify-between items-center px-1">
              <label className="text-xs uppercase tracking-[0.2em] text-white/40 font-semibold">Password</label>
              {!isSignUp && (
                <button 
                  type="button" 
                  onClick={handleForgotPassword}
                  className="text-[10px] uppercase tracking-wider text-primary/60 hover:text-primary transition-colors font-bold"
                >
                  Forgot?
                </button>
              )}
            </div>
            <div className="relative group">
              <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-white/20 group-focus-within:text-primary/60 transition-colors" size={18} />
              <input 
                type="password" 
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full h-13 bg-white/5 border border-white/10 rounded-2xl pl-12 pr-6 outline-none focus:border-primary/40 focus:bg-white/10 transition-all duration-300"
                placeholder="••••••••"
                required
              />
            </div>
          </div>

          <button 
            type="submit" 
            disabled={loading}
            className="btn-premium w-full h-14 justify-center text-base shadow-lg shadow-primary/20"
          >
            {loading ? 'Processing...' : (
              <>
                {isSignUp ? 'Join Sanctuary' : 'Sign In'}
                {isSignUp ? <UserPlus size={20} /> : <LogIn size={20} />}
              </>
            )}
          </button>
        </form>

        <div className="relative my-8">
          <div className="absolute inset-0 flex items-center">
            <span className="w-full border-t border-white/5"></span>
          </div>
          <div className="relative flex justify-center text-xs uppercase">
            <span className="bg-[#0f0a1f] px-4 text-white/20 tracking-widest font-bold">OR</span>
          </div>
        </div>

        <button 
          onClick={handleGoogleLogin}
          disabled={loading}
          className="w-full h-13 bg-white/5 border border-white/10 rounded-2xl flex items-center justify-center gap-3 hover:bg-white/10 hover:border-white/20 transition-all duration-300 active:scale-95 mb-10"
        >
          <Chrome size={20} className="text-white/60" />
          <span className="text-sm font-semibold tracking-wide">Continue with Google</span>
        </button>

        <div className="pt-6 border-t border-white/5 text-center relative z-10">
            <p className="text-sm text-white/30 font-medium">
                {isSignUp ? 'Already have an account?' : "Don't have an account?"}
                <button 
                  onClick={() => setIsSignUp(!isSignUp)}
                  className="ml-2 text-primary hover:text-primary-light transition-colors font-bold"
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
