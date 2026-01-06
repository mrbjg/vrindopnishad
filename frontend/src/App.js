import React, { useState, useEffect } from 'react';
import './App.css';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import axios from 'axios';
import HomePage from './pages/HomePage';
import ContentListPage from './pages/ContentListPage';
import ContentDetailPage from './pages/ContentDetailPage';
import AdminLoginPage from './pages/AdminLoginPage';
import AdminDashboard from './pages/AdminDashboard';
import CategoryPage from './pages/CategoryPage';
import LoaderDemo from './pages/LoaderDemo';
import { mockApiService } from './services/mockData';
import Loader from './components/Loader';
import { LoadingProvider } from './contexts/LoadingContext';
import { ThemeProvider } from './contexts/ThemeContext';

import { auth } from './firebase';
import { onAuthStateChanged, signOut as firebaseSignOut } from 'firebase/auth';
import LoginPage from './pages/LoginPage';

// Backend URL with fallback for development
const BACKEND_URL = process.env.REACT_APP_BACKEND_URL || 'http://localhost:8000';
const USE_MOCK_DATA = process.env.REACT_APP_DEMO_MODE === 'true' || !BACKEND_URL || BACKEND_URL === '';
export const API = USE_MOCK_DATA ? null : `${BACKEND_URL}/api`;
export const USE_DEMO_MODE = USE_MOCK_DATA;

export const AuthContext = React.createContext();
export const ApiContext = React.createContext();

function App() {
  const [isAdmin, setIsAdmin] = useState(false);
  const [user, setUser] = useState(null);
  const [token, setToken] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const storedToken = localStorage.getItem('admin_token');

    // Firebase Auth Listener
    const unsubscribe = onAuthStateChanged(auth, (firebaseUser) => {
      setUser(firebaseUser);
      if (!storedToken) {
        setLoading(false);
      }
    });

    if (storedToken) {
      verifyToken(storedToken);
    }

    return () => unsubscribe();
  }, []);

  const verifyToken = async (tk) => {
    try {
      if (USE_MOCK_DATA) {
        await mockApiService.verifyToken();
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
    await firebaseSignOut(auth);
  };

  if (loading) {
    return <Loader fullScreen text="Loading Vrindopnishad..." />;
  }

  return (
    <ThemeProvider>
      <LoadingProvider>
        <AuthContext.Provider value={{ isAdmin, user, token, login, logout }}>
          <ApiContext.Provider value={{ apiService: USE_MOCK_DATA ? mockApiService : null, isDemoMode: USE_MOCK_DATA }}>
            <div className="App min-h-screen bg-background text-foreground">
              {USE_MOCK_DATA && (
                <div className="fixed top-2.5 right-2.5 bg-amber-500 text-white px-4 py-2 rounded-lg z-[1000] text-xs font-bold shadow-lg">
                  📋 Demo Mode (No Backend)
                </div>
              )}
              <BrowserRouter basename={process.env.PUBLIC_URL}>
                <Routes>
                  <Route path="/" element={<HomePage />} />
                  <Route path="/content" element={<ContentListPage />} />
                  <Route path="/content/:id" element={<ContentDetailPage />} />
                  <Route path="/category/:category" element={<CategoryPage />} />
                  <Route path="/loader-demo" element={<LoaderDemo />} />
                  <Route path="/login" element={<LoginPage />} />
                  <Route path="/admin-old/login" element={<AdminLoginPage />} />
                  <Route
                    path="/admin-old/dashboard"
                    element={isAdmin ? <AdminDashboard /> : <Navigate to="/admin-old/login" />}
                  />
                </Routes>
              </BrowserRouter>
            </div>
          </ApiContext.Provider>
        </AuthContext.Provider>
      </LoadingProvider>
    </ThemeProvider>
  );
}

export default App;
