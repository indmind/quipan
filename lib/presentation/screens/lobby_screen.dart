import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quizpancasila/domain/entities/room.dart';
import 'package:quizpancasila/presentation/controllers/auth_controller.dart';
import 'package:quizpancasila/presentation/controllers/lobby_controller.dart';
import 'package:quizpancasila/presentation/screens/countdown_screen.dart';
import 'package:quizpancasila/presentation/screens/home_screen.dart';
import 'package:quizpancasila/presentation/screens/leaderbord_screen.dart';
import 'package:quizpancasila/presentation/screens/quiz_screen.dart';
import 'package:quizpancasila/presentation/widgets/participant_item.dart';

class LobbyScreen extends HookWidget {
  const LobbyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = useProvider(authControllerProvider);
    final controller = useProvider(lobbyControllerProvider);

    final room = controller.joinedRoom;
    final participants = controller.joinedRoomPlayers;

    final roomNameController = useTextEditingController(
      text: room?.name ?? '',
    );

    useEffect(() {
      Future.microtask(() => checkRoomStatus(controller));
    }, []);

    confirmLeaveRoom() {
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
          confirmLeaveRoom();

          return false;
        },
        child: ProviderListener<LobbyController>(
          provider: lobbyControllerProvider,
          onChange: (context, value) {
            checkRoomStatus(value);
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
                        if (user?.uid == room?.hostUID)
                          Expanded(
                            child: TextField(
                              controller: roomNameController,
                              decoration: const InputDecoration(
                                hintText: 'Room name',
                              ),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) {
                                if (roomNameController.text.isNotEmpty) {
                                  controller
                                      .updateRoomName(roomNameController.text);
                                }
                              },
                            ),
                          )
                        else
                          Text(room?.name ?? '-'),
                        ElevatedButton(
                          onPressed: () {
                            if (controller.isHost) {
                              confirmLeaveRoom();
                            } else {
                              // bypass snackbar
                              controller.leaveRoom();
                            }
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
                                  bgColor: participant.uid == room?.hostUID
                                      ? Colors.green
                                      : participant.uid == user?.uid
                                          ? Colors.blue
                                          : Colors.grey,
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
                            controller.startCountdown();
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

  void checkRoomStatus(LobbyController value) {
    if (value.joinedRoom == null) {
      Get.off(() => const HomeScreen());
    } else if (value.joinedRoom!.status == RoomStatus.countingDown) {
      Get.off(() => const CountdownScreen());
    } else if (value.joinedRoom!.status == RoomStatus.inProgress) {
      Get.off(() => const QuizScreen());
    } else if (value.joinedRoom!.status == RoomStatus.finished) {
      Get.off(() => const LeaderbordScreen());
    }
  }
}
