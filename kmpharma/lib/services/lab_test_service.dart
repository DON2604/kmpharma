import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kmpharma/constants.dart';
import 'package:kmpharma/services/secure_storage_service.dart';

class LabTestService {
  static const secureStorage = FlutterSecureStorage();

  Future<Map<String, dynamic>> analyzePrescription({
    required File file,
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

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$url/lab-test/analyze-prescription'),
      );

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),
      );

      // Add fields
      request.fields['phone_number'] = phoneNumber;
      request.fields['session_id'] = sessionId;

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Prescription Analysis Response:');
        print(json.encode(responseData));
        return responseData;
      } else {
        throw Exception('Failed to analyze prescription: ${response.statusCode}');
      }
    } catch (e) {
      print('Error analyzing prescription: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> bookLabTest({
    required List<String> tests,
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
        Uri.parse('$url/lab-test/book'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'phone_number': phoneNumber,
          'session_id': sessionId,
          'tests': tests,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Lab Test Booking Response:');
        print(json.encode(responseData));
        return responseData;
      } else {
        throw Exception('Failed to book lab test: ${response.statusCode}');
      }
    } catch (e) {
      print('Error booking lab test: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserLabTests() async {
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
        Uri.parse('$url/lab-test/user/$phoneNumber/$sessionId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        print('User Lab Tests Response:');
        print(json.encode(responseData));
        return responseData.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch lab tests: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching lab tests: $e');
      rethrow;
    }
  }
}
