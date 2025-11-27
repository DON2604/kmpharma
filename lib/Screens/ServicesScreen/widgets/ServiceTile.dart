import 'package:flutter/material.dart';

Widget serviceTile(IconData icon, String title) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white10,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white24),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xffeaf2ff),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 26, color: Colors.blue),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
