import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => android;
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCFYCnn8bUqSfL619UhNyv3G6Vvkrmp7hk',
    appId: '1:315344044519:android:a1b2c3d4e5f6a7b8c9d0',
    messagingSenderId: '315344044519',
    projectId: 'mata3m-masr',
    storageBucket: 'mata3m-masr.firebasestorage.app',
  );
}
