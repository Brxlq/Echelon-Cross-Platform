import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import 'app_cache.dart';

/// A mock authentication service.
class YummyAuth extends ChangeNotifier {
  YummyAuth({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  // Stores user state properties on platform specific file system.
  final _appCache = AppCache();

  Future<bool> get loggedIn async {
    if (_firebaseAuth.currentUser != null) {
      return true;
    }
    return _appCache.isUserLoggedIn();
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _appCache.invalidate();
    notifyListeners();
  }

  /// Signs in a user.
  Future<bool> signIn(String email, String password) async {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty || password.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-credential',
        message: 'Email and password are required.',
      );
    }

    await _firebaseAuth.signInWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );
    await _appCache.cacheUser();
    notifyListeners();
    return true;
  }

  Future<bool> signUp(String email, String password) async {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty || password.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-credential',
        message: 'Email and password are required.',
      );
    }

    await _firebaseAuth.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );
    await _appCache.cacheUser();
    notifyListeners();
    return true;
  }
}
