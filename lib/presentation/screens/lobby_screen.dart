import 'package:entry/entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quizpancasila/domain/entities/room.dart';
import 'package:quizpancasila/presentation/constants/colors.dart';
import 'package:quizpancasila/presentation/controllers/auth_controller.dart';
import 'package:quizpancasila/presentation/controllers/lobby_controller.dart';
import 'package:quizpancasila/presentation/screens/countdown_screen.dart';
import 'package:quizpancasila/presentation/screens/home_screen.dart';
import 'package:quizpancasila/presentation/screens/leaderbord_screen.dart';
import 'package:quizpancasila/presentation/screens/quiz_screen.dart';
import 'package:quizpancasila/presentation/widgets/participant_item.dart';
import 'package:responsive_grid/responsive_grid.dart';

class LobbyScreen extends HookWidget {
  const LobbyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = useProvider(authControllerProvider);
    final controller = useProvider(lobbyControllerProvider);

    final room = controller.current;
    final participants = controller.joinedRoomPlayers;

    final roomNameController = useTextEditingController(
      text: room?.name ?? '',
    );

    useEffect(() {
      Future.microtask(() => checkRoomStatus(controller));
    }, []);

    confirmLeaveRoom() {
      Get.showSnackbar(GetBar(
        message: controller.isHost
            ? 'Kamu adalah host room ini, ingin menutup room?'
            : 'Yakin keluar dari room?',
        backgroundColor: controller.isHost ? Colors.red : Colors.grey,
        duration: 5.seconds,
        animationDuration: 500.milliseconds,
        snackStyle: SnackStyle.FLOATING,
        snackPosition:
            controller.isHost ? SnackPosition.TOP : SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(8),
        borderRadius: 10.0,
        onTap: (_) {
          controller.leaveRoom();
        },
        mainButton: TextButton(
          style: TextButton.styleFrom(
            primary: kBackgroundColor,
          ),
          child: Text(
            controller.isHost ? 'Tutup' : 'Keluar',
          ),
          onPressed: () {
            controller.leaveRoom();
          },
        ),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: controller.isHost
            ? TextField(
                controller: roomNameController,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Room name',
                ),
                style: Get.textTheme.headline6!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (roomNameController.text.isNotEmpty) {
                    controller.updateRoomName(roomNameController.text);
                  }
                },
              )
            : Text(
                room?.name ?? '',
                style: Get.textTheme.headline6!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: controller.isHost ? Colors.red : null,
            ),
            onPressed: () {
              if (controller.isHost) {
                confirmLeaveRoom();
              } else {
                // bypass snackbar
                controller.leaveRoom();
              }
            },
          ),
        ],
      ),
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
              child: Column(
                children: [
                  if (controller.message != null) Text(controller.message!),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ResponsiveGridRow(
                          children: participants
                              .map(
                                (participant) => ResponsiveGridCol(
                                  xs: 6,
                                  md: 3,
                                  xl: 2,
                                  child: Entry.offset(
                                    duration: 0.5.seconds,
                                    curve: Curves.easeInOutExpo,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ParticipantItem(
                                        participant: participant,
                                        bgColor:
                                            participant.uid == room?.hostUID
                                                ? Colors.green
                                                : participant.uid == user?.uid
                                                    ? Colors.blue
                                                    : kPrimaryLightColor,
                                        info: participant.uid == room?.hostUID
                                            ? 'Host'
                                            : participant.uid == user?.uid
                                                ? 'Kamu'
                                                : null,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
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
    );
  }

  void checkRoomStatus(LobbyController value) {
    if (value.current == null) {
      Get.off(() => const HomeScreen());
    } else if (value.current!.status == RoomStatus.countingDown) {
      Get.off(() => const CountdownScreen());
    } else if (value.current!.status == RoomStatus.inProgress) {
      Get.off(() => const QuizScreen());
    } else if (value.current!.status == RoomStatus.finished) {
      Get.off(() => const LeaderbordScreen());
    }
  }
}
