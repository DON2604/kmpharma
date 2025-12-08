import 'package:flutter/material.dart';

class AddReminderButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddReminderButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add, size: 26, color: Colors.black),
          label: const Text(
            "Add Reminder",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff00E0FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
