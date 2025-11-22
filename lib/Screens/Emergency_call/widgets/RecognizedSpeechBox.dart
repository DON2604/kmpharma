import 'package:flutter/material.dart';

class RecognizedSpeechBox extends StatelessWidget {
  final String text;
  final bool isListening;

  const RecognizedSpeechBox({
    super.key,
    required this.text,
    required this.isListening,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black26),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: isListening ? Colors.black : Colors.black54,
        ),
      ),
    );
  }
}
