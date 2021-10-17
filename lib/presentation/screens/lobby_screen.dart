import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quizpancasila/presentation/controllers/auth_controller.dart';
import 'package:quizpancasila/presentation/controllers/lobby_controller.dart';
import 'package:quizpancasila/presentation/screens/home_screen.dart';
import 'package:quizpancasila/presentation/screens/quiz_scrreen.dart';
import 'package:quizpancasila/presentation/widgets/participant_item.dart';

class LobbyScreen extends HookWidget {
  const LobbyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = useProvider(authControllerProvider);
    final controller = useProvider(lobbyControllerProvider);

    final room = controller.joinedRoom;
    final participants = controller.joinedRoomPlayers;

    leaveRoom() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.isHost
                ? 'You are a host, do you want to close this room?'
                : 'Do you want to leave the room?',
          ),
          action: SnackBarAction(
            label: controller.isHost ? 'Close' : 'Leave',
            onPressed: () {
              controller.leaveRoom();
            },
          ),
        ),
      );
    }

    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          leaveRoom();

          return false;
        },
        child: ProviderListener<LobbyController>(
          provider: lobbyControllerProvider,
          onChange: (context, value) {
            if (value.joinedRoom == null) {
              Get.off(() => const HomeScreen());
            }
          },
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(room?.name ?? '-'),
                        ElevatedButton(
                          onPressed: () {
                            leaveRoom();
                          },
                          style: ElevatedButton.styleFrom(
                            primary: controller.isHost ? Colors.red : null,
                          ),
                          child: Text(controller.isHost ? 'Close' : 'Leave'),
                        ),
                      ],
                    ),
                    if (controller.message != null) Text(controller.message!),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          children: participants
                              .map(
                                (participant) => ParticipantItem(
                                  participant: participant,
                                  isHost: participant.uid == room?.hostUID,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    if (user?.uid == room?.hostUID)
                      SizedBox(
                        width: double.infinity,
                        height: Get.height * 0.1,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(() => const QuizScreen());
                          },
                          child: const Text('Start'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
