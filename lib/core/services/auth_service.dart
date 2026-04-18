import 'package:flutter/foundation.dart';

/// Authentication service — Firebase-ready with development mock.
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

  /// Sign in with email and password.
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Replace with Firebase Auth
      // final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      //   email: email, password: password,
      // );
      await Future.delayed(const Duration(seconds: 1));
      _userId = 'dev-user-001';
      _userEmail = email;
      _displayName = email.split('@').first;
      _role = 'admin';
      _isAuthenticated = true;
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
    _userId = null;
    _userEmail = null;
    _displayName = null;
    _role = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Register a new user.
  Future<bool> register(String email, String password, String name, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Replace with Firebase Auth
      await Future.delayed(const Duration(seconds: 1));
      _userId = 'dev-user-${DateTime.now().millisecondsSinceEpoch}';
      _userEmail = email;
      _displayName = name;
      _role = role;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
