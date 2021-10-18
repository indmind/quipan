import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quizpancasila/domain/entities/question.dart';
import 'package:quizpancasila/presentation/controllers/lobby_controller.dart';
import 'package:quizpancasila/presentation/screens/home_screen.dart';
import 'package:quizpancasila/presentation/screens/leaderbord_screen.dart';

class QuizScreen extends HookWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = useProvider(lobbyControllerProvider);

    final room = controller.joinedRoom;
    final questions = controller.questions;

    final hasQuestion =
        questions.isNotEmpty && room!.currentQuestionIndex < questions.length;

    useEffect(() {
      Future.microtask(() {
        if (room!.currentQuestionIndex > questions.length) {
          Get.off(() => const LeaderbordScreen());
        }
      });
    }, [controller]);

    final Question? question =
        hasQuestion ? questions[room!.currentQuestionIndex] : null;

    return Scaffold(
      body: ProviderListener<LobbyController>(
        provider: lobbyControllerProvider,
        onChange: (context, lobby) {
          if (lobby.joinedRoom == null) {
            Get.off(() => const HomeScreen());
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(question?.question ?? 'Loading...'),
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
    );
  }
}
