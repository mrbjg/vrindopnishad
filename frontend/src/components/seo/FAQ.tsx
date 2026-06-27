'use client';

import React, { useState } from 'react';
import { generateFAQSchema, FAQItem } from '@/lib/schemas';
import JsonLd from './JsonLd';

interface FAQProps {
  questions: FAQItem[];
  title?: string;
  className?: string;
}

export default function FAQ({ questions, title = 'Frequently Asked Questions', className = '' }: FAQProps) {
  const [openIndex, setOpenIndex] = useState<number | null>(null);

  if (!questions || questions.length === 0) return null;

  const schema = generateFAQSchema(questions);

  const toggleFAQ = (index: number) => {
    setOpenIndex(openIndex === index ? null : index);
  };

  return (
    <>
      <JsonLd data={schema} />
      <section className={`mt-16 pt-8 border-t border-white/10 ${className}`} aria-label="FAQ">
        <h2 className="text-xl font-bold font-serif mb-6 text-amber-500/90">{title}</h2>
        <div className="space-y-4">
          {questions.map((q, idx) => {
            const isOpen = openIndex === idx;
            return (
              <div
                key={idx}
                className="border border-white/5 rounded-2xl bg-white/[0.02] overflow-hidden transition-all duration-300 hover:border-amber-500/20"
              >
                <button
                  type="button"
                  onClick={() => toggleFAQ(idx)}
                  className="w-full text-left px-5 py-4 flex justify-between items-center gap-4 text-sm font-medium text-white/80 hover:text-amber-400 focus:outline-none transition-colors"
                  aria-expanded={isOpen}
                  aria-controls={`faq-answer-${idx}`}
                >
                  <span>{q.question}</span>
                  <span className="text-amber-500/80 font-bold text-lg select-none">
                    {isOpen ? '−' : '+'}
                  </span>
                </button>
                <div
                  id={`faq-answer-${idx}`}
                  role="region"
                  aria-labelledby={`faq-question-${idx}`}
                  className={`transition-all duration-300 ease-in-out overflow-hidden ${
                    isOpen ? 'max-h-[500px] border-t border-white/5' : 'max-h-0'
                  }`}
                >
                  <div className="px-5 py-4 text-xs leading-relaxed text-white/60">
                    {q.answer}
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </section>
    </>
  );
}
