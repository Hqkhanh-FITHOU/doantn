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
    apiKey: 'AIzaSyB7cVYHajmlcpic2qlexg07d4UOPytU5ts',
    appId: '1:736067251440:web:6133932ca689b9ed2ee635',
    messagingSenderId: '736067251440',
    projectId: 'test-16a8b',
    authDomain: 'test-16a8b.firebaseapp.com',
    databaseURL: 'https://test-16a8b-default-rtdb.firebaseio.com',
    storageBucket: 'test-16a8b.appspot.com',
    measurementId: 'G-FCFEYC2DV4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDmH_FfN0Bryd7YJJ5ppzqLgg0AwV_mvQg',
    appId: '1:736067251440:android:fbb2a43543b2932d2ee635',
    messagingSenderId: '736067251440',
    projectId: 'test-16a8b',
    databaseURL: 'https://test-16a8b-default-rtdb.firebaseio.com',
    storageBucket: 'test-16a8b.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA-SXpCINC4NWW28KjwRNY-iE2IKErHb80',
    appId: '1:736067251440:ios:e721bf536dc2cddc2ee635',
    messagingSenderId: '736067251440',
    projectId: 'test-16a8b',
    databaseURL: 'https://test-16a8b-default-rtdb.firebaseio.com',
    storageBucket: 'test-16a8b.appspot.com',
    iosBundleId: 'com.example.doantn',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA-SXpCINC4NWW28KjwRNY-iE2IKErHb80',
    appId: '1:736067251440:ios:e721bf536dc2cddc2ee635',
    messagingSenderId: '736067251440',
    projectId: 'test-16a8b',
    databaseURL: 'https://test-16a8b-default-rtdb.firebaseio.com',
    storageBucket: 'test-16a8b.appspot.com',
    iosBundleId: 'com.example.doantn',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB7cVYHajmlcpic2qlexg07d4UOPytU5ts',
    appId: '1:736067251440:web:79301775c403f0e42ee635',
    messagingSenderId: '736067251440',
    projectId: 'test-16a8b',
    authDomain: 'test-16a8b.firebaseapp.com',
    databaseURL: 'https://test-16a8b-default-rtdb.firebaseio.com',
    storageBucket: 'test-16a8b.appspot.com',
    measurementId: 'G-KFD9Q07MP2',
  );

}