import { useEffect } from 'react';
import { useLocation } from 'react-router-dom';

const ScrollToTop = () => {
  const { pathname } = useLocation();

  useEffect(() => {
    window.scrollTo(0, 0);
    
    
    const pookizContainer = document.getElementById('pookiz-main-scroll-container');
    if (pookizContainer) {
      pookizContainer.scrollTo(0, 0);
    }

    
    const kbClassicContainer = document.getElementById('kb-classic-content-container');
    if (kbClassicContainer) {
      kbClassicContainer.scrollTo(0, 0);
    }

    
    if (window.lenis) {
      window.lenis.scrollTo(0, { immediate: true });
      window.lenis.resize();
    }
  }, [pathname]);

  return null;
};

export default ScrollToTop;
