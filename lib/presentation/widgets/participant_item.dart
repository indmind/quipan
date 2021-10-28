import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizpancasila/domain/entities/user.dart';

class ParticipantItem extends StatelessWidget {
  final User participant;
  final Color? bgColor;
  final String? info;

  const ParticipantItem({
    Key? key,
    required this.participant,
    this.bgColor,
    this.info,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white,
        // add soft box shadow
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!.withOpacity(0.5),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
            child: Text(
              participant.name,
              textAlign: TextAlign.center,
            ),
          ),
          if (info != null)
            Positioned(
              right: 2,
              bottom: 2,
              child: Text(
                info!,
                style: Get.textTheme.caption,
              ),
            ),
        ],
      ),
    );
  }
}
