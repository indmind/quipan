import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quizpancasila/presentation/controllers/auth_controller.dart';
import 'package:quizpancasila/presentation/controllers/lobby_controller.dart';

import 'home_screen.dart';

class LeaderbordScreen extends HookWidget {
  const LeaderbordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = useProvider(authControllerProvider);
    final lobby = useProvider(lobbyControllerProvider);

    final isHost = user?.uid == lobby.joinedRoom?.hostUID;

    return Scaffold(
      body: ProviderListener<LobbyController>(
        provider: lobbyControllerProvider,
        onChange: (context, lobby) {
          if (lobby.joinedRoom == null) {
            Get.off(() => const HomeScreen());
          }
        },
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                const Text('Leaderbord'),
                if (isHost)
                  ElevatedButton(
                    onPressed: () {
                      context.read(lobbyControllerProvider.notifier).endGame();
                    },
                    child: const Text('End Game'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
