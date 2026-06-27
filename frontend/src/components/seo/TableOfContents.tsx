'use client';

import React, { useEffect, useState } from 'react';

interface HeadingItem {
  id: string;
  text: string;
  level: number;
}

interface TableOfContentsProps {
  contentSelector?: string;
  title?: string;
}

export default function TableOfContents({ contentSelector = 'article', title = 'Table of Contents' }: TableOfContentsProps) {
  const [headings, setHeadings] = useState<HeadingItem[]>([]);
  const [activeId, setActiveId] = useState<string>('');

  useEffect(() => {
    const container = document.querySelector(contentSelector);
    if (!container) return;

    // Query both h2 and h3 inside the content container
    const headingElements = container.querySelectorAll('h2, h3');
    const items: HeadingItem[] = [];

    headingElements.forEach((el, idx) => {
      // Ensure the heading has an id for linking
      if (!el.id) {
        const text = el.textContent || '';
        el.id = `toc-heading-${idx}-${text.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '')}`;
      }

      items.push({
        id: el.id,
        text: el.textContent || '',
        level: el.tagName === 'H2' ? 2 : 3,
      });
    });

    setHeadings(items);

    // IntersectionObserver to watch which heading is active
    const observer = new IntersectionObserver(
      (entries) => {
        const visibleEntries = entries.filter((e) => e.isIntersecting);
        if (visibleEntries.length > 0) {
          // Set the top-most visible heading as active
          const sorted = visibleEntries.sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top);
          setActiveId(sorted[0].target.id);
        }
      },
      { rootMargin: '-10% 0px -80% 0px' }
    );

    headingElements.forEach((el) => observer.observe(el));

    return () => observer.disconnect();
  }, [contentSelector]);

  if (headings.length === 0) return null;

  return (
    <nav className="p-5 border border-white/5 rounded-2xl bg-white/[0.01] sticky top-24 max-h-[calc(100vh-120px)] overflow-y-auto" aria-label="Table of contents">
      <h2 className="text-[10px] font-bold uppercase tracking-widest text-amber-500/80 mb-4 select-none">
        {title}
      </h2>
      <ul className="space-y-2.5 text-xs text-white/50">
        {headings.map((h) => (
          <li
            key={h.id}
            style={{ paddingLeft: h.level === 3 ? '12px' : '0px' }}
            className="transition-all duration-300"
          >
            <a
              href={`#${h.id}`}
              onClick={(e) => {
                e.preventDefault();
                document.getElementById(h.id)?.scrollIntoView({ behavior: 'smooth' });
              }}
              className={`hover:text-amber-400 block py-0.5 leading-snug transition-colors ${
                activeId === h.id ? 'text-amber-500 font-medium scale-[1.02] origin-left' : ''
              }`}
            >
              {h.text}
            </a>
          </li>
        ))}
      </ul>
    </nav>
  );
}
