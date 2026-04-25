import React from 'react';
import { Link } from 'react-router-dom';
import { ALL_SEO_PAGES } from './InternalLinks';

const SEOFooter = () => {
  return (
    <footer className="mt-24 pt-12 border-t border-white/10 pb-8">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-12">
        {/* About Column */}
        <div>
          <h3 className="text-lg font-bold mb-4 text-white/90">About Vrindopnishad</h3>
          <p className="text-sm text-white/50 leading-relaxed">
            Vrindopnishad is the premier digital sanctuary for authentic spiritual and Vedic knowledge.
            We preserve and share sacred Sanskrit shlokas, strotras, devotional poetry, and divine wisdom
            from the saints of Vrindavan.
          </p>
        </div>

        {/* Knowledge Pages */}
        <div>
          <h3 className="text-lg font-bold mb-4 text-white/90">Explore Knowledge</h3>
          <ul className="space-y-2">
            {ALL_SEO_PAGES.slice(0, 5).map(page => (
              <li key={page.path}>
                <Link to={page.path} className="text-sm text-white/50 hover:text-primary transition-colors">
                  {page.title}
                </Link>
              </li>
            ))}
          </ul>
        </div>

        {/* More Links */}
        <div>
          <h3 className="text-lg font-bold mb-4 text-white/90">More Resources</h3>
          <ul className="space-y-2">
            {ALL_SEO_PAGES.slice(5).map(page => (
              <li key={page.path}>
                <Link to={page.path} className="text-sm text-white/50 hover:text-primary transition-colors">
                  {page.title}
                </Link>
              </li>
            ))}
            <li>
              <Link to="/content" className="text-sm text-white/50 hover:text-primary transition-colors">
                Browse All Content
              </Link>
            </li>
            <li>
              <a href="https://vrindopnishad.in" target="_blank" rel="noopener noreferrer" className="text-sm text-white/50 hover:text-primary transition-colors">
                Vrindopnishad Main Site ↗
              </a>
            </li>
          </ul>
        </div>
      </div>

      <div className="text-center text-xs text-white/30 pt-8 border-t border-white/5">
        <p>© {new Date().getFullYear()} Vrindopnishad. All rights reserved.</p>
        <p className="mt-1">A sacred digital platform preserving Vedic and devotional heritage.</p>
      </div>
    </footer>
  );
};

export default SEOFooter;
