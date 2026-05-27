import React from 'react';
import { Link } from 'react-router-dom';


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
  { path: '/braj-rasik-heritage', title: 'Braj Rasik Heritage', desc: 'The rich spiritual legacy of Vrindavan' },
  { path: '/what-is-radha-snata', title: 'What is Radha Snata?', desc: 'Morning pastimes and spiritual meaning' },
  { path: '/nitya-vihar-vs-nikunj-vihar', title: 'Nitya Vihar vs Nikunj Vihar', desc: 'Timeless love-play and secluded bowers' },
  { path: '/glossary', title: 'Spiritual Glossary', desc: 'Braj Rasik vocabulary & theological terms' },
  { path: '/places', title: 'Braj Dham Places', desc: 'Sacred guide to Vrindavan holy sites' },
  { path: '/who-is-harirae-ji', title: 'Who is Harirae Ji?', desc: 'Biography, teachings, and Varta literature' },
  { path: '/what-is-madhurya-and-sakhi-bhava', title: 'Madhurya & Sakhi Bhava', desc: 'Sentiments of conjugal love and companion service' },
  { path: '/radhavallabh-vs-gaudiya-sampradaya', title: 'Radhavallabh vs Gaudiya', desc: 'Philosophical comparison and differences' },
  { path: '/vrindavan-parikrama-guide', title: 'Vrindavan Parikrama Guide', desc: 'Route, ghats, and spiritual rules' },
  { path: '/history-of-radhavallabh-sampradaya', title: 'Radhavallabh Sampradaya History', desc: 'Complete history, founder and teachings' },
  { path: '/major-rasik-saints-of-braj', title: 'Major Rasik Saints of Braj', desc: 'Biographies, lineages and contributions' },
];

const InternalLinks = ({ exclude = [], count = 4 }) => {
  const links = ALL_SEO_PAGES
    .filter(page => !exclude.includes(page.path))
    .slice(0, count);

  return (
    <nav className="mt-16 pt-8 border-t border-white/10" aria-label="Related Topics">
      <h2 className="text-xs font-bold uppercase tracking-widest mb-4 text-white/40">Related Topics</h2>
      <div className="flex flex-wrap gap-3">
        {links.map(link => (
          <Link
            key={link.path}
            to={link.path}
            className="px-4 py-2.5 rounded-2xl bg-white/[0.02] border border-white/5 hover:border-primary/30 text-xs text-white/70 hover:text-primary hover:bg-primary/5 transition-all duration-300 font-medium"
          >
            {link.title}
          </Link>
        ))}
      </div>
    </nav>
  );
};


export { ALL_SEO_PAGES };
export default InternalLinks;
