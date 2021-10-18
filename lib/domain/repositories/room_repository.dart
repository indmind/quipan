import 'package:dartz/dartz.dart';
import 'package:quizpancasila/common/failure.dart';
import 'package:quizpancasila/domain/entities/question.dart';
import 'package:quizpancasila/domain/entities/room.dart';
import 'package:quizpancasila/domain/entities/user.dart';

abstract class RoomRepository {
  Stream<List<Room>> onOpenRoomsChanged();
  Stream<Room?> onRoomChanged(String roomId);

  Future<Either<Failure, List<Room>>> getOpenRooms();

  Future<Either<Failure, Room>> createRoom({
    required String hostUID,
    required List<String> questionIDs,
    String? roomName,
  });

  Future<Either<Failure, Room>> updateRoomName({
    required String roomID,
    required String roomName,
  });

  Future<Either<Failure, Room>> joinRoom({
    required String userUID,
    required String roomID,
  });

  Future<Either<Failure, Room>> leaveRoom({
    required String userUID,
    required String roomID,
  });

  Future<Either<Failure, Room>> startRoomCountdown(String roomID);
  Future<Either<Failure, Room>> startRoomQuiz(String roomID);

  Future<Either<Failure, Room>> deleteRoom(String roomID);

  Future<Either<Failure, Room?>> getActiveRoom(String userUID);

  Future<Either<Failure, List<User>>> getRoomPlayers(String roomID);
  Future<Either<Failure, List<Question>>> getRoomQuestions(String roomID);
}
