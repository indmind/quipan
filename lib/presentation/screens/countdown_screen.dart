import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quizpancasila/domain/entities/room.dart';
import 'package:quizpancasila/presentation/controllers/lobby_controller.dart';
import 'package:quizpancasila/presentation/hooks/countdown_hook.dart';
import 'package:quizpancasila/presentation/screens/home_screen.dart';
import 'package:quizpancasila/presentation/screens/quiz_screen.dart';

class CountdownScreen extends HookWidget {
  const CountdownScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final countdown = useCountdown(3, disposeOnEnd: true);

    useEffect(() {
      if (countdown.tick == 0) {
        context.read(lobbyControllerProvider).startQuiz();
      }
    }, [countdown.tick]);

    return ProviderListener<LobbyController>(
      provider: lobbyControllerProvider,
      onChange: (context, value) {
        if (value.current == null) {
          Get.off(() => const HomeScreen());
        } else if (value.current!.status == RoomStatus.inProgress) {
          Get.off(() => const QuizScreen());
        }
      },
      child: Scaffold(
        body: Center(
          child: Text(
            '${countdown.tick}',
            style: Theme.of(context).textTheme.headline4,
          ),
        ),
      ),
    );
  }
}
