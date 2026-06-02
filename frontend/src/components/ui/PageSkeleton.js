import React from 'react';

const PageSkeleton = ({ variant = 'grid', count = 6 }) => {
  
  // 1. Content Detail Page Skeleton (Breadcrumbs, Saint card, Sanskrit lines, Translations)
  if (variant === 'detail') {
    return (
      <div className="animate-fade-in max-w-4xl mx-auto px-4 py-8">
        {/* Breadcrumbs */}
        <div className="flex items-center gap-2 mb-8 text-xs select-none">
          <div className="skeleton w-12 h-4 rounded" />
          <span className="text-white/20">→</span>
          <div className="skeleton w-28 h-4 rounded" />
          <span className="text-white/20">→</span>
          <div className="skeleton w-36 h-4 rounded" />
        </div>

        {/* Written By metadata banner */}
        <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-10 mb-12 border-b border-white/5 pb-10">
          <div className="flex flex-col gap-6">
            <div className="flex flex-col items-center lg:items-start gap-4">
              <div className="skeleton w-24 h-6 rounded-full" />
              <div className="flex flex-col items-center lg:items-start">
                <div className="skeleton w-16 h-3 rounded mb-2" />
                <div className="skeleton w-56 h-8 rounded-lg" />
              </div>
            </div>
          </div>
          {/* Action buttons skeleton */}
          <div className="hidden lg:flex items-center gap-4">
            <div className="skeleton w-10 h-10 rounded-full" />
            <div className="skeleton w-10 h-10 rounded-full" />
            <div className="skeleton w-10 h-10 rounded-full" />
            <div className="skeleton w-24 h-10 rounded-full" />
          </div>
        </div>

        {/* Main Verse Heading */}
        <div className="skeleton w-3/4 h-12 rounded-xl mb-6" />
        <div className="skeleton w-1/2 h-12 rounded-xl mb-8" />

        {/* Description Box */}
        <div className="border-l-4 border-white/10 pl-6 mb-12 space-y-3">
          <div className="skeleton w-full h-4 rounded" />
          <div className="skeleton w-4/5 h-4 rounded" />
        </div>

        {/* Content Sections */}
        <div className="space-y-16">
          {/* Section 1: Sanskrit Text (Centered lines) */}
          <div className="py-12 border-b border-white/5 flex flex-col items-center">
            <div className="skeleton w-32 h-4 rounded mb-8" />
            <div className="space-y-4 w-2/3 flex flex-col items-center">
              <div className="skeleton w-full h-6 rounded" />
              <div className="skeleton w-5/6 h-6 rounded" />
              <div className="skeleton w-full h-6 rounded" />
              <div className="skeleton w-4/5 h-6 rounded" />
            </div>
          </div>

          {/* Section 2: Hindi Meaning (Left-aligned lines) */}
          <div className="py-12 border-b border-white/5">
            <div className="skeleton w-36 h-4 rounded mb-8" />
            <div className="space-y-4">
              <div className="skeleton w-full h-5 rounded" />
              <div className="skeleton w-11/12 h-5 rounded" />
              <div className="skeleton w-5/6 h-5 rounded" />
              <div className="skeleton w-full h-5 rounded" />
            </div>
          </div>

          {/* Section 3: Hinglish Transliteration */}
          <div className="py-12 border-b border-white/5">
            <div className="skeleton w-48 h-4 rounded mb-8" />
            <div className="space-y-4">
              <div className="skeleton w-full h-5 rounded" />
              <div className="skeleton w-4/5 h-5 rounded" />
            </div>
          </div>
        </div>
      </div>
    );
  }

  // 2. Saint Biography Detail Page Skeleton (Avatar circle, Info grid boxes, Tabs, bio card, verses list)
  if (variant === 'saint') {
    return (
      <div className="animate-fade-in max-w-4xl mx-auto px-4 py-8">
        {/* Back Link */}
        <div className="skeleton w-20 h-5 rounded mb-8" />

        {/* Header Grid: Avatar circle on left, Title + metadata boxes on right */}
        <div className="flex flex-col sm:flex-row items-center gap-6 mb-8 pb-6 border-b border-white/5">
          <div className="w-24 h-24 rounded-full skeleton shrink-0" />
          <div className="flex-1 w-full space-y-3">
            <div className="skeleton w-36 h-5 rounded-full" />
            <div className="skeleton w-3/4 h-10 rounded-xl" />
            {/* 3 info grid boxes */}
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 text-left mt-3 w-full">
              {[1, 2, 3].map(i => (
                <div key={i} className="border border-white/5 rounded-xl p-3 space-y-1">
                  <div className="skeleton w-12 h-3 rounded" />
                  <div className="skeleton w-20 h-4 rounded" />
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Traditional Lineage Card */}
        <div className="mb-8 p-5 rounded-2xl border border-white/5 bg-white/[0.005] space-y-4">
          <div className="skeleton w-48 h-4 rounded" />
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {[1, 2, 3, 4].map(i => (
              <div key={i} className="py-2 border-b border-white/5 flex justify-between">
                <div className="skeleton w-24 h-3 rounded" />
                <div className="skeleton w-32 h-4 rounded" />
              </div>
            ))}
          </div>
        </div>

        {/* Tab buttons bar */}
        <div className="flex border-b border-white/10 mb-8 gap-6 pb-[2px]">
          {['bio', 'teachings', 'literary', 'faq'].map(tab => (
            <div key={tab} className="py-3 w-20">
              <div className="skeleton w-full h-4 rounded" />
            </div>
          ))}
        </div>

        {/* Bio text box card */}
        <div className="mb-12 border-l-4 border-white/10 p-6 bg-white/[0.005] space-y-3">
          <div className="skeleton w-full h-4 rounded" />
          <div className="skeleton w-full h-4 rounded" />
          <div className="skeleton w-5/6 h-4 rounded" />
          <div className="skeleton w-full h-4 rounded" />
          <div className="skeleton w-2/3 h-4 rounded" />
        </div>

        {/* Verses list section */}
        <div className="space-y-6">
          <div className="skeleton w-48 h-8 rounded-lg" />
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {[1, 2, 3, 4].map(i => (
              <div key={i} className="border border-white/5 rounded-2xl p-5 h-36 flex flex-col justify-between">
                <div>
                  <div className="flex justify-between mb-2">
                    <div className="skeleton w-16 h-5 rounded" />
                    <div className="skeleton w-6 h-6 rounded-full" />
                  </div>
                  <div className="skeleton w-2/3 h-5 rounded-md" />
                </div>
                <div className="skeleton w-full h-4 rounded" />
              </div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  // 3. Scripture Grantha / Raga Detail Page Skeleton (Banner details, Verse catalog grid)
  if (variant === 'granth') {
    return (
      <div className="animate-fade-in max-w-4xl mx-auto px-4 py-8">
        {/* Back Link */}
        <div className="skeleton w-24 h-5 rounded mb-8" />

        {/* Banner Details Row */}
        <div className="mb-10 pb-8 border-b border-white/5 flex flex-col md:flex-row md:items-end justify-between gap-6">
          <div className="space-y-3 flex-1">
            <div className="skeleton w-24 h-4 rounded-full" />
            <div className="skeleton w-2/3 h-10 rounded-xl" />
            <div className="flex items-center gap-2 mt-3">
              <div className="skeleton w-4 h-4 rounded-full" />
              <div className="skeleton w-36 h-4 rounded" />
            </div>
          </div>
          {/* Bookmark Button */}
          <div className="skeleton w-32 h-10 rounded-full" />
        </div>

        {/* Verses Grid Section */}
        <div className="space-y-6">
          <div className="flex items-center justify-between mb-6">
            <div className="skeleton w-48 h-7 rounded-lg" />
            <div className="skeleton w-16 h-5 rounded-full" />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {Array.from({ length: count }, (_, i) => (
              <div key={i} className="border border-white/5 rounded-2xl p-5 h-36 flex flex-col justify-between">
                <div>
                  <div className="flex justify-between mb-2">
                    <div className="skeleton w-16 h-5 rounded" />
                    <div className="skeleton w-6 h-6 rounded-full" />
                  </div>
                  <div className="skeleton w-3/4 h-5 rounded-md" />
                </div>
                <div className="skeleton w-full h-4 rounded" />
              </div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  // 4. Sidebar List Layout (for settings sidebar or custom panels)
  if (variant === 'list') {
    return (
      <div className="animate-fade-in flex gap-6 w-full min-h-[60vh]">
        {/* Sidebar */}
        <div className="hidden lg:block w-56 shrink-0 space-y-3">
          <div className="skeleton w-full h-10 rounded-xl mb-4" />
          {[1, 2, 3, 4, 5, 6, 7].map(i => (
            <div key={i} className="skeleton w-full h-6 rounded" />
          ))}
        </div>
        
        {/* Main Content */}
        <div className="flex-1 space-y-4">
          <div className="skeleton w-2/3 h-8 rounded-lg mb-2" />
          <div className="skeleton w-1/3 h-4 rounded mb-6" />
          <div className="space-y-3">
            {[1, 2, 3, 4, 5].map(i => (
              <div key={i} className="skeleton w-full h-4 rounded" />
            ))}
          </div>
        </div>
      </div>
    );
  }

  // 4.5. Cards Grid Only (without headers/pills)
  if (variant === 'grid-only') {
    return (
      <div className="animate-fade-in grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        {Array.from({ length: count }, (_, i) => (
          <div key={i} className="skeleton-card flex flex-col justify-between h-52">
            <div>
              <div className="flex justify-between items-start mb-4">
                <div className="skeleton w-20 h-6 rounded-full" />
                <div className="skeleton w-6 h-6 rounded-full" />
              </div>
              <div className="skeleton skeleton-title w-3/4 mb-4" />
              <div className="space-y-2">
                <div className="skeleton skeleton-text w-full" />
                <div className="skeleton skeleton-text w-full" />
                <div className="skeleton skeleton-text w-2/3" />
              </div>
            </div>
            <div className="pt-4 border-t border-white/5 flex gap-2">
              <div className="skeleton w-16 h-5 rounded-md" />
              <div className="skeleton w-16 h-5 rounded-md" />
            </div>
          </div>
        ))}
      </div>
    );
  }

  // 5. Default Grid Layout Showcase (Search items, Collections index)
  return (
    <div className="animate-fade-in">
      {/* Search Bar section */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-6 md:mb-8">
        <div>
          <div className="skeleton w-48 h-8 rounded-lg mb-2" />
          <div className="skeleton w-64 h-4 rounded" />
        </div>
        <div className="skeleton w-full md:w-80 h-11 rounded-2xl" />
      </div>
      
      {/* Category Pills */}
      <div className="flex gap-3 mb-8">
        {[1, 2, 3, 4].map(i => (
          <div key={i} className="skeleton w-20 h-9 rounded-full" />
        ))}
      </div>
      
      {/* Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        {Array.from({ length: count }, (_, i) => (
          <div key={i} className="skeleton-card flex flex-col justify-between h-52">
            <div>
              <div className="flex justify-between items-start mb-4">
                <div className="skeleton w-20 h-6 rounded-full" />
                <div className="skeleton w-6 h-6 rounded-full" />
              </div>
              <div className="skeleton skeleton-title w-3/4 mb-4" />
              <div className="space-y-2">
                <div className="skeleton skeleton-text w-full" />
                <div className="skeleton skeleton-text w-full" />
                <div className="skeleton skeleton-text w-2/3" />
              </div>
            </div>
            <div className="pt-4 border-t border-white/5 flex gap-2">
              <div className="skeleton w-16 h-5 rounded-md" />
              <div className="skeleton w-16 h-5 rounded-md" />
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default PageSkeleton;
