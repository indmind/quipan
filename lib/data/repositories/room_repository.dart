import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizpancasila/domain/entities/room.dart';
import 'package:quizpancasila/common/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:quizpancasila/domain/repositories/room_repository.dart';

class RoomRepositoryImpl implements RoomRepository {
  final FirebaseFirestore _firestore;

  RoomRepositoryImpl(this._firestore);

  CollectionReference<Room> get _ref =>
      _firestore.collection('rooms').withConverter<Room>(
            fromFirestore: (snapshot, options) =>
                Room.fromJson(snapshot.data()!..['id'] = snapshot.id),
            toFirestore: (value, options) => value.toJson()..remove('id'),
          );
  @override
  Stream<List<Room>> onOpenRoomsChanged() {
    return _ref
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Future<Either<Failure, List<Room>>> getOpenRooms() async {
    try {
      final snapshot = await _ref.where('status', isEqualTo: 'open').get();

      return Right(snapshot.docs.map((doc) => doc.data()).toList());
    } on FirebaseException catch (e) {
      return Left(DatabaseFailure(e.message ?? 'Unkown Failure'));
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

      final doc = await _ref.add(room);

      return Right(room.copyWith(id: doc.id));
    } on FirebaseException catch (e) {
      return Left(DatabaseFailure(e.message ?? 'Unkown Failure'));
    }
  }
}
