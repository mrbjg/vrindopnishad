'use client';

import React, { useState, useEffect } from 'react';
import { SettingsProvider } from './SettingsContext';
import { ThemeProvider } from './ThemeContext';
import { AudioProvider } from './AudioContext';
import { LoadingProvider } from './LoadingContext';
import { apiService } from '../services/api';

export const AuthContext = React.createContext();
export const ApiContext = React.createContext();

export function ClientProviders({ children }) {
  const [isAdmin, setIsAdmin] = useState(false);
  const [user, setUser] = useState(null);
  const [token, setToken] = useState(null);
  const [loading, setLoading] = useState(true);

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

  if (loading) {
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
                {children}
              </ApiContext.Provider>
            </AuthContext.Provider>
          </LoadingProvider>
        </AudioProvider>
      </ThemeProvider>
    </SettingsProvider>
  );
}
export default ClientProviders;
