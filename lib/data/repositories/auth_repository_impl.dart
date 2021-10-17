import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:quizpancasila/common/exception.dart';
import 'package:quizpancasila/domain/entities/user.dart';
import 'package:quizpancasila/domain/repositories/auth_repository.dart';
import 'package:username_gen/username_gen.dart';

class AuthRepositoryImpl implements AuthRepository {
  final auth.FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl(this._firebaseAuth);

  @override
  Stream<User?> get onAuthStateChanged =>
      _firebaseAuth.userChanges().map(User.fromFirebase);

  @override
  User? currentUser() {
    try {
      return User.fromFirebase(_firebaseAuth.currentUser);
    } on auth.FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Unknown error');
    }
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    try {
      await _firebaseAuth.currentUser?.updateDisplayName(displayName);
    } on auth.FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Unknown error');
    }
  }

  @override
  Future<void> signInAnonymously() async {
    try {
      await _firebaseAuth.signInAnonymously();

      final user = _firebaseAuth.currentUser;

      if (user != null && user.displayName == null) {
        await user.updateDisplayName(UsernameGen().generate());
      }
    } on auth.FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Unknown error');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await signInAnonymously();
    } on auth.FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Unknown error');
    }
  }
}
