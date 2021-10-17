import 'package:dartz/dartz.dart';
import 'package:quizpancasila/common/failure.dart';
import 'package:quizpancasila/domain/entities/room.dart';

abstract class RoomRepository {
  Stream<List<Room>> onOpenRoomsChanged();
  Future<Either<Failure, List<Room>>> getOpenRooms();

  Future<Either<Failure, Room>> createRoom({
    required String hostUID,
    required List<String> questionIDs,
    String? roomName,
  });
}
