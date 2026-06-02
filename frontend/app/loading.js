'use client';

import React from 'react';
import { usePathname } from 'next/navigation';
import PageSkeleton from '../src/components/ui/PageSkeleton';
import { getSkeletonVariant } from '../src/lib/router-compat';

export default function RootLoading() {
  const pathname = usePathname() || '';
  const variant = getSkeletonVariant(pathname);
  
  return (
    <div className="min-h-[80vh] flex flex-col justify-start py-8">
      <PageSkeleton variant={variant} />
    </div>
  );
}
