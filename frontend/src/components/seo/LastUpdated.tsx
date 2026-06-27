import React from 'react';

interface LastUpdatedProps {
  date: string;
  className?: string;
}

export default function LastUpdated({ date, className = '' }: LastUpdatedProps) {
  if (!date) return null;

  let displayDate = date;
  try {
    const d = new Date(date);
    if (!isNaN(d.getTime())) {
      displayDate = d.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
      });
    }
  } catch (e) {}

  return (
    <span className={`inline-flex items-center gap-1 text-[11px] text-white/40 ${className}`}>
      <span>Last Updated:</span>
      <time dateTime={date} className="text-white/60 font-medium">
        {displayDate}
      </time>
    </span>
  );
}
