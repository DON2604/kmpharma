import 'package:flutter/material.dart';

Widget quickAccessItem({
  required Color bgColor,
  required Color iconBg,
  required IconData icon,
  required String title,
  required String sub,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, size: 24, color: Colors.black87),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(sub, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
      ],
    ),
  );
}
