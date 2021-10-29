import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quizpancasila/domain/entities/question.dart';
import 'package:quizpancasila/domain/entities/question_option.dart';
import 'package:quizpancasila/domain/entities/room.dart';
import 'package:quizpancasila/presentation/constants/colors.dart';
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
      appBar: AppBar(
        title: Text("Pertanyaan ${(room?.currentQuestionIndex ?? 0) + 1}"),
        automaticallyImplyLeading: false,
      ),
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 22.0),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(10),
                            // soft shadow
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Text(
                            question?.question ?? 'Loading...',
                            style: Get.theme.textTheme.bodyText1!.copyWith(
                              fontSize: 18,
                              color: kBackgroundColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: Divider(
                            thickness: 1,
                            height: 26,
                          ),
                        ),
                        ListView.builder(
                          itemCount: question?.options.length ?? 0,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final option = question!.options[index];

                            return _buildOption(
                                controller, question, option, showedAt);
                          },
                        ),
                      ],
                    ),
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

  Widget _buildOption(
    LobbyController controller,
    Question question,
    QuestionOption option,
    // so that we can calculate the score
    ValueNotifier<DateTime?> showedAt,
  ) {
    final isAnswered = controller.isCurrentQuestionAnswered &&
        controller.answers[question.id] == option.id;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12.0,
      ),
      child: Material(
        color: isAnswered
            ? option.isCorrect
                ? Colors.green[200]
                : Colors.red[200]
            : controller.isCurrentQuestionAnswered
                ? Colors.grey[200]
                : Colors.yellow[200],
        borderRadius: BorderRadius.circular(999),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () {
            if (controller.isCurrentQuestionAnswered) {
              return;
            }

            final timeToAnswerMs =
                DateTime.now().difference(showedAt.value!).inMilliseconds;

            controller.answer(
              questionId: question.id,
              optionId: option.id,
              questionDurationMs: question.duration * 1000,
              answerDuration: timeToAnswerMs,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Spacer(),
                Expanded(
                  flex: 12,
                  child: Text(
                    option.value,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (isAnswered)
                  if (option.isCorrect)
                    const Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.check,
                          color: Colors.green,
                        ),
                      ),
                    )
                  else
                    const Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                      ),
                    )
                else
                  const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
