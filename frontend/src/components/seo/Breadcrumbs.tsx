import React from 'react';
import { Link } from '@/lib/router-compat';
import { generateBreadcrumbSchema, BreadcrumbItem } from '@/lib/schemas';
import JsonLd from './JsonLd';

interface BreadcrumbsProps {
  items: BreadcrumbItem[];
  className?: string;
}

export default function Breadcrumbs({ items, className = '' }: BreadcrumbsProps) {
  const schema = generateBreadcrumbSchema(items);

  return (
    <>
      <JsonLd data={schema} />
      <nav
        aria-label="Breadcrumb"
        className={`max-w-6xl mx-auto px-4 pt-4 mb-2 flex flex-wrap items-center gap-1.5 text-xs text-white/50 select-none ${className}`}
      >
        {items.map((item, idx) => {
          const isLast = idx === items.length - 1;

          return (
            <React.Fragment key={item.path}>
              {idx > 0 && <span className="mx-1 text-white/30" aria-hidden="true">→</span>}
              {isLast ? (
                <span className="text-white/80 font-medium truncate max-w-[200px] sm:max-w-xs" aria-current="page">
                  {item.name}
                </span>
              ) : (
                <Link
                  href={item.path}
                  className="hover:text-amber-400 transition-colors font-normal text-white/50"
                >
                  {item.name}
                </Link>
              )}
            </React.Fragment>
          );
        })}
      </nav>
    </>
  );
}
