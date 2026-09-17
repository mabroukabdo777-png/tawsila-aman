const CACHE_NAME = 'mot3amy-v5-337-real';
const ASSETS = ['./','./index.html','./manifest.json'];
self.addEventListener('install', e=>{
  self.skipWaiting();
  e.waitUntil(caches.open(CACHE_NAME).then(c=>c.addAll(ASSETS)));
});
self.addEventListener('activate', e=>{
  e.waitUntil(caches.keys().then(keys=>Promise.all(keys.map(k=>{ if(k!==CACHE_NAME) return caches.delete(k); }))).then(()=>self.clients.claim()));
});
self.addEventListener('fetch', e=>{
  e.respondWith(fetch(e.request).then(r=>r).catch(()=>caches.match(e.request)));
});
