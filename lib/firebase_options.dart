// File generated manually based on google-services.json configurations.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
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
    apiKey: 'AIzaSyAQRAtYMFyUVEljGdcbwoMc9pTIwwxDv_M',
    appId: '1:986270588185:web:23d7ab1729ada2072bf988',
    messagingSenderId: '986270588185',
    projectId: 'proteinova',
    authDomain: 'proteinova.firebaseapp.com',
    storageBucket: 'proteinova.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAQRAtYMFyUVEljGdcbwoMc9pTIwwxDv_M',
    appId: '1:986270588185:android:23d7ab1729ada2072bf988',
    messagingSenderId: '986270588185',
    projectId: 'proteinova',
    storageBucket: 'proteinova.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAQRAtYMFyUVEljGdcbwoMc9pTIwwxDv_M',
    appId: '1:986270588185:ios:23d7ab1729ada2072bf988',
    messagingSenderId: '986270588185',
    projectId: 'proteinova',
    storageBucket: 'proteinova.firebasestorage.app',
    iosBundleId: 'com.example.proteinovaConnect',
  );
}
