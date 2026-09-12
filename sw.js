const CACHE='matam-masr-v16-luxury';
self.addEventListener('install',e=>{
  self.skipWaiting();
  e.waitUntil(caches.open(CACHE).then(c=>c.addAll(['./','./index.html','./manifest.json'])));
});
self.addEventListener('activate',e=>{
  e.waitUntil(
    caches.keys().then(keys=>Promise.all(keys.map(k=>{
      if(k!==CACHE) return caches.delete(k);
    }))).then(()=>self.clients.claim())
  );
});
self.addEventListener('fetch',e=>{
  e.respondWith(fetch(e.request).catch(()=>caches.match(e.request)));
});
