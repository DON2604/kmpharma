import 'package:flutter/material.dart';

class MicFab extends StatelessWidget {
  final VoidCallback onPressed;

  const MicFab({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color(0xff00E0FF),
      onPressed: onPressed,
      child: const Icon(Icons.mic, color: Colors.black, size: 30),
    );
  }
}
