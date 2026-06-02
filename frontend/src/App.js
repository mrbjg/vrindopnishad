import React, { useState, useEffect } from 'react';
import './App.css';
import { BrowserRouter, Routes, Route, Navigate, useLocation } from 'react-router-dom';
import axios from 'axios';
import { auth } from './firebase';
import { AudioProvider } from './contexts/AudioContext';
import { LoadingProvider } from './contexts/LoadingContext';
import { useSettings } from './contexts/SettingsContext';
import { apiService } from './services/api';
import Layout from './components/Layout';
import ScrollToTop from './components/ScrollToTop';
import PageSkeleton from './components/ui/PageSkeleton';
import Lenis from 'lenis';
import 'lenis/dist/lenis.css';


const lazyWithRetry = (componentImport) => React.lazy(() => 
  componentImport().catch((error) => {
    const errorMsg = error && error.message ? String(error.message).toLowerCase() : '';
    const errorName = error && error.name ? String(error.name).toLowerCase() : '';
    const isChunkError = 
      errorMsg.includes('loading chunk') || 
      errorMsg.includes('unexpected token') || 
      errorMsg.includes('failed to fetch') ||
      errorMsg.includes('dynamically imported') ||
      errorName.includes('chunkloaderror');
    if (isChunkError) {
      window.location.reload();
      return new Promise(() => {}); 
    }
    throw error;
  })
);


const HomePage = lazyWithRetry(() => import('./pages/HomePage'));
const ContentListPage = lazyWithRetry(() => import('./pages/ContentListPage'));
const ContentDetailPage = lazyWithRetry(() => import('./pages/ContentDetailPage'));
const CategoryPage = lazyWithRetry(() => import('./pages/CategoryPage'));
const LoginPage = lazyWithRetry(() => import('./pages/LoginPage'));
const AdminLoginPage = lazyWithRetry(() => import('./pages/AdminLoginPage'));
const AdminDashboard = lazyWithRetry(() => import('./pages/AdminDashboard'));
const LoaderDemo = lazyWithRetry(() => import('./pages/LoaderDemo'));
const BookmarksPage = lazyWithRetry(() => import('./pages/BookmarksPage'));


const SaintsListPage = lazyWithRetry(() => import('./pages/SaintsListPage'));
const SaintDetailPage = lazyWithRetry(() => import('./pages/SaintDetailPage'));
const BooksListPage = lazyWithRetry(() => import('./pages/BooksListPage'));
const BookDetailPage = lazyWithRetry(() => import('./pages/BookDetailPage'));
const RagasListPage = lazyWithRetry(() => import('./pages/RagasListPage'));
const RagaDetailPage = lazyWithRetry(() => import('./pages/RagaDetailPage'));


const WhatIsVrindopnishad = lazyWithRetry(() => import('./pages/seo/WhatIsVrindopnishad'));
const MeaningPage = lazyWithRetry(() => import('./pages/seo/MeaningPage'));
const OriginPage = lazyWithRetry(() => import('./pages/seo/OriginPage'));
const PhilosophyPage = lazyWithRetry(() => import('./pages/seo/PhilosophyPage'));
const TeachingsPage = lazyWithRetry(() => import('./pages/seo/TeachingsPage'));
const ImportancePage = lazyWithRetry(() => import('./pages/seo/ImportancePage'));
const DevotionalPage = lazyWithRetry(() => import('./pages/seo/DevotionalPage'));
const FAQPage = lazyWithRetry(() => import('./pages/seo/FAQPage'));
const ComparisonPage = lazyWithRetry(() => import('./pages/seo/ComparisonPage'));
const GuidePage = lazyWithRetry(() => import('./pages/seo/GuidePage'));
const BrajRasikHeritage = lazyWithRetry(() => import('./pages/seo/BrajRasikHeritage'));
const RadhaSnataPage = lazyWithRetry(() => import('./pages/seo/RadhaSnataPage'));
const NityaViharPage = lazyWithRetry(() => import('./pages/seo/NityaViharPage'));
const GlossaryPage = lazyWithRetry(() => import('./pages/seo/GlossaryPage'));
const PlacesPage = lazyWithRetry(() => import('./pages/seo/PlacesPage'));
const HariraeJiPage = lazyWithRetry(() => import('./pages/seo/HariraeJiPage'));
const MadhuryaBhavaPage = lazyWithRetry(() => import('./pages/seo/MadhuryaBhavaPage'));
const RadhavallabhVsGaudiya = lazyWithRetry(() => import('./pages/seo/RadhavallabhVsGaudiya'));
const ParikramaGuide = lazyWithRetry(() => import('./pages/seo/ParikramaGuide'));
const GlossaryDetailPage = lazyWithRetry(() => import('./pages/seo/GlossaryDetailPage'));
const MajorRasikSaints = lazyWithRetry(() => import('./pages/seo/MajorRasikSaints'));
const KnowledgeBasePage = lazyWithRetry(() => import('./pages/KnowledgeBasePage'));
const HistoryOfRadhavallabh = lazyWithRetry(() => import('./pages/seo/HistoryOfRadhavallabh'));
const AboutPage = lazyWithRetry(() => import('./pages/seo/AboutPage'));
const EditorialPolicyPage = lazyWithRetry(() => import('./pages/seo/EditorialPolicyPage'));
const SourcesPage = lazyWithRetry(() => import('./pages/seo/SourcesPage'));
const ContactPage = lazyWithRetry(() => import('./pages/seo/ContactPage'));
const KnowledgeBaseLayout = lazyWithRetry(() => import('./components/KnowledgeBaseLayout'));
const PromoLanding = lazyWithRetry(() => import('./pages/PromoLanding'));




const BACKEND_URL = process.env.REACT_APP_BACKEND_URL;
const USE_SUPABASE = process.env.REACT_APP_DATABASE_PROVIDER === 'supabase' && process.env.REACT_APP_SUPABASE_URL && process.env.REACT_APP_SUPABASE_ANON_KEY;
const USE_MOCK_DATA = process.env.REACT_APP_DEMO_MODE === 'true';

export const API = USE_SUPABASE ? 'supabase' : (USE_MOCK_DATA ? null : `${BACKEND_URL}/api`);
export const USE_DEMO_MODE = USE_MOCK_DATA;

export const AuthContext = React.createContext();
export const ApiContext = React.createContext();

const LenisScroll = () => {
  const { settings } = useSettings();
  const { pathname } = useLocation();
  const [containerType, setContainerType] = useState('window');

  
  const isMobile = window.matchMedia('(max-width: 1023px)').matches || 
                   ('ontouchstart' in window) || 
                   (navigator.maxTouchPoints > 0);

  
  useEffect(() => {
    const checkContainer = () => {
      const pookizContainer = document.getElementById('pookiz-main-scroll-container');
      const kbClassicContainer = document.getElementById('kb-classic-content-container');
      
      let detectedType = 'window';
      if (settings.layoutMode === 'pookiz' && pookizContainer) {
        detectedType = 'pookiz';
      } else if (kbClassicContainer) {
        detectedType = 'kb';
      }

      if (detectedType !== containerType) {
        setContainerType(detectedType);
      }
    };

    const frameId = requestAnimationFrame(checkContainer);
    return () => cancelAnimationFrame(frameId);
  }, [pathname, settings.layoutMode, containerType]);

  useEffect(() => {
    
    if (isMobile) return;

    
    if (!settings.smoothScroll) {
      document.documentElement.style.removeProperty('overflow');
      document.body.style.removeProperty('overflow');
      document.documentElement.classList.remove('lenis');
      return;
    }

    const pookizContainer = document.getElementById('pookiz-main-scroll-container');
    const kbClassicContainer = document.getElementById('kb-classic-content-container');

    
    const lenisOptions = {
      duration: 1.2,
      easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
      orientation: 'vertical',
      gestureOrientation: 'vertical',
      smoothWheel: true,
      wheelMultiplier: 1,
      smoothTouch: false,
      infinite: false,
    };

    if (containerType === 'pookiz' && pookizContainer) {
      lenisOptions.wrapper = pookizContainer;
      lenisOptions.content = pookizContainer.firstElementChild || pookizContainer;
    } else if (containerType === 'kb' && kbClassicContainer) {
      lenisOptions.wrapper = kbClassicContainer;
      lenisOptions.content = kbClassicContainer.firstElementChild || kbClassicContainer;
    }

    const lenis = new Lenis(lenisOptions);
    window.lenis = lenis;

    function raf(time) {
      lenis.raf(time);
      requestAnimationFrame(raf);
    }

    const rafId = requestAnimationFrame(raf);

    
    const resizeObserver = new ResizeObserver(() => {
      lenis.resize();
    });

    const target = containerType === 'pookiz' && pookizContainer ? pookizContainer :
                   containerType === 'kb' && kbClassicContainer ? kbClassicContainer :
                   document.body;

    if (target) {
      resizeObserver.observe(target);
    }

    return () => {
      cancelAnimationFrame(rafId);
      resizeObserver.disconnect();
      lenis.destroy();
      window.lenis = null;
      document.documentElement.style.removeProperty('overflow');
      document.body.style.removeProperty('overflow');
      
      if (pookizContainer) {
        pookizContainer.style.removeProperty('overflow');
      }
      if (kbClassicContainer) {
        kbClassicContainer.style.removeProperty('overflow');
      }
    };
  }, [settings.smoothScroll, containerType, isMobile]);

  return null;
};

function App() {
  const [isAdmin, setIsAdmin] = useState(false);
  const [user, setUser] = useState(null);
  const [token, setToken] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const storedToken = localStorage.getItem('admin_token');

    
    const unsubscribe = apiService.onAuthChanged(async (currentUser, activeToken) => {
      setUser(currentUser);
      setToken(activeToken);
      if (currentUser) {
        
        if (currentUser.email === 'admin@vrindopnishad.com' || currentUser.email === 'admin@vrindavaani.com') {
          setIsAdmin(true);
        }
      } else {
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

  
  useEffect(() => {
    const timer = setTimeout(() => {
      
      try {
        apiService.getAllContent(null, 10000);
      } catch (e) {
        console.warn('Failed to warm up database cache:', e);
      }

      
      const preloadList = [
        () => import('./pages/ContentListPage'),
        () => import('./pages/ContentDetailPage'),
        () => import('./pages/SaintsListPage'),
        () => import('./pages/SaintDetailPage'),
        () => import('./pages/BooksListPage'),
        () => import('./pages/BookDetailPage'),
        () => import('./pages/RagasListPage'),
        () => import('./pages/RagaDetailPage'),
        () => import('./pages/KnowledgeBasePage')
      ];

      const loadNextChunk = (index) => {
        if (index >= preloadList.length) return;

        
        const scheduler = window.requestIdleCallback || ((cb) => setTimeout(cb, 1000));

        scheduler(() => {
          preloadList[index]()
            .then(() => {
              
              setTimeout(() => loadNextChunk(index + 1), 600);
            })
            .catch(() => {
              
              setTimeout(() => loadNextChunk(index + 1), 300);
            });
        });
      };

      loadNextChunk(0);
    }, 4500); 
    return () => clearTimeout(timer);
  }, []);

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
    await apiService.logout();
  };

  const refreshUser = () => {
    if (auth?.currentUser) {
      
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

  
  const mainRoutes = [
    { path: '/', element: <HomePage /> },
    { path: '/content', element: <ContentListPage /> },
    { path: '/content/:id', element: <ContentDetailPage /> },
    { path: '/category/:category', element: <CategoryPage /> },
    { path: '/loader-demo', element: <LoaderDemo /> },
    { path: '/saints', element: <SaintsListPage /> },
    { path: '/saint/:slug', element: <SaintDetailPage /> },
    { path: '/saints/:slug', element: <SaintDetailPage /> },
    { path: '/books', element: <BooksListPage /> },
    { path: '/book/:slug', element: <BookDetailPage /> },
    { path: '/granthas', element: <BooksListPage /> },
    { path: '/granthas/:slug', element: <BookDetailPage /> },
    { path: '/ragas', element: <RagasListPage /> },
    { path: '/raga/:slug', element: <RagaDetailPage /> },
    { path: '/ragas/:slug', element: <RagaDetailPage /> },
    { path: '/bookmarks', element: <BookmarksPage /> }
  ];

  const kbRoutes = [
    { path: 'knowledge-base', element: <KnowledgeBasePage /> },
    { path: 'what-is-vrindopnishad', element: <WhatIsVrindopnishad /> },
    { path: 'meaning', element: <MeaningPage /> },
    { path: 'origin', element: <OriginPage /> },
    { path: 'philosophy', element: <PhilosophyPage /> },
    { path: 'teachings', element: <TeachingsPage /> },
    { path: 'importance', element: <ImportancePage /> },
    { path: 'devotion', element: <DevotionalPage /> },
    { path: 'faq', element: <FAQPage /> },
    { path: 'comparison-with-upanishads', element: <ComparisonPage /> },
    { path: 'guide', element: <GuidePage /> },
    { path: 'braj-rasik-heritage', element: <BrajRasikHeritage /> },
    { path: 'what-is-radha-snata', element: <RadhaSnataPage /> },
    { path: 'nitya-vihar-vs-nikunj-vihar', element: <NityaViharPage /> },
    { path: 'glossary', element: <GlossaryPage /> },
    { path: 'glossary/:slug', element: <GlossaryDetailPage /> },
    { path: 'history-of-radhavallabh-sampradaya', element: <HistoryOfRadhavallabh /> },
    { path: 'major-rasik-saints-of-braj', element: <MajorRasikSaints /> },
    { path: 'places', element: <PlacesPage /> },
    { path: 'who-is-harirae-ji', element: <HariraeJiPage /> },
    { path: 'what-is-madhurya-and-sakhi-bhava', element: <MadhuryaBhavaPage /> },
    { path: 'radhavallabh-vs-gaudiya-sampradaya', element: <RadhavallabhVsGaudiya /> },
    { path: 'vrindavan-parikrama-guide', element: <ParikramaGuide /> },
    { path: 'about', element: <AboutPage /> },
    { path: 'editorial-policy', element: <EditorialPolicyPage /> },
    { path: 'sources', element: <SourcesPage /> },
    { path: 'contact', element: <ContactPage /> }
  ];

  return (
    <AudioProvider>
      <LoadingProvider>
        <AuthContext.Provider value={{ isAdmin, user, token, login, logout, refreshUser }}>
          <ApiContext.Provider value={{ apiService: apiService, isDemoMode: USE_MOCK_DATA }}>
            <BrowserRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
              <ScrollToTop />
              <LenisScroll />
              <Routes>
                {/* Promo/Landing — full-screen, NO Layout wrapper */}
                <Route path="/promo" element={
                  <React.Suspense fallback={null}>
                    <PromoLanding />
                  </React.Suspense>
                } />
                <Route path="/landing" element={
                  <React.Suspense fallback={null}>
                    <PromoLanding />
                  </React.Suspense>
                } />
                <Route path="/hi/promo" element={
                  <React.Suspense fallback={null}>
                    <PromoLanding />
                  </React.Suspense>
                } />
                <Route path="/hi/landing" element={
                  <React.Suspense fallback={null}>
                    <PromoLanding />
                  </React.Suspense>
                } />

                {/* All other routes — wrapped in Layout */}
                <Route path="*" element={
                  <Layout>
                    <React.Suspense fallback={<PageSkeleton variant="grid" count={6} />}>
                      <Routes>
                        {mainRoutes.flatMap(({ path, element }) => [
                          <Route key={path} path={path} element={element} />,
                          <Route key={`hi-${path}`} path={path === '/' ? '/hi' : `/hi${path}`} element={element} />
                        ])}

                        <Route element={<KnowledgeBaseLayout />}>
                          {kbRoutes.flatMap(({ path, element }) => [
                            <Route key={path} path={`/${path}`} element={element} />,
                            <Route key={`hi-${path}`} path={`/hi/${path}`} element={element} />
                          ])}
                        </Route>

                        <Route path="/login" element={<LoginPage />} />
                        <Route path="/admin-old/login" element={<AdminLoginPage />} />
                        <Route
                          path="/admin-old/dashboard"
                          element={isAdmin ? <AdminDashboard /> : <Navigate to="/admin-old/login" />}
                        />

                        <Route path="*" element={<Navigate to="/" replace />} />
                      </Routes>
                    </React.Suspense>
                  </Layout>
                } />
              </Routes>
            </BrowserRouter>
          </ApiContext.Provider>
        </AuthContext.Provider>
      </LoadingProvider>
    </AudioProvider>
  );
}

export default App;
