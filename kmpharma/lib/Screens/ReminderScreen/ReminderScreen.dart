import 'package:flutter/material.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Map<String, dynamic>> reminders = [
    {"title": "Take morning medicine", "time": "8:00 AM"},
    {"title": "Drink 2L of water", "time": "11:00 AM"},
    {"title": "Evening vitamin dose", "time": "7:00 PM"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D1B2A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Reminders",
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
      ),

      floatingActionButton: _micFab(),

      body: Column(
        children: [
          const SizedBox(height: 10),
          _addReminderButton(),
          const SizedBox(height: 15),
          Expanded(child: _reminderList()),
        ],
      ),
    );
  }

  // --------------------------------------------------------
  // MIC Floating Button
  // --------------------------------------------------------
  Widget _micFab() {
    return FloatingActionButton(
      backgroundColor: const Color(0xff00E0FF),
      onPressed: () {
        // open voice input
      },
      child: const Icon(Icons.mic, color: Colors.black, size: 30),
    );
  }

  // --------------------------------------------------------
  // Add Reminder Button
  // --------------------------------------------------------
  Widget _addReminderButton() {
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
          onPressed: () {
            _showAddDialog();
          },
        ),
      ),
    );
  }

  // --------------------------------------------------------
  // Reminders List
  // --------------------------------------------------------
  Widget _reminderList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      itemCount: reminders.length,
      itemBuilder: (ctx, i) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xff1B263B),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Time
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminders[i]["title"],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    reminders[i]["time"],
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Delete icon
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () {
                  setState(() {
                    reminders.removeAt(i);
                  });
                },
              )
            ],
          ),
        );
      },
    );
  }

  // --------------------------------------------------------
  // Add Reminder Dialog
  // --------------------------------------------------------
  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final timeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xff1B263B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "New Reminder",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _inputField(titleCtrl, "Title"),
              const SizedBox(height: 12),
              _inputField(timeCtrl, "Time"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff00E0FF),
              ),
              onPressed: () {
                if (titleCtrl.text.trim().isNotEmpty &&
                    timeCtrl.text.trim().isNotEmpty) {
                  setState(() {
                    reminders.add({
                      "title": titleCtrl.text.trim(),
                      "time": timeCtrl.text.trim(),
                    });
                  });
                }
                Navigator.pop(ctx);
              },
              child: const Text("Add", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  // TextField
  Widget _inputField(TextEditingController c, String label) {
    return TextField(
      controller: c,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white38),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
