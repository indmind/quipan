import 'package:flutter/material.dart';
import 'package:quizpancasila/domain/entities/user.dart';

class ParticipantItem extends StatelessWidget {
  final User participant;
  final bool isHost;

  const ParticipantItem({
    Key? key,
    required this.participant,
    this.isHost = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isHost ? Colors.green : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(participant.name),
    );
  }
}
