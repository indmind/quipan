import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizpancasila/domain/entities/question.dart';
import 'package:quizpancasila/domain/entities/room.dart';
import 'package:quizpancasila/domain/entities/user.dart';

extension References on FirebaseFirestore {
  CollectionReference<User> get users =>
      collection('users').withConverter<User>(
        fromFirestore: (snapshot, options) =>
            User.fromJson(snapshot.data()!..['uid'] = snapshot.id),
        toFirestore: (value, options) => value.toJson()..remove('uid'),
      );

  CollectionReference<Question> get questions =>
      collection('questions').withConverter<Question>(
        fromFirestore: (snapshot, options) =>
            Question.fromJson(snapshot.data()!..['id'] = snapshot.id),
        toFirestore: (value, options) => value.toJson()..remove('id'),
      );

  CollectionReference<Room> get rooms =>
      collection('rooms').withConverter<Room>(
        fromFirestore: (snapshot, options) =>
            Room.fromJson(snapshot.data()!..['id'] = snapshot.id),
        toFirestore: (value, options) => value.toJson()..remove('id'),
      );
}
