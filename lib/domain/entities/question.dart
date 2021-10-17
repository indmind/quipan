import 'package:equatable/equatable.dart';

import 'package:quizpancasila/domain/entities/question_option.dart';

class Question extends Equatable {
  final String id;
  final String question;
  final List<QuestionOption> options;
  final List<String> tags;

  const Question({
    required this.id,
    required this.question,
    required this.options,
    required this.tags,
  });

  Question copyWith({
    String? id,
    String? question,
    List<QuestionOption>? options,
    List<String>? tags,
  }) {
    return Question(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        id,
        question,
        options,
        tags,
      ];

  factory Question.fake() => const Question(
        id: '1',
        question: 'Apakah kamu suka makan nasi goreng?',
        options: [
          QuestionOption(
            id: '1',
            value: 'Ya',
            isCorrect: true,
          ),
          QuestionOption(
            id: '2',
            value: 'Tidak',
            isCorrect: false,
          ),
        ],
        tags: ['makanan'],
      );
}
