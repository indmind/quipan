import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quizpancasila/common/general_providers.dart';
import 'package:quizpancasila/data/repositories/auth_repository_impl.dart';
import 'package:quizpancasila/data/repositories/question_repository.dart';
import 'package:quizpancasila/data/repositories/room_repository.dart';
import 'package:quizpancasila/domain/repositories/auth_repository.dart';
import 'package:quizpancasila/domain/repositories/question_repository.dart';
import 'package:quizpancasila/domain/repositories/room_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(firebaseAuthProvider),
    ref.read(firestoreProvider),
  );
});

final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return QuestionRepositoryImpl(
    ref.read(firestoreProvider),
  );
});

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  return RoomRepositoryImpl(
    ref.read(firestoreProvider),
  );
});
