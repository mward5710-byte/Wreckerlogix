import 'package:flutter/foundation.dart';

/// Firebase configuration for WreckerLogix.
///
/// HOW TO SET UP:
/// 1. Go to https://console.firebase.google.com
/// 2. Create a new project called "WreckerLogix"
/// 3. Add iOS, Android, and Web apps
/// 4. Replace the placeholder values below with your real Firebase config
/// 5. Set [isConfigured] to true
///
/// Alternatively, run `flutterfire configure` from the project root
/// to auto-generate this file.
class FirebaseConfig {
  FirebaseConfig._();

  /// Set to true once you've added your real Firebase project credentials.
  static const bool isConfigured = false;

  // ---------------------------------------------------------------------------
  // Web
  // ---------------------------------------------------------------------------
  static const String webApiKey = 'YOUR_WEB_API_KEY';
  static const String webAppId = 'YOUR_WEB_APP_ID';
  static const String webMessagingSenderId = 'YOUR_MESSAGING_SENDER_ID';
  static const String webProjectId = 'YOUR_PROJECT_ID';
  static const String webAuthDomain = 'YOUR_PROJECT_ID.firebaseapp.com';
  static const String webStorageBucket = 'YOUR_PROJECT_ID.appspot.com';

  // ---------------------------------------------------------------------------
  // Android
  // ---------------------------------------------------------------------------
  static const String androidApiKey = 'YOUR_ANDROID_API_KEY';
  static const String androidAppId = 'YOUR_ANDROID_APP_ID';

  // ---------------------------------------------------------------------------
  // iOS
  // ---------------------------------------------------------------------------
  static const String iosApiKey = 'YOUR_IOS_API_KEY';
  static const String iosAppId = 'YOUR_IOS_APP_ID';
  static const String iosBundleId = 'com.wreckerlogix.app';

  /// Print setup instructions to debug console.
  static void printSetupInstructions() {
    debugPrint('╔══════════════════════════════════════════════════════════╗');
    debugPrint('║  🔥 Firebase is NOT configured yet                      ║');
    debugPrint('║                                                          ║');
    debugPrint('║  The app is running in OFFLINE / DEV mode.               ║');
    debugPrint('║  All data is stored locally in memory.                   ║');
    debugPrint('║                                                          ║');
    debugPrint('║  To connect Firebase:                                    ║');
    debugPrint('║  1. Create a project at console.firebase.google.com      ║');
    debugPrint('║  2. Add your platform apps (iOS, Android, Web)           ║');
    debugPrint('║  3. Update lib/core/services/firebase_options.dart        ║');
    debugPrint('║  4. Set isConfigured = true                              ║');
    debugPrint('║  5. Run: flutterfire configure (optional auto-setup)     ║');
    debugPrint('╚══════════════════════════════════════════════════════════╝');
  }
}
