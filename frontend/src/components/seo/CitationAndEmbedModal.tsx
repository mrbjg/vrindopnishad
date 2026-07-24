'use client';

import React, { useState } from 'react';

interface CitationAndEmbedModalProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  slug: string;
  author?: string;
}

export default function CitationAndEmbedModal({
  isOpen,
  onClose,
  title,
  slug,
  author = 'Braj Rasik Saint'
}: CitationAndEmbedModalProps) {
  const [activeTab, setActiveTab] = useState<'embed' | 'citation'>('embed');
  const [copiedFormat, setCopiedFormat] = useState<string | null>(null);

  if (!isOpen) return null;

  const baseUrl = 'https://path.vrindopnishad.in';
  const pageUrl = `${baseUrl}/lyrics/${slug}`;
  const embedUrl = `${baseUrl}/embed/lyrics/${slug}`;

  // Generated Embed Code snippet
  const embedCode = `<iframe src="${embedUrl}" width="100%" height="280" frameborder="0" style="border-radius:12px; border:1px solid rgba(255,255,255,0.12); overflow:hidden;" title="${title} - Vrindopnishad"></iframe>\n<p style="font-size:12px; color:#888; text-align:right; margin-top:4px;">Source: <a href="${pageUrl}" target="_blank" rel="noopener" style="color:#d97706; text-decoration:underline;">Vrindopnishad Sanctuary</a></p>`;

  // Citations
  const currentYear = new Date().getFullYear();
  const cleanAuthor = author ? author.replace(/जी की वाणी/g, '').replace(/जी/g, '').trim() : 'Rasik Saint';

  const citations = {
    markdown: `[${title} — ${cleanAuthor} | Vrindopnishad Sanctuary](${pageUrl})`,
    html: `<a href="${pageUrl}" target="_blank" title="${title} on Vrindopnishad">${title} (${cleanAuthor}) - Vrindopnishad Sanctuary</a>`,
    apa: `Vrindopnishad Editorial Sanctuary. (${currentYear}). ${title} (Verse by ${cleanAuthor}). Retrieved from ${pageUrl}`,
    mla: `"${title}." Composed by ${cleanAuthor}. Vrindopnishad Sanctuary, ${currentYear}, ${pageUrl}.`,
    bibtex: `@misc{vrindopnishad_${slug.replace(/[^a-zA-Z0-9]/g, '_')},\n  title = {${title}},\n  author = {${cleanAuthor}},\n  publisher = {Vrindopnishad Sanctuary},\n  year = {${currentYear}},\n  url = {${pageUrl}}\n}`
  };

  const handleCopy = (text: string, formatKey: string) => {
    navigator.clipboard.writeText(text);
    setCopiedFormat(formatKey);
    setTimeout(() => setCopiedFormat(null), 2200);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md animate-fadeIn">
      <div className="relative w-full max-w-2xl bg-zinc-900 border border-white/15 rounded-2xl shadow-2xl overflow-hidden flex flex-col max-h-[90vh]">
        {/* Modal Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-white/10 bg-zinc-950/60">
          <div className="flex items-center gap-2">
            <span className="w-2.5 h-2.5 rounded-full bg-amber-500 animate-pulse"></span>
            <h3 className="text-base font-semibold text-white">Cite & Embed Content</h3>
          </div>
          <button
            onClick={onClose}
            className="p-1 text-white/60 hover:text-white rounded-lg hover:bg-white/10 transition-colors"
            aria-label="Close modal"
          >
            <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        {/* Modal Navigation Tabs */}
        <div className="flex border-b border-white/10 bg-black/40 px-6 pt-2">
          <button
            onClick={() => setActiveTab('embed')}
            className={`py-2.5 px-4 text-sm font-medium border-b-2 transition-colors ${
              activeTab === 'embed'
                ? 'border-amber-500 text-amber-400 font-semibold'
                : 'border-transparent text-white/60 hover:text-white'
            }`}
          >
            Embed Widget (Backlink Generator)
          </button>
          <button
            onClick={() => setActiveTab('citation')}
            className={`py-2.5 px-4 text-sm font-medium border-b-2 transition-colors ${
              activeTab === 'citation'
                ? 'border-amber-500 text-amber-400 font-semibold'
                : 'border-transparent text-white/60 hover:text-white'
            }`}
          >
            Academic & Blog Citations
          </button>
        </div>

        {/* Modal Body */}
        <div className="p-6 overflow-y-auto space-y-6">
          {activeTab === 'embed' && (
            <div className="space-y-4">
              <p className="text-xs text-zinc-400">
                Embed this interactive verse card into your blog, Medium post, or website. Includes player and attribution link back to Vrindopnishad.
              </p>

              {/* Code Snippet Box */}
              <div className="relative group">
                <label className="block text-[11px] font-mono text-amber-400/90 mb-1.5 uppercase tracking-wider">
                  HTML Embed Code
                </label>
                <textarea
                  readOnly
                  rows={4}
                  value={embedCode}
                  className="w-full p-3 font-mono text-xs bg-black/60 border border-white/10 rounded-xl text-zinc-300 focus:outline-none focus:border-amber-500/50 resize-none selection:bg-amber-500/30"
                />
                <button
                  onClick={() => handleCopy(embedCode, 'embed')}
                  className="mt-2 flex items-center gap-2 px-4 py-2 bg-amber-600 hover:bg-amber-500 text-white font-medium text-xs rounded-lg transition-all duration-200 shadow-md active:scale-95"
                >
                  {copiedFormat === 'embed' ? (
                    <>
                      <svg className="w-4 h-4 text-emerald-300" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                      </svg>
                      Copied Embed Code!
                    </>
                  ) : (
                    <>
                      <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                      </svg>
                      Copy Embed Code
                    </>
                  )}
                </button>
              </div>

              {/* Live Preview Section */}
              <div className="mt-4 pt-4 border-t border-white/10">
                <span className="block text-xs font-semibold text-zinc-300 mb-2">Live Card Preview:</span>
                <div className="border border-white/10 rounded-xl overflow-hidden bg-black/40 p-4">
                  <div className="flex items-center justify-between border-b border-white/10 pb-3 mb-3">
                    <div>
                      <span className="text-[10px] uppercase font-bold text-amber-500 tracking-wider">Vrindopnishad Verse</span>
                      <h4 className="text-sm font-bold text-white leading-tight">{title}</h4>
                      <p className="text-xs text-zinc-400">By {cleanAuthor}</p>
                    </div>
                    <a href={pageUrl} target="_blank" rel="noopener noreferrer" className="px-3 py-1 bg-amber-500/10 text-amber-400 text-xs rounded-full border border-amber-500/20 hover:bg-amber-500/20">
                      Read Full →
                    </a>
                  </div>
                  <p className="text-xs text-zinc-400 italic">"Sacred verse text rendered seamlessly..."</p>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'citation' && (
            <div className="space-y-4">
              <p className="text-xs text-zinc-400">
                Copy formatted citations for research papers, books, or online articles:
              </p>

              {/* Markdown Link */}
              <div className="p-3 bg-black/50 border border-white/10 rounded-xl">
                <div className="flex items-center justify-between mb-1.5">
                  <span className="text-xs font-semibold text-amber-400">Markdown Link (For Blogs & GitHub)</span>
                  <button
                    onClick={() => handleCopy(citations.markdown, 'markdown')}
                    className="text-xs text-zinc-300 hover:text-white px-2 py-0.5 rounded bg-white/5 hover:bg-white/10 transition-colors"
                  >
                    {copiedFormat === 'markdown' ? 'Copied!' : 'Copy'}
                  </button>
                </div>
                <code className="block text-[11px] font-mono text-zinc-300 break-all select-all">
                  {citations.markdown}
                </code>
              </div>

              {/* HTML Anchor */}
              <div className="p-3 bg-black/50 border border-white/10 rounded-xl">
                <div className="flex items-center justify-between mb-1.5">
                  <span className="text-xs font-semibold text-amber-400">HTML Backlink Anchor</span>
                  <button
                    onClick={() => handleCopy(citations.html, 'html')}
                    className="text-xs text-zinc-300 hover:text-white px-2 py-0.5 rounded bg-white/5 hover:bg-white/10 transition-colors"
                  >
                    {copiedFormat === 'html' ? 'Copied!' : 'Copy'}
                  </button>
                </div>
                <code className="block text-[11px] font-mono text-zinc-300 break-all select-all">
                  {citations.html}
                </code>
              </div>

              {/* APA 7 */}
              <div className="p-3 bg-black/50 border border-white/10 rounded-xl">
                <div className="flex items-center justify-between mb-1.5">
                  <span className="text-xs font-semibold text-amber-400">APA (7th Edition)</span>
                  <button
                    onClick={() => handleCopy(citations.apa, 'apa')}
                    className="text-xs text-zinc-300 hover:text-white px-2 py-0.5 rounded bg-white/5 hover:bg-white/10 transition-colors"
                  >
                    {copiedFormat === 'apa' ? 'Copied!' : 'Copy'}
                  </button>
                </div>
                <p className="text-xs text-zinc-300 select-all">{citations.apa}</p>
              </div>

              {/* MLA 9 */}
              <div className="p-3 bg-black/50 border border-white/10 rounded-xl">
                <div className="flex items-center justify-between mb-1.5">
                  <span className="text-xs font-semibold text-amber-400">MLA (9th Edition)</span>
                  <button
                    onClick={() => handleCopy(citations.mla, 'mla')}
                    className="text-xs text-zinc-300 hover:text-white px-2 py-0.5 rounded bg-white/5 hover:bg-white/10 transition-colors"
                  >
                    {copiedFormat === 'mla' ? 'Copied!' : 'Copy'}
                  </button>
                </div>
                <p className="text-xs text-zinc-300 select-all">{citations.mla}</p>
              </div>

              {/* BibTeX */}
              <div className="p-3 bg-black/50 border border-white/10 rounded-xl">
                <div className="flex items-center justify-between mb-1.5">
                  <span className="text-xs font-semibold text-amber-400">BibTeX</span>
                  <button
                    onClick={() => handleCopy(citations.bibtex, 'bibtex')}
                    className="text-xs text-zinc-300 hover:text-white px-2 py-0.5 rounded bg-white/5 hover:bg-white/10 transition-colors"
                  >
                    {copiedFormat === 'bibtex' ? 'Copied!' : 'Copy'}
                  </button>
                </div>
                <pre className="text-[10px] font-mono text-zinc-300 overflow-x-auto whitespace-pre-wrap select-all">
                  {citations.bibtex}
                </pre>
              </div>
            </div>
          )}
        </div>

        {/* Modal Footer */}
        <div className="px-6 py-3 border-t border-white/10 bg-zinc-950/60 flex items-center justify-between text-xs text-zinc-500">
          <span>Preserving Vrindavan Heritage with Open Attribution</span>
          <button
            onClick={onClose}
            className="px-4 py-1.5 bg-white/10 hover:bg-white/15 text-white font-medium rounded-lg transition-colors"
          >
            Done
          </button>
        </div>
      </div>
    </div>
  );
}
