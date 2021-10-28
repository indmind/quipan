import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizpancasila/common/generator.dart';
import 'package:quizpancasila/domain/entities/question.dart';
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
        .where('status', isEqualTo: 'open')
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
    roomName ??= roomNameGen.generate();

    try {
      final room = Room(
        // we are going to replace once we have a proper id generated
        id: '',
        hostUID: hostUID,
        name: roomName,
        questionIds: questionIDs,
        currentQuestionIndex: 0,
        status: RoomStatus.open,
        createdAt: Timestamp.now(),
        playerUIDs: [hostUID],
        playerScores: {hostUID: 0},
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
            "playerScores.$userUID": 0,
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
            "playerScores.$userUID": FieldValue.delete(),
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
          .where('status', isNotEqualTo: 'ended')
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

  @override
  Future<Either<Failure, List<Question>>> getRoomQuestions(
      String roomID) async {
    try {
      final snapshot = await _firestore.rooms.doc(roomID).get();

      if (snapshot.exists) {
        final room = snapshot.data()!;

        final questionSnapshot = await _firestore.questions
            .where(FieldPath.documentId, whereIn: room.questionIds)
            .get();

        return Right(questionSnapshot.docs.map((doc) => doc.data()).toList());
      } else {
        return Left(DatabaseFailure('Room Not Found'));
      }
    } on FirebaseException catch (e) {
      return Left(DatabaseFailure(e.message ?? 'Unknown Failure'));
    }
  }

  @override
  Future<Either<Failure, Room>> startRoomCountdown(String roomID) async {
    try {
      final doc = await _firestore.rooms.doc(roomID).get();

      if (doc.exists) {
        await doc.reference.update({
          'status': 'counting_down',
          'currentQuestionIndex': 0,
        });

        return Right(doc.data()!.copyWith(
              status: RoomStatus.countingDown,
              currentQuestionIndex: 0,
            ));
      } else {
        return Left(DatabaseFailure('Room Not Found'));
      }
    } on FirebaseException catch (e) {
      return Left(DatabaseFailure(e.message ?? 'Unknown Failure'));
    }
  }

  @override
  Future<Either<Failure, Room>> startRoomQuiz(String roomID) async {
    try {
      final doc = await _firestore.rooms.doc(roomID).get();

      if (doc.exists) {
        await doc.reference.update({
          'status': 'in_progress',
          'startedAt': FieldValue.serverTimestamp(),
        });

        return Right(
          doc.data()!.copyWith(
                status: RoomStatus.inProgress,
                startedAt: Timestamp.now(),
              ),
        );
      } else {
        return Left(DatabaseFailure('Room Not Found'));
      }
    } on FirebaseException catch (e) {
      return Left(DatabaseFailure(e.message ?? 'Unknown Failure'));
    }
  }

  @override
  Future<Either<Failure, Room>> startNextQuestion(String roomID) async {
    try {
      final doc = await _firestore.rooms.doc(roomID).get();

      if (doc.exists) {
        await doc.reference.update({
          'currentQuestionIndex': FieldValue.increment(1),
        });

        return Right(
          doc.data()!.copyWith(
                currentQuestionIndex: doc.data()!.currentQuestionIndex + 1,
              ),
        );
      } else {
        return Left(DatabaseFailure('Room Not Found'));
      }
    } on FirebaseException catch (e) {
      return Left(DatabaseFailure(e.message ?? 'Unknown Failure'));
    }
  }

  @override
  Future<Either<Failure, Room>> finishQuiz(String roomID) async {
    try {
      final doc = await _firestore.rooms.doc(roomID).get();

      if (doc.exists) {
        await doc.reference.update({
          'status': 'finished',
          'finishedAt': FieldValue.serverTimestamp(),
        });

        return Right(
          doc.data()!.copyWith(
                status: RoomStatus.finished,
                endedAt: Timestamp.now(),
              ),
        );
      } else {
        return Left(DatabaseFailure('Room Not Found'));
      }
    } on FirebaseException catch (e) {
      return Left(DatabaseFailure(e.message ?? 'Unknown Failure'));
    }
  }

  @override
  Future<Either<Failure, Room>> endGame(String roomID) async {
    try {
      final doc = await _firestore.rooms.doc(roomID).get();

      if (doc.exists) {
        await doc.reference.update({
          'status': 'ended',
          'endedAt': FieldValue.serverTimestamp(),
        });

        return Right(
          doc.data()!.copyWith(
                status: RoomStatus.ended,
                endedAt: Timestamp.now(),
              ),
        );
      } else {
        return Left(DatabaseFailure('Room Not Found'));
      }
    } on FirebaseException catch (e) {
      return Left(DatabaseFailure(e.message ?? 'Unknown Failure'));
    }
  }

  @override
  Future<Either<Failure, Room>> submitScore(
      String roomID, String userUID, int score) async {
    try {
      final doc = await _firestore.rooms.doc(roomID).get();

      if (doc.exists) {
        await doc.reference.update({
          'playerScores.$userUID': score,
        });

        return Right(
          doc.data()!.copyWith(
                playerScores: Map.from(doc.data()!.playerScores)
                  ..[userUID] = score,
              ),
        );
      } else {
        return Left(DatabaseFailure('Room Not Found'));
      }
    } on FirebaseException catch (e) {
      return Left(DatabaseFailure(e.message ?? 'Unknown Failure'));
    }
  }
}
