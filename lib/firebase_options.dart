// File generated for Firebase configuration
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAXHquz0l7CDt_zx5qsrdMDQ1bxyzF1o0s',
    appId: '1:662923885492:android:be660be0e91106be0690e1',
    messagingSenderId: '662923885492',
    projectId: 'dijlahapps2',
    storageBucket: 'dijlahapps2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDjt6pg0YStnht0h2AoPjONSy45WKtCom8',
    appId: '1:662923885492:ios:8ed2dc4bbd281ede0690e1',
    messagingSenderId: '662923885492',
    projectId: 'dijlahapps2',
    storageBucket: 'dijlahapps2.firebasestorage.app',
    iosBundleId: 'com.dijlah.alseraj',
  );
}
