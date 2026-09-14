const CACHE_NAME = 'tawsila-v8-final';
const urlsToCache = [
  './',
  './index.html',
  './manifest.json'
];

self.addEventListener('install', event => {
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(urlsToCache))
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys => Promise.all(
      keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k))
    )).then(()=>self.clients.claim())
  );
});

self.addEventListener('fetch', event => {
  event.respondWith(
    fetch(event.request).then(res=>{
      const clone=res.clone();
      caches.open(CACHE_NAME).then(cache=>cache.put(event.request, clone));
      return res;
    }).catch(()=>caches.match(event.request))
  );
});

self.addEventListener('message', event=>{
  if(event.data && event.data.type==='SKIP_WAITING'){
    self.skipWaiting();
  }
});

self.addEventListener('push', event=>{
  const data = event.data ? event.data.json() : {title:'Tawsila Aman', body:'طلب جديد حقيقي'};
  event.waitUntil(
    self.registration.showNotification(data.title, {body:data.body, icon:'https://cdn-icons-png.flaticon.com/512/3774/3774099.png'})
  );
});
