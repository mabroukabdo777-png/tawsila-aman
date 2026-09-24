const CACHE='sf-egypt-v36-full-company';// sf-egypt-v33-approved-instant';const ASSETS=['./','./index.html','./manifest.json','./icon-192.png','./icon-512.png'];
self.addEventListener('install',e=>{e.waitUntil(caches.open(CACHE).then(c=>c.addAll(ASSETS)));self.skipWaiting();});
self.addEventListener('activate',e=>{e.waitUntil(caches.keys().then(ks=>Promise.all(ks.filter(k=>k!==CACHE).map(k=>caches.delete(k)))));self.clients.claim();});
self.addEventListener('fetch',e=>{e.respondWith(caches.match(e.request).then(r=>r||fetch(e.request)));});
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-database-compat.js');
firebase.initializeApp({apiKey:"AIzaSyB8N4JFuAKT7qvIa6E6qhVxoQwYTv_IZCA",authDomain:"super-flash-b05d8.firebaseapp.com",databaseURL:"https://super-flash-b05d8-default-rtdb.firebaseio.com",projectId:"super-flash-b05d8",storageBucket:"super-flash-b05d8.firebasestorage.app",messagingSenderId:"102354982378",appId:"1:102354982378:web:7f94dad6b685fa95004e93"});
const messaging=firebase.messaging();
try{
  const db = firebase.database();
  let lastNotifAt = 0;
  db.ref('notifications').orderByChild('at').limitToLast(1).on('child_added', snap=>{
    const n = snap.val();
    if(!n) return;
    if(Date.now() - n.at > 120000) return;
    if(n.at <= lastNotifAt) return;
    lastNotifAt = n.at;
    if(n.type==='new_order'){
      self.registration.showNotification('📦 طلب جديد - Super Flash - حقيقي', {
        body: (n.text||'طلب جديد') + ' - ' + (n.price||'') + 'ج - ' + (n.customerName||'') + ' - مصر كلها',
        icon:'./icon-192.png',
        badge:'./icon-192.png',
        vibrate:[200,100,200,100,200],
        data:{url:'./'},
        requireInteraction:true
      });
    } else if(n.type==='payment_receipt'){
      self.registration.showNotification('💰 إيصال دفع جديد - حقيقي', {
        body: n.driverName + ' بعت إيصال ' + (n.amount||'') + 'ج',
        icon:'./icon-192.png',
        badge:'./icon-192.png',
        vibrate:[200,100,200],
        requireInteraction:true
      });
    } else if(n.type==='debt_whatsapp'){
      self.registration.showNotification('💬 دليفري عداد 150ج بعت واتس', {
        body: n.driverName + ' - ' + n.driverPhone + ' - ' + n.debt + 'ج - مصر كلها',
        icon:'./icon-192.png',
        badge:'./icon-192.png',
        vibrate:[200,100,200],
        requireInteraction:true
      });
    }
  });
}catch(e){ console.log('DB listener failed', e); }

messaging.onBackgroundMessage(payload=>{
  const title=payload.notification?.title||'Super Flash - مصر كلها - حقيقي';
  const body=payload.notification?.body||'طلب جديد جنبك - حقيقي';
  self.registration.showNotification(title,{body,icon:'./icon-192.png',badge:'./icon-192.png',vibrate:[200,100,200],requireInteraction:true,data:{url:'./'}});
});
self.addEventListener('notificationclick',e=>{
  e.notification.close();
  e.waitUntil(clients.matchAll({type:'window'}).then(clientsArr=>{
    const had = clientsArr.find(c=>c.url.includes('super-flash') || c.url.includes('index'));
    if(had) return had.focus();
    return clients.openWindow('./');
  }));
});
self.addEventListener('push',e=>{
  if(e.data){
    try{
      const data=e.data.json();
      const title=data.notification?.title||'Super Flash - حقيقي';
      const body=data.notification?.body||'طلب جديد - مصر كلها - حقيقي';
      e.waitUntil(self.registration.showNotification(title,{body,icon:'./icon-192.png',badge:'./icon-192.png',vibrate:[200,100,200,100,200],requireInteraction:true}));
    }catch(err){
      e.waitUntil(self.registration.showNotification('Super Flash - طلب جديد حقيقي',{body:'طلب جديد جنبك - افتح التطبيق - حقيقي',icon:'./icon-192.png',requireInteraction:true}));
    }
  }
});
