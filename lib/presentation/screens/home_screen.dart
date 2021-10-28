import 'package:entry/entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quizpancasila/presentation/controllers/auth_controller.dart';
import 'package:quizpancasila/presentation/controllers/lobby_controller.dart';
import 'package:quizpancasila/presentation/controllers/room_controller.dart';
import 'package:quizpancasila/presentation/screens/lobby_screen.dart';
import 'package:quizpancasila/presentation/widgets/quiz_room_item.dart';
import 'package:responsive_grid/responsive_grid.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = useProvider(authControllerProvider);
    final displayNameController =
        useTextEditingController(text: authController?.name);
    final displayName = useState<String?>(authController?.name);

    final roomController = useProvider(roomControllerProvider);
    final lobbyController = useProvider(lobbyControllerProvider);

    useEffect(() {
      displayNameController.text = authController?.name ?? '';
      displayName.value = authController?.name ?? '';
    }, [authController]);

    return ProviderListener<LobbyController>(
      provider: lobbyControllerProvider,
      onChange: (context, value) {
        if (value.current != null) {
          Get.off(() => const LobbyScreen());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: displayNameController,
                          onChanged: (value) {
                            displayName.value = value;
                          },
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                          decoration: InputDecoration(
                            hintText: 'Username',
                            fillColor: Colors.grey[200],
                            filled: true,
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5.5),
                        decoration: BoxDecoration(
                          color: authController?.name != displayName.value
                              ? Colors.green
                              : Colors.grey[400],
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: IconButton(
                          onPressed: authController?.name != displayName.value
                              ? () async {
                                  final controller = context
                                      .read(authControllerProvider.notifier);

                                  await controller.updateDisplayName(
                                      displayNameController.text);

                                  Get.showSnackbar(GetBar(
                                    message: 'Nama berhasil diganti!',
                                    backgroundColor: Colors.green,
                                    duration: 2.seconds,
                                    animationDuration: 500.milliseconds,
                                    snackStyle: SnackStyle.FLOATING,
                                    margin: const EdgeInsets.all(8),
                                    borderRadius: 10.0,
                                  ));
                                }
                              : null,
                          icon: const Icon(Icons.check),
                        ),
                      ),
                    ],
                  ),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     final controller =
                  //         context.read(authControllerProvider.notifier);
                  //     controller.signOut();
                  //   },
                  //   child: const Text('Sign Out'),
                  // ),
                  const SizedBox(height: 53),
                  Text(
                    'Silahkan\nMemasuki Room',
                    style: Get.textTheme.headline4,
                  ),
                  const SizedBox(height: 17),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        textStyle: Get.textTheme.headline6!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                      onPressed: () {
                        final controller =
                            context.read(roomControllerProvider.notifier);
                        controller.createRoom();
                      },
                      child: const Text('Buat Room'),
                    ),
                  ),
                ],
              ),
            ),
            if (lobbyController.message != null) Text(lobbyController.message!),
            if (roomController.message != null) Text(roomController.message!),
            if (roomController.openRooms.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0),
                child: Text(
                  'Belum ada room permainan untuk saat ini, buat room dengan tombol di atas dan ajak temanmu bermain! '
                      .tr,
                  textAlign: TextAlign.center,
                ),
              )
            else
              Expanded(
                child: ResponsiveGridList(
                  desiredItemWidth: 134.0,
                  minSpacing: 22.0,
                  children: roomController.openRooms
                      .map(
                        (room) => Entry.all(
                          child: QuizRoomItem(
                            quizRoom: room,
                            onTap: () {
                              final controller = context
                                  .read(lobbyControllerProvider.notifier);

                              controller.joinRoom(room.id);
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            // ListView.builder(
            //   itemCount: roomController.openRooms.length,
            //   shrinkWrap: true,
            //   physics: const NeverScrollableScrollPhysics(),
            //   padding: const EdgeInsets.symmetric(horizontal: 20),
            //   itemBuilder: (context, index) => QuizRoomItem(
            //     quizRoom: roomController.openRooms[index],
            //     onTap: () {
            //       final controller =
            //           context.read(lobbyControllerProvider.notifier);

            //       controller.joinRoom(roomController.openRooms[index].id);
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
