
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyC_Bwet-hzbWIMtonl0ZA_sUgkQvdn_Ueg',
    appId: '1:173041456507:web:1cc37639d700d126ddd9de',
    messagingSenderId: '173041456507',
    projectId: 'job-portal-680b3',
    authDomain: 'job-portal-680b3.firebaseapp.com',
    storageBucket: 'job-portal-680b3.firebasestorage.app',
    measurementId: 'G-RXE36CC97D',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA0YN3ywVS2H9QyM2AfFbc4SJhTxSt_eWU',
    appId: '1:173041456507:android:3b3c03260e5385a2ddd9de',
    messagingSenderId: '173041456507',
    projectId: 'job-portal-680b3',
    storageBucket: 'job-portal-680b3.firebasestorage.app',
  );
}
