const CACHE='matam-masr-v17-luxury-auto';
self.addEventListener('install',e=>{ self.skipWaiting(); e.waitUntil(caches.open(CACHE).then(c=>c.addAll(['./','./index.html','./manifest.json']))); });
self.addEventListener('activate',e=>{ e.waitUntil(caches.keys().then(keys=>Promise.all(keys.map(k=>{ if(k!==CACHE) return caches.delete(k); }))).then(()=>self.clients.claim())); });
self.addEventListener('fetch',e=>{
  if(e.request.mode==='navigate' || e.request.url.includes('index.html')){
    e.respondWith(fetch(e.request).then(r=>{ const cl=r.clone(); caches.open(CACHE).then(c=>c.put(e.request,cl)); return r; }).catch(()=>caches.match(e.request)));
  } else {
    e.respondWith(caches.match(e.request).then(c=>c||fetch(e.request)));
  }
});
self.addEventListener('message',e=>{ if(e.data==='SKIP_WAITING') self.skipWaiting(); });
