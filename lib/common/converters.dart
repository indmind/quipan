import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:quizpancasila/domain/entities/question_option.dart';

class TimestampConverter implements JsonConverter<Timestamp, Timestamp> {
  const TimestampConverter();

  @override
  Timestamp fromJson(Timestamp timestamp) => timestamp;

  @override
  Timestamp toJson(Timestamp timestamp) => timestamp;
}

class NullableTimestampConverter
    implements JsonConverter<Timestamp?, Timestamp?> {
  const NullableTimestampConverter();

  @override
  Timestamp? fromJson(Timestamp? timestamp) => timestamp;

  @override
  Timestamp? toJson(Timestamp? timestamp) => timestamp;
}

class QuestionOptionConverter
    implements JsonConverter<QuestionOption, Map<String, dynamic>> {
  const QuestionOptionConverter();

  @override
  QuestionOption fromJson(Map<String, dynamic> json) =>
      QuestionOption.fromJson(json);

  @override
  Map<String, dynamic> toJson(QuestionOption object) => object.toJson();
}
