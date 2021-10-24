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

    // reset the timer when the question changes
    useEffect(() {
      if (question != null) {
        timer.reset(question.duration);
      }
    }, [question]);

    // start next question if the timer is finished
    useEffect(() {
      if (timer.isFinished) {
        if (room == null) {
          Get.off(() => const HomeScreen());
          return;
        }

        // if this is the last question, finish the game
        if (room.currentQuestionIndex < questions.length - 1) {
          controller.startNextQuestion();
        } else {
          controller.finishQuiz();
        }
      }
    }, [timer.isFinished]);

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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Time left: ${timer.tick}"),
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
                      // onTap: () => controller.answer(option.id),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
