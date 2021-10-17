import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quizpancasila/data/repositories/repository_providers.dart';
import 'package:quizpancasila/domain/entities/room.dart';
import 'package:quizpancasila/domain/entities/user.dart';

import 'package:quizpancasila/domain/repositories/question_repository.dart';
import 'package:quizpancasila/domain/repositories/room_repository.dart';
import 'package:quizpancasila/presentation/controllers/auth_controller.dart';

final lobbyControllerProvider = ChangeNotifierProvider<LobbyController>((ref) {
  return LobbyController(ref.read);
});

class LobbyController extends ChangeNotifier {
  final Reader _read;

  late final QuestionRepository questionRepository;
  late final RoomRepository roomRepository;

  LobbyController(this._read) {
    questionRepository = _read(questionRepositoryProvider);
    roomRepository = _read(roomRepositoryProvider);
  }

  Room? _joinedRoom;
  Room? get joinedRoom => _joinedRoom;

  final List<User> _joinedRoomPlayers = [];
  List<User> get joinedRoomPlayers => _joinedRoomPlayers;

  String? _message;
  String? get message => _message;

  bool get isHost => _joinedRoom?.hostUID == _read(authControllerProvider)?.uid;

  StreamSubscription<Room?>? _roomSubscription;

  Future<void> subscribeToJoinedRoom() async {
    _roomSubscription?.cancel();

    if (joinedRoom == null) return;

    _roomSubscription =
        roomRepository.onRoomChanged(joinedRoom!.id).listen((room) {
      if (room?.status == RoomStatus.open) {
        fetchActiveRoomPlayers();
      } else {
        setActiveRoom(null);
      }
    });
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }

  Future<void> setActiveRoom(Room? room) async {
    _joinedRoom = room;
    notifyListeners();

    await subscribeToJoinedRoom();
  }

  Future<void> fetchActiveRoom() async {
    final user = _read(authControllerProvider);

    if (user == null) {
      _message = 'You are not logged in';
      notifyListeners();
      return;
    }

    final room = await roomRepository.getActiveRoom(user.uid);

    room.fold(
      (error) {
        _message = error.message;
        notifyListeners();
      },
      (room) {
        setActiveRoom(room);
      },
    );
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
        _joinedRoom = room;
        notifyListeners();
      },
    );
  }

  Future<void> joinRoom(String roomId) async {
    final user = _read(authControllerProvider);

    if (user == null) {
      _message = 'You must be logged in to join a room';
      notifyListeners();
      return;
    }

    final result = await roomRepository.joinRoom(
      roomID: roomId,
      userUID: user.uid,
    );

    result.fold(
      (failure) {
        _message = failure.message;
        notifyListeners();
      },
      (room) {
        setActiveRoom(room);
      },
    );
  }

  Future<void> leaveRoom() async {
    final user = _read(authControllerProvider);

    if (_joinedRoom == null) {
      _message = 'You are not in a room';
      notifyListeners();
      return;
    }

    final result = isHost
        ? await roomRepository.deleteRoom(_joinedRoom!.id)
        : await roomRepository.leaveRoom(
            roomID: _joinedRoom!.id,
            userUID: user!.uid,
          );

    result.fold(
      (failure) {
        _message = failure.message;
        notifyListeners();
      },
      (room) {
        setActiveRoom(null);
      },
    );
  }

  Future<void> fetchActiveRoomPlayers() async {
    if (joinedRoom == null) {
      _joinedRoomPlayers.clear();
      notifyListeners();
      return;
    }

    final result = await roomRepository.getRoomPlayers(joinedRoom!.id);

    result.fold(
      (failure) {
        _message = failure.message;
        notifyListeners();
      },
      (players) {
        _joinedRoomPlayers.clear();
        _joinedRoomPlayers.addAll(players);
        notifyListeners();
      },
    );
  }
}
