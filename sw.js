const CACHE = 'sg-sales-v6';
const STATIC = ['./manifest.json', './icon.svg', './sw.js'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(STATIC)));
  self.skipWaiting();
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', e => {
  // Pass through API calls
  if (e.request.url.includes('workers.dev') || e.request.url.includes('hubapi.com')) return;

  // Network-first for HTML — always get the latest index.html, fall back to cache offline
  if (e.request.destination === 'document' || e.request.url.endsWith('/') || e.request.url.endsWith('/index.html')) {
    e.respondWith(
      fetch(e.request).then(r => {
        caches.open(CACHE).then(c => c.put(e.request, r.clone()));
        return r;
      }).catch(() => caches.match(e.request))
    );
    return;
  }

  // Cache-first for other static assets (icons, manifest)
  e.respondWith(caches.match(e.request).then(hit => hit || fetch(e.request)));
});
