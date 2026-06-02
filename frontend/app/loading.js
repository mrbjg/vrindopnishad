import React from 'react';
import PageSkeleton from '../src/components/ui/PageSkeleton';

export default function RootLoading() {
  return <PageSkeleton variant="grid" count={6} />;
}
