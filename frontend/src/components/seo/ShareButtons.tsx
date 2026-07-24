'use client';

import React, { useState, useEffect } from 'react';
import CitationAndEmbedModal from './CitationAndEmbedModal';

interface ShareButtonsProps {
  url?: string;
  title?: string;
  slug?: string;
  author?: string;
  className?: string;
}

export default function ShareButtons({
  url,
  title = 'Check this out on Vrindopnishad',
  slug,
  author,
  className = ''
}: ShareButtonsProps) {
  const [copied, setCopied] = useState(false);
  const [canShare, setCanShare] = useState(false);
  const [isEmbedModalOpen, setIsEmbedModalOpen] = useState(false);
  const shareUrl = typeof window !== 'undefined' ? (url || window.location.href) : '';

  useEffect(() => {
    if (typeof navigator !== 'undefined' && !!navigator.share) {
      setCanShare(true);
    }
  }, []);

  const handleShare = async () => {
    if (navigator.share) {
      try {
        await navigator.share({
          title,
          url: shareUrl,
        });
      } catch (err) {
        console.warn('Web Share failed:', err);
      }
    } else {
      handleCopy();
    }
  };

  const handleCopy = () => {
    navigator.clipboard.writeText(shareUrl);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const encodedUrl = encodeURIComponent(shareUrl);
  const encodedTitle = encodeURIComponent(title);

  return (
    <div className={`flex flex-wrap items-center gap-3 mt-8 ${className}`}>
      <span className="text-[10px] font-bold uppercase tracking-widest text-white/30 mr-1 select-none">
        Share:
      </span>

      {/* Copy Link Button */}
      <button
        onClick={handleCopy}
        className="w-8 h-8 rounded-full border border-white/10 flex items-center justify-center bg-white/[0.02] hover:bg-amber-500/10 hover:border-amber-500/30 text-white/70 hover:text-amber-400 transition-all duration-300 relative group"
        title="Copy Link"
        aria-label="Copy Page Link"
      >
        {copied ? (
          <svg className="w-3.5 h-3.5 text-green-500" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5} aria-hidden="true">
            <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
          </svg>
        ) : (
          <svg className="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2} aria-hidden="true">
            <path strokeLinecap="round" strokeLinejoin="round" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z" />
          </svg>
        )}
        <span className="absolute -top-8 left-1/2 -translate-x-1/2 scale-0 group-hover:scale-100 bg-black text-[10px] text-white/90 px-2 py-1 rounded border border-white/10 transition-all duration-200 pointer-events-none whitespace-nowrap">
          {copied ? 'Copied!' : 'Copy Link'}
        </span>
      </button>

      {/* Twitter Share */}
      <a
        href={`https://twitter.com/intent/tweet?url=${encodedUrl}&text=${encodedTitle}`}
        target="_blank"
        rel="noopener noreferrer"
        className="w-8 h-8 rounded-full border border-white/10 flex items-center justify-center bg-white/[0.02] hover:bg-amber-500/10 hover:border-amber-500/30 text-white/70 hover:text-amber-400 transition-all duration-300 relative group"
        title="Share on X"
        aria-label="Share on X"
      >
        <svg className="w-3.5 h-3.5 fill-current" viewBox="0 0 24 24" aria-hidden="true">
          <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
        </svg>
        <span className="absolute -top-8 left-1/2 -translate-x-1/2 scale-0 group-hover:scale-100 bg-black text-[10px] text-white/90 px-2 py-1 rounded border border-white/10 transition-all duration-200 pointer-events-none whitespace-nowrap">
          Share on X
        </span>
      </a>

      {/* WhatsApp Share */}
      <a
        href={`https://api.whatsapp.com/send?text=${encodedTitle}%20${encodedUrl}`}
        target="_blank"
        rel="noopener noreferrer"
        className="w-8 h-8 rounded-full border border-white/10 flex items-center justify-center bg-white/[0.02] hover:bg-amber-500/10 hover:border-amber-500/30 text-white/70 hover:text-amber-400 transition-all duration-300 relative group"
        title="Share on WhatsApp"
        aria-label="Share on WhatsApp"
      >
        <svg className="w-3.5 h-3.5 fill-current" viewBox="0 0 24 24" aria-hidden="true">
          <path d="M.057 24l1.687-6.163c-1.041-1.804-1.588-3.849-1.587-5.946C.06 5.348 5.397.01 12.008.01c3.202.001 6.212 1.248 8.477 3.514 2.266 2.268 3.507 5.28 3.505 8.484-.004 6.657-5.34 11.997-11.953 11.997-2.005-.001-3.973-.502-5.724-1.457L0 24zm6.59-4.846c1.6.95 3.188 1.449 4.825 1.451 5.436 0 9.86-4.42 9.864-9.864.002-2.637-1.03-5.114-2.905-6.99S14.64 1.139 12.008 1.139c-5.435 0-9.861 4.421-9.865 9.864-.001 2.03.536 4.021 1.558 5.765l-.99 3.613 3.708-.973zm11.224-5.415c-.297-.149-1.758-.868-2.031-.967-.272-.099-.47-.149-.668.149-.198.297-.768.967-.941 1.165-.173.198-.347.223-.644.074-.297-.149-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.496.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.568-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347z" />
        </svg>
        <span className="absolute -top-8 left-1/2 -translate-x-1/2 scale-0 group-hover:scale-100 bg-black text-[10px] text-white/90 px-2 py-1 rounded border border-white/10 transition-all duration-200 pointer-events-none whitespace-nowrap">
          Share on WhatsApp
        </span>
      </a>

      {/* Telegram Share */}
      <a
        href={`https://t.me/share/url?url=${encodedUrl}&text=${encodedTitle}`}
        target="_blank"
        rel="noopener noreferrer"
        className="w-8 h-8 rounded-full border border-white/10 flex items-center justify-center bg-white/[0.02] hover:bg-amber-500/10 hover:border-amber-500/30 text-white/70 hover:text-amber-400 transition-all duration-300 relative group"
        title="Share on Telegram"
        aria-label="Share on Telegram"
      >
        <svg className="w-3.5 h-3.5 fill-current" viewBox="0 0 24 24" aria-hidden="true">
          <path d="M9.78 18.65l.28-4.28 7.68-6.92c.34-.31-.07-.47-.52-.18L7.69 12.2 3.58 10.9c-.89-.28-.9-.89.19-1.31l16.07-6.2c.74-.27 1.39.18 1.17 1.25l-2.73 12.87c-.2 1-.8 1.25-1.63.78l-4.17-3.07-2.01 1.94c-.22.22-.4.4-.8.4z" />
        </svg>
        <span className="absolute -top-8 left-1/2 -translate-x-1/2 scale-0 group-hover:scale-100 bg-black text-[10px] text-white/90 px-2 py-1 rounded border border-white/10 transition-all duration-200 pointer-events-none whitespace-nowrap">
          Share on Telegram
        </span>
      </a>

      {/* Cite & Embed Button (Backlink & Attribution Generator) */}
      <button
        onClick={() => setIsEmbedModalOpen(true)}
        className="px-3 py-1 rounded-full border border-amber-500/30 flex items-center gap-1.5 bg-amber-500/10 hover:bg-amber-500/20 text-amber-400 text-xs font-medium transition-all duration-300 relative group"
        title="Cite or Embed this Verse"
        aria-label="Cite or Embed this Verse"
      >
        <svg className="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
          <path strokeLinecap="round" strokeLinejoin="round" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" />
        </svg>
        <span>Cite / Embed</span>
      </button>

      {/* Render Citation and Embed Modal */}
      {slug && (
        <CitationAndEmbedModal
          isOpen={isEmbedModalOpen}
          onClose={() => setIsEmbedModalOpen(false)}
          title={title}
          slug={slug}
          author={author}
        />
      )}
    </div>
  );
}
