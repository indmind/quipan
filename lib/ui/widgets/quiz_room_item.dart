import 'package:flutter/material.dart';
import 'package:quizpancasila/data/models/quiz_room.dart';

class QuizRoomItem extends StatelessWidget {
  final QuizRoom quizRoom;
  final void Function()? onTap;

  const QuizRoomItem({
    Key? key,
    required this.quizRoom,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(quizRoom.name),
      ),
    );
  }
}
