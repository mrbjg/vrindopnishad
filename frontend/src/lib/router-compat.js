'use client';

import React from 'react';
import NextLink from 'next/link';
import { usePathname, useRouter, useSearchParams as useNextSearchParams, useParams as useNextParams } from 'next/navigation';

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
  const searchParams = useNextSearchParams();
  return {
    pathname,
    search: searchParams ? `?${searchParams.toString()}` : '',
    hash: '',
    state: null
  };
}

export function useSearchParams() {
  const searchParams = useNextSearchParams();
  const setSearchParams = () => {};
  return [searchParams, setSearchParams];
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
