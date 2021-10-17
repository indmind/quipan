import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizpancasila/domain/entities/user.dart';
import 'package:quizpancasila/presentation/screens/quiz_scrreen.dart';
import 'package:quizpancasila/presentation/widgets/participant_item.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final participants = User.fakeData;

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  children: participants
                      .map(
                        (participant) =>
                            ParticipantItem(participant: participant),
                      )
                      .toList(),
                ),
              ),
            ),
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
    );
  }
}
