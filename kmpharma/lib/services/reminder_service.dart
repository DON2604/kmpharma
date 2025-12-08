import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kmpharma/constants.dart';
import 'package:kmpharma/services/secure_storage_service.dart';

class ReminderService {
  Future<List<Map<String, dynamic>>> getUserReminders() async {
    try {
      final phoneNumber = await SecureStorageService.getPhoneNumber();
      final sessionId = await SecureStorageService.getSessionId();

      if (phoneNumber == null || phoneNumber.isEmpty) {
        throw Exception('Phone number not found. Please login again.');
      }

      if (sessionId == null || sessionId.isEmpty) {
        throw Exception('Session ID not found. Please login again.');
      }

      final response = await http.get(
        Uri.parse('$url/reminder/user/$phoneNumber/$sessionId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        print('User Reminders Response:');
        print(json.encode(responseData));
        return responseData.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch reminders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching reminders: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createReminder({
    required String reminderText,
    required DateTime reminderTime,
  }) async {
    try {
      final phoneNumber = await SecureStorageService.getPhoneNumber();
      final sessionId = await SecureStorageService.getSessionId();

      if (phoneNumber == null || phoneNumber.isEmpty) {
        throw Exception('Phone number not found. Please login again.');
      }

      if (sessionId == null || sessionId.isEmpty) {
        throw Exception('Session ID not found. Please login again.');
      }

      final response = await http.post(
        Uri.parse('$url/reminder/create'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'phone_number': phoneNumber,
          'session_id': sessionId,
          'reminder_text': reminderText,
          'reminder_time': reminderTime.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Create Reminder Response:');
        print(json.encode(responseData));
        return responseData;
      } else {
        throw Exception('Failed to create reminder: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating reminder: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteReminder({
    required String reminderId,
  }) async {
    try {
      final phoneNumber = await SecureStorageService.getPhoneNumber();
      final sessionId = await SecureStorageService.getSessionId();

      if (phoneNumber == null || phoneNumber.isEmpty) {
        throw Exception('Phone number not found. Please login again.');
      }

      if (sessionId == null || sessionId.isEmpty) {
        throw Exception('Session ID not found. Please login again.');
      }

      final response = await http.delete(
        Uri.parse('$url/reminder/cancel/$reminderId/$phoneNumber/$sessionId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Delete Reminder Response:');
        print(json.encode(responseData));
        return responseData;
      } else {
        throw Exception('Failed to delete reminder: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting reminder: $e');
      rethrow;
    }
  }
}
