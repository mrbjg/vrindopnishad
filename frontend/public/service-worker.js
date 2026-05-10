const CACHE_NAME = 'vrindopnishad-fast-v2';
const STATIC_ASSETS = [
    '/',
    '/index.html',
    '/manifest.json'
];

self.addEventListener('install', event => {
    event.waitUntil(
        caches.open(CACHE_NAME).then(cache => {
            return cache.addAll(STATIC_ASSETS).catch(err => console.log('Pre-cache failed', err));
        })
    );
    // Activate immediately
    self.skipWaiting();
});

self.addEventListener('activate', event => {
    event.waitUntil(
        caches.keys().then(keys => {
            return Promise.all(keys.filter(key => key !== CACHE_NAME).map(key => caches.delete(key)));
        })
    );
    // Take control of all clients immediately
    self.clients.claim();
});

self.addEventListener('fetch', event => {
    const url = new URL(event.request.url);
    
    // CRITICAL SEO FIX: Never intercept these paths — let them go to the server directly
    // This prevents the service worker from serving cached HTML for sitemap, robots, etc.
    if (
        url.pathname === '/sitemap.xml' ||
        url.pathname === '/robots.txt' ||
        url.pathname.startsWith('/api/') ||
        url.pathname.endsWith('.xml') ||
        url.pathname.includes('google') && url.pathname.endsWith('.html')
    ) {
        return; // Don't call event.respondWith — browser handles natively
    }

    // For navigation requests (HTML pages), always go to network first
    // This ensures Googlebot always gets the latest index.html with correct meta tags
    if (event.request.mode === 'navigate') {
        event.respondWith(
            fetch(event.request).catch(() => caches.match('/index.html'))
        );
        return;
    }

    // Cache First for static assets only
    if (url.pathname.startsWith('/static/') || url.pathname.includes('logo') || url.pathname.includes('icon')) {
        event.respondWith(
            caches.match(event.request).then(response => {
                return response || fetch(event.request).then(fetchResponse => {
                    return caches.open(CACHE_NAME).then(cache => {
                        cache.put(event.request, fetchResponse.clone());
                        return fetchResponse;
                    });
                });
            })
        );
        return;
    }

    // Network First (with fallback) for everything else
    event.respondWith(
        fetch(event.request).catch(() => caches.match(event.request))
    );
});
