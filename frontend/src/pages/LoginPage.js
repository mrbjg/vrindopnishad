import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { apiService } from '../services/api';
import { useLoading } from '../contexts/LoadingContext';
import Navigation from '../components/Navigation';

const LoginPage = () => {
    const [isLogin, setIsLogin] = useState(true);
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const { showLoading, hideLoading } = useLoading();
    const navigate = useNavigate();

    const handleEmailAuth = async (e) => {
        e.preventDefault();
        setError('');
        showLoading(isLogin ? 'Signing in...' : 'Creating account...');

        try {
            if (isLogin) {
                await apiService.login(email, password);
            } else {
                await apiService.signUp(email, password);
                if (!isLogin) {
                    alert('Check your email for the confirmation link!');
                }
            }
            navigate('/');
        } catch (err) {
            setError(err.message || 'Authentication failed');
        } finally {
            hideLoading();
        }
    };

    const handleGoogleSignIn = async () => {
        setError('');
        showLoading('Signing in with Google...');
        try {
            await apiService.signInWithGoogle();
            // OAuth redirect will handle the navigation
        } catch (err) {
            setError(err.message || 'Google Sign-In failed');
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
                        <div className="om-symbol mb-3" style={{ fontSize: '3rem', color: '#f59e0b' }}>ॐ</div>
                        <h2>{isLogin ? 'Welcome Back' : 'Create Account'}</h2>
                        <p style={{ color: '#666', marginTop: '0.5rem' }}>
                            {isLogin
                                ? 'Sign in to continue your spiritual journey'
                                : 'Begin your path to enlightenment'}
                        </p>
                    </div>

                    <form onSubmit={handleEmailAuth}>
                        <div className="form-group">
                            <label className="form-label">Email</label>
                            <input
                                type="email"
                                className="form-input"
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                placeholder="name@example.com"
                                required
                            />
                        </div>

                        <div className="form-group">
                            <label className="form-label">Password</label>
                            <input
                                type="password"
                                className="form-input"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                placeholder="Min 6 characters"
                                required
                            />
                        </div>

                        {error && (
                            <div style={{
                                padding: '1rem',
                                background: '#ffebee',
                                borderRadius: '8px',
                                color: '#c62828',
                                marginBottom: '1rem',
                                fontSize: '0.9rem'
                            }}>
                                {error}
                            </div>
                        )}

                        <button
                            type="submit"
                            className="btn btn-primary"
                            style={{ width: '100%', marginBottom: '1rem' }}
                        >
                            {isLogin ? 'Sign In' : 'Create Account'}
                        </button>
                    </form>

                    <div className="text-center mb-4">
                        <span style={{ color: '#999', fontSize: '0.9rem' }}>OR</span>
                    </div>

                    <button
                        onClick={handleGoogleSignIn}
                        className="btn"
                        style={{
                            width: '100%',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            background: 'white',
                            border: '1px solid #ddd',
                            color: '#333'
                        }}
                    >
                        <img
                            src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg"
                            alt="Google"
                            style={{ width: '18px', marginRight: '10px' }}
                        />
                        Continue with Google
                    </button>

                    <div className="mt-4 text-center">
                        <p style={{ fontSize: '0.9rem', color: '#666' }}>
                            {isLogin ? "Don't have an account? " : "Already have an account? "}
                            <button
                                onClick={() => setIsLogin(!isLogin)}
                                style={{
                                    background: 'none',
                                    border: 'none',
                                    color: '#f59e0b',
                                    fontWeight: 'bold',
                                    cursor: 'pointer'
                                }}
                            >
                                {isLogin ? 'Sign Up' : 'Sign In'}
                            </button>
                        </p>
                    </div>

                    <div className="mt-3 text-center border-t pt-3">
                        <Link to="/admin/login" style={{ fontSize: '0.8rem', color: '#999' }}>
                            Admin Login
                        </Link>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default LoginPage;
