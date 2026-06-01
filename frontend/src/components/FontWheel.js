import React from 'react';
import { Type } from 'lucide-react';

const FontWheel = ({ value, onChange }) => {
  const sizes = [
    { id: 1, label: 'A-', title: 'Smaller Text' },
    { id: 2, label: 'A', title: 'Default Text' },
    { id: 4, label: 'A+', title: 'Larger Text' }
  ];

  const parsedValue = parseInt(value, 10) || 2;

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
