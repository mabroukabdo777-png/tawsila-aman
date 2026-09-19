import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

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
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB0eHMekVj3hxInK2n1HfBEjEshGp2njpg',
    appId: '1:282224755647:web:deb4a22bcb7274c8b1570a',
    messagingSenderId: '282224755647',
    projectId: 'soqshpin',
    authDomain: 'soqshpin.firebaseapp.com',
    databaseURL: 'https://soqshpin-default-rtdb.firebaseio.com',
    storageBucket: 'soqshpin.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB0eHMekVj3hxInK2n1HfBEjEshGp2njpg',
    appId: '1:282224755647:android:soqshpin',
    messagingSenderId: '282224755647',
    projectId: 'soqshpin',
    databaseURL: 'https://soqshpin-default-rtdb.firebaseio.com',
    storageBucket: 'soqshpin.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB0eHMekVj3hxInK2n1HfBEjEshGp2njpg',
    appId: '1:282224755647:ios:soqshpin',
    messagingSenderId: '282224755647',
    projectId: 'soqshpin',
    databaseURL: 'https://soqshpin-default-rtdb.firebaseio.com',
    storageBucket: 'soqshpin.firebasestorage.app',
    iosBundleId: 'com.example.tawsilaAman',
  );
}
