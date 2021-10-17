import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quizpancasila/data/repositories/repository_providers.dart';
import 'package:quizpancasila/domain/entities/user.dart';
import 'package:quizpancasila/domain/repositories/auth_repository.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, User?>((ref) {
  final authRepository = ref.read(authRepositoryProvider);

  return AuthController(authRepository)..signInAnonymously();
});

class AuthController extends StateNotifier<User?> {
  final AuthRepository _repository;

  StreamSubscription<User?>? _subscription;

  AuthController(this._repository) : super(null) {
    _subscription?.cancel();
    _subscription =
        _repository.onAuthStateChanged.listen((user) => state = user);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> signInAnonymously() async {
    final user = _repository.currentUser();

    if (user == null) {
      await _repository.signInAnonymously();
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    await _repository.updateDisplayName(displayName);
  }

  Future<void> signOut() async {
    await _repository.signOut();
  }
}
