import 'package:equatable/equatable.dart';

class QuestionOption extends Equatable {
  final String id;
  final String value;
  final bool isCorrect;

  const QuestionOption({
    required this.id,
    required this.value,
    required this.isCorrect,
  });

  @override
  List<Object?> get props => [
        id,
        value,
        isCorrect,
      ];

  factory QuestionOption.fake() => const QuestionOption(
        id: '1',
        value: 'fake',
        isCorrect: false,
      );
}
