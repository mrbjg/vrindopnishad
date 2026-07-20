import React from 'react';

const PageSkeleton = ({ variant = 'grid', count = 6 }) => {
  
  // ─────────────────────────────────────────────
  // 1. CONTENT DETAIL PAGE — /lyrics/[slug]
  //    Mirrors: Back link → Category badge + Author + Action buttons → Title → Description → Sanskrit section → AI section → Transliteration
  // ─────────────────────────────────────────────
  if (variant === 'detail') {
    return (
      <div className="animate-fade-in max-w-4xl mx-auto px-4 py-8">
        {/* Back link */}
        <div className="flex items-center gap-2 mb-8">
          <div className="skeleton w-4 h-4 rounded" />
          <div className="skeleton w-28 h-4 rounded" />
        </div>

        {/* Main content card area */}
        <div className="w-full px-0 py-4 md:px-14 md:py-14 mb-12">
          {/* Header: Badge + Author on left, Action buttons on right */}
          <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-10 mb-12 border-b border-white/5 pb-10">
            <div className="flex flex-col gap-6 w-full lg:w-auto">
              <div className="flex flex-col items-center lg:items-start gap-4">
                {/* Category badge */}
                <div className="skeleton w-20 h-6 rounded-full" />
                {/* Written By label + author name */}
                <div className="flex flex-col items-center lg:items-start">
                  <div className="skeleton w-16 h-2.5 rounded mb-2" />
                  <div className="skeleton w-48 h-7 rounded-lg" />
                </div>
              </div>
            </div>
            {/* Action buttons (desktop) */}
            <div className="hidden lg:flex items-center gap-4">
              <div className="skeleton w-10 h-10 rounded-full" />
              <div className="skeleton w-10 h-10 rounded-full" />
              <div className="skeleton w-10 h-10 rounded-full" />
              <div className="skeleton w-20 h-10 rounded-full" />
            </div>
          </div>

          {/* Title (large gradient heading) */}
          <div className="skeleton w-4/5 h-12 rounded-xl mb-4 pt-8" />
          <div className="skeleton w-3/5 h-12 rounded-xl mb-8 pb-4" />

          {/* Description quote */}
          <div className="pl-6 mb-12 space-y-3" style={{ borderLeft: '4px solid rgba(255,255,255,0.1)' }}>
            <div className="skeleton w-full h-4 rounded" />
            <div className="skeleton w-4/5 h-4 rounded" />
          </div>

          {/* Content Sections */}
          <div className="space-y-16">
            {/* Section 1: Sanskrit Text — centered lines with ॐ watermark feel */}
            <div className="relative py-8 sm:py-16 border-b border-white/5 flex flex-col items-center">
              {/* Section label */}
              <div className="flex items-center gap-4 mb-8 sm:mb-12">
                <div className="skeleton w-8 h-px rounded" />
                <div className="skeleton w-20 h-3 rounded" />
                <div className="skeleton w-8 h-px rounded" />
              </div>
              {/* Verse lines */}
              <div className="space-y-4 w-full max-w-2xl flex flex-col items-center">
                <div className="skeleton w-4/5 h-6 rounded" />
                <div className="skeleton w-3/5 h-6 rounded" />
                <div className="skeleton w-4/5 h-6 rounded" />
                <div className="skeleton w-2/3 h-6 rounded" />
                <div className="skeleton w-3/4 h-6 rounded" />
                <div className="skeleton w-1/2 h-6 rounded" />
              </div>
            </div>

            {/* Section 2: AI Insight section */}
            <div className="py-8 border-b border-white/5">
              {/* AI Header bar */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6 pb-4 border-b border-white/5">
                <div className="flex items-center gap-2">
                  <div className="skeleton w-4 h-4 rounded" />
                  <div className="skeleton w-24 h-3 rounded" />
                </div>
                <div className="flex items-center gap-6">
                  <div className="flex items-center gap-2">
                    <div className="skeleton w-20 h-3 rounded" />
                    <div className="skeleton w-8 h-4 rounded-full" />
                  </div>
                  <div className="skeleton w-24 h-7 rounded-full" />
                </div>
              </div>
              {/* CTA placeholder */}
              <div className="py-4">
                <div className="skeleton w-72 h-4 rounded mb-5" />
                <div className="skeleton w-40 h-10 rounded-xl" />
              </div>
            </div>

            {/* Section 3: Romanized Transliteration */}
            <div className="relative py-8 sm:py-16 border-b border-white/5 flex flex-col items-center">
              <div className="flex items-center gap-4 mb-8 sm:mb-12">
                <div className="skeleton w-8 h-px rounded" />
                <div className="skeleton w-28 h-3 rounded" />
                <div className="skeleton w-8 h-px rounded" />
              </div>
              <div className="space-y-4 w-full max-w-2xl flex flex-col items-center">
                <div className="skeleton w-full h-5 rounded" />
                <div className="skeleton w-4/5 h-5 rounded" />
                <div className="skeleton w-full h-5 rounded" />
                <div className="skeleton w-3/5 h-5 rounded" />
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // ─────────────────────────────────────────────
  // 2. SAINT DETAIL PAGE — /saints/[slug]
  //    Mirrors: Back link → Avatar + Badge + Name + 3 info grid boxes → Lineage card → Tabs bar → Bio text → Verses grid
  // ─────────────────────────────────────────────
  if (variant === 'saint') {
    return (
      <div className="animate-fade-in max-w-4xl mx-auto px-4 py-8">
        {/* Back Link */}
        <div className="flex items-center gap-2 mb-8">
          <div className="skeleton w-3.5 h-3.5 rounded" />
          <div className="skeleton w-16 h-3 rounded" />
        </div>

        {/* Header: Avatar + Name + 3 info boxes */}
        <div className="flex flex-col sm:flex-row items-center gap-6 mb-8 pb-6 border-b border-white/5 text-center sm:text-left">
          {/* Avatar circle */}
          <div className="w-24 h-24 rounded-full skeleton shrink-0" />
          <div className="flex-1 min-w-0 w-full space-y-3">
            {/* Badge */}
            <div className="skeleton w-32 h-5 rounded-full" />
            {/* Saint name */}
            <div className="skeleton w-3/4 h-10 rounded-xl" />
            {/* 3 info grid boxes (Lineage / Era / Place) */}
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 mt-3 w-full">
              {[1, 2, 3].map(i => (
                <div key={i} className="bg-white/[0.015] border border-white/5 rounded-xl p-2.5 space-y-1.5">
                  <div className="skeleton w-16 h-2 rounded" />
                  <div className="skeleton w-24 h-3.5 rounded" />
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Spiritual Lineage Card */}
        <div className="mb-8 p-5 rounded-2xl border border-white/5 bg-white/[0.01] space-y-4">
          <div className="flex items-center gap-2 mb-4">
            <div className="skeleton w-3.5 h-3.5 rounded" />
            <div className="skeleton w-52 h-3 rounded" />
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
            {[1, 2, 3, 4].map(i => (
              <div key={i} className="py-2 border-b border-white/5 flex justify-between gap-4">
                <div className="skeleton w-28 h-3 rounded" />
                <div className="skeleton w-36 h-3 rounded" />
              </div>
            ))}
          </div>
        </div>

        {/* Tab buttons bar */}
        <div className="flex border-b border-white/10 mb-8 gap-6 overflow-x-auto pb-[2px]">
          {['जीवनी', 'दर्शन', 'साहित्य', 'FAQ'].map(tab => (
            <div key={tab} className="py-3 flex-none">
              <div className="skeleton w-16 h-3 rounded" />
            </div>
          ))}
        </div>

        {/* Bio text block */}
        <div className="min-h-[16rem] space-y-3 mb-12">
          <div className="skeleton w-full h-4 rounded" />
          <div className="skeleton w-full h-4 rounded" />
          <div className="skeleton w-5/6 h-4 rounded" />
          <div className="skeleton w-full h-4 rounded" />
          <div className="skeleton w-2/3 h-4 rounded" />
          <div className="skeleton w-full h-4 rounded" />
          <div className="skeleton w-4/5 h-4 rounded" />
        </div>

        {/* Verses Section */}
        <div className="space-y-6">
          <div className="flex items-center justify-between">
            <div className="skeleton w-40 h-6 rounded-lg" />
            <div className="skeleton w-12 h-5 rounded-full" />
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {[1, 2, 3, 4].map(i => (
              <div key={i} className="border border-white/5 rounded-2xl p-5 h-36 flex flex-col justify-between">
                <div>
                  <div className="flex justify-between mb-3">
                    <div className="skeleton w-16 h-5 rounded-full" />
                    <div className="skeleton w-6 h-6 rounded-full" />
                  </div>
                  <div className="skeleton w-3/4 h-5 rounded-md" />
                </div>
                <div className="skeleton w-full h-3.5 rounded" />
              </div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  // ─────────────────────────────────────────────
  // 3. GRANTH / RAGA DETAIL PAGE — /granthas/[slug], /ragas/[slug]
  //    Mirrors: Back link → Badge + Title + Author info → Bookmark button → Verse count + grid
  // ─────────────────────────────────────────────
  if (variant === 'granth') {
    return (
      <div className="animate-fade-in max-w-4xl mx-auto px-4 py-8">
        {/* Back Link */}
        <div className="flex items-center gap-2 mb-8">
          <div className="skeleton w-3.5 h-3.5 rounded" />
          <div className="skeleton w-20 h-3 rounded" />
        </div>

        {/* Banner Details Row */}
        <div className="mb-10 pb-8 border-b border-white/5 flex flex-col md:flex-row md:items-end justify-between gap-6">
          <div className="space-y-3 flex-1">
            <div className="skeleton w-20 h-5 rounded-full" />
            <div className="skeleton w-2/3 h-10 rounded-xl" />
            <div className="flex items-center gap-2 mt-3">
              <div className="skeleton w-4 h-4 rounded-full" />
              <div className="skeleton w-36 h-4 rounded" />
            </div>
          </div>
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
                  <div className="flex justify-between mb-3">
                    <div className="skeleton w-16 h-5 rounded-full" />
                    <div className="skeleton w-6 h-6 rounded-full" />
                  </div>
                  <div className="skeleton w-3/4 h-5 rounded-md" />
                </div>
                <div className="skeleton w-full h-3.5 rounded" />
              </div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  // ─────────────────────────────────────────────
  // 4. SIDEBAR LIST LAYOUT (Daily Practice, etc.)
  //    Mirrors: Sidebar navigation + Main content area
  // ─────────────────────────────────────────────
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

  // ─────────────────────────────────────────────
  // 4.5. CARDS GRID ONLY (Saints, Books, Ragas list pages — no search/pills header)
  //    Mirrors: Glass card grid with badge + title + text + footer tags
  // ─────────────────────────────────────────────
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

  // ─────────────────────────────────────────────
  // 5. CATEGORY PAGE / CONTENT LIST — /lyrics, /category/[category]
  //    Mirrors: Title + subtitle → Search bar → Category pills → Card grid
  // ─────────────────────────────────────────────
  return (
    <div className="animate-fade-in">
      {/* Header: Title + Search */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-6 md:mb-8">
        <div>
          <div className="skeleton w-48 h-8 rounded-lg mb-2" />
          <div className="skeleton w-64 h-4 rounded" />
        </div>
        <div className="skeleton w-full md:w-80 h-11 rounded-2xl" />
      </div>
      
      {/* Category Pills */}
      <div className="flex gap-3 mb-8">
        {[1, 2, 3, 4, 5].map(i => (
          <div key={i} className="skeleton w-20 h-9 rounded-full flex-none" />
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
