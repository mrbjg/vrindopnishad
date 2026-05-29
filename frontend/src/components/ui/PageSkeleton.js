import React from 'react';


const PageSkeleton = ({ variant = 'grid', count = 6 }) => {

  if (variant === 'detail') {
    return (
      <div className="animate-fade-in max-w-4xl mx-auto px-4 py-8">
        
        <div className="flex items-center gap-2 mb-6">
          <div className="skeleton w-16 h-4 rounded" />
          <div className="skeleton w-3 h-3 rounded-full" />
          <div className="skeleton w-24 h-4 rounded" />
        </div>
        
        <div className="skeleton w-3/4 h-8 rounded-lg mb-3" />
        <div className="skeleton w-1/3 h-4 rounded mb-8" />
        
        <div className="space-y-4">
          <div className="skeleton w-full h-4 rounded" />
          <div className="skeleton w-full h-4 rounded" />
          <div className="skeleton w-5/6 h-4 rounded" />
          <div className="skeleton w-full h-4 rounded" />
          <div className="skeleton w-2/3 h-4 rounded" />
        </div>
        <div className="mt-8 space-y-4">
          <div className="skeleton w-1/2 h-6 rounded-lg" />
          <div className="skeleton w-full h-4 rounded" />
          <div className="skeleton w-full h-4 rounded" />
          <div className="skeleton w-4/5 h-4 rounded" />
        </div>
      </div>
    );
  }

  if (variant === 'list') {
    return (
      <div className="animate-fade-in flex gap-6 w-full min-h-[60vh]">
        
        <div className="hidden lg:block w-56 shrink-0 space-y-3">
          <div className="skeleton w-full h-10 rounded-xl mb-4" />
          {[1,2,3,4,5,6,7].map(i => (
            <div key={i} className="skeleton w-full h-6 rounded" />
          ))}
        </div>
        
        <div className="flex-1 space-y-4">
          <div className="skeleton w-2/3 h-8 rounded-lg mb-2" />
          <div className="skeleton w-1/3 h-4 rounded mb-6" />
          <div className="space-y-3">
            {[1,2,3,4,5].map(i => (
              <div key={i} className="skeleton w-full h-4 rounded" />
            ))}
          </div>
        </div>
      </div>
    );
  }

  
  return (
    <div className="animate-fade-in">
      
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-6 md:mb-8">
        <div>
          <div className="skeleton w-48 h-8 rounded-lg mb-2" />
          <div className="skeleton w-64 h-4 rounded" />
        </div>
        <div className="skeleton w-full md:w-80 h-11 rounded-2xl" />
      </div>
      
      <div className="flex gap-3 mb-8">
        {[1,2,3,4].map(i => (
          <div key={i} className="skeleton w-20 h-9 rounded-full" />
        ))}
      </div>
      
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
