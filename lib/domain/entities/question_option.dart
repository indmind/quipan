import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'question_option.g.dart';

@JsonSerializable()
class QuestionOption extends Equatable {
  final int id;
  final String value;
  @JsonKey(name: 'is_correct')
  final bool isCorrect;

  const QuestionOption({
    required this.id,
    required this.value,
    required this.isCorrect,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) =>
      _$QuestionOptionFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionOptionToJson(this);

  @override
  List<Object?> get props => [
        id,
        value,
        isCorrect,
      ];

  factory QuestionOption.fake() => const QuestionOption(
        id: 1,
        value: 'fake',
        isCorrect: false,
      );
}
