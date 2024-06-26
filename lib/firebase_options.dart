// File generated by FlutterFire CLI.
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
    apiKey: 'AIzaSyBpcwcc4zx8nBZO8_ozssheDXWhkFqwzi0',
    appId: '1:57221760290:web:5af52cb849fd653a63517b',
    messagingSenderId: '57221760290',
    projectId: 'car-parking-locator-ced20',
    authDomain: 'car-parking-locator-ced20.firebaseapp.com',
    storageBucket: 'car-parking-locator-ced20.appspot.com',
    measurementId: 'G-9LPHVRD49Y',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB9z-4LjeQ3AO7zRam3-4xNSDsPI0r4RuU',
    appId: '1:57221760290:android:072416a7b27a94ee63517b',
    messagingSenderId: '57221760290',
    projectId: 'car-parking-locator-ced20',
    storageBucket: 'car-parking-locator-ced20.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDhATOYN1z_HCaDRjMag13WaOwbdM4TV1A',
    appId: '1:57221760290:ios:ec807468e97c4f7a63517b',
    messagingSenderId: '57221760290',
    projectId: 'car-parking-locator-ced20',
    storageBucket: 'car-parking-locator-ced20.appspot.com',
    iosBundleId: 'com.example.carParkingLocator',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDhATOYN1z_HCaDRjMag13WaOwbdM4TV1A',
    appId: '1:57221760290:ios:ec807468e97c4f7a63517b',
    messagingSenderId: '57221760290',
    projectId: 'car-parking-locator-ced20',
    storageBucket: 'car-parking-locator-ced20.appspot.com',
    iosBundleId: 'com.example.carParkingLocator',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBpcwcc4zx8nBZO8_ozssheDXWhkFqwzi0',
    appId: '1:57221760290:web:2f4019f500e7408763517b',
    messagingSenderId: '57221760290',
    projectId: 'car-parking-locator-ced20',
    authDomain: 'car-parking-locator-ced20.firebaseapp.com',
    storageBucket: 'car-parking-locator-ced20.appspot.com',
    measurementId: 'G-NNHYE25DFQ',
  );
}
