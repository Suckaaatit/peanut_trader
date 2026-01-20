const CACHE_NAME = 'peanut-v5';
const ASSETS = [
  './', './index.html', './index.tsx', './manifest.json',
  'https://cdn.tailwindcss.com',
  'https://unpkg.com/@babel/standalone/babel.min.js'
];

self.addEventListener('install', (e) => {
  e.waitUntil(caches.open(CACHE_NAME).then((c) => c.addAll(ASSETS)));
  self.skipWaiting();
});

self.addEventListener('activate', (e) => {
  e.waitUntil(
    Promise.all([
      caches.keys().then((keys) =>
        Promise.all(keys.map((k) => (k !== CACHE_NAME ? caches.delete(k) : Promise.resolve())))
      ),
      self.clients.claim()
    ])
  );
});

self.addEventListener('fetch', (e) => {
  e.respondWith(caches.match(e.request).then((r) => r || fetch(e.request)));
});
