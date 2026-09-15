const CACHE='tawsila-aman-v16-auto-update-scroll-drivers';
const URLS=['./','./index.html','./manifest.json','./m261997owner.html','./privacy.html','./terms.html','./about.html','./logo.png','./icon-192.png','./icon-512.png','./screenshot-1.png','./screenshot-2.png'];

self.addEventListener('install',e=>{
  e.waitUntil(
    caches.open(CACHE).then(c=>c.addAll(URLS))
    .then(()=>self.skipWaiting())
  );
});

self.addEventListener('activate',e=>{
  e.waitUntil(
    caches.keys().then(keys=>Promise.all(
      keys.filter(k=>k!==CACHE).map(k=>caches.delete(k))
    )).then(()=>self.clients.claim())
  );
});

self.addEventListener('fetch',e=>{
  const url=e.request.url;
  if(url.includes('firebase')||url.includes('firestore')||url.includes('nominatim')||url.includes('osrm')||url.includes('google')||url.includes('freesound')){
    return;
  }
  // Network-first for index.html to get updates instantly
  if(url.endsWith('/') || url.includes('index.html')){
    e.respondWith(
      fetch(e.request).then(res=>{
        const clone=res.clone();
        caches.open(CACHE).then(c=>c.put(e.request, clone));
        return res;
      }).catch(()=>caches.match(e.request).then(r=>r||caches.match('./index.html')))
    );
    return;
  }
  e.respondWith(
    caches.match(e.request).then(r=>r||fetch(e.request).then(res=>{
      const clone=res.clone();
      caches.open(CACHE).then(c=>c.put(e.request, clone)).catch(()=>{});
      return res;
    }).catch(()=>caches.match('./index.html')))
  );
});

self.addEventListener('message',e=>{
  if(e.data && e.data.action==='skipWaiting'){
    self.skipWaiting();
  }
});

self.addEventListener('push',e=>{
  const data=e.data?e.data.json():{};
  self.registration.showNotification(data.title||'🔔 طلب جديد - توصيلة أمان', {body:data.body||'عندك طلب جديد', icon:'./icon-192.png'});
});

self.addEventListener('notificationclick',e=>{ 
  e.notification.close(); 
  e.waitUntil(clients.openWindow('./index.html')); 
});
