import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:quizpancasila/common/exception.dart';
import 'package:quizpancasila/domain/entities/user.dart';
import 'package:quizpancasila/domain/repositories/auth_repository.dart';
import 'package:username_gen/username_gen.dart';
import 'package:quizpancasila/common/references.dart';

class AuthRepositoryImpl implements AuthRepository {
  final auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this._firebaseAuth, this._firestore);

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
      await _updateFirestore();
    } on auth.FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Unknown error');
    }
  }

  @override
  Future<void> signInAnonymously() async {
    try {
      await _firebaseAuth.signInAnonymously();

      final user = _firebaseAuth.currentUser;

      // check for new user
      if (user != null && user.displayName == null) {
        await user.updateDisplayName(UsernameGen().generate());
        await _updateFirestore();
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

  Future<void> _updateFirestore() async {
    final user = _firebaseAuth.currentUser;

    if (user != null) {
      await _firestore.users.doc(user.uid).set(
            User.fromFirebase(user)!,
            SetOptions(merge: true),
          );
    }
  }
}
