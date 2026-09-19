// File generated - توصيلة أمان
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC-MATA3M-MASR-PLACEHOLDER',
    appId: '1:123456789:web:abc123',
    messagingSenderId: '123456789',
    projectId: 'mata3m-masr',
    authDomain: 'mata3m-masr.firebaseapp.com',
    storageBucket: 'mata3m-masr.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC-MATA3M-MASR-PLACEHOLDER',
    appId: '1:123456789:android:abc123',
    messagingSenderId: '123456789',
    projectId: 'mata3m-masr',
    storageBucket: 'mata3m-masr.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC-MATA3M-MASR-PLACEHOLDER',
    appId: '1:123456789:ios:abc123',
    messagingSenderId: '123456789',
    projectId: 'mata3m-masr',
    storageBucket: 'mata3m-masr.appspot.com',
    iosBundleId: 'com.example.tawsilaAman',
  );
}
