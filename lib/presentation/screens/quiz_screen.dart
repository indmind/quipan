import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quizpancasila/domain/entities/question.dart';
import 'package:quizpancasila/domain/entities/room.dart';
import 'package:quizpancasila/presentation/controllers/lobby_controller.dart';
import 'package:quizpancasila/presentation/hooks/countdown_hook.dart';
import 'package:quizpancasila/presentation/screens/home_screen.dart';
import 'package:quizpancasila/presentation/screens/leaderbord_screen.dart';
import 'package:rainbow_color/rainbow_color.dart';

class QuizScreen extends HookWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = useProvider(lobbyControllerProvider);

    final room = controller.current;
    final questions = controller.questions;

    final hasQuestion = room != null &&
        questions.isNotEmpty &&
        room.currentQuestionIndex < questions.length;

    final Question? question =
        hasQuestion ? questions[room!.currentQuestionIndex] : null;

    final timer = useCountdown(question?.duration ?? 0);
    final showedAt = useState<DateTime?>(null);

    final progressController = useAnimationController();

    final progressColorAnimation = progressController.drive(
      RainbowColorTween([
        Colors.green,
        Colors.green,
        Colors.yellow,
        Colors.red,
      ]),
    );

    final progressValueAnimation = progressController.drive(
      Tween<double>(
        begin: 1,
        end: 0,
      ),
    );

    // reset the timer when the question changes
    useEffect(() {
      if (question != null) {
        progressController.duration = question.duration.seconds;
        progressController.forward(from: 0);

        timer.reset(question.duration);
        showedAt.value = DateTime.now();
      }
    }, [question]);

    // start next question if the timer is finished
    useEffect(() {
      if (room == null) {
        Get.off(() => const HomeScreen());
        return;
      }

      // check if the timer is finished and question has been loaded
      if (timer.isFinished && questions.isNotEmpty) {
        // if this is not the last question, go to nextQuestion
        if (room.currentQuestionIndex < questions.length - 1) {
          controller.startNextQuestion();
        } else {
          controller.finishQuiz();
        }
      }
      // listen to timer and questions list
    }, [timer.isFinished, questions]);

    return Scaffold(
      body: ProviderListener<LobbyController>(
        provider: lobbyControllerProvider,
        onChange: (context, lobby) {
          if (lobby.current == null) {
            Get.off(() => const HomeScreen());
          } else if (lobby.current!.status == RoomStatus.finished) {
            Get.off(() => const LeaderbordScreen());
          }
        },
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        question?.question ?? 'Loading...',
                        style: Get.theme.textTheme.headline3,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        itemCount: question?.options.length ?? 0,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final option = question!.options[index];

                          return ListTile(
                            title: Text(option.value),
                            selected:
                                controller.answers[question.id] == option.id,
                            tileColor: controller.isCurrentQuestionAnswered
                                ? (option.isCorrect ? Colors.green : Colors.red)
                                : null,
                            onTap: () {
                              if (controller.isCurrentQuestionAnswered) {
                                return;
                              }

                              final timeToAnswerMs = DateTime.now()
                                  .difference(showedAt.value!)
                                  .inMilliseconds;

                              controller.answer(
                                questionId: question.id,
                                optionId: option.id,
                                questionDurationMs: question.duration * 1000,
                                answerDuration: timeToAnswerMs,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: progressValueAnimation,
                builder: (context, _) {
                  return LinearProgressIndicator(
                    value: progressValueAnimation.value,
                    valueColor: progressColorAnimation,
                    minHeight: 8.0,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
