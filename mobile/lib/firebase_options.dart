import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    return android;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'fake-api-key',
    appId: '1:000000000000:web:abcdef123456',
    messagingSenderId: '000000000000',
    projectId: 'moh-medication-app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'fake-android-key',
    appId: '1:000000000000:android:abcdef123456',
    messagingSenderId: '000000000000',
    projectId: 'moh-medication-app',
  );
}
