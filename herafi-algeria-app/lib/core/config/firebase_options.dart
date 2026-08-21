// Real values taken from android/app/google-services.json
// (app: com.herafi.algeria — project: herafi-algeria).
// Generated 2026-08-20 without Firebase CLI login (values verified against
// the official google-services.json shipped with the project).

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web is not configured for this project.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS is not configured for this project.');
      case TargetPlatform.macOS:
        throw UnsupportedError('macOS is not configured for this project.');
      case TargetPlatform.windows:
        throw UnsupportedError('Windows is not configured for this project.');
      case TargetPlatform.linux:
        throw UnsupportedError('Linux is not configured for this project.');
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Real values for com.herafi.algeria (herafi-algeria).
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDOncaX8vttH72GcuhRj1N_yRmngatgN60',
    appId: '1:16674347103:android:820ce3fd256d096160a3ea',
    messagingSenderId: '16674347103',
    projectId: 'herafi-algeria',
    storageBucket: 'herafi-algeria.firebasestorage.app',
  );
}
