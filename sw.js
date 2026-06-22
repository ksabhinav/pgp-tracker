// PGP10 Reading Tracker — service worker (offline shell + installable PWA)
const CACHE = 'pgp10-v11';
const ASSETS = [
  './',
  './index.html',
  './manifest.webmanifest',
  './config.js',
  './vendor/supabase.min.js',
  './icons/icon-192.png',
  './icons/icon-512.png',
  './icons/icon-maskable-512.png',
  './icons/apple-touch-icon.png',
  './icons/favicon-32.png'
];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE)
      .then(c => Promise.allSettled(ASSETS.map(a => c.add(a))))  // tolerate any single miss
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;                  // let Supabase POST/PATCH pass straight through
  const url = new URL(req.url);
  if (url.origin !== location.origin) return;        // never intercept Supabase API / other origins

  // Network-first for things that change between deploys (page + config),
  // so updated Supabase keys / app code show up immediately when online.
  const networkFirst = req.mode === 'navigate'
    || url.pathname.endsWith('/config.js')
    || url.pathname.endsWith('/index.html')
    || url.pathname.endsWith('/');
  if (networkFirst) {
    e.respondWith(
      fetch(req).then(res => {
        const copy = res.clone();
        caches.open(CACHE).then(c => c.put(req, copy));
        return res;
      }).catch(() => caches.match(req).then(hit => hit || caches.match('./index.html')))
    );
    return;
  }
  // Cache-first for immutable static assets (icons, vendored lib).
  e.respondWith(
    caches.match(req).then(hit => hit || fetch(req).then(res => {
      const copy = res.clone();
      caches.open(CACHE).then(c => c.put(req, copy));
      return res;
    }).catch(() => caches.match('./index.html')))
  );
});
