import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quizpancasila/domain/entities/room.dart';
import 'package:quizpancasila/presentation/controllers/auth_controller.dart';
import 'package:quizpancasila/presentation/screens/lobby_screen.dart';
import 'package:quizpancasila/presentation/widgets/quiz_room_item.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quizRooms = Room.fakeData;
    final user = useProvider(authControllerProvider);
    final displayNameController = useTextEditingController(text: user?.name);

    useEffect(() {
      displayNameController.text = user?.name ?? '';
    }, [user]);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TextField(
              controller: displayNameController,
              decoration: const InputDecoration(
                hintText: 'Username',
              ),
              onChanged: (value) {
                final controller =
                    context.read(authControllerProvider.notifier);

                controller.updateDisplayName(value);
              },
            ),
            ElevatedButton(
              onPressed: () {
                final controller =
                    context.read(authControllerProvider.notifier);
                controller.signOut();
              },
              child: const Text('Sign Out'),
            ),
            ListView.builder(
              itemCount: quizRooms.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, index) => QuizRoomItem(
                quizRoom: quizRooms[index],
                onTap: () {
                  Get.to(() => const LobbyScreen());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
