import React from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight } from 'lucide-react';

const ALL_SEO_PAGES = [
  { path: '/what-is-vrindopnishad', title: 'What is Vrindopnishad?', desc: 'Discover the vision and mission of Vrindopnishad' },
  { path: '/meaning', title: 'Meaning of Vrindopnishad', desc: 'Etymology and spiritual significance explained' },
  { path: '/origin', title: 'Origin of Vrindopnishad', desc: 'Historical roots and Vrindavan connection' },
  { path: '/philosophy', title: 'Philosophy of Vrindopnishad', desc: 'Core philosophical framework and principles' },
  { path: '/teachings', title: 'Teachings of Vrindopnishad', desc: 'Key spiritual teachings and wisdom' },
  { path: '/importance', title: 'Importance of Vrindopnishad', desc: 'Why Vrindopnishad matters in modern times' },
  { path: '/devotion', title: 'Devotional Explanation', desc: 'Understanding Bhakti through Vrindopnishad' },
  { path: '/faq', title: 'Frequently Asked Questions', desc: 'Common questions about Vrindopnishad answered' },
  { path: '/comparison-with-upanishads', title: 'Comparison with Upanishads', desc: 'How Vrindopnishad relates to classical Upanishads' },
  { path: '/guide', title: 'Complete Guide', desc: 'A beginner-friendly summary of Vrindopnishad' },
];

/**
 * Renders "Related Topics" section with internal links
 * @param {string[]} exclude - paths to exclude (e.g., the current page)
 * @param {number} count - number of links to show (default 4)
 */
const InternalLinks = ({ exclude = [], count = 4 }) => {
  const links = ALL_SEO_PAGES
    .filter(page => !exclude.includes(page.path))
    .slice(0, count);

  return (
    <nav className="mt-16 pt-12 border-t border-white/10" aria-label="Related Topics">
      <h2 className="text-2xl font-bold mb-8 text-white/90">Related Topics</h2>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {links.map(link => (
          <Link
            key={link.path}
            to={link.path}
            className="glass-card p-6 flex items-start gap-4 group hover:border-primary/30 transition-all duration-300"
          >
            <div className="flex-1">
              <h3 className="font-semibold text-white/90 group-hover:text-primary transition-colors">
                {link.title}
              </h3>
              <p className="text-sm text-white/50 mt-1">{link.desc}</p>
            </div>
            <ArrowRight size={18} className="text-white/30 group-hover:text-primary mt-1 transition-colors" />
          </Link>
        ))}
      </div>
    </nav>
  );
};

export { ALL_SEO_PAGES };
export default InternalLinks;
