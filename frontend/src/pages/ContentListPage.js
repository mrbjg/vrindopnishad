import React, { useState, useEffect, useContext } from 'react';
import { Link } from 'react-router-dom';
import { ApiContext } from '../App';
import { Search, Filter, ArrowRight, Tag } from 'lucide-react';

const ContentListPage = () => {
  const { apiService } = useContext(ApiContext);
  const [content, setContent] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState(null);

  useEffect(() => {
    fetchData();
  }, [selectedCategory]);

  const fetchData = async () => {
    setLoading(true);
    try {
      const data = await apiService.getAllContent(selectedCategory);
      const cats = await apiService.getCategories();
      setContent(data);
      setCategories(cats);
    } catch (error) {
      console.error('Error fetching content:', error);
    } finally {
      setLoading(false);
    }
  };

  const filteredContent = content.filter(item => 
    item.title?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    item.hindi_text?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="animate-fade-in">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6 mb-12">
        <div>
          <h1 className="text-4xl font-bold mb-2 tracking-tight">Spiritual Repository</h1>
          <p className="text-white/50">Explore the vast collection of sacred content</p>
        </div>

        <div className="relative w-full md:w-96">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-white/30" size={20} />
          <input 
            type="text" 
            placeholder="Search verses, titles..." 
            className="w-full h-12 bg-white/5 border border-white/10 rounded-full pl-12 pr-6 outline-none focus:border-primary/50 transition-colors"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
      </div>

      {/* Categories Horizontal Scroll */}
      <div className="flex gap-3 overflow-x-auto pb-6 scrollbar-hide mb-8">
        <button 
          onClick={() => setSelectedCategory(null)}
          className={`flex-none px-6 py-2 rounded-full border transition-all ${!selectedCategory ? 'bg-primary border-transparent text-white' : 'bg-white/5 border-white/10 text-white/60 hover:border-white/20'}`}
        >
          All
        </button>
        {categories.map(cat => (
          <button 
            key={cat}
            onClick={() => setSelectedCategory(cat)}
            className={`flex-none px-6 py-2 rounded-full border transition-all capitalize ${selectedCategory === cat ? 'bg-primary border-transparent text-white' : 'bg-white/5 border-white/10 text-white/60 hover:border-white/20'}`}
          >
            {cat}s
          </button>
        ))}
      </div>

      {loading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {[1,2,3,4,5,6].map(i => (
            <div key={i} className="glass-card h-64 animate-pulse"></div>
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {filteredContent.map(item => (
            <Link to={`/content/${item.id}`} key={item.id} className="glass-card group flex flex-col justify-between">
              <div>
                <div className="flex justify-between items-start mb-4">
                  <span className="badge border-primary/20 text-primary/70">{item.category}</span>
                  <div className="text-white/20 group-hover:text-primary transition-colors">
                    <ArrowRight size={20} />
                  </div>
                </div>
                <h3 className="text-xl font-bold mb-4 line-clamp-2 leading-tight group-hover:text-primary/90 transition-colors">
                  {item.title}
                </h3>
                <p className="text-white/60 text-sm line-clamp-3 leading-relaxed mb-6">
                  {item.hindi_text || item.english_translation}
                </p>
              </div>
              
              <div className="pt-4 border-t border-white/5 flex flex-wrap gap-2">
                {item.tags?.slice(0, 3).map(tag => (
                  <span key={tag} className="text-[10px] uppercase tracking-wider text-white/40 flex items-center gap-1 bg-white/5 px-2 py-1 rounded">
                    <Tag size={10} />
                    {tag}
                  </span>
                ))}
              </div>
            </Link>
          ))}
        </div>
      )}

      {!loading && filteredContent.length === 0 && (
        <div className="text-center py-24 glass-card">
           <Search size={48} className="mx-auto text-white/20 mb-6" />
           <p className="text-white/40">No content found matching your search.</p>
        </div>
      )}
    </div>
  );
};

export default ContentListPage;
