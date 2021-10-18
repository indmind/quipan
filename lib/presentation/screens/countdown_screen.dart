import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quizpancasila/domain/entities/room.dart';
import 'package:quizpancasila/presentation/controllers/lobby_controller.dart';
import 'package:quizpancasila/presentation/screens/home_screen.dart';
import 'package:quizpancasila/presentation/screens/quiz_screen.dart';

class CountdownScreen extends HookWidget {
  const CountdownScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final countdown = useState(3);

    useEffect(() {
      Timer? timer;

      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (countdown.value > 0) {
          countdown.value -= 1;
        } else {
          timer?.cancel();
          context.read(lobbyControllerProvider).startQuiz();
        }
      });

      return timer.cancel;
    }, []);

    return ProviderListener<LobbyController>(
      provider: lobbyControllerProvider,
      onChange: (context, value) {
        if (value.joinedRoom == null) {
          Get.off(() => const HomeScreen());
        } else if (value.joinedRoom!.status == RoomStatus.inProgress) {
          Get.off(() => const QuizScreen());
        }
      },
      child: Scaffold(
        body: Center(
          child: Text(
            '${countdown.value}',
            style: Theme.of(context).textTheme.headline4,
          ),
        ),
      ),
    );
  }
}
