import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizpancasila/domain/entities/room.dart';
import 'package:quizpancasila/common/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:quizpancasila/domain/entities/user.dart';
import 'package:quizpancasila/domain/repositories/room_repository.dart';
import 'package:quizpancasila/common/references.dart';

class RoomRepositoryImpl implements RoomRepository {
  final FirebaseFirestore _firestore;

  RoomRepositoryImpl(this._firestore);

  @override
  Stream<List<Room>> onOpenRoomsChanged() {
    return _firestore.rooms
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Stream<Room?> onRoomChanged(String roomId) {
    return _firestore.rooms
        .doc(roomId)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  @override
  Future<Either<Failure, List<Room>>> getOpenRooms() async {
    try {
      final snapshot =
          await _firestore.rooms.where('status', isEqualTo: 'open').get();

      return Right(snapshot.docs.map((doc) => doc.data()).toList());
    } on FirebaseException catch (e) {
      return Left(DatabaseFailure(e.message ?? 'Unknown Failure'));
    }
  }

  @override
  Future<Either<Failure, Room>> createRoom({
    required String hostUID,
    required List<String> questionIDs,
    String? roomName,
  }) async {
    roomName ??= 'Room ${DateTime.now().millisecondsSinceEpoch}';

    try {
      final room = Room(
        // we are going to replace once we have a proper id generated
        id: '',
        hostUID: hostUID,
        name: roomName,
        questionIds: questionIDs,
        status: RoomStatus.open,
        createdAt: Timestamp.now(),
        playerUIDs: [hostUID],
      );

      final doc = await _firestore.rooms.add(room);

      return Right(room.copyWith(id: doc.id));
    } on FirebaseException catch (e) {
      return Left(DatabaseFailure(e.message ?? 'Unknown Failure'));
    }
  }

   @override
  Future<Either<Failure, Room>> updateRoomName({
    required String roomID,
    required String roomName,
  }) async {
    try {
      final doc = await _firestore.rooms.doc(roomID).get();

      if (doc.exists) {
        await doc.reference.update({'name': roomName});

        return Right(doc.data()!);
      } else {
        return Left(DatabaseFailure('Room Not Found'));
      }
    } on FirebaseException catch (e) {
      return Left(DatabaseFailure(e.message ?? 'Unknown Failure'));
    }
  }

  @override
  Future<Either<Failure, Room>> deleteRoom(String roomID) async {
    try {
      final doc = await _firestore.rooms.doc(roomID).get();

      if (doc.exists) {
        doc.reference.delete();

        return Right(doc.data()!);
      } else {
        return Left(DatabaseFailure('Room Not Found'));
      }
    } on FirebaseException catch (e) {
      return Left(DatabaseFailure(e.message ?? 'Unknown Failure'));
    }
  }

  @override
  Future<Either<Failure, Room>> joinRoom({
    required String userUID,
    required String roomID,
  }) async {
    try {
      final doc = await _firestore.rooms.doc(roomID).get();

      if (doc.exists) {
        final room = doc.data()!;

        if (room.status == RoomStatus.open) {
          await _firestore.rooms.doc(roomID).update({
            'playerUIDs': FieldValue.arrayUnion([userUID]),
          });

          return Right(
              room.copyWith(playerUIDs: [...room.playerUIDs, userUID]));
        } else {
          return Left(DatabaseFailure('Room is not open'));
        }
      } else {
        return Left(DatabaseFailure('Room Not Found'));
      }
    } on FirebaseException catch (e) {
      return Left(DatabaseFailure(e.message ?? 'Unknown Failure'));
    }
  }

  @override
  Future<Either<Failure, Room>> leaveRoom(
      {required String userUID, required String roomID}) async {
    try {
      final doc = await _firestore.rooms.doc(roomID).get();

      if (doc.exists) {
        final room = doc.data()!;

        if (room.status == RoomStatus.open) {
          await _firestore.rooms.doc(roomID).update({
            'playerUIDs': FieldValue.arrayRemove([userUID]),
          });

          return Right(room.copyWith(
              playerUIDs:
                  room.playerUIDs.where((uid) => uid != userUID).toList()));
        } else {
          return Left(DatabaseFailure('Room is not open'));
        }
      } else {
        return Left(DatabaseFailure('Room Not Found'));
      }
    } on FirebaseException catch (e) {
      return Left(DatabaseFailure(e.message ?? 'Unknown Failure'));
    }
  }

  @override
  Future<Either<Failure, Room?>> getActiveRoom(String userUID) async {
    try {
      final snapshot = await _firestore.rooms
          .where('playerUIDs', arrayContains: userUID)
          .where('status', isEqualTo: 'open')
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Right(snapshot.docs.first.data());
      } else {
        return const Right(null);
      }
    } on FirebaseException catch (e) {
      return Left(DatabaseFailure(e.message ?? 'Unknown Failure'));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getRoomPlayers(String roomID) async {
    try {
      final snapshot = await _firestore.rooms.doc(roomID).get();

      if (snapshot.exists) {
        final room = snapshot.data()!;

        final userSnapshot = await _firestore.users
            .where(FieldPath.documentId, whereIn: room.playerUIDs)
            .get();

        return Right(userSnapshot.docs.map((doc) => doc.data()).toList());
      } else {
        return Left(DatabaseFailure('Room Not Found'));
      }
    } on FirebaseException catch (e) {
      return Left(DatabaseFailure(e.message ?? 'Unknown Failure'));
    }
  }
}
