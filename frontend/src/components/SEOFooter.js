import React from 'react';
import { Link } from 'react-router-dom';
import { ALL_SEO_PAGES } from './InternalLinks';

const SEOFooter = () => {
  return (
    <footer className="mt-24 pt-8 border-t border-white/10 pb-8 text-left">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6 pb-6 border-b border-white/5">
        <div className="flex flex-wrap gap-x-6 gap-y-2">
          {ALL_SEO_PAGES.slice(0, 5).map(page => (
            <Link key={page.path} to={page.path} className="text-xs text-white/40 hover:text-primary transition-colors">
              {page.title}
            </Link>
          ))}
        </div>
        <div className="flex flex-wrap gap-x-6 gap-y-2">
          {ALL_SEO_PAGES.slice(5).map(page => (
            <Link key={page.path} to={page.path} className="text-xs text-white/40 hover:text-primary transition-colors">
              {page.title}
            </Link>
          ))}
          <Link to="/content" className="text-xs text-white/40 hover:text-primary transition-colors">
            All Content
          </Link>
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

