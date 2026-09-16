// PWA Service Worker - تثبيت مباشر  + إشعار يرن حتى لو مقفول
const CACHE_NAME = 'tawsila-v10';
const urlsToCache = ['./','./index.html','./manifest.json'];

self.addEventListener('install', event => {
  event.waitUntil(caches.open(CACHE_NAME).then(cache => cache.addAll(urlsToCache)));
  self.skipWaiting();
});

self.addEventListener('activate', event => {
  event.waitUntil(caches.keys().then(cacheNames => Promise.all(cacheNames.map(n=> n!==CACHE_NAME ? caches.delete(n) : null))));
  self.clients.claim();
});

self.addEventListener('fetch', event => {
  event.respondWith(caches.match(event.request).then(r=> r || fetch(event.request)));
});

try {
  importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js');
  importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js');
  firebase.initializeApp({
    apiKey: "AIzaSyA-EXAMPLE-REPLACE-WITH-YOUR-KEY",
    authDomain: "soqshpin.firebaseapp.com",
    databaseURL: "https://soqshpin-default-rtdb.firebaseio.com",
    projectId: "soqshpin",
    storageBucket: "soqshpin.appspot.com",
    messagingSenderId: "123456789",
    appId: "1:123456789:web:abcdef"
  });
  const messaging = firebase.messaging();
  messaging.onBackgroundMessage((payload) => {
    const title = payload.notification?.title || 'توصيلة أمان - طلب جديد 🔥';
    const options = {
      body: payload.notification?.body || 'فيه طلب قريب منك',
      icon: 'https://cdn-icons-png.flaticon.com/512/3774/3774083.png',
      badge: 'https://cdn-icons-png.flaticon.com/512/3774/3774083.png',
      vibrate: [300,100,300,100,500],
      requireInteraction: true,
      data: payload.data
    };
    self.registration.showNotification(title, options);
  });
} catch(e){}

self.addEventListener('notificationclick', (event)=>{
  event.notification.close();
  event.waitUntil(clients.openWindow('./'));
});
