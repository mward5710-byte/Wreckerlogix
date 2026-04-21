import 'package:flutter/foundation.dart';
import 'firebase_options.dart';

/// Authentication service — Firebase Auth when configured, dev mock otherwise.
class AuthService extends ChangeNotifier {
  String? _userId;
  String? _userEmail;
  String? _displayName;
  String? _role; // 'dispatcher', 'driver', 'admin', 'accountant'
  bool _isAuthenticated = false;
  bool _isLoading = false;

  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get displayName => _displayName;
  String? get role => _role;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isDriver => _role == 'driver';
  bool get isDispatcher => _role == 'dispatcher';
  bool get isAdmin => _role == 'admin';

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
    notifyListeners();
  }

  /// Register a new user.
  Future<bool> register(
      String email, String password, String name, String role) async {
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

  void _registerDev(String email, String name, String role) {
    _userId = 'dev-user-${DateTime.now().millisecondsSinceEpoch}';
    _userEmail = email;
    _displayName = name;
    _role = role;
    _isAuthenticated = true;
  }
}
