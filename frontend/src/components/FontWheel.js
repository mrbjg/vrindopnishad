import React from 'react';
import { Type } from 'lucide-react';

const FontWheel = ({ value, onChange }) => {
  const sizes = [
    { id: 1, label: 'XS' },
    { id: 2, label: 'SM' },
    { id: 3, label: 'MD' },
    { id: 4, label: 'LG' },
    { id: 5, label: 'XL' }
  ];

  const parsedValue = parseInt(value, 10) || 3;

  return (
    <div className="font-wheel-wrapper group">
      <div className="font-wheel-label">
        <Type size={12} className="opacity-40" />
        <span>Appearance Dial</span>
      </div>
      
      <div className="font-wheel-container flex items-center justify-between px-2">
        {sizes.map((size) => (
          <button 
            key={size.id}
            onClick={() => onChange(size.id)}
            className={`font-wheel-item-segmented flex-1 ${parsedValue === size.id ? 'active' : ''}`}
            title={`Set text size to ${size.label}`}
          >
            <span className="font-wheel-text">{size.label}</span>
          </button>
        ))}
      </div>
    </div>
  );
};

export default FontWheel;
