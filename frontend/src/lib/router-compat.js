'use client';

import React from 'react';
import NextLink from 'next/link';
import { usePathname, useRouter, useParams as useNextParams } from 'next/navigation';

export function getSkeletonVariant(destination) {
  if (typeof destination !== 'string') return 'grid';
  const path = destination.toLowerCase().trim();
  const cleanPath = path.split('?')[0].split('#')[0].replace(/\/$/, '');

  // Detail views (must have a slug after the path prefix)
  if (/\/(content|lyrics)\/.+/.test(cleanPath)) {
    return 'detail';
  }
  if (/\/saints?\/.+/.test(cleanPath)) {
    return 'saint';
  }
  if (/\/(granthas|books|ragas|raga)\/.+/.test(cleanPath)) {
    return 'granth';
  }

  // Grid/List index views
  const gridPaths = [
    '',
    '/hi',
    '/content',
    '/hi/content',
    '/lyrics',
    '/hi/lyrics',
    '/saints',
    '/hi/saints',
    '/granthas',
    '/hi/granthas',
    '/books',
    '/hi/books',
    '/ragas',
    '/hi/ragas',
  ];
  
  if (gridPaths.includes(cleanPath) || /\/category\/.+/.test(cleanPath)) {
    return 'grid';
  }

  return 'list';
}

export const Link = React.forwardRef(({ to, href, children, onClick, ...props }, ref) => {
  const destination = to || href || '#';
  const router = useRouter();
  
  const isHashOrExternal = typeof destination === 'string' && (
    destination.startsWith('#') || 
    destination.startsWith('http') || 
    destination.startsWith('mailto:') ||
    destination.startsWith('tel:')
  );
  
  const handleMouseEnter = (e) => {
    if (props.onMouseEnter) props.onMouseEnter(e);
    if (!isHashOrExternal && destination && typeof destination === 'string') {
      try {
        router.prefetch(destination);
      } catch (err) {}
    }
  };

  const handleClick = (e) => {
    if (onClick) onClick(e);
    if (e.defaultPrevented) return;
    
    if (isHashOrExternal || e.button !== 0 || e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) {
      return;
    }
    
    e.preventDefault();
    
    const variant = getSkeletonVariant(destination);
    
    if (typeof window !== 'undefined') {
      window.dispatchEvent(new CustomEvent('instant-navigate', { detail: { variant, path: destination } }));
    }
    
    router.push(destination);
  };

  if (isHashOrExternal) {
    return (
      <a href={destination} ref={ref} onClick={onClick} {...props}>
        {children}
      </a>
    );
  }

  return (
    <a href={destination} ref={ref} onClick={handleClick} onMouseEnter={handleMouseEnter} onFocus={handleMouseEnter} {...props}>
      {children}
    </a>
  );
});

Link.displayName = 'Link';

export function useLocation() {
  const pathname = usePathname() || '';
  const [search, setSearch] = React.useState('');

  React.useEffect(() => {
    if (typeof window !== 'undefined') {
      setSearch(window.location.search || '');
    }
  }, [pathname]);

  return {
    pathname,
    search,
    hash: '',
    state: null
  };
}

export function useSearchParams() {
  const [searchParams, setSearchParams] = React.useState(null);

  React.useEffect(() => {
    if (typeof window !== 'undefined') {
      setSearchParams(new URLSearchParams(window.location.search));
    }
  }, []);

  const setParams = () => {};
  return [searchParams || new URLSearchParams(), setParams];
}

export function useNavigate() {
  const router = useRouter();
  return (to, options) => {
    if (!to) return;
    if (typeof to === 'number') {
      if (to === -1) router.back();
      else if (to === 1) router.forward();
      return;
    }
    const variant = getSkeletonVariant(to);
    if (typeof window !== 'undefined') {
      window.dispatchEvent(new CustomEvent('instant-navigate', { detail: { variant, path: to } }));
    }
    if (options?.replace) {
      router.replace(to);
    } else {
      router.push(to);
    }
  };
}

export function useParams() {
  return useNextParams() || {};
}

export function Outlet() {
  return null;
}
