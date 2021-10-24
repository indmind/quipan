import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quizpancasila/data/repositories/repository_providers.dart';
import 'package:quizpancasila/domain/entities/question.dart';
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

  Room? _current;
  Room? get current => _current;

  final List<User> _joinedRoomPlayers = [];
  List<User> get joinedRoomPlayers => _joinedRoomPlayers;

  final List<Question> _questions = [];
  List<Question> get questions => _questions;

  String? _message;
  String? get message => _message;

  bool get isHost => _current?.hostUID == _read(authControllerProvider)?.uid;

  StreamSubscription<Room?>? _roomSubscription;

  Future<void> subscribeToJoinedRoom() async {
    _roomSubscription?.cancel();

    if (current == null) return;

    _roomSubscription =
        roomRepository.onRoomChanged(current!.id).listen((room) async {
      final status = room?.status;

      switch (status) {
        case RoomStatus.open:
          fetchPlayers();
          break;
        case RoomStatus.countingDown:
          _current = room;
          notifyListeners();

          fetchQuestions();
          break;
        case RoomStatus.inProgress:
          _current = room;
          if (questions.isEmpty) await fetchQuestions();

          notifyListeners();
          break;
        case RoomStatus.finished:
          _current = room;
          notifyListeners();
          break;
        case RoomStatus.ended:
        default:
          setActiveRoom(null);
          break;
      }
    });
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }

  Future<void> setActiveRoom(Room? room) async {
    _current = room;
    notifyListeners();

    if (room != null) {
      await subscribeToJoinedRoom();
    }
  }

  Future<void> fetchActiveRoom() async {
    final user = _read(authControllerProvider);

    if (user == null) {
      _message = 'You are not logged in';
      notifyListeners();
      return;
    } else {
      _message = null;
      notifyListeners();
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

  Future<void> updateRoomName(String name) async {
    final user = _read(authControllerProvider);

    if (user == null) {
      _message = 'You are not logged in';
      notifyListeners();
      return;
    } else if (current == null) {
      _message = 'You are not in a room';
      notifyListeners();
      return;
    } else if (current!.hostUID != user.uid) {
      _message = 'You are not the host of this room';
      notifyListeners();
      return;
    }

    final room = await roomRepository.updateRoomName(
      roomID: current!.id,
      roomName: name,
    );

    room.fold(
      (error) {
        _message = error.message;
        notifyListeners();
      },
      (room) {
        // setActiveRoom(room);
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

    if (_current == null) {
      _message = 'You are not in a room';
      notifyListeners();
      return;
    }

    final result = isHost
        ? await roomRepository.deleteRoom(_current!.id)
        : await roomRepository.leaveRoom(
            roomID: _current!.id,
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

  Future<void> fetchPlayers() async {
    if (current == null) {
      _joinedRoomPlayers.clear();
      notifyListeners();
      return;
    }

    final result = await roomRepository.getRoomPlayers(current!.id);

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

  Future<void> fetchQuestions() async {
    if (current == null) {
      _questions.clear();
      notifyListeners();
      return;
    }

    final result = await roomRepository.getRoomQuestions(current!.id);

    result.fold(
      (failure) {
        _message = failure.message;
        notifyListeners();
      },
      (questions) {
        _questions.clear();
        _questions.addAll(questions);
        notifyListeners();
      },
    );
  }

  Future<void> startCountdown() async {
    if (current == null) {
      _message = 'You are not in a room';
      notifyListeners();
      return;
    }

    if (current!.hostUID != _read(authControllerProvider)!.uid) {
      return;
    }

    final result = await roomRepository.startRoomCountdown(current!.id);

    result.fold(
      (failure) {
        _message = failure.message;
        notifyListeners();
      },
      (room) {
        _current = room;
        notifyListeners();

        fetchQuestions();
      },
    );
  }

  // Start the quiz only if the user is the one who started the quiz
  Future<void> startQuiz() async {
    if (current == null) {
      _message = 'You are not in a room';
      notifyListeners();
      return;
    }

    if (current!.hostUID != _read(authControllerProvider)!.uid) {
      return;
    }

    final result = await roomRepository.startRoomQuiz(current!.id);

    result.fold(
      (failure) {
        _message = failure.message;
        notifyListeners();
      },
      (room) {
        _current = room;
        notifyListeners();
      },
    );
  }

  Future<void> startNextQuestion() async {
    if (current == null) {
      _message = 'You are not in a room';
      notifyListeners();
      return;
    }

    if (current!.hostUID != _read(authControllerProvider)!.uid) {
      return;
    }

    final result = await roomRepository.startNextQuestion(current!.id);

    result.fold(
      (failure) {
        _message = failure.message;
        notifyListeners();
      },
      (room) {
        _current = room;
        notifyListeners();
      },
    );
  }

  Future<void> finishQuiz() async {
    if (current == null) {
      _message = 'You are not in a room';
      notifyListeners();
      return;
    }

    if (current!.hostUID != _read(authControllerProvider)!.uid) {
      return;
    }

    final result = await roomRepository.finishQuiz(current!.id);

    result.fold(
      (failure) {
        _message = failure.message;
        notifyListeners();
      },
      (room) {
        _current = room;
        notifyListeners();
      },
    );
  }

  Future<void> endGame() async {
    if (current == null) {
      _message = 'You are not in a room';
      notifyListeners();
      return;
    }

    if (current!.hostUID != _read(authControllerProvider)!.uid) {
      return;
    }

    final result = await roomRepository.endGame(current!.id);

    result.fold(
      (failure) {
        _message = failure.message;
        notifyListeners();
      },
      (room) {
        _current = room;
        notifyListeners();
      },
    );
  }
}
