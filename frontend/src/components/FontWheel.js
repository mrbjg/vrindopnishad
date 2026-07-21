import React from 'react';
import { Type } from 'lucide-react';

const FontWheel = ({ value, onChange, compact = false }) => {
  const sizes = [
    { id: 1, label: 'A-', title: 'Smaller Text' },
    { id: 2, label: 'A', title: 'Default Text' },
    { id: 4, label: 'A+', title: 'Larger Text' }
  ];

  const parsedValue = parseInt(value, 10) || 2;

  if (compact) {
    return (
      <div className="inline-flex items-center gap-1.5 p-1.5 rounded-full border border-[var(--glass-border)] bg-[var(--glass-bg)] backdrop-blur-md">
        {sizes.map((size) => (
          <button
            key={size.id}
            onClick={() => onChange(size.id)}
            className={`px-3 py-1 text-xs font-bold rounded-full transition-all ${
              parsedValue === size.id
                ? 'bg-[rgba(var(--primary-rgb),0.18)] text-[var(--primary-color)] border border-[rgba(var(--primary-rgb),0.35)] shadow-sm'
                : 'text-stone-700 dark:text-white/60 hover:text-stone-900 dark:hover:text-white'
            }`}
            title={size.title}
          >
            {size.label}
          </button>
        ))}
      </div>
    );
  }

  return (
    <div className="font-wheel-wrapper group">
      <div className="font-wheel-label">
        <Type size={12} className="opacity-40" />
        <span>Text Size</span>
      </div>
      
      <div className="font-wheel-container flex items-center justify-between px-2">
        {sizes.map((size) => (
          <button 
            key={size.id}
            onClick={() => onChange(size.id)}
            className={`font-wheel-item-segmented flex-1 ${parsedValue === size.id ? 'active' : ''}`}
            title={size.title}
          >
            <span className="font-wheel-text">{size.label}</span>
          </button>
        ))}
      </div>
    </div>
  );
};

export default FontWheel;
