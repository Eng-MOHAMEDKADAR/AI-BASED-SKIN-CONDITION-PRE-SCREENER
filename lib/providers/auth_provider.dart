import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _authService.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? firebaseUser) {
    if (firebaseUser == null) {
      _user = null;
    } else {
      _user = UserModel(uid: firebaseUser.uid, email: firebaseUser.email ?? "");
    }
    notifyListeners();
  }

  /// ✅ Register new user and immediately sign them out
  Future<void> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.register(email, password);
      await _authService.logout(); // ✅ Sign out after registration
      _user = null;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.login(email, password);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      final email = _user?.email ?? "";
      await _authService.reauthenticate(email, currentPassword);
      await _authService.changePassword(newPassword);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
