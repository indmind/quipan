import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Room extends Equatable {
  final String id;
  final String name;
  final String hostUID;
  final List<String> playerUIDs;
  final List<String> questionIds;
  final Timestamp createdAt;
  final Timestamp startedAt;
  final Timestamp endedAt;

  const Room({
    required this.id,
    required this.name,
    required this.hostUID,
    required this.playerUIDs,
    required this.questionIds,
    required this.createdAt,
    required this.startedAt,
    required this.endedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        hostUID,
        playerUIDs,
        questionIds,
        createdAt,
        startedAt,
        endedAt,
      ];

  static List<Room> fakeData = [
    Room(
      id: '1',
      name: 'Room 1',
      hostUID: '1',
      playerUIDs: const ['1', '2', '3'],
      questionIds: const ['1', '2', '3'],
      createdAt: Timestamp.now(),
      startedAt: Timestamp.now(),
      endedAt: Timestamp.now(),
    ),
    Room(
      id: '2',
      name: 'Room 2',
      hostUID: '2',
      playerUIDs: const ['1', '2', '3'],
      questionIds: const ['1', '2', '3'],
      createdAt: Timestamp.now(),
      startedAt: Timestamp.now(),
      endedAt: Timestamp.now(),
    ),
    Room(
      id: '3',
      name: 'Room 3',
      hostUID: '3',
      playerUIDs: const ['1', '2', '3'],
      questionIds: const ['1', '2', '3'],
      createdAt: Timestamp.now(),
      startedAt: Timestamp.now(),
      endedAt: Timestamp.now(),
    ),
  ];
}
