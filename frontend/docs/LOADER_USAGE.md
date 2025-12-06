# Loader Component Usage Guide

This application now includes a beautiful animated loader (Load #9 style) with bouncing bubbles that can be used throughout the application.

## Files Created

1. **`/src/components/Loader.js`** - The main Loader component
2. **`/src/components/Loader.css`** - Loader animations and styles
3. **`/src/contexts/LoadingContext.js`** - Global loading state management

## Usage Methods

### Method 1: Direct Component Usage (Local Loading State)

Use the `Loader` component directly in any component when you need a loading indicator:

```javascript
import Loader from '../components/Loader';

function MyComponent() {
  const [loading, setLoading] = useState(true);

  return (
    <div>
      {loading ? (
        <Loader text="Loading data..." />
      ) : (
        <div>Your content here</div>
      )}
    </div>
  );
}
```

### Method 2: Fullscreen Loader

For fullscreen loading overlays (e.g., during initial app load):

```javascript
import Loader from '../components/Loader';

function MyComponent() {
  const [loading, setLoading] = useState(true);

  if (loading) {
    return <Loader fullScreen text="Loading application..." />;
  }

  return <div>Your content</div>;
}
```

### Method 3: Global Loading State (RECOMMENDED)

Use the `useLoading` hook from `LoadingContext` to control loading state globally:

```javascript
import { useLoading } from '../contexts/LoadingContext';

function MyComponent() {
  const { showLoading, hideLoading } = useLoading();

  const fetchData = async () => {
    showLoading('Fetching content...');
    try {
      const response = await fetch('/api/data');
      const data = await response.json();
      // Process data
    } catch (error) {
      console.error(error);
    } finally {
      hideLoading();
    }
  };

  return (
    <button onClick={fetchData}>Load Data</button>
  );
}
```

## Component Props

### Loader Component Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `fullScreen` | boolean | `false` | If true, displays as fullscreen overlay |
| `show` | boolean | `true` | Controls visibility of loader |
| `text` | string | `''` | Optional loading text to display |

### useLoading Hook Methods

| Method | Parameters | Description |
|--------|------------|-------------|
| `showLoading` | `text?: string` | Shows the global loader with optional text |
| `hideLoading` | none | Hides the global loader |
| `isLoading` | getter | Returns current loading state (boolean) |

## Examples

### Example 1: Page-Level Loading

```javascript
import React, { useState, useEffect } from 'react';
import Loader from '../components/Loader';

function ContentPage() {
  const [loading, setLoading] = useState(true);
  const [content, setContent] = useState([]);

  useEffect(() => {
    loadContent();
  }, []);

  const loadContent = async () => {
    setLoading(true);
    try {
      const data = await fetchContent();
      setContent(data);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <Loader fullScreen text="Loading page..." />;
  }

  return <div>{/* Your content */}</div>;
}
```

### Example 2: Inline Loader (Within a Section)

```javascript
import Loader from '../components/Loader';

function DataSection() {
  const [loading, setLoading] = useState(false);

  return (
    <div className="data-section">
      <h2>Section Title</h2>
      {loading ? (
        <Loader text="Loading section..." />
      ) : (
        <div>Section content</div>
      )}
    </div>
  );
}
```

### Example 3: Form Submission with Global Loader

```javascript
import { useLoading } from '../contexts/LoadingContext';

function MyForm() {
  const { showLoading, hideLoading } = useLoading();

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    showLoading('Submitting form...');
    
    try {
      await submitFormData();
      alert('Success!');
    } catch (error) {
      alert('Error: ' + error.message);
    } finally {
      hideLoading();
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      {/* Form fields */}
      <button type="submit">Submit</button>
    </form>
  );
}
```

### Example 4: Multiple Async Operations

```javascript
import { useLoading } from '../contexts/LoadingContext';

function Dashboard() {
  const { showLoading, hideLoading } = useLoading();

  const refreshAllData = async () => {
    showLoading('Refreshing dashboard...');
    
    try {
      await Promise.all([
        fetchUsers(),
        fetchStats(),
        fetchNotifications()
      ]);
    } finally {
      hideLoading();
    }
  };

  return (
    <div>
      <button onClick={refreshAllData}>Refresh All</button>
      {/* Dashboard content */}
    </div>
  );
}
```

## Styling Customization

The loader styling can be customized in `Loader.css`:

```css
/* Change bubble colors */
.bubble-1 {
  background: linear-gradient(135deg, #your-color-1, #your-color-2);
}

.bubble-2 {
  background: linear-gradient(135deg, #your-color-3, #your-color-4);
}

/* Change animation speed */
.load-9 .spinner {
  animation: loadingI 1s linear infinite; /* faster */
}
```

## Best Practices

1. **Use Global Loading for App-Wide Operations**: Login, logout, initial data fetch
2. **Use Local Loading for Component-Specific Operations**: Individual form submissions, section refreshes
3. **Always Provide Meaningful Text**: Instead of "Loading...", use "Fetching content...", "Saving changes...", etc.
4. **Clean Up**: Always hide the loader in `finally` blocks to ensure it's hidden even if errors occur
5. **Avoid Nested Loaders**: Don't show multiple loaders at the same time

## Integration Status

The loader has been integrated into:

- ✅ `App.js` - Initial app loading
- ✅ `ContentListPage.js` - Content fetching
- 🔲 Other pages (you can add as needed)

## Need Help?

If you need to add the loader to other components or have questions, refer to the examples above or check the existing implementations in `App.js` and `ContentListPage.js`.
