import 'package:flutter/material.dart';

class MicButton extends StatelessWidget {
  final bool isListening;
  final AnimationController pulseAnimation;
  final VoidCallback onTap;

  const MicButton({
    super.key,
    required this.isListening,
    required this.pulseAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: pulseAnimation,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isListening ? Colors.red : const Color.fromARGB(255, 96, 80, 80),
          ),
          child: Icon(
            isListening ? Icons.mic : Icons.mic_none,
            color: Colors.white,
            size: 42,
          ),
        ),
      ),
    );
  }
}
