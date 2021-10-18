import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quizpancasila/presentation/controllers/auth_controller.dart';
import 'package:quizpancasila/presentation/controllers/lobby_controller.dart';
import 'package:quizpancasila/presentation/controllers/room_controller.dart';
import 'package:quizpancasila/presentation/screens/lobby_screen.dart';
import 'package:quizpancasila/presentation/widgets/quiz_room_item.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = useProvider(authControllerProvider);
    final displayNameController =
        useTextEditingController(text: authController?.name);

    final roomController = useProvider(roomControllerProvider);
    final lobbyController = useProvider(lobbyControllerProvider);

    useEffect(() {
      displayNameController.text = authController?.name ?? '';
    }, [authController]);

    return ProviderListener<LobbyController>(
      provider: lobbyControllerProvider,
      onChange: (context, value) {
        if (value.joinedRoom != null) {
          Get.off(() => const LobbyScreen());
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: displayNameController,
                        decoration: const InputDecoration(
                          hintText: 'Username',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        final controller =
                            context.read(authControllerProvider.notifier);

                        controller
                            .updateDisplayName(displayNameController.text);
                      },
                      icon: const Icon(Icons.save),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final controller =
                      context.read(authControllerProvider.notifier);
                  controller.signOut();
                },
                child: const Text('Sign Out'),
              ),
              ElevatedButton(
                onPressed: () {
                  final controller =
                      context.read(roomControllerProvider.notifier);
                  controller.createRoom();
                },
                child: const Text('Create Room'),
              ),
              if (lobbyController.message != null)
                Text(lobbyController.message!),
              if (roomController.message != null) Text(roomController.message!),
              if (roomController.openRooms.isEmpty)
                Text('No active rooms'.tr)
              else
                ListView.builder(
                  itemCount: roomController.openRooms.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemBuilder: (context, index) => QuizRoomItem(
                    quizRoom: roomController.openRooms[index],
                    onTap: () {
                      final controller =
                          context.read(lobbyControllerProvider.notifier);

                      controller.joinRoom(roomController.openRooms[index].id);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
