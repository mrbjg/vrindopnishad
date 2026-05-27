import React, { useState, useEffect } from 'react';
import './App.css';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import axios from 'axios';
import { auth } from './firebase';
import { onAuthStateChanged, signOut } from 'firebase/auth';
import { AudioProvider } from './contexts/AudioContext';
import { LoadingProvider } from './contexts/LoadingContext';
import { useSettings } from './contexts/SettingsContext';
import { apiService } from './services/api';
import Layout from './components/Layout';
import ScrollToTop from './components/ScrollToTop';
import Lenis from 'lenis';
import 'lenis/dist/lenis.css';

// Performance: Route-based Code Splitting
const HomePage = React.lazy(() => import('./pages/HomePage'));
const ContentListPage = React.lazy(() => import('./pages/ContentListPage'));
const ContentDetailPage = React.lazy(() => import('./pages/ContentDetailPage'));
const CategoryPage = React.lazy(() => import('./pages/CategoryPage'));
const LoginPage = React.lazy(() => import('./pages/LoginPage'));
const AdminLoginPage = React.lazy(() => import('./pages/AdminLoginPage'));
const AdminDashboard = React.lazy(() => import('./pages/AdminDashboard'));
const LoaderDemo = React.lazy(() => import('./pages/LoaderDemo'));

// Dynamic Relations Pages
const SaintsListPage = React.lazy(() => import('./pages/SaintsListPage'));
const SaintDetailPage = React.lazy(() => import('./pages/SaintDetailPage'));
const BooksListPage = React.lazy(() => import('./pages/BooksListPage'));
const BookDetailPage = React.lazy(() => import('./pages/BookDetailPage'));
const RagasListPage = React.lazy(() => import('./pages/RagasListPage'));
const RagaDetailPage = React.lazy(() => import('./pages/RagaDetailPage'));

// SEO Content Pages
const WhatIsVrindopnishad = React.lazy(() => import('./pages/seo/WhatIsVrindopnishad'));
const MeaningPage = React.lazy(() => import('./pages/seo/MeaningPage'));
const OriginPage = React.lazy(() => import('./pages/seo/OriginPage'));
const PhilosophyPage = React.lazy(() => import('./pages/seo/PhilosophyPage'));
const TeachingsPage = React.lazy(() => import('./pages/seo/TeachingsPage'));
const ImportancePage = React.lazy(() => import('./pages/seo/ImportancePage'));
const DevotionalPage = React.lazy(() => import('./pages/seo/DevotionalPage'));
const FAQPage = React.lazy(() => import('./pages/seo/FAQPage'));
const ComparisonPage = React.lazy(() => import('./pages/seo/ComparisonPage'));
const GuidePage = React.lazy(() => import('./pages/seo/GuidePage'));
const BrajRasikHeritage = React.lazy(() => import('./pages/seo/BrajRasikHeritage'));
const RadhaSnataPage = React.lazy(() => import('./pages/seo/RadhaSnataPage'));
const NityaViharPage = React.lazy(() => import('./pages/seo/NityaViharPage'));

// Backend URL with fallback for development
const BACKEND_URL = process.env.REACT_APP_BACKEND_URL;
const USE_SUPABASE = process.env.REACT_APP_SUPABASE_URL && process.env.REACT_APP_SUPABASE_ANON_KEY;
const USE_MOCK_DATA = process.env.REACT_APP_DEMO_MODE === 'true';

export const API = USE_SUPABASE ? 'supabase' : (USE_MOCK_DATA ? null : `${BACKEND_URL}/api`);
export const USE_DEMO_MODE = USE_MOCK_DATA;

export const AuthContext = React.createContext();
export const ApiContext = React.createContext();

function App() {
  const { settings } = useSettings();
  const [isAdmin, setIsAdmin] = useState(false);
  const [user, setUser] = useState(null);
  const [token, setToken] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const storedToken = localStorage.getItem('admin_token');

    // Firebase Auth Listener
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      setUser(firebaseUser);
      if (firebaseUser) {
        const token = await firebaseUser.getIdToken();
        setToken(token);
        // If the user's email is the admin email, consider them admin
        if (firebaseUser.email === 'admin@vrindopnishad.com') {
          setIsAdmin(true);
        }
      } else {
        setToken(null);
        setIsAdmin(false);
      }
      setLoading(false);
    });

    if (storedToken) {
      verifyToken(storedToken);
    }

    return () => {
      unsubscribe();
    };
  }, []);

  // Dedicated useEffect for Smooth Scrolling (Lenis)
  useEffect(() => {
    // Detect mobile touch devices or small viewports
    const isMobile = window.matchMedia('(max-width: 1023px)').matches || 
                     ('ontouchstart' in window) || 
                     (navigator.maxTouchPoints > 0);

    if (!settings.smoothScroll || isMobile) {
      // Restore native scrolling immediately by clearing inline styles
      document.documentElement.style.removeProperty('overflow');
      document.body.style.removeProperty('overflow');
      document.documentElement.classList.remove('lenis');
      return;
    }

    // Initialize Lenis Smooth Scroll
    const lenis = new Lenis({
      duration: 1.2,
      easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
      orientation: 'vertical',
      gestureOrientation: 'vertical',
      smoothWheel: true,
      wheelMultiplier: 1,
      smoothTouch: false, // Disable touch handling on mobile to prevent conflicts
      infinite: false,
    });

    function raf(time) {
      lenis.raf(time);
      requestAnimationFrame(raf);
    }

    requestAnimationFrame(raf);

    return () => {
      lenis.destroy();
      document.documentElement.style.removeProperty('overflow');
      document.body.style.removeProperty('overflow');
    };
  }, [settings.smoothScroll]);

  const verifyToken = async (tk) => {
    try {
      if (USE_MOCK_DATA) {
        await apiService.verifyToken();
      } else {
        const response = await axios.get(`${API}/auth/verify`, {
          headers: { Authorization: `Bearer ${tk}` }
        });
        if (!response.data.valid) {
          localStorage.removeItem('admin_token');
          setLoading(false);
          return;
        }
      }
      setToken(tk);
      setIsAdmin(true);
    } catch (error) {
      console.log('Token verification failed, clearing token');
      localStorage.removeItem('admin_token');
    } finally {
      setLoading(false);
    }
  };

  const login = (newToken) => {
    localStorage.setItem('admin_token', newToken);
    setToken(newToken);
    setIsAdmin(true);
  };

  const logout = async () => {
    localStorage.removeItem('admin_token');
    setToken(null);
    setIsAdmin(false);
    await signOut(auth);
  };

  const refreshUser = () => {
    if (auth.currentUser) {
      // Create a new object reference to trigger re-render
      setUser({ ...auth.currentUser });
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center relative overflow-hidden bg-transparent">
        <div className="celestial-bg">
          <div className="stars"></div>
          <div className="nebula"></div>
        </div>
        <div className="flex flex-col items-center gap-8 animate-pulse">
          <div className="text-6xl text-primary/40">ॐ</div>
          <div className="skeleton w-48 h-1 rounded-full opacity-20"></div>
        </div>
      </div>
    );
  }

  return (
    <AudioProvider>
      <LoadingProvider>
        <AuthContext.Provider value={{ isAdmin, user, token, login, logout, refreshUser }}>
          <ApiContext.Provider value={{ apiService: apiService, isDemoMode: USE_MOCK_DATA }}>
            <BrowserRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
              <ScrollToTop />
              <Layout>
                <React.Suspense fallback={
                  <div className="min-h-[60vh] flex items-center justify-center">
                    <div className="text-4xl text-primary/20 animate-pulse">ॐ</div>
                  </div>
                }>
                  <Routes>
                    <Route path="/" element={<HomePage />} />
                    <Route path="/hi" element={<HomePage />} />
                    
                    <Route path="/content" element={<ContentListPage />} />
                    <Route path="/hi/content" element={<ContentListPage />} />
                    
                    <Route path="/content/:id" element={<ContentDetailPage />} />
                    <Route path="/hi/content/:id" element={<ContentDetailPage />} />
                    
                    <Route path="/category/:category" element={<CategoryPage />} />
                    <Route path="/hi/category/:category" element={<CategoryPage />} />
                    
                    <Route path="/loader-demo" element={<LoaderDemo />} />
                    
                    {/* Dynamic Relations Routes */}
                    <Route path="/saints" element={<SaintsListPage />} />
                    <Route path="/hi/saints" element={<SaintsListPage />} />
                    <Route path="/saint/:slug" element={<SaintDetailPage />} />
                    <Route path="/hi/saint/:slug" element={<SaintDetailPage />} />
                    
                    <Route path="/books" element={<BooksListPage />} />
                    <Route path="/hi/books" element={<BooksListPage />} />
                    <Route path="/book/:slug" element={<BookDetailPage />} />
                    <Route path="/hi/book/:slug" element={<BookDetailPage />} />
                    
                    <Route path="/ragas" element={<RagasListPage />} />
                    <Route path="/hi/ragas" element={<RagasListPage />} />
                    <Route path="/raga/:slug" element={<RagaDetailPage />} />
                    <Route path="/hi/raga/:slug" element={<RagaDetailPage />} />
                    
                    {/* SEO Content Pages */}
                    <Route path="/what-is-vrindopnishad" element={<WhatIsVrindopnishad />} />
                    <Route path="/hi/what-is-vrindopnishad" element={<WhatIsVrindopnishad />} />
                    
                    <Route path="/meaning" element={<MeaningPage />} />
                    <Route path="/hi/meaning" element={<MeaningPage />} />
                    
                    <Route path="/origin" element={<OriginPage />} />
                    <Route path="/hi/origin" element={<OriginPage />} />
                    
                    <Route path="/philosophy" element={<PhilosophyPage />} />
                    <Route path="/hi/philosophy" element={<PhilosophyPage />} />
                    
                    <Route path="/teachings" element={<TeachingsPage />} />
                    <Route path="/hi/teachings" element={<TeachingsPage />} />
                    
                    <Route path="/importance" element={<ImportancePage />} />
                    <Route path="/hi/importance" element={<ImportancePage />} />
                    
                    <Route path="/devotion" element={<DevotionalPage />} />
                    <Route path="/hi/devotion" element={<DevotionalPage />} />
                    
                    <Route path="/faq" element={<FAQPage />} />
                    <Route path="/hi/faq" element={<FAQPage />} />
                    
                    <Route path="/comparison-with-upanishads" element={<ComparisonPage />} />
                    <Route path="/hi/comparison-with-upanishads" element={<ComparisonPage />} />
                    
                    <Route path="/guide" element={<GuidePage />} />
                    <Route path="/hi/guide" element={<GuidePage />} />
                    
                    <Route path="/braj-rasik-heritage" element={<BrajRasikHeritage />} />
                    <Route path="/hi/braj-rasik-heritage" element={<BrajRasikHeritage />} />
                    
                    <Route path="/what-is-radha-snata" element={<RadhaSnataPage />} />
                    <Route path="/hi/what-is-radha-snata" element={<RadhaSnataPage />} />
                    
                    <Route path="/nitya-vihar-vs-nikunj-vihar" element={<NityaViharPage />} />
                    <Route path="/hi/nitya-vihar-vs-nikunj-vihar" element={<NityaViharPage />} />
                    
                    <Route path="/login" element={<LoginPage />} />
                    <Route path="/admin-old/login" element={<AdminLoginPage />} />
                    <Route
                      path="/admin-old/dashboard"
                      element={isAdmin ? <AdminDashboard /> : <Navigate to="/admin-old/login" />}
                    />
                    {/* Catch-all: redirect unknown routes to home */}
                    <Route path="*" element={<Navigate to="/" replace />} />
                  </Routes>
                </React.Suspense>
              </Layout>
            </BrowserRouter>
          </ApiContext.Provider>
        </AuthContext.Provider>
      </LoadingProvider>
    </AudioProvider>
  );
}

export default App;
