'use client';

import React from 'react';
import NextLink from 'next/link';
import { usePathname, useRouter, useParams as useNextParams } from 'next/navigation';

export const Link = React.forwardRef(({ to, href, children, ...props }, ref) => {
  const destination = to || href || '#';
  
  
  const isHashOrExternal = typeof destination === 'string' && (destination.startsWith('#') || destination.startsWith('http') || destination.startsWith('mailto:'));
  
  if (isHashOrExternal) {
    return (
      <a href={destination} ref={ref} {...props}>
        {children}
      </a>
    );
  }

  return (
    <NextLink href={destination} ref={ref} {...props}>
      {children}
    </NextLink>
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
