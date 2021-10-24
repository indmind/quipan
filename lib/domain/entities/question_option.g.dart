// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_option.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionOption _$QuestionOptionFromJson(Map<String, dynamic> json) =>
    QuestionOption(
      id: json['id'] as int,
      value: json['value'] as String,
      isCorrect: json['is_correct'] as bool,
    );

Map<String, dynamic> _$QuestionOptionToJson(QuestionOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'value': instance.value,
      'is_correct': instance.isCorrect,
    };
