import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quizpancasila/common/general_providers.dart';
import 'package:quizpancasila/data/repositories/auth_repository_impl.dart';
import 'package:quizpancasila/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(firebaseAuthProvider));
});
