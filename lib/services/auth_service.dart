import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current logged in user
  User? get currentUser => _auth.currentUser;

  /// Auth state changes (login/logout listener)
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Register new user
  Future<UserModel?> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel(
        uid: credential.user!.uid,
        email: credential.user!.email!,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Login existing user
  Future<UserModel?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel(
        uid: credential.user!.uid,
        email: credential.user!.email!,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Change password
  Future<void> changePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      } else {
        throw Exception("No user logged in");
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Failed to change password");
    }
  }

  /// Re-authenticate user (required before password change)
  Future<void> reauthenticate(String email, String password) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      } else {
        throw Exception("No user logged in");
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Re-authentication failed");
    }
  }
}
