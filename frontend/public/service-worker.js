const CACHE_NAME = 'vrindopnishad-fast-v4';
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
    
    self.skipWaiting();
});

self.addEventListener('activate', event => {
    event.waitUntil(
        caches.keys().then(keys => {
            return Promise.all(keys.filter(key => key !== CACHE_NAME).map(key => caches.delete(key)));
        })
    );
    
    self.clients.claim();
});

self.addEventListener('fetch', event => {
    const url = new URL(event.request.url);
    
    
    if (url.protocol !== 'http:' && url.protocol !== 'https:') {
        return;
    }

    
    
    
    if (
        url.pathname === '/sitemap.xml' ||
        url.pathname === '/robots.txt' ||
        url.pathname.startsWith('/api/') ||
        url.pathname.endsWith('.xml') ||
        url.pathname.includes('google') && url.pathname.endsWith('.html')
    ) {
        return; 
    }

    
    
    if (event.request.mode === 'navigate') {
        event.respondWith(
            fetch(event.request).catch(() => caches.match('/index.html'))
        );
        return;
    }

    
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

    
    event.respondWith(
        fetch(event.request).catch(() => caches.match(event.request))
    );
});
