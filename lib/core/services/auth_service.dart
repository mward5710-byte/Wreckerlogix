import 'package:flutter/foundation.dart';
import 'firebase_options.dart';

/// Supported authentication methods.
enum AuthMethod { emailPassword, apple, passkey }

/// Authentication service — Firebase Auth when configured, dev mock otherwise.
/// Supports email/password, Sign in with Apple, and Passkey authentication.
class AuthService extends ChangeNotifier {
  String? _userId;
  String? _userEmail;
  String? _displayName;
  String? _role; // 'dispatcher', 'driver', 'admin', 'accountant'
  bool _isAuthenticated = false;
  bool _isLoading = false;
  AuthMethod? _lastAuthMethod;
  bool _passkeyRegistered = false;

  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get displayName => _displayName;
  String? get role => _role;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isDriver => _role == 'driver';
  bool get isDispatcher => _role == 'dispatcher';
  bool get isAdmin => _role == 'admin';
  AuthMethod? get lastAuthMethod => _lastAuthMethod;
  bool get passkeyRegistered => _passkeyRegistered;

  /// Whether we're using the real Firebase backend or dev mock.
  bool get isFirebaseActive => FirebaseConfig.isConfigured;

  /// Sign in with email and password.
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (FirebaseConfig.isConfigured) {
        // ─── Real Firebase Auth ───
        // TODO: Uncomment once platform folders are generated:
        // final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        //   email: email, password: password,
        // );
        // _userId = cred.user?.uid;
        // _userEmail = cred.user?.email;
        // _displayName = cred.user?.displayName ?? email.split('@').first;
        // _role = 'admin'; // fetch from Firestore user doc
        // _isAuthenticated = true;
        _signInDev(email);
      } else {
        // ─── Dev mock ───
        _signInDev(email);
      }

      _lastAuthMethod = AuthMethod.emailPassword;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Apple.
  ///
  /// Uses the Sign in with Apple SDK. In dev mode, simulates a successful
  /// Apple authentication with a mock Apple user.
  Future<bool> signInWithApple() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (FirebaseConfig.isConfigured) {
        // ─── Real Sign in with Apple + Firebase Auth ───
        // TODO: Uncomment once platform folders & Firebase are configured:
        //
        // import 'dart:convert';
        // import 'dart:math';
        // import 'package:crypto/crypto.dart';
        // import 'package:sign_in_with_apple/sign_in_with_apple.dart';
        //
        // // Generate a nonce for security
        // final rawNonce = _generateNonce();
        // final nonce = sha256.convert(utf8.encode(rawNonce)).toString();
        //
        // final appleCredential = await SignInWithApple.getAppleIDCredential(
        //   scopes: [
        //     AppleIDAuthorizationScopes.email,
        //     AppleIDAuthorizationScopes.fullName,
        //   ],
        //   nonce: nonce,
        // );
        //
        // final oauthCredential = OAuthProvider('apple.com').credential(
        //   idToken: appleCredential.identityToken,
        //   rawNonce: rawNonce,
        // );
        //
        // final userCredential =
        //     await FirebaseAuth.instance.signInWithCredential(oauthCredential);
        //
        // _userId = userCredential.user?.uid;
        // _userEmail = userCredential.user?.email ?? appleCredential.email;
        // _displayName = [
        //   appleCredential.givenName,
        //   appleCredential.familyName,
        // ].where((n) => n != null).join(' ');
        // if (_displayName?.isEmpty ?? true) {
        //   _displayName = userCredential.user?.displayName ?? 'Apple User';
        // }
        // _role = 'admin'; // fetch from Firestore user doc
        // _isAuthenticated = true;
        _signInAppleDev();
      } else {
        // ─── Dev mock ───
        _signInAppleDev();
      }

      _lastAuthMethod = AuthMethod.apple;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Passkey / biometric authentication.
  ///
  /// Uses platform-native passkey (FIDO2/WebAuthn) credentials.
  /// In dev mode, simulates a successful passkey authentication.
  Future<bool> signInWithPasskey() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (FirebaseConfig.isConfigured) {
        // ─── Real Passkey / WebAuthn Auth ───
        // TODO: Implement once backend FIDO2 server is configured:
        //
        // 1. Request authentication challenge from server
        // 2. Use platform authenticator (Face ID, Touch ID, etc.)
        // 3. Send signed assertion back to server
        // 4. Server verifies and returns Firebase custom token
        // 5. Sign in with Firebase custom token
        //
        // This requires a FIDO2-capable backend and platform-specific setup.
        _signInPasskeyDev();
      } else {
        // ─── Dev mock ───
        _signInPasskeyDev();
      }

      _lastAuthMethod = AuthMethod.passkey;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register a passkey for the current user.
  ///
  /// Creates a FIDO2/WebAuthn credential linked to the user's account,
  /// enabling future biometric sign-in.
  Future<bool> registerPasskey() async {
    if (!_isAuthenticated) return false;

    _isLoading = true;
    notifyListeners();

    try {
      if (FirebaseConfig.isConfigured) {
        // ─── Real Passkey Registration ───
        // TODO: Implement once backend FIDO2 server is configured:
        //
        // 1. Request registration challenge from server
        // 2. Use platform authenticator to create credential
        // 3. Send public key back to server for storage
        _passkeyRegistered = true;
      } else {
        // ─── Dev mock ───
        _passkeyRegistered = true;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    if (FirebaseConfig.isConfigured) {
      // TODO: Uncomment once platform folders are generated:
      // await FirebaseAuth.instance.signOut();
    }
    _userId = null;
    _userEmail = null;
    _displayName = null;
    _role = null;
    _isAuthenticated = false;
    _lastAuthMethod = null;
    notifyListeners();
  }

  /// Register a new user.
  Future<bool> register(String email, String password, String name, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (FirebaseConfig.isConfigured) {
        // ─── Real Firebase Auth ───
        // TODO: Uncomment once platform folders are generated:
        // final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        //   email: email, password: password,
        // );
        // await cred.user?.updateDisplayName(name);
        // _userId = cred.user?.uid;
        // // Store role in Firestore:
        // // await FirebaseFirestore.instance.collection('users').doc(_userId).set({
        // //   'name': name, 'role': role, 'email': email, 'createdAt': FieldValue.serverTimestamp(),
        // // });
        _registerDev(email, name, role);
      } else {
        _registerDev(email, name, role);
      }

      _lastAuthMethod = AuthMethod.emailPassword;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Dev helpers ───

  void _signInDev(String email) {
    _userId = 'dev-user-001';
    _userEmail = email;
    _displayName = email.split('@').first;
    _role = 'admin';
    _isAuthenticated = true;
  }

  void _signInAppleDev() {
    _userId = 'apple-user-001';
    _userEmail = 'apple.user@privaterelay.appleid.com';
    _displayName = 'Apple User';
    _role = 'admin';
    _isAuthenticated = true;
  }

  void _signInPasskeyDev() {
    _userId = 'passkey-user-001';
    _userEmail = 'passkey@wreckerlogix.com';
    _displayName = 'Passkey User';
    _role = 'admin';
    _isAuthenticated = true;
    _passkeyRegistered = true;
  }

  void _registerDev(String email, String name, String role) {
    _userId = 'dev-user-${DateTime.now().millisecondsSinceEpoch}';
    _userEmail = email;
    _displayName = name;
    _role = role;
    _isAuthenticated = true;
  }
}
