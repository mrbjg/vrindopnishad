'use client';

import React, { useState, useEffect } from 'react';
import { SettingsProvider, useSettings } from './SettingsContext';
import { ThemeProvider } from './ThemeContext';
import { AudioProvider } from './AudioContext';
import { LoadingProvider } from './LoadingContext';
import { apiService } from '../services/api';
import { usePathname } from 'next/navigation';
import CelestialParticles from '../components/CelestialParticles';
import PageSkeleton from '../components/ui/PageSkeleton';

export const AuthContext = React.createContext();
export const ApiContext = React.createContext();

function PersistentBackground() {
  const [mounted, setMounted] = useState(false);
  const pathname = usePathname();
  const { settings } = useSettings();

  useEffect(() => {
    setMounted(true);
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
      <CelestialParticles />
    </div>
  );
}

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
        console.log(`[InstantNavigate] Path mismatch detected. Triggering instant skeleton swap: variant="${variant}"`);
        setTransition({ variant, path });
      } else {
        console.log(`[InstantNavigate] Same path clicked. Bypassing skeleton swap.`);
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
              <ApiContext.Provider value={{ apiService, isDemoMode: false }}>
                <PersistentBackground />
                {transition ? (
                  <div className="min-h-[80vh] flex flex-col justify-start py-8">
                    <PageSkeleton variant={transition.variant} />
                  </div>
                ) : children}
              </ApiContext.Provider>
            </AuthContext.Provider>
          </LoadingProvider>
        </AudioProvider>
      </ThemeProvider>
    </SettingsProvider>
  );
}
export default ClientProviders;
