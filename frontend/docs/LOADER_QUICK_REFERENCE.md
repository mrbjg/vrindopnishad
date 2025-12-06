# 🚀 Loader Quick Reference

## Import

```javascript
// For inline/local loading
import Loader from '../components/Loader';

// For global loading
import { useLoading } from '../contexts/LoadingContext';
```

## Basic Usage

### 1. Inline Loader (Component-Level)

```javascript
function MyComponent() {
  const [loading, setLoading] = useState(true);

  if (loading) {
    return <Loader text="Loading..." />;
  }

  return <div>Content</div>;
}
```

### 2. Fullscreen Loader (Page-Level)

```javascript
function MyPage() {
  const [loading, setLoading] = useState(true);

  if (loading) {
    return <Loader fullScreen text="Loading page..." />;
  }

  return <div>Page Content</div>;
}
```

### 3. Global Loader (BEST for async operations)

```javascript
function MyComponent() {
  const { showLoading, hideLoading } = useLoading();

  const handleClick = async () => {
    showLoading('Processing...');
    try {
      await doSomething();
    } finally {
      hideLoading();
    }
  };

  return <button onClick={handleClick}>Click Me</button>;
}
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `fullScreen` | boolean | `false` | Fullscreen overlay |
| `show` | boolean | `true` | Show/hide loader |
| `text` | string | `''` | Loading text |

## useLoading Hook

```javascript
const { showLoading, hideLoading, isLoading } = useLoading();

showLoading('Custom text...');  // Show with text
hideLoading();                  // Hide
console.log(isLoading);         // Get current state
```

## Common Patterns

### API Call

```javascript
const { showLoading, hideLoading } = useLoading();

const fetchData = async () => {
  showLoading('Fetching data...');
  try {
    const data = await api.getData();
    setData(data);
  } catch (error) {
    console.error(error);
  } finally {
    hideLoading();
  }
};
```

### Form Submission

```javascript
const { showLoading, hideLoading } = useLoading();

const handleSubmit = async (e) => {
  e.preventDefault();
  showLoading('Submitting...');
  try {
    await api.submit(formData);
    alert('Success!');
  } finally {
    hideLoading();
  }
};
```

### Multiple Operations

```javascript
const { showLoading, hideLoading } = useLoading();

const refreshAll = async () => {
  showLoading('Refreshing...');
  try {
    await Promise.all([
      fetchUsers(),
      fetchStats(),
      fetchData()
    ]);
  } finally {
    hideLoading();
  }
};
```

## ✅ Do's

- ✅ Use global loader for API calls
- ✅ Always hide in `finally` block
- ✅ Provide meaningful text
- ✅ Use inline loader for sections
- ✅ Use fullscreen for pages

## ❌ Don'ts

- ❌ Don't nest multiple loaders
- ❌ Don't forget to hide loader
- ❌ Don't use generic "Loading..."
- ❌ Don't block user unnecessarily
- ❌ Don't use for instant operations

## Demo

Visit `/loader-demo` to see all variations in action!

## Files

- **Component:** `src/components/Loader.js`
- **Styles:** `src/components/Loader.css`
- **Context:** `src/contexts/LoadingContext.js`
- **Demo:** `src/pages/LoaderDemo.js`

## Support

For more examples, see:
- `LOADER_USAGE.md` - Detailed usage guide
- `LOADER_IMPLEMENTATION.md` - Full implementation details
- `src/pages/LoaderDemo.js` - Live examples
