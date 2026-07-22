'use client';

import React, { useState, useEffect } from 'react';
import { SettingsProvider, useSettings } from './SettingsContext';
import { ThemeProvider } from './ThemeContext';
import { AudioProvider } from './AudioContext';
import { LoadingProvider } from './LoadingContext';
import { apiService } from '../services/api';
import { usePathname } from 'next/navigation';
const CelestialParticles = React.lazy(() => import('../components/CelestialParticles'));
import PageSkeleton from '../components/ui/PageSkeleton';
import ScrollToTop from '../components/ScrollToTop';
import Layout from '../components/Layout';
import Lenis from 'lenis';
import 'lenis/dist/lenis.css';

export const AuthContext = React.createContext();
export const ApiContext = React.createContext();

function PersistentBackground() {
  const [mounted, setMounted] = useState(false);
  const pathname = usePathname();
  const { settings } = useSettings();

  useEffect(() => {
    // Delay particles initialization until after critical FCP / LCP render
    const timer = setTimeout(() => {
      setMounted(true);
    }, 1200);
    return () => clearTimeout(timer);
  }, []);

  if (!mounted) return null;

  const isPromoOrLanding = pathname === '/promo' || 
                           pathname === '/landing' || 
                           pathname === '/hi/promo' || 
                           pathname === '/hi/landing';

  if (isPromoOrLanding) return null;
  if (settings.layoutMode === 'pookiz') return null;

  return (
    <div className="celestial-bg">
      <div className="stars"></div>
      <div className="nebula"></div>
      <React.Suspense fallback={null}>
        <CelestialParticles />
      </React.Suspense>
    </div>
  );
}

const LenisScroll = () => {
  const { settings } = useSettings();
  const pathname = usePathname();
  const [containerType, setContainerType] = useState('window');

  const isMobile = typeof window !== 'undefined' && (
    window.matchMedia('(max-width: 1023px)').matches || 
    ('ontouchstart' in window) || 
    (navigator.maxTouchPoints > 0)
  );

  useEffect(() => {
    if (typeof window === 'undefined') return;

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

    checkContainer();

    const observer = new MutationObserver(() => {
      checkContainer();
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true
    });

    return () => {
      observer.disconnect();
    };
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
      document.documentElement.style.removeProperty('height');
      document.body.style.removeProperty('height');
      document.documentElement.classList.remove('lenis');
      document.documentElement.classList.remove('lenis-stopped');
      document.documentElement.classList.remove('lenis-smooth');
      document.documentElement.classList.remove('lenis-scrolling');
      
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

export function ClientProviders({ children }) {
  const [isAdmin, setIsAdmin] = useState(false);
  const [user, setUser] = useState(null);
  const [token, setToken] = useState(null);
  const [loading, setLoading] = useState(true);
  const [transition, setTransition] = useState(null);
  const pathname = usePathname();

  useEffect(() => {
    console.log(`[InstantNavigate] Pathname changed to: "${pathname}". Resetting transition skeleton.`);
    setTransition(null);
  }, [pathname]);

  useEffect(() => {
    const handleInstantNavigate = (e) => {
      const { variant, path } = e.detail;
      const currentClean = window.location.pathname.toLowerCase().replace(/\/$/, '');
      const targetClean = path.split('?')[0].split('#')[0].toLowerCase().replace(/\/$/, '');
      
      console.log(`[InstantNavigate] Event received: variant="${variant}", path="${path}" (normalized: "${targetClean}"), currentPathname="${window.location.pathname}" (normalized: "${currentClean}")`);
      
      if (targetClean !== currentClean) {
        setTransition({ variant: variant || 'grid', path });
      }
    };
    window.addEventListener('instant-navigate', handleInstantNavigate);
    return () => {
      window.removeEventListener('instant-navigate', handleInstantNavigate);
    };
  }, []);

  useEffect(() => {
    const storedToken = typeof window !== 'undefined' ? localStorage.getItem('admin_token') : null;

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
    } else {
      setLoading(false);
    }

    return () => {
      unsubscribe();
    };
  }, []);

  const verifyToken = async (tk) => {
    try {
      await apiService.verifyToken();
      setToken(tk);
      setIsAdmin(true);
    } catch (error) {
      console.log('Token verification failed, clearing token');
      if (typeof window !== 'undefined') {
        localStorage.removeItem('admin_token');
      }
    } finally {
      setLoading(false);
    }
  };

  const login = (newToken) => {
    if (typeof window !== 'undefined') {
      localStorage.setItem('admin_token', newToken);
    }
    setToken(newToken);
    setIsAdmin(true);
  };

  const logout = async () => {
    if (typeof window !== 'undefined') {
      localStorage.removeItem('admin_token');
    }
    setToken(null);
    setIsAdmin(false);
    await apiService.logout();
  };

  const refreshUser = () => {
    
  };

  const isAdminRoute = typeof window !== 'undefined' && window.location.pathname.startsWith('/admin');
  if (loading && isAdminRoute) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#09090b]">
        <div className="flex flex-col items-center gap-8 animate-pulse">
          <div className="text-6xl text-amber-500/40">ॐ</div>
          <div className="w-48 h-1 bg-amber-500/20 rounded-full"></div>
        </div>
      </div>
    );
  }

  return (
    <SettingsProvider>
      <ThemeProvider>
        <AudioProvider>
          <LoadingProvider>
            <AuthContext.Provider value={{ isAdmin, user, token, login, logout, refreshUser }}>
              <ApiContext.Provider value={{ apiService, isDemoMode: false, transition }}>
                <PersistentBackground />
                <ScrollToTop />
                <LenisScroll />
                <Layout>
                  {children}
                </Layout>
              </ApiContext.Provider>
            </AuthContext.Provider>
          </LoadingProvider>
        </AudioProvider>
      </ThemeProvider>
    </SettingsProvider>
  );
}
export default ClientProviders;
