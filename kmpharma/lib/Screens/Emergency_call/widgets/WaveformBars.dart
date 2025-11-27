import 'package:flutter/material.dart';

class WaveformBars extends StatelessWidget {
  final List<double> values;
  final bool isListening;

  const WaveformBars({
    super.key,
    required this.values,
    required this.isListening,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: values.map((v) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 4,
            height: isListening ? v : 5,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }).toList(),
      ),
    );
  }
}
