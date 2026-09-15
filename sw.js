const CACHE='tawsila-aman-v12-silent';
const URLS=['./','./index.html','./manifest.json','./m261997owner.html','./privacy.html','./terms.html','./about.html','./logo.png'];
self.addEventListener('install',e=>{
  e.waitUntil(caches.open(CACHE).then(c=>c.addAll(URLS)).then(()=>self.skipWaiting()))
});
self.addEventListener('activate',e=>{
  e.waitUntil(
    caches.keys().then(k=>Promise.all(k.filter(x=>x!==CACHE).map(x=>caches.delete(x))))
    .then(()=>self.clients.claim())
  )
});
self.addEventListener('fetch',e=>{
  if(e.request.url.includes('firebase')||e.request.url.includes('nominatim')||e.request.url.includes('osrm')||e.request.url.includes('firestore')||e.request.url.includes('google')||e.request.url.includes('freesound')) return;
  e.respondWith(caches.match(e.request).then(r=>r||fetch(e.request).catch(()=>caches.match('./index.html'))));
});
self.addEventListener('message',e=>{
  if(e.data && e.data.action==='skipWaiting'){
    self.skipWaiting();
  }
});
self.addEventListener('push',e=>{
  const data=e.data?e.data.json():{};
  self.registration.showNotification(data.title||'🔔 طلب جديد - توصيلة أمان', {body:data.body||'عندك طلب جديد', icon:'./logo.png'});
});
self.addEventListener('notificationclick',e=>{ e.notification.close(); e.waitUntil(clients.openWindow('./index.html')); });
