import React, { useRef, useEffect, useState } from 'react';
import { Type } from 'lucide-react';

const FontWheel = ({ value, onChange }) => {
  const scrollRef = useRef(null);
  const [active, setActive] = useState(value);
  const sizes = [
    { id: 1, label: 'XS' },
    { id: 2, label: 'SM' },
    { id: 3, label: 'MD' },
    { id: 4, label: 'LG' },
    { id: 5, label: 'XL' }
  ];

  const isDragging = useRef(false);
  const startX = useRef(0);
  const scrollLeftStart = useRef(0);

  // Handle initial scroll position
  useEffect(() => {
    if (scrollRef.current) {
      const container = scrollRef.current;
      const activeItem = container.querySelector(`[data-id="${value}"]`);
      if (activeItem) {
        const scrollLeft = activeItem.offsetLeft - (container.offsetWidth / 2) + (activeItem.offsetWidth / 2);
        container.scrollTo({ left: scrollLeft, behavior: 'instant' });
      }
    }
  }, [value]);

  const handleScroll = () => {
    if (!scrollRef.current || isDragging.current) return;
    const container = scrollRef.current;
    const centerX = container.scrollLeft + container.offsetWidth / 2;
    
    let closestId = active;
    let minDistance = Infinity;

    // Only look at items with data-id
    const items = container.querySelectorAll('[data-id]');
    items.forEach((child) => {
      const childCenterX = child.offsetLeft + child.offsetWidth / 2;
      const distance = Math.abs(centerX - childCenterX);
      if (distance < minDistance) {
        minDistance = distance;
        closestId = parseInt(child.getAttribute('data-id'));
      }
    });

    if (closestId !== active) {
      setActive(closestId);
      onChange(closestId);
    }
  };

  const handleMouseDown = (e) => {
    isDragging.current = true;
    startX.current = e.pageX - scrollRef.current.offsetLeft;
    scrollLeftStart.current = scrollRef.current.scrollLeft;
    scrollRef.current.classList.add('dragging');
  };

  const handleMouseMove = (e) => {
    if (!isDragging.current) return;
    e.preventDefault();
    const x = e.pageX - scrollRef.current.offsetLeft;
    const walk = (x - startX.current) * 2; // scroll-fast factor
    scrollRef.current.scrollLeft = scrollLeftStart.current - walk;
  };

  const handleMouseStop = () => {
    if (!isDragging.current) return;
    isDragging.current = false;
    scrollRef.current.classList.remove('dragging');
    // Trigger snapping after drag
    handleScroll();
  };

  return (
    <div className="font-wheel-wrapper group">
      <div className="font-wheel-label">
        <Type size={12} className="opacity-40" />
        <span>Appearance Dial</span>
      </div>
      
      <div className="font-wheel-container">
        {/* Selection Indicator & Center Point */}
        <div className="font-wheel-indicator"></div>
        <div className="font-wheel-center-point"></div>
        
        <div 
          ref={scrollRef}
          onScroll={handleScroll}
          onMouseDown={handleMouseDown}
          onMouseMove={handleMouseMove}
          onMouseUp={handleMouseStop}
          onMouseLeave={handleMouseStop}
          className="font-wheel-scroll hide-scrollbar select-none cursor-grab active:cursor-grabbing"
        >
          {/* Padding for center alignment */}
          <div className="font-wheel-padding"></div>
          
          {sizes.map((size) => (
            <div 
              key={size.id}
              data-id={size.id}
              className={`font-wheel-item ${active === size.id ? 'active' : ''}`}
              onClick={(e) => {
                const container = scrollRef.current;
                const scrollLeft = e.currentTarget.offsetLeft - (container.offsetWidth / 2) + (e.currentTarget.offsetWidth / 2);
                container.scrollTo({ left: scrollLeft, behavior: 'smooth' });
              }}
            >
              <span className="font-wheel-text">{size.label}</span>
            </div>
          ))}
          
          <div className="font-wheel-padding"></div>
        </div>
      </div>
    </div>
  );
};

export default FontWheel;
