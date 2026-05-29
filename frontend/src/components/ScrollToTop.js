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

    // Also scroll Classic KB layout content scroll container to top if present
    const kbClassicContainer = document.getElementById('kb-classic-content-container');
    if (kbClassicContainer) {
      kbClassicContainer.scrollTo(0, 0);
    }

    // Reset Lenis smooth scroll coordinates and boundary limits if active
    if (window.lenis) {
      window.lenis.scrollTo(0, { immediate: true });
      window.lenis.resize();
    }
  }, [pathname]);

  return null;
};

export default ScrollToTop;
