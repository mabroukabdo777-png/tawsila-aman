const CACHE_NAME = 'mot3amy-v2'; // غير الرقم ده كل ما تعمل تحديث

self.addEventListener('install', (e) => {
  self.skipWaiting(); // يخليه يحدث فوراً
  e.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(['./','./index.html','./logo.png','./icon-192.png']))
  );
});

self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys().then(keys => Promise.all(keys.map(k => { if(k !== CACHE_NAME) return caches.delete(k) }))).then(()=>self.clients.claim())
  );
});

self.addEventListener('fetch', (e) => {
  e.respondWith(
    fetch(e.request).catch(()=>caches.match(e.request))
  );
});
