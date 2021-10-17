import 'package:quizpancasila/domain/entities/user.dart';

abstract class AuthRepository {
  Stream<User> get onAuthStateChanged;
  Future<User> currentUser();
  Future<User> signInAnonymously();
  Future<void> signOut();
}
