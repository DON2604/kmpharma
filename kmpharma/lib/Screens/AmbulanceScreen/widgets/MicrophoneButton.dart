import 'package:flutter/material.dart';

class MicrophoneButton extends StatelessWidget {
  final bool isListening;
  final AnimationController micPulseController;
  final VoidCallback onTap;

  const MicrophoneButton({
    super.key,
    required this.isListening,
    required this.micPulseController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: ScaleTransition(
            scale: micPulseController,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: isListening ? Colors.red : const Color(0xFF0A84FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isListening ? Icons.mic : Icons.mic_none,
                  size: 35,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            isListening
                ? "Listening... Tap to stop"
                : "Press the mic and say destination",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
