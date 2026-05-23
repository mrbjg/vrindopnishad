import React, { useState, useEffect, useContext } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { ApiContext } from '../App';
import { extractRelations } from '../utils/relations';
import { Book, ArrowLeft, Search, FileText } from 'lucide-react';
import { Helmet } from 'react-helmet-async';

const BooksListPage = () => {
  const location = useLocation();
  const isHindiRoute = location.pathname.startsWith('/hi');
  const { apiService } = useContext(ApiContext);
  
  const [books, setBooks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    let active = true;
    const load = async () => {
      try {
        const allItems = await apiService.getAllContent(null, 10000);
        const relations = extractRelations(allItems);
        if (active) {
          setBooks(relations.books);
        }
      } catch (error) {
        console.error('Error loading books:', error);
      } finally {
        if (active) setLoading(false);
      }
    };
    load();
    return () => { active = false; };
  }, [apiService]);

  const filteredBooks = books.filter(b => 
    b.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    b.hinglishName.toLowerCase().includes(searchQuery.toLowerCase()) ||
    b.author.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="animate-fade-in max-w-6xl mx-auto px-4 py-8">
      <Helmet>
        <title>{isHindiRoute ? "प्रमुख ग्रन्थ एवं रस शास्त्र | Vrindopnishad" : "Sacred Granthas & Books | Vrindopnishad"}</title>
        <meta name="description" content={isHindiRoute ? "ब्रज रस के प्रमुख ग्रन्थों, वाणियों और शास्त्रों का संग्रह।" : "Read and browse the sacred books, granthas and vanis written by the saints of Vrindavan."} />
        <link rel="canonical" href={isHindiRoute ? "https://path.vrindopnishad.in/hi/books" : "https://path.vrindopnishad.in/books"} />
      </Helmet>

      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6 mb-12">
        <div>
          <Link to="/" className="inline-flex items-center gap-2 text-white/40 hover:text-white mb-4 transition-colors text-xs uppercase tracking-wider">
            <ArrowLeft size={14} />
            Back to Home
          </Link>
          <h1 className="text-4xl font-bold font-headings text-sacred-gradient">
            {isHindiRoute ? "प्रमुख ग्रन्थ एवं वाणियाँ" : "Sacred Granthas & Vaanis"}
          </h1>
          <p className="text-white/50 text-sm mt-1">
            {isHindiRoute ? "रसिक संतों द्वारा रचित दिव्य ग्रन्थ और वाणी संग्रह" : "Treasury of classical devotional scriptures"}
          </p>
        </div>

        <div className="relative w-full md:w-80">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-white/30" size={18} />
          <input 
            type="text" 
            placeholder={isHindiRoute ? "ग्रन्थ खोजें..." : "Search Books..."} 
            className="w-full h-11 bg-white/5 border border-white/10 rounded-full pl-11 pr-6 outline-none focus:border-amber-500/50 transition-colors text-sm"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
      </div>

      {loading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {[1, 2, 3].map(i => (
            <div key={i} className="glass-card h-32 animate-pulse space-y-4">
              <div className="h-5 bg-white/10 rounded w-2/3" />
              <div className="h-3 bg-white/5 rounded w-1/2" />
            </div>
          ))}
        </div>
      ) : filteredBooks.length === 0 ? (
        <div className="text-center py-20 glass-card">
          <Book size={48} className="mx-auto text-white/20 mb-4" />
          <p className="text-white/40">{isHindiRoute ? "कोई ग्रन्थ नहीं मिले" : "No books found matching your search."}</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredBooks.map(book => (
            <Link 
              key={book.name} 
              to={isHindiRoute ? `/hi/book/${book.slug}` : `/book/${book.slug}`}
              className="glass-card group hover:border-amber-500/30 transition-all duration-300 flex flex-col justify-between hover:shadow-2xl"
            >
              <div>
                <span className="text-[10px] uppercase tracking-widest text-amber-500 font-bold block mb-2">Grantha</span>
                <h3 className="font-bold text-lg text-white/90 group-hover:text-primary transition-colors leading-tight mb-1">
                  {book.name}
                </h3>
                <span className="text-xs text-white/40 block">
                  By {isHindiRoute ? book.author : book.author}
                </span>
              </div>
              
              <div className="pt-4 mt-6 border-t border-white/5 flex justify-between items-center text-xs">
                <span className="text-white/30 flex items-center gap-1">
                  <FileText size={12} />
                  {book.verses.length} {book.verses.length === 1 ? 'Verse' : 'Verses'}
                </span>
                <span className="text-primary font-medium group-hover:translate-x-1 transition-transform">
                  {isHindiRoute ? "पाठ खोलें →" : "Read Book →"}
                </span>
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
};

export default BooksListPage;
