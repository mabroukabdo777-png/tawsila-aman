const CACHE='super-flash-company-v1';
const ASSETS=['./','./index.html','./manifest.json','./icon-192.png','./icon-512.png'];
self.addEventListener('install',e=>{
  e.waitUntil(caches.open(CACHE).then(c=>c.addAll(ASSETS)).then(()=>self.skipWaiting()));
});
self.addEventListener('activate',e=>{
  e.waitUntil(caches.keys().then(k=>Promise.all(k.map(c=>c!==CACHE?caches.delete(c):null))).then(()=>self.clients.claim()));
});
self.addEventListener('fetch',e=>{
  e.respondWith(caches.match(e.request).then(c=>{
    const f=fetch(e.request).then(r=>{
      if(r&&r.status===200&&e.request.method==='GET'){
        const cl=r.clone();
        caches.open(CACHE).then(ca=>ca.put(e.request,cl));
      }
      return r;
    }).catch(()=>c);
    return c||f;
  }));
});
