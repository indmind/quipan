import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class User {
  final String uid;
  final String name;
  User({
    required this.uid,
    required this.name,
  });

  User copyWith({
    String? uid,
    String? name,
  }) {
    return User(
      uid: uid ?? this.uid,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'],
      name: map['name'],
    );
  }

  static User? fromFirebase(auth.User? user) {
    if (user == null) return null;

    return User(
      uid: user.uid,
      name: user.displayName ?? 'Anonymous',
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  String toString() => 'User(uid: $uid, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User && other.uid == uid && other.name == name;
  }

  @override
  int get hashCode => uid.hashCode ^ name.hashCode;

  // dummy data
  static final List<User> fakeData = [
    User(uid: '1', name: 'John Doe'),
    User(uid: '2', name: 'Jane Doe'),
  ];
}
