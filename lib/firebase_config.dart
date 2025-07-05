// lib/firebase_config.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

// Define your FirebaseOptions for Web
// IMPORTANT: These values are now correctly provided by you.
const FirebaseOptions firebaseAndroidOptions = FirebaseOptions(
  apiKey: "1:220626158058:android:5b51118351cbd7eb433293",
  authDomain: "safescann-aa466.firebaseapp.com",
  projectId: "safescann-aa466",
  storageBucket: "safescann-aa466.appspot.com",
  messagingSenderId: "220626158058",
  appId: "AIzaSyCSEFjpARjtSmNv76nmdgLYfXmTMQiTv34",
);
const FirebaseOptions firebaseWebOptions = FirebaseOptions(
  apiKey: "AIzaSyCsAuX1KfXOjy-OT_xBS13VXBlHGbK4llw",
  authDomain: "safescann-aa466.firebaseapp.com",
  projectId: "safescann-aa466",
  storageBucket: "safescann-aa466.appspot.app",
  messagingSenderId: "220626158058",
  appId: "1:220626158058:web:d232e4683556a46f433293",
  measurementId: "G-BJ7NHCLGP1",
);

/// Returns the appropriate FirebaseOptions for the current platform.
FirebaseOptions? getPlatformFirebaseOptions() {
  if (kIsWeb) {
    return firebaseWebOptions;
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return firebaseAndroidOptions;
  // Add cases for iOS, macOS, Windows, Linux if you have their specific options
  // case TargetPlatform.iOS:
  //   return firebaseIosOptions;
  // case TargetPlatform.macOS:
  //   return firebaseMacosOptions;
  // case TargetPlatform.windows:
  //   return firebaseWindowsOptions;
  // case TargetPlatform.linux:
  //   return firebaseLinuxOptions;
    default: // <--- CORRECTED SYNTAX: default case inside the switch block
      print('Unsupported platform for Firebase initialization: $defaultTargetPlatform');
      return null;
  }
}
