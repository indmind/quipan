import 'package:flutter/material.dart';
import 'package:quizpancasila/domain/entities/room.dart';
import 'package:quizpancasila/presentation/constants/colors.dart';

class QuizRoomItem extends StatelessWidget {
  final Room quizRoom;
  final void Function()? onTap;

  const QuizRoomItem({
    Key? key,
    required this.quizRoom,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kPrimaryLightColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 161,
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              const Expanded(
                child: Icon(
                  Icons.door_back_door_outlined,
                  color: kPrimaryColor,
                  size: 100,
                ),
              ),
              Text(
                quizRoom.name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
