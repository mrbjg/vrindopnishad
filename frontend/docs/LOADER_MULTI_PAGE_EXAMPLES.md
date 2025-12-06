# 🎯 Complete Loader Usage Examples

## Multi-Page Usage Guide

The loader has been optimized for easy use across **multiple webpages** with several usage patterns.

---

## Method 1: Local Loading (Component-Specific) ⭐ RECOMMENDED

Use the `useLocalLoading` hook for page-specific loading:

```javascript
import React, { useEffect } from 'react';
import Loader from '../components/Loader';
import useLocalLoading from '../hooks/useLocalLoading';

function MyPage() {
  const { loading, withLoading } = useLocalLoading();
  const [data, setData] = useState([]);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    await withLoading(async () => {
      const response = await fetch('/api/data');
      const result = await response.json();
      setData(result);
    });
  };

  if (loading) {
    return <Loader fullScreen text="Loading page..." />;
  }

  return <div>{/* Your content */}</div>;
}
```

---

## Method 2: Global Loading (App-Wide)

Use for operations that affect the entire app:

```javascript
import { useLoading } from '../contexts/LoadingContext';

function LoginPage() {
  const { showLoading, hideLoading } = useLoading();

  const handleLogin = async (e) => {
    e.preventDefault();
    showLoading('Logging in...');
    try {
      await api.login(credentials);
    } finally {
      hideLoading();
    }
  };

  return <form onSubmit={handleLogin}>...</form>;
}
```

---

## Method 3: Inline Section Loader

For loading specific sections within a page:

```javascript
import Loader from '../components/Loader';

function Dashboard() {
  const [statsLoading, setStatsLoading] = useState(true);
  const [postsLoading, setPostsLoading] = useState(true);

  return (
    <div>
      <h1>Dashboard</h1>
      
      {/* Stats Section */}
      <div className="stats-section">
        {statsLoading ? (
          <Loader text="Loading stats..." size="small" />
        ) : (
          <StatsDisplay />
        )}
      </div>

      {/* Posts Section */}
      <div className="posts-section">
        {postsLoading ? (
          <Loader text="Loading posts..." />
        ) : (
          <PostsList />
        )}
      </div>
    </div>
  );
}
```

---

## Common Page Patterns

### Pattern 1: Simple Page Load

```javascript
import React, { useState, useEffect } from 'react';
import Loader from '../components/Loader';
import useLocalLoading from '../hooks/useLocalLoading';

function ProductsPage() {
  const { loading, startLoading, stopLoading } = useLocalLoading(true);
  const [products, setProducts] = useState([]);

  useEffect(() => {
    async function fetchProducts() {
      try {
        const data = await api.getProducts();
        setProducts(data);
      } finally {
        stopLoading();
      }
    }
    fetchProducts();
  }, []);

  if (loading) return <Loader fullScreen text="Loading products..." />;

  return (
    <div>
      {products.map(product => (
        <ProductCard key={product.id} {...product} />
      ))}
    </div>
  );
}
```

### Pattern 2: Form Submission

```javascript
import { useLoading } from '../contexts/LoadingContext';

function ContactPage() {
  const { showLoading, hideLoading } = useLoading();

  const handleSubmit = async (formData) => {
    showLoading('Sending message...');
    try {
      await api.sendMessage(formData);
      alert('Message sent!');
    } catch (error) {
      alert('Error: ' + error.message);
    } finally {
      hideLoading();
    }
  };

  return <ContactForm onSubmit={handleSubmit} />;
}
```

### Pattern 3: Multiple Async Operations

```javascript
import useLocalLoading from '../hooks/useLocalLoading';

function ReportsPage() {
  const { loading, withLoading } = useLocalLoading();

  const refreshAll = async () => {
    await withLoading(async () => {
      await Promise.all([
        fetchSalesData(),
        fetchUserData(),
        fetchAnalytics()
      ]);
    });
  };

  return (
    <div>
      <button onClick={refreshAll}>Refresh All</button>
      {loading && <Loader text="Refreshing reports..." />}
      {/* Report content */}
    </div>
  );
}
```

### Pattern 4: Conditional Loading

```javascript
function SearchPage() {
  const [searching, setSearching] = useState(false);
  const [results, setResults] = useState([]);

  const handleSearch = async (query) => {
    setSearching(true);
    try {
      const data = await api.search(query);
      setResults(data);
    } finally {
      setSearching(false);
    }
  };

  return (
    <div>
      <SearchInput onSearch={handleSearch} />
      
      {searching ? (
        <Loader text="Searching..." />
      ) : results.length > 0 ? (
        <ResultsList results={results} />
      ) : (
        <EmptyState />
      )}
    </div>
  );
}
```

---

## Loader Sizes

### Default Size (Standard)
```javascript
<Loader text="Loading..." />
```

### Small Size (Compact spaces)
```javascript
<Loader text="Loading..." size="small" />
```

### Fullscreen (Page loads)
```javascript
<Loader fullScreen text="Loading page..." />
```

---

## Quick Reference

| Use Case | Method | Code |
|----------|--------|------|
| **Page load** | Local hook | `useLocalLoading()` |
| **Form submit** | Global context | `useLoading()` |
| **Section load** | Direct component | `<Loader />` |
| **Button action** | Global context | `showLoading()` |
| **Multiple ops** | Local hook | `withLoading(async () => {})` |

---

## Complete Example: Blog Page

```javascript
import React, { useState, useEffect } from 'react';
import Loader from '../components/Loader';
import useLocalLoading from '../hooks/useLocalLoading';
import { useLoading } from '../contexts/LoadingContext';

function BlogPage() {
  // Page-level loading
  const { loading: pageLoading, startLoading, stopLoading } = useLocalLoading(true);
  const [posts, setPosts] = useState([]);
  
  // Global loading for actions
  const { showLoading, hideLoading } = useLoading();

  // Load posts on mount
  useEffect(() => {
    loadPosts();
  }, []);

  const loadPosts = async () => {
    try {
      const data = await api.getPosts();
      setPosts(data);
    } finally {
      stopLoading();
    }
  };

  const handleDelete = async (postId) => {
    if (!confirm('Delete this post?')) return;
    
    showLoading('Deleting post...');
    try {
      await api.deletePost(postId);
      await loadPosts();
    } finally {
      hideLoading();
    }
  };

  // Show fullscreen loader while page loads
  if (pageLoading) {
    return <Loader fullScreen text="Loading blog posts..." />;
  }

  return (
    <div className="blog-page">
      <h1>Blog Posts</h1>
      
      {posts.length === 0 ? (
        <p>No posts yet.</p>
      ) : (
        posts.map(post => (
          <div key={post.id} className="post-card">
            <h2>{post.title}</h2>
            <p>{post.excerpt}</p>
            <button onClick={() => handleDelete(post.id)}>
              Delete
            </button>
          </div>
        ))
      )}
    </div>
  );
}

export default BlogPage;
```

---

## Best Practices

✅ **DO:**
- Use `useLocalLoading` for page-specific loading
- Use `useLoading` (global) for cross-page operations (login, logout)
- Always clean up loading state in `finally` block
- Provide descriptive loading text
- Use `size="small"` for inline sections

❌ **DON'T:**
- Don't mix both loading methods for the same operation
- Don't forget to hide the loader
- Don't use generic "Loading..." text
- Don't nest multiple fullscreen loaders
- Don't use fullscreen for small sections

---

## Import Examples

```javascript
// Local loading (most pages)
import Loader from '../components/Loader';
import useLocalLoading from '../hooks/useLocalLoading';

// Global loading (app-wide operations)
import { useLoading } from '../contexts/LoadingContext';

// Both (if needed)
import Loader from '../components/Loader';
import useLocalLoading from '../hooks/useLocalLoading';
import { useLoading } from '../contexts/LoadingContext';
```

---

## Files You Need

- ✅ `src/components/Loader.js` - The component
- ✅ `src/components/Loader.css` - Styles (no outer box!)
- ✅ `src/hooks/useLocalLoading.js` - Local loading hook
- ✅ `src/contexts/LoadingContext.js` - Global loading context

All files are already created and ready to use! 🎉
