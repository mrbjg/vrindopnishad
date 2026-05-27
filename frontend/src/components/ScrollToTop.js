import { useEffect } from 'react';
import { useLocation } from 'react-router-dom';

const ScrollToTop = () => {
  const { pathname } = useLocation();

  useEffect(() => {
    window.scrollTo(0, 0);
    
    // Also scroll Pookiz layout main scroll container to top if present
    const pookizContainer = document.getElementById('pookiz-main-scroll-container');
    if (pookizContainer) {
      pookizContainer.scrollTo(0, 0);
    }
  }, [pathname]);

  return null;
};

export default ScrollToTop;
