'use client';

import React, { useState, useEffect } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { ArrowLeft, Trash2, BookOpen, FileText, Bookmark } from 'lucide-react';
import { transliterate } from '../utils/transliterate';

const BookmarksPage = () => {
  const location = useLocation();
  const isHindiRoute = location.pathname.startsWith('/hi');
  const [bookmarks, setBookmarks] = useState([]);
  const [activeTab, setActiveTab] = useState('verses'); // 'verses' or 'books'

  useEffect(() => {
    try {
      const saved = localStorage.getItem('vrindopnishad_bookmarks');
      if (saved) {
        setBookmarks(JSON.parse(saved));
      }
    } catch (e) {
      console.error('Failed to load bookmarks:', e);
    }
  }, []);

  const removeBookmark = (itemToRemove) => {
    try {
      let updated = [];
      if (itemToRemove.type === 'verse') {
        updated = bookmarks.filter(b => !(b.type === 'verse' && b.id?.toString() === itemToRemove.id?.toString()));
      } else {
        updated = bookmarks.filter(b => !(b.type === 'book' && b.slug === itemToRemove.slug));
      }
      setBookmarks(updated);
      localStorage.setItem('vrindopnishad_bookmarks', JSON.stringify(updated));
    } catch (e) {
      console.error('Failed to update bookmarks:', e);
    }
  };

  const clearAll = () => {
    if (window.confirm(isHindiRoute ? "क्या आप सभी बुकमार्क हटाना चाहते हैं?" : "Are you sure you want to clear all bookmarks?")) {
      setBookmarks([]);
      localStorage.removeItem('vrindopnishad_bookmarks');
    }
  };

  const bookmarkedVerses = bookmarks.filter(b => b.type === 'verse');
  const bookmarkedBooks = bookmarks.filter(b => b.type === 'book');

  return (
    <div className="animate-fade-in max-w-4xl mx-auto px-4 py-8">
      <Helmet>
        <title>{isHindiRoute ? "मेरी पाठ सूची (बुकमार्क) | Vrindopnishad" : "Meri Paath Suchi (Bookmarks) | Vrindopnishad"}</title>
        <meta name="description" content="Manage your saved verses, hymns, shlokas, and sacred granthas for quick reading offline." />
      </Helmet>

      <Link 
        to={isHindiRoute ? "/hi/" : "/"} 
        className="inline-flex items-center gap-2 text-white/40 hover:text-white mb-8 transition-colors text-xs uppercase tracking-wider"
      >
        <ArrowLeft size={14} />
        {isHindiRoute ? "मुख्य पृष्ठ" : "Back to Sanctuary"}
      </Link>

      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-10 pb-6 border-b border-white/5">
        <div>
          <span className="text-[10px] uppercase tracking-[0.25em] text-primary font-bold block mb-2">
            {isHindiRoute ? "संग्रहित स्वाध्याय" : "Saved Devotion"}
          </span>
          <h1 className="text-3xl md:text-4xl font-bold font-headings text-sacred-gradient flex items-center gap-3">
            <Bookmark className="text-primary w-8 h-8" />
            {isHindiRoute ? "मेरी पाठ सूची" : "Meri Paath Suchi"}
          </h1>
        </div>
        
        {bookmarks.length > 0 && (
          <button 
            onClick={clearAll}
            className="text-xs text-red-400/60 hover:text-red-400 transition-colors border border-red-500/10 hover:border-red-500/30 bg-red-500/5 px-4 py-2 rounded-full font-medium"
          >
            {isHindiRoute ? "सभी साफ़ करें" : "Clear All List"}
          </button>
        )}
      </div>

      {bookmarks.length === 0 ? (
        <div className="glass-card text-center py-20 px-6">
          <Bookmark className="w-16 h-16 text-white/10 mx-auto mb-6" />
          <h3 className="text-2xl font-bold mb-3 font-headings">
            {isHindiRoute ? "आपकी पाठ सूची खाली है" : "No Bookmarks Saved"}
          </h3>
          <p className="text-white/40 mb-8 max-w-md mx-auto text-sm leading-relaxed">
            {isHindiRoute 
              ? "ग्रन्थ या वाणी पढ़ते समय ऊपर दिए गए बुकमार्क बटन पर क्लिक करके अपनी स्वाध्याय सूची में जोड़ें।" 
              : "While reading verses or granthas, tap the bookmark icon to collect them here for distraction-free offline reading."
            }
          </p>
          <Link 
            to={isHindiRoute ? "/hi/content" : "/content"} 
            className="btn-sacred-gold px-8 py-3 text-sm inline-block"
          >
            {isHindiRoute ? "संग्रह का अन्वेषण करें" : "Explore Library"}
          </Link>
        </div>
      ) : (
        <div>
          {/* Tabs */}
          <div className="flex gap-4 mb-8 border-b border-white/5 pb-0.5">
            <button
              onClick={() => setActiveTab('verses')}
              className={`pb-3 text-sm font-semibold tracking-wide relative transition-colors ${
                activeTab === 'verses' ? 'text-primary' : 'text-white/40 hover:text-white/60'
              }`}
            >
              <span className="flex items-center gap-2">
                <FileText size={16} />
                {isHindiRoute ? `संकलित वाणी-पद (${bookmarkedVerses.length})` : `Saved Verses (${bookmarkedVerses.length})`}
              </span>
              {activeTab === 'verses' && (
                <div className="absolute bottom-0 left-0 right-0 h-[2px] bg-primary rounded-full" />
              )}
            </button>
            <button
              onClick={() => setActiveTab('books')}
              className={`pb-3 text-sm font-semibold tracking-wide relative transition-colors ${
                activeTab === 'books' ? 'text-primary' : 'text-white/40 hover:text-white/60'
              }`}
            >
              <span className="flex items-center gap-2">
                <BookOpen size={16} />
                {isHindiRoute ? `पवित्र ग्रन्थ (${bookmarkedBooks.length})` : `Sacred Granthas (${bookmarkedBooks.length})`}
              </span>
              {activeTab === 'books' && (
                <div className="absolute bottom-0 left-0 right-0 h-[2px] bg-primary rounded-full" />
              )}
            </button>
          </div>

          {/* List display */}
          {activeTab === 'verses' ? (
            bookmarkedVerses.length === 0 ? (
              <div className="py-12 text-center text-white/30 text-sm italic">
                {isHindiRoute ? "कोई वाणी/श्लोक सहेजा नहीं गया है।" : "No verses saved yet."}
              </div>
            ) : (
              <div className="grid grid-cols-1 gap-4">
                {bookmarkedVerses.map((verse) => {
                  const titleDeva = verse.title || "";
                  const titleHing = transliterate(titleDeva);
                  const displayTitle = isHindiRoute 
                    ? titleDeva 
                    : (titleHing && titleHing !== titleDeva ? titleHing : titleDeva);

                  return (
                    <div 
                      key={verse.id}
                      className="glass-card p-5 flex items-center justify-between gap-6 group hover:border-amber-500/20 transition-all"
                    >
                      <Link 
                        to={isHindiRoute ? `/hi/content/${verse.slug || verse.id}` : `/content/${verse.slug || verse.id}`}
                        className="flex-1 min-w-0"
                      >
                        <div className="flex items-center gap-2 mb-1">
                          <span className="text-[9px] uppercase tracking-wider px-2 py-0.5 rounded bg-white/5 border border-white/5 text-white/50">
                            {verse.category}
                          </span>
                          {verse.author && (
                            <span className="text-[10px] text-primary/80 font-medium">
                              • {verse.author}
                            </span>
                          )}
                        </div>
                        <h3 className="font-bold text-base text-white/90 group-hover:text-primary transition-colors truncate">
                          {displayTitle}
                        </h3>
                      </Link>

                      <button
                        onClick={() => removeBookmark(verse)}
                        className="text-white/30 hover:text-red-400 p-2 rounded-full hover:bg-red-500/5 transition-all shrink-0"
                        title={isHindiRoute ? "हटाएं" : "Remove"}
                      >
                        <Trash2 size={16} />
                      </button>
                    </div>
                  );
                })}
              </div>
            )
          ) : (
            bookmarkedBooks.length === 0 ? (
              <div className="py-12 text-center text-white/30 text-sm italic">
                {isHindiRoute ? "कोई ग्रन्थ सहेजा नहीं गया है।" : "No books saved yet."}
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {bookmarkedBooks.map((book) => (
                  <div 
                    key={book.slug}
                    className="glass-card p-5 flex items-center justify-between gap-6 group hover:border-amber-500/20 transition-all"
                  >
                    <Link 
                      to={isHindiRoute ? `/hi/book/${book.slug}` : `/book/${book.slug}`}
                      className="flex-1 min-w-0"
                    >
                      <span className="text-[9px] uppercase tracking-wider text-amber-500 mb-1.5 block">
                        {isHindiRoute ? "ग्रन्थ" : "Granth"}
                      </span>
                      <h3 className="font-bold text-lg text-white/90 group-hover:text-primary transition-colors truncate font-headings">
                        {book.name}
                      </h3>
                      {book.author && (
                        <p className="text-white/40 text-xs truncate mt-1">
                          {isHindiRoute ? `रचयिता: ${book.author}` : `By ${book.author}`}
                        </p>
                      )}
                    </Link>

                    <button
                      onClick={() => removeBookmark(book)}
                      className="text-white/30 hover:text-red-400 p-2 rounded-full hover:bg-red-500/5 transition-all shrink-0"
                      title={isHindiRoute ? "हटाएं" : "Remove"}
                    >
                      <Trash2 size={16} />
                    </button>
                  </div>
                ))}
              </div>
            )
          )}
        </div>
      )}
    </div>
  );
};

export default BookmarksPage;
