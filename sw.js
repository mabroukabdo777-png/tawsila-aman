const CACHE='matam-masr-v24-full-final';
self.addEventListener('install',e=>{
  self.skipWaiting();
  console.log('SW v24 installing - full features');
});
self.addEventListener('activate',e=>{
  e.waitUntil(
    caches.keys().then(keys=>Promise.all(keys.map(k=>{
      if(k!==CACHE){
        console.log('Deleting old cache:',k);
        return caches.delete(k);
      }
    }))).then(()=>self.clients.claim())
  );
});
self.addEventListener('fetch',e=>{
  e.respondWith(fetch(e.request).catch(()=>caches.match(e.request)));
});
self.addEventListener('message',e=>{if(e.data==='SKIP_WAITING')self.skipWaiting();});
