import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDUgaVH4o-lByFoL3teF1bwmsI72tTWp7E',
    appId: '1:594357834931:web:55de4a22c9547f24e28cc6',
    messagingSenderId: '594357834931',
    projectId: 'islamic-scholar-58c30',
    authDomain: 'islamic-scholar-58c30.firebaseapp.com',
    storageBucket: 'islamic-scholar-58c30.firebasestorage.app',
    measurementId: 'G-4R62RTQNQW',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAJUF6lAi0lbMf1BMbzvdcoMa7uxmMIGbs',
    appId: '1:594357834931:ios:3e0dba0229fa07f1e28cc6',
    messagingSenderId: '594357834931',
    projectId: 'islamic-scholar-58c30',
    storageBucket: 'islamic-scholar-58c30.firebasestorage.app',
    iosBundleId: 'com.example.islamicScholarProject',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAJUF6lAi0lbMf1BMbzvdcoMa7uxmMIGbs',
    appId: '1:594357834931:ios:3e0dba0229fa07f1e28cc6',
    messagingSenderId: '594357834931',
    projectId: 'islamic-scholar-58c30',
    storageBucket: 'islamic-scholar-58c30.firebasestorage.app',
    iosBundleId: 'com.example.islamicScholarProject',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDUgaVH4o-lByFoL3teF1bwmsI72tTWp7E',
    appId: '1:594357834931:web:f1582759d5869ab9e28cc6',
    messagingSenderId: '594357834931',
    projectId: 'islamic-scholar-58c30',
    authDomain: 'islamic-scholar-58c30.firebaseapp.com',
    storageBucket: 'islamic-scholar-58c30.firebasestorage.app',
    measurementId: 'G-JX5J2QPGJG',
  );
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDcf_F_bsYq1IgGhithYwXzHZ4zHvYoYvQ',
    appId: '1:594357834931:android:420f88ccb98216ece28cc6',
    messagingSenderId: '594357834931',
    projectId: 'islamic-scholar-58c30',
    storageBucket: 'islamic-scholar-58c30.firebasestorage.app',
  );
}
