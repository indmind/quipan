// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:quizpancasila/common/converters.dart';

part 'room.g.dart';

enum RoomStatus {
  @JsonValue('open')
  open,
  @JsonValue('counting_down')
  countingDown,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('finished')
  finished,
  @JsonValue('ended')
  ended,
}

@JsonSerializable()
@TimestampConverter()
@NullableTimestampConverter()
class Room extends Equatable {
  final String id;
  final String name;
  final String hostUID;
  final List<String> playerUIDs;
  final List<String> questionIds;
  final Map<String, int> playerScores;
  final int currentQuestionIndex;
  final RoomStatus status;

  final Timestamp createdAt;
  final Timestamp? startedAt;
  final Timestamp? finishedAt;
  final Timestamp? endedAt;

  const Room({
    required this.id,
    required this.name,
    required this.hostUID,
    required this.playerUIDs,
    required this.questionIds,
    required this.playerScores,
    required this.currentQuestionIndex,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.finishedAt,
    this.endedAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  Map<String, dynamic> toJson() => _$RoomToJson(this);

  Room copyWith({
    String? id,
    String? name,
    String? hostUID,
    List<String>? playerUIDs,
    List<String>? questionIds,
    Map<String, int>? playerScores,
    int? currentQuestionIndex,
    RoomStatus? status,
    Timestamp? createdAt,
    Timestamp? startedAt,
    Timestamp? finishedAt,
    Timestamp? endedAt,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      hostUID: hostUID ?? this.hostUID,
      playerUIDs: playerUIDs ?? this.playerUIDs,
      questionIds: questionIds ?? this.questionIds,
      playerScores: playerScores ?? this.playerScores,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        hostUID,
        playerUIDs,
        questionIds,
        playerScores,
        currentQuestionIndex,
        createdAt,
        startedAt,
        finishedAt,
        endedAt,
      ];

  static List<Room> fakeData = [
    Room(
      id: '1',
      name: 'Room 1',
      hostUID: '1',
      playerUIDs: const ['1', '2', '3'],
      questionIds: const ['1', '2', '3'],
      playerScores: {'1': 0, '2': 0, '3': 0},
      currentQuestionIndex: 0,
      status: RoomStatus.open,
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
      playerScores: {'1': 0, '2': 0, '3': 0},
      currentQuestionIndex: 0,
      status: RoomStatus.open,
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
      playerScores: {'1': 0, '2': 0, '3': 0},
      currentQuestionIndex: 0,
      status: RoomStatus.ended,
      createdAt: Timestamp.now(),
      startedAt: Timestamp.now(),
      endedAt: Timestamp.now(),
    ),
  ];
}
