const CACHE='matam-masr-v20-full';
self.addEventListener('install',e=>{self.skipWaiting();e.waitUntil(caches.open(CACHE).then(c=>c.addAll(['./','./index.html','./manifest.json'])))} );
self.addEventListener('activate',e=>{e.waitUntil(caches.keys().then(k=>Promise.all(k.map(x=>{if(x!==CACHE)return caches.delete(x)}))).then(()=>self.clients.claim()))});
self.addEventListener('fetch',e=>{if(e.request.mode==='navigate'){e.respondWith(fetch(e.request).then(r=>{const cl=r.clone();caches.open(CACHE).then(c=>c.put(e.request,cl));return r}).catch(()=>caches.match(e.request)))}else{e.respondWith(caches.match(e.request).then(c=>c||fetch(e.request)))}});
self.addEventListener('message',e=>{if(e.data==='SKIP_WAITING')self.skipWaiting()});
