// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Room _$RoomFromJson(Map<String, dynamic> json) => Room(
      id: json['id'] as String,
      name: json['name'] as String,
      hostUID: json['hostUID'] as String,
      playerUIDs: (json['playerUIDs'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      questionIds: (json['questionIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      currentQuestionIndex: json['currentQuestionIndex'] as int,
      status: $enumDecode(_$RoomStatusEnumMap, json['status']),
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Timestamp),
      startedAt: const NullableTimestampConverter()
          .fromJson(json['startedAt'] as Timestamp?),
      finishedAt: const NullableTimestampConverter()
          .fromJson(json['finishedAt'] as Timestamp?),
      endedAt: const NullableTimestampConverter()
          .fromJson(json['endedAt'] as Timestamp?),
    );

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'hostUID': instance.hostUID,
      'playerUIDs': instance.playerUIDs,
      'questionIds': instance.questionIds,
      'currentQuestionIndex': instance.currentQuestionIndex,
      'status': _$RoomStatusEnumMap[instance.status],
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'startedAt':
          const NullableTimestampConverter().toJson(instance.startedAt),
      'finishedAt':
          const NullableTimestampConverter().toJson(instance.finishedAt),
      'endedAt': const NullableTimestampConverter().toJson(instance.endedAt),
    };

const _$RoomStatusEnumMap = {
  RoomStatus.open: 'open',
  RoomStatus.countingDown: 'counting_down',
  RoomStatus.inProgress: 'in_progress',
  RoomStatus.finished: 'finished',
  RoomStatus.ended: 'ended',
};
