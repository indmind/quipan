import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quizpancasila/data/repositories/repository_providers.dart';
import 'package:quizpancasila/domain/entities/room.dart';

import 'package:quizpancasila/domain/repositories/question_repository.dart';
import 'package:quizpancasila/domain/repositories/room_repository.dart';
import 'package:quizpancasila/presentation/controllers/auth_controller.dart';
import 'package:quizpancasila/presentation/controllers/lobby_controller.dart';

final roomControllerProvider = ChangeNotifierProvider<RoomController>((ref) {
  return RoomController(ref.read)..fetchOpenRooms();
});

class RoomController extends ChangeNotifier {
  final Reader _read;

  late final QuestionRepository questionRepository;
  late final RoomRepository roomRepository;

  RoomController(this._read) {
    questionRepository = _read(questionRepositoryProvider);
    roomRepository = _read(roomRepositoryProvider);
  }

  final List<Room> _openRooms = [];
  List<Room> get openRooms => _openRooms;

  String? _message;
  String? get message => _message;

  StreamSubscription? _openRoomsSubscription;

  @override
  void dispose() {
    _openRoomsSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchOpenRooms() async {
    _openRoomsSubscription?.cancel();
    _openRoomsSubscription =
        roomRepository.onOpenRoomsChanged().listen((rooms) {
      _openRooms.clear();
      _openRooms.addAll(rooms);
      notifyListeners();
    });
  }

  Future<void> createRoom() async {
    final user = _read(authControllerProvider);

    if (user == null) {
      _message = 'You must be logged in to create a room';
      notifyListeners();
      return;
    }

    // grab 5 random questions
    final questions = await questionRepository.getRandomQuestions(5);

    if (questions.isLeft()) {
      questions.leftMap((failure) {
        _message = failure.message;

        notifyListeners();
      });

      return;
    }

    final result = await roomRepository.createRoom(
      hostUID: user.uid,
      questionIDs: questions.getOrElse(() => []).map((q) => q.id).toList(),
    );

    result.fold(
      (failure) {
        _message = failure.message;
        notifyListeners();
      },
      (room) {
        _read(lobbyControllerProvider).setActiveRoom(room);
      },
    );
  }
}
