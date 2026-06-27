import React from 'react';

export interface LinkProps extends React.AnchorHTMLAttributes<HTMLAnchorElement> {
  to?: string;
  href?: string;
  children?: React.ReactNode;
}

export const Link: React.ForwardRefExoticComponent<LinkProps & React.RefAttributes<HTMLAnchorElement>>;

export function getSkeletonVariant(destination: string): 'detail' | 'saint' | 'granth' | 'grid' | 'list';

export function useLocation(): {
  pathname: string;
  search: string;
};
