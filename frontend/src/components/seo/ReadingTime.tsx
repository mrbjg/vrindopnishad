import React from 'react';

interface ReadingTimeProps {
  text: string;
  wpm?: number;
  className?: string;
}

export default function ReadingTime({ text, wpm = 200, className = '' }: ReadingTimeProps) {
  if (!text) return null;

  const wordCount = text.trim().split(/\s+/).length;
  const time = Math.max(1, Math.round(wordCount / wpm));

  return (
    <span className={`inline-flex items-center gap-1 text-[11px] text-white/40 ${className}`}>
      <svg className="w-3.5 h-3.5 text-amber-500/70" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
      <span>{time} min read</span>
    </span>
  );
}
