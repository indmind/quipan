import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:quizpancasila/common/failure.dart';
import 'package:quizpancasila/domain/entities/question.dart';
import 'package:quizpancasila/domain/repositories/question_repository.dart';
import 'package:quizpancasila/common/references.dart';

class QuestionRepositoryImpl extends QuestionRepository {
  final FirebaseFirestore _firestore;

  QuestionRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, Question>> getQuestion(String questionId) async {
    try {
      final doc = await _firestore.questions.doc(questionId).get();
      return Right(doc.data()!);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Question>>> getQuestions() async {
    try {
      final result = await _firestore.questions.get();

      return Right(result.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Question>>> getRandomQuestions(int count) async {
    try {
      // lets just to the naive way
      final questionsResult = await getQuestions();

      if (questionsResult.isLeft()) {
        // resend back the failure
        return questionsResult;
      }

      final questions = questionsResult.getOrElse(() => []);

      // pick random questions by count
      final randomQuestions = List<Question>.generate(
        min(count, questions.length),
        (index) {
          final randomIndex = Random().nextInt(questions.length);

          final question = questions.elementAt(randomIndex);

          // remove the question from the list to avoid duplicates
          questions.removeAt(randomIndex);

          return question;
        },
      );

      return Right(randomQuestions);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
