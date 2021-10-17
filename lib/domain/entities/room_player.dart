import 'package:equatable/equatable.dart';

class RoomPlayer extends Equatable {
  final String id;
  final String roomId;
  final String playerUID;
  final int score;
  final List<String> answeredQuestionUids;

  const RoomPlayer({
    required this.id,
    required this.roomId,
    required this.playerUID,
    required this.score,
    required this.answeredQuestionUids,
  });

  @override
  List<Object?> get props => [
        id,
        roomId,
        playerUID,
        score,
        answeredQuestionUids,
      ];
}
