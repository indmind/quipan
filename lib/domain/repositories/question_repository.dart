import 'package:dartz/dartz.dart';
import 'package:quizpancasila/common/failure.dart';
import 'package:quizpancasila/domain/entities/question.dart';

abstract class QuestionRepository {
  Future<Either<Failure, Question>> getQuestion(String questionId);
  Future<Either<Failure, List<Question>>> getQuestions();
  Future<Either<Failure, List<Question>>> getRandomQuestions(int count);
}
