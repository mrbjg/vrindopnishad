const CACHE_NAME = 'vrindopnishad-fast-v1';
const STATIC_ASSETS = [
    '/',
    '/index.html',
    '/manifest.json',
    '/static/css/main.84563192.css', // Note: These will be updated dynamically in a real build process
    '/static/js/main.1d11f288.js'
];

self.addEventListener('install', event => {
    event.waitUntil(
        caches.open(CACHE_NAME).then(cache => {
            return cache.addAll(STATIC_ASSETS).catch(err => console.log('Pre-cache failed', err));
        })
    );
});

self.addEventListener('activate', event => {
    event.waitUntil(
        caches.keys().then(keys => {
            return Promise.all(keys.filter(key => key !== CACHE_NAME).map(key => caches.delete(key)));
        })
    );
});

self.addEventListener('fetch', event => {
    const url = new URL(event.request.url);
    
    // Cache First for static assets
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

    // Network First (with fallback) for others
    event.respondWith(
        fetch(event.request).catch(() => caches.match(event.request))
    );
});
