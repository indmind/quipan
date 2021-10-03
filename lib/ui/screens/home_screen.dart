import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizpancasila/data/models/quiz_room.dart';
import 'package:quizpancasila/ui/screens/lobby_screen.dart';
import 'package:quizpancasila/ui/widgets/quiz_room_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quizRooms = QuizRoom.fakeData;

    return Scaffold(
      body: ListView.builder(
        itemCount: quizRooms.length,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) => QuizRoomItem(
          quizRoom: quizRooms[index],
          onTap: () {
            Get.to(() => const LobbyScreen());
          },
        ),
      ),
    );
  }
}
