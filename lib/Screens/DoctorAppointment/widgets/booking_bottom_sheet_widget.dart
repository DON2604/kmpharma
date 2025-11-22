import 'package:flutter/material.dart';

class BookingBottomSheetWidget extends StatelessWidget {
  final List<String> timeSlots;
  final String? selectedTimeSlot;
  final Function(String?) onTimeSlotChanged;
  final VoidCallback onBookPressed;

  const BookingBottomSheetWidget({
    super.key,
    required this.timeSlots,
    required this.selectedTimeSlot,
    required this.onTimeSlotChanged,
    required this.onBookPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: selectedTimeSlot,
            hint: const Text("Select a time slot"),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            items: timeSlots.map((slot) {
              return DropdownMenuItem(
                value: slot,
                child: Text(slot),
              );
            }).toList(),
            onChanged: onTimeSlotChanged,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onBookPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Book Appointment",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
