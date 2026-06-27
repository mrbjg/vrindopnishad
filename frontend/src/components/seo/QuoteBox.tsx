import React from 'react';

interface QuoteBoxProps {
  quote: string;
  author: string;
  source?: string;
  sourceUrl?: string;
  className?: string;
}

export default function QuoteBox({ quote, author, source, sourceUrl, className = '' }: QuoteBoxProps) {
  return (
    <blockquote className={`my-8 p-6 border-l-4 border-amber-500 bg-white/[0.01] rounded-r-2xl ${className}`}>
      <p className="text-sm font-serif italic text-white/90 leading-relaxed mb-3">
        "{quote}"
      </p>
      <footer className="text-[11px] text-white/40 flex items-center gap-1">
        <span className="font-medium text-white/60">— {author}</span>
        {source && (
          <>
            <span aria-hidden="true">•</span>
            {sourceUrl ? (
              <a
                href={sourceUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="hover:text-amber-400 transition-colors underline decoration-dotted"
              >
                <cite>{source}</cite>
              </a>
            ) : (
              <cite>{source}</cite>
            )}
          </>
        )}
      </footer>
    </blockquote>
  );
}
