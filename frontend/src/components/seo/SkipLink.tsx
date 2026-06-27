import React from 'react';

interface SkipLinkProps {
  targetId?: string;
  label?: string;
}

export default function SkipLink({ targetId = 'main-content', label = 'Skip to main content' }: SkipLinkProps) {
  return (
    <a
      href={`#${targetId}`}
      className="sr-only focus:not-sr-only focus:fixed focus:top-4 focus:left-4 focus:z-[9999] focus:bg-amber-600 focus:text-white focus:px-4 focus:py-2.5 focus:rounded-xl focus:font-medium focus:text-xs focus:shadow-2xl focus:border focus:border-amber-400 focus:outline-none transition-all"
    >
      {label}
    </a>
  );
}
