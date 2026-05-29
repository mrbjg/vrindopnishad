import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { X, ChevronRight } from 'lucide-react';
import AudioPlayButton from '../ui/AudioPlayButton';

const PreviewDrawer = ({
  isHi,
  selectedItem,
  previewType,
  closePreview,
  books,
  onNavigatePreview,
}) => {
  const [drawerTab, setDrawerTab] = useState('bio');

  
  useEffect(() => {
    setDrawerTab('bio');
  }, [selectedItem]);

  if (!selectedItem) return null;

  return (
    <>
      <div
        className={`preview-drawer-backdrop ${selectedItem ? 'active' : ''}`}
        onClick={closePreview}
      />
      <div className={`preview-drawer ${selectedItem ? 'active' : ''}`}>
        <div className="drawer-drag-handle" />
        <div className="flex-1 flex flex-col overflow-hidden px-5 sm:px-6 pt-4">
          
          <div className="flex items-start justify-between gap-4 mb-4 pb-4 border-b border-white/5">
            <div className="min-w-0">
              <span className="text-[9px] uppercase tracking-[0.2em] text-primary font-bold block mb-1">
                {previewType === 'saint'
                  ? 'Holy Biography'
                  : previewType === 'book'
                  ? 'Scripture'
                  : previewType === 'raga'
                  ? 'Raga'
                  : 'Verse'}
              </span>
              <h2 className="text-lg sm:text-xl font-bold font-headings text-minimal-gold truncate">
                {previewType === 'saint'
                  ? isHi ? selectedItem.name : selectedItem.hinglishName
                  : previewType === 'book' || previewType === 'raga'
                  ? selectedItem.name
                  : selectedItem.title}
              </h2>
              {previewType === 'book' && selectedItem.author && (
                <span className="text-xs text-white/40 block mt-1">By {selectedItem.author}</span>
              )}
              {previewType === 'raga' && (
                <span className="text-xs text-white/40 block mt-0.5">{selectedItem.hinglishName}</span>
              )}
            </div>
            <button
              onClick={closePreview}
              className="w-8 h-8 rounded-full bg-white/5 flex items-center justify-center text-white/40 hover:text-white transition-colors hover:bg-white/10 shrink-0 min-h-[32px] min-w-[32px]"
            >
              <X size={16} />
            </button>
          </div>

          
          <div className="drawer-scroll-container pb-6">
            
            {previewType === 'saint' && (
              <div>
                <div className="drawer-tabs mb-4 flex gap-1 bg-white/5 p-1 rounded-xl">
                  {['bio', 'books', 'verses'].map((tab) => (
                    <button
                      key={tab}
                      onClick={() => setDrawerTab(tab)}
                      className={`drawer-tab flex-1 py-1.5 text-center text-xs font-semibold rounded-lg transition-all ${
                        drawerTab === tab
                          ? 'bg-white/10 text-white shadow-sm'
                          : 'text-white/55 hover:text-white'
                      }`}
                    >
                      {tab === 'bio'
                        ? 'Biography'
                        : tab === 'books'
                        ? `Books (${selectedItem.books?.length || 0})`
                        : `Verses (${selectedItem.verses?.length || 0})`}
                    </button>
                  ))}
                </div>
                {drawerTab === 'bio' && (
                  selectedItem.biography ? (
                    <p className="text-white/70 text-xs sm:text-sm leading-relaxed whitespace-pre-line bg-white/5 p-4 rounded-xl border border-white/5">
                      {selectedItem.biography.text}
                    </p>
                  ) : (
                    <p className="text-white/40 text-center py-8 text-xs">Biography not available.</p>
                  )
                )}
                {drawerTab === 'books' && (
                  <div className="grid grid-cols-1 gap-2">
                    {selectedItem.books?.length > 0 ? (
                      selectedItem.books.map((bName) => {
                        const m = books.find((b) => b.name === bName);
                        return (
                          <button
                            key={bName}
                            onClick={() => {
                              if (m) onNavigatePreview(m, 'book');
                            }}
                            className="p-3 text-left rounded-xl bg-white/5 hover:bg-white/10 border border-white/5 flex items-center justify-between text-xs font-bold w-full transition-colors group touch-manipulation min-h-[40px]"
                          >
                            <span className="text-white/90 group-hover:text-primary transition-colors">
                              {bName}
                            </span>
                            <ChevronRight
                              size={14}
                              className="text-white/20 group-hover:text-primary transition-colors"
                            />
                          </button>
                        );
                      })
                    ) : (
                      <p className="text-white/40 text-center py-8 text-xs">No books.</p>
                    )}
                  </div>
                )}
                {drawerTab === 'verses' && (
                  <div className="space-y-2">
                    {selectedItem.verses?.map((v, i) => (
                      <Link
                        key={`${v.slug || v.id || 'verse'}-${i}`}
                        to={isHi ? `/hi/content/${v.slug || v.id}` : `/content/${v.slug || v.id}`}
                        onClick={closePreview}
                        className="block p-3 rounded-xl bg-white/5 hover:bg-white/10 border border-white/5 text-xs font-bold text-white/85 hover:text-primary transition-colors truncate touch-manipulation min-h-[38px]"
                      >
                        {v.cleanTitle || v.title}
                      </Link>
                    ))}
                  </div>
                )}
              </div>
            )}

            
            {previewType === 'book' && (
              <div className="space-y-2">
                {selectedItem.verses?.map((v, i) => (
                  <Link
                    key={`${v.slug || v.id || 'verse'}-${i}`}
                    to={isHi ? `/hi/content/${v.slug || v.id}` : `/content/${v.slug || v.id}`}
                    onClick={closePreview}
                    className="block p-3 rounded-xl bg-white/5 hover:bg-white/10 border border-white/5 text-xs font-bold text-white/85 hover:text-primary transition-colors truncate touch-manipulation min-h-[38px]"
                  >
                    {v.cleanTitle || v.title}
                  </Link>
                ))}
              </div>
            )}

            
            {previewType === 'raga' && (
              <div className="space-y-2">
                {selectedItem.verses?.map((v, i) => (
                  <Link
                    key={`${v.slug || v.id || 'verse'}-${i}`}
                    to={isHi ? `/hi/content/${v.slug || v.id}` : `/content/${v.slug || v.id}`}
                    onClick={closePreview}
                    className="block p-3 rounded-xl bg-white/5 hover:bg-white/10 border border-white/5 text-xs font-bold text-white/85 hover:text-primary transition-colors truncate touch-manipulation min-h-[38px]"
                  >
                    {v.cleanTitle || v.title}
                  </Link>
                ))}
              </div>
            )}

            
            {previewType === 'verse' && (
              <div className="space-y-4 text-xs sm:text-sm">
                {selectedItem.audio_url && (
                  <div className="glass-card p-4 flex items-center justify-between border border-white/5 mb-2">
                    <span className="font-semibold text-white/80">Recitation:</span>
                    <AudioPlayButton
                      track={selectedItem}
                      className="bg-primary text-white p-3 rounded-full hover:scale-105 shadow-lg shadow-primary/20"
                      size={20}
                    />
                  </div>
                )}
                {selectedItem.sanskrit_text && (
                  <div className="bg-white/5 p-4 sm:p-5 rounded-2xl border border-white/5 text-center">
                    <h5 className="text-[9px] uppercase tracking-wider text-amber-500/60 font-bold mb-2">
                      Original Scripture
                    </h5>
                    <p className="font-bold text-minimal-gold leading-relaxed whitespace-pre-line font-headings select-all text-sm sm:text-base text-center py-1">
                      {selectedItem.sanskrit_text}
                    </p>
                  </div>
                )}
                {selectedItem.hindi_text && (
                  <div className="bg-white/5 p-4 rounded-xl border border-white/5">
                    <h5 className="text-[9px] uppercase tracking-wider text-white/40 font-bold mb-1">भावार्थ</h5>
                    <p className="text-white/70 leading-relaxed font-light text-xs sm:text-sm">
                      {selectedItem.hindi_text}
                    </p>
                  </div>
                )}
                {selectedItem.english_translation && (
                  <div className="bg-white/5 p-4 rounded-xl border border-white/5">
                    <h5 className="text-[9px] uppercase tracking-wider text-white/40 font-bold mb-1">English</h5>
                    <p className="text-white/60 leading-relaxed font-light italic text-xs sm:text-sm">
                      {selectedItem.english_translation}
                    </p>
                  </div>
                )}
                {selectedItem.description && !selectedItem.hindi_text && !selectedItem.english_translation && (
                  <div className="bg-white/5 p-4 rounded-xl border border-white/5">
                    <h5 className="text-[9px] uppercase tracking-wider text-white/40 font-bold mb-1 font-mono">
                      Description
                    </h5>
                    <p className="text-white/65 leading-relaxed font-light text-xs sm:text-sm">
                      {selectedItem.description}
                    </p>
                  </div>
                )}
              </div>
            )}
          </div>

          
          <div className="py-4 border-t border-white/5 flex gap-3 shrink-0">
            {previewType === 'saint' && (
              <Link
                to={isHi ? `/hi/saint/${selectedItem.slug}` : `/saint/${selectedItem.slug}`}
                onClick={closePreview}
                className="btn-premium flex-1 text-center py-3 text-xs uppercase tracking-wider font-semibold min-h-[44px] flex items-center justify-center"
              >
                Open Full Page
              </Link>
            )}
            {previewType === 'book' && (
              <Link
                to={isHi ? `/hi/book/${selectedItem.slug}` : `/book/${selectedItem.slug}`}
                onClick={closePreview}
                className="btn-premium flex-1 text-center py-3 text-xs uppercase tracking-wider font-semibold min-h-[44px] flex items-center justify-center"
              >
                Open Full Page
              </Link>
            )}
            {previewType === 'raga' && (
              <Link
                to={isHi ? `/hi/raga/${selectedItem.slug}` : `/raga/${selectedItem.slug}`}
                onClick={closePreview}
                className="btn-premium flex-1 text-center py-3 text-xs uppercase tracking-wider font-semibold min-h-[44px] flex items-center justify-center"
              >
                Open Full Page
              </Link>
            )}
            {previewType === 'verse' && (
              <Link
                to={isHi ? `/hi/content/${selectedItem.slug || selectedItem.id}` : `/content/${selectedItem.slug || selectedItem.id}`}
                onClick={closePreview}
                className="btn-premium flex-1 text-center py-3 text-xs uppercase tracking-wider font-semibold min-h-[44px] flex items-center justify-center"
              >
                Open Full Page
              </Link>
            )}
          </div>
        </div>
      </div>
    </>
  );
};

export default React.memo(PreviewDrawer);
