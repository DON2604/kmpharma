import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kmpharma/constants.dart';
import 'package:kmpharma/services/secure_storage_service.dart';

class DoctorAppointmentService {

  /// Book a doctor appointment
  Future<Map<String, dynamic>> bookDoctorAppointment({
    required String symptoms,
    required String preferredSpecialization,
    required DateTime preferredDate,
    required String preferredTime, // HH:mm
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
        Uri.parse('$url/doctor-appointment/book'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'phone_number': phoneNumber,
          'session_id': sessionId,
          'symptoms': symptoms,
          'preferred_specialization': preferredSpecialization,
          'preferred_date': preferredDate.toIso8601String(),
          'preferred_time': preferredTime,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('Doctor Appointment Booking Response:');
        print(json.encode(responseData));
        return responseData;
      } else {
        throw Exception(
          'Failed to book appointment: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error booking doctor appointment: $e');
      rethrow;
    }
  }

  /// Get user doctor appointments
  Future<List<Map<String, dynamic>>> getUserDoctorAppointments() async {
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
        Uri.parse(
          '$url/doctor-appointment/user/$phoneNumber/$sessionId',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        print('User Doctor Appointments Response:');
        print(json.encode(responseData));
        return responseData.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
          'Failed to fetch appointments: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching doctor appointments: $e');
      rethrow;
    }
  }
}
