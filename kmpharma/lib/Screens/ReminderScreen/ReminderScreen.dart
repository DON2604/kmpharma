import 'package:flutter/material.dart';
import 'package:kmpharma/services/reminder_service.dart';
import 'package:intl/intl.dart';
import 'widgets/add_reminder_button.dart';
import 'widgets/add_reminder_dialog.dart';
import 'widgets/delete_confirmation_dialog.dart';
import 'widgets/mic_fab.dart';
import 'widgets/reminder_list_item.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Map<String, dynamic>> reminders = [];
  final ReminderService _reminderService = ReminderService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    try {
      final fetchedReminders = await _reminderService.getUserReminders();
      setState(() {
        reminders = fetchedReminders.map((reminder) {
          // Parse the reminder_time to a readable format
          String timeString = '—';
          try {
            final dateTime = DateTime.parse(reminder['reminder_time']);
            timeString = DateFormat('hh:mm a').format(dateTime);
          } catch (e) {
            print('Error parsing time: $e');
          }

          return {
            "id": reminder['id'],
            "title": reminder['reminder_text'] ?? 'Reminder',
            "time": timeString,
            "created_at": reminder['created_at'],
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load reminders: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AddReminderDialog(
        onAdd: (reminderText, reminderTime) => _createReminder(reminderText, reminderTime),
      ),
    );
  }

  Future<void> _createReminder(String reminderText, DateTime reminderTime) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Creating reminder...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      await _reminderService.createReminder(
        reminderText: reminderText,
        reminderTime: reminderTime,
      );

      await _loadReminders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create reminder: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(String reminderId) {
    showDialog(
      context: context,
      builder: (ctx) => DeleteConfirmationDialog(
        onConfirm: () => _deleteReminder(reminderId),
      ),
    );
  }

  Future<void> _deleteReminder(String reminderId) async {
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deleting reminder...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      await _reminderService.deleteReminder(reminderId: reminderId);
      await _loadReminders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete reminder: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadReminders,
          ),
        ],
      ),
      floatingActionButton: MicFab(
        onPressed: () {
          // TODO: Implement voice input
        },
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          AddReminderButton(onPressed: _showAddDialog),
          const SizedBox(height: 15),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xff00E0FF),
                    ),
                  )
                : reminders.isEmpty
                    ? const Center(
                        child: Text(
                          'No reminders yet',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        itemCount: reminders.length,
                        itemBuilder: (ctx, i) {
                          return ReminderListItem(
                            title: reminders[i]["title"],
                            time: reminders[i]["time"],
                            onDelete: () => _showDeleteConfirmation(reminders[i]["id"]),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
