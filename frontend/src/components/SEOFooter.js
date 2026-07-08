import React from 'react';
import { Link } from 'react-router-dom';
import { ALL_SEO_PAGES } from './InternalLinks';

const SEOFooter = () => {
  return (
    <footer className="mt-24 pt-8 border-t border-white/10 pb-8 text-left">
      {/* Primary Navigation Hubs (SEO crawlable anchors) */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 pb-6 border-b border-white/5 mb-6">
        <div>
          <h3 className="text-[10px] font-bold uppercase tracking-widest text-amber-500/80 mb-3">Primary Hubs (English)</h3>
          <div className="flex flex-wrap gap-x-4 gap-y-2">
            <Link to="/lyrics" className="text-xs text-white/50 hover:text-primary transition-colors font-medium">Shlokas &amp; Verses</Link>
            <Link to="/saints" className="text-xs text-white/50 hover:text-primary transition-colors font-medium">Rasik Saints</Link>
            <Link to="/ragas" className="text-xs text-white/50 hover:text-primary transition-colors font-medium">Classical Ragas</Link>
            <Link to="/places" className="text-xs text-white/50 hover:text-primary transition-colors font-medium">Braj Pilgrimage</Link>
            <Link to="/glossary" className="text-xs text-white/50 hover:text-primary transition-colors font-medium">Spiritual Glossary</Link>
          </div>
        </div>
        <div>
          <h3 className="text-[10px] font-bold uppercase tracking-widest text-amber-500/80 mb-3">मुख्य अनुक्रमणिका (हिन्दी)</h3>
          <div className="flex flex-wrap gap-x-4 gap-y-2">
            <Link to="/hi/lyrics" className="text-xs text-white/50 hover:text-primary transition-colors font-medium">पवित्र श्लोक और पद</Link>
            <Link to="/hi/saints" className="text-xs text-white/50 hover:text-primary transition-colors font-medium">रसिक संत जीवनी</Link>
            <Link to="/hi/ragas" className="text-xs text-white/50 hover:text-primary transition-colors font-medium">राग अनुक्रमणिका</Link>
            <Link to="/hi/places" className="text-xs text-white/50 hover:text-primary transition-colors font-medium">पवित्र लीला स्थल</Link>
            <Link to="/hi/glossary" className="text-xs text-white/50 hover:text-primary transition-colors font-medium">आध्यात्मिक शब्दावली</Link>
          </div>
        </div>
      </div>

      {/* Static Wiki / Knowledge Base Pages */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6 pb-6 border-b border-white/5">
        <div className="flex flex-wrap gap-x-6 gap-y-2">
          {ALL_SEO_PAGES.slice(0, 12).map(page => (
            <Link key={page.path} to={page.path} className="text-[11px] text-white/40 hover:text-primary transition-colors">
              {page.title}
            </Link>
          ))}
        </div>
        <div className="flex flex-wrap gap-x-6 gap-y-2">
          {ALL_SEO_PAGES.slice(12).map(page => (
            <Link key={page.path} to={page.path} className="text-[11px] text-white/40 hover:text-primary transition-colors">
              {page.title}
            </Link>
          ))}
        </div>
      </div>

      <div className="flex flex-col sm:flex-row justify-between items-center pt-6 text-[10px] text-white/30 gap-2">
        <p>© {new Date().getFullYear()} Vrindopnishad. All rights reserved.</p>
        <p>Preserving the sacred spiritual heritage of Vrindavan.</p>
      </div>
    </footer>
  );
};

export default SEOFooter;

