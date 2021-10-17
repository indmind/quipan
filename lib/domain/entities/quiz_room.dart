import 'dart:convert';

class QuizRoom {
  final String id;
  final String name;
  final String masterId;

  QuizRoom({
    required this.id,
    required this.name,
    required this.masterId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'masterId': masterId,
    };
  }

  factory QuizRoom.fromMap(Map<String, dynamic> map) {
    return QuizRoom(
      id: map['id'],
      name: map['name'],
      masterId: map['masterId'],
    );
  }

  String toJson() => json.encode(toMap());

  factory QuizRoom.fromJson(String source) =>
      QuizRoom.fromMap(json.decode(source));

  static final List<QuizRoom> fakeData = [
    QuizRoom(
      id: '1',
      name: 'Quiz Room 1',
      masterId: '1',
    ),
    QuizRoom(
      id: '2',
      name: 'Quiz Room 2',
      masterId: '2',
    ),
    QuizRoom(
      id: '3',
      name: 'Quiz Room 3',
      masterId: '3',
    ),
  ];
}
