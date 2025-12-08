import 'package:flutter/material.dart';

class LoadingDots extends StatelessWidget {
  final AnimationController dotController;

  const LoadingDots({
    super.key,
    required this.dotController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: dotController,
      builder: (context, child) {
        int dots = ((dotController.value * 3).floor() % 4);
        String displayText = "Fetching location${"." * dots}";
        return Text(
          displayText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        );
      },
    );
  }
}
