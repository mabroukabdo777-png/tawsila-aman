const VERSION='v4-black-premium';
self.addEventListener('install',e=>{self.skipWaiting()});
self.addEventListener('activate',e=>{
  e.waitUntil(clients.claim());
  e.waitUntil(caches.keys().then(k=>Promise.all(k.map(x=>caches.delete(x)))));
});
self.addEventListener('fetch',e=>{e.respondWith(fetch(e.request))});
