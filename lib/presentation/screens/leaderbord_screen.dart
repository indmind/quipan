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

    final isHost = user?.uid == lobby.current?.hostUID;

    return Scaffold(
      body: ProviderListener<LobbyController>(
        provider: lobbyControllerProvider,
        onChange: (context, lobby) {
          if (lobby.current == null) {
            Get.off(() => const HomeScreen());
          }
        },
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Leaderbord',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isHost)
                  ElevatedButton(
                    onPressed: () {
                      context.read(lobbyControllerProvider.notifier).endGame();
                    },
                    child: const Text('End Game'),
                  ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lobby.leaderboard.length,
                  itemBuilder: (context, index) {
                    final user = lobby.leaderboard[index];

                    final playerHasScore =
                        lobby.current?.playerScores.containsKey(user.uid) ??
                            false;

                    final score = playerHasScore
                        ? lobby.current?.playerScores[user.uid] ?? 0
                        : 0;

                    return ListTile(
                      title: Text(user.name),
                      subtitle: Text(score.toString()),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == 0
                              ? Colors.green
                              : index == 1
                                  ? Colors.yellow
                                  : index == 2
                                      ? Colors.orange
                                      : Colors.grey,
                        ),
                        child: Center(child: Text((index + 1).toString())),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
