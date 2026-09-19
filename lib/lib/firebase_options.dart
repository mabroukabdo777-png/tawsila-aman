import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(apiKey: 'AIzaSy-placeholder', appId: '1:123:android:abc', messagingSenderId: '123', projectId: 'tawsila-aman');
  }
}
