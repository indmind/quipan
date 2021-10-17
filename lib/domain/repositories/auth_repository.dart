import 'package:quizpancasila/domain/entities/user.dart';

abstract class AuthRepository {
  Stream<User?> get onAuthStateChanged;
  User? currentUser();
  Future<void> updateDisplayName(String displayName);
  Future<void> signInAnonymously();
  Future<void> signOut();
}
