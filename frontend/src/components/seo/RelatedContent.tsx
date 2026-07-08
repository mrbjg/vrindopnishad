import React from 'react';
import { Link } from '@/lib/router-compat';

export interface RelatedItem {
  name: string;
  slug: string;
  category?: string;
  type: 'saint' | 'grantha' | 'verse' | 'raga' | 'glossary' | 'festival';
}

interface RelatedContentProps {
  items: RelatedItem[];
  title?: string;
  className?: string;
}

const typeConfig = {
  saint: { bg: 'bg-emerald-500/10', border: 'border-emerald-500/20', text: 'text-emerald-400', label: 'Saint', prefix: '/saints' },
  grantha: { bg: 'bg-amber-500/10', border: 'border-amber-500/20', text: 'text-amber-400', label: 'Scripture', prefix: '/granthas' },
  verse: { bg: 'bg-blue-500/10', border: 'border-blue-500/20', text: 'text-blue-400', label: 'Verse', prefix: '/lyrics' },
  raga: { bg: 'bg-purple-500/10', border: 'border-purple-500/20', text: 'text-purple-400', label: 'Raga', prefix: '/ragas' },
  glossary: { bg: 'bg-rose-500/10', border: 'border-rose-500/20', text: 'text-rose-400', label: 'Concept', prefix: '/glossary' },
  festival: { bg: 'bg-indigo-500/10', border: 'border-indigo-500/20', text: 'text-indigo-400', label: 'Festival', prefix: '/festivals' }
};

export default function RelatedContent({ items, title = 'Related Topics', className = '' }: RelatedContentProps) {
  if (!items || items.length === 0) return null;

  return (
    <nav className={`mt-16 pt-8 border-t border-white/10 ${className}`} aria-label="Related content links">
      <h2 className="text-xs font-bold uppercase tracking-widest mb-4 text-white/40">{title}</h2>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        {items.map((item) => {
          const cfg = typeConfig[item.type];
          if (!cfg) return null;

          return (
            <Link
              key={`${item.type}-${item.slug}`}
              href={`${cfg.prefix}/${encodeURIComponent(item.slug)}`}
              className="p-4 rounded-2xl bg-white/[0.01] border border-white/5 hover:border-amber-500/20 hover:bg-white/[0.02] flex items-center justify-between gap-4 transition-all duration-300 group"
            >
              <div className="flex flex-col gap-1">
                <span className={`text-[9px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-full w-fit ${cfg.bg} ${cfg.text} select-none`}>
                  {cfg.label}
                </span>
                <span className="text-xs font-medium text-white/80 group-hover:text-amber-400 transition-colors font-serif">
                  {item.name}
                </span>
              </div>
              <span className="text-white/20 group-hover:text-amber-400 group-hover:translate-x-0.5 transition-all text-xs select-none">
                →
              </span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
