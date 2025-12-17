import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kmpharma/constants.dart';
import 'package:kmpharma/services/secure_storage_service.dart';

class MedicineService {
  static const secureStorage = FlutterSecureStorage();

  Future<Map<String, dynamic>> analyzePrescription({required File file}) async {
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
        Uri.parse('$url/medicine-booking/analyze-prescription'),
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

  Future<Map<String, dynamic>> orderMedicine({
    required List<String> medicines,
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
        Uri.parse('$url/medicine-booking/book'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'phone_number': phoneNumber,
          'session_id': sessionId,
          'medicines': medicines,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Medicine Order Response:');
        print(json.encode(responseData));
        return responseData;
      } else {
        throw Exception('Failed to order medicine: ${response.statusCode}');
      }
    } catch (e) {
      print('Error ordering medicine: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserMedicineOrders() async {
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
        Uri.parse('$url/medicine-booking/user/$phoneNumber/$sessionId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        print('User Medicine Orders Response:');
        print(json.encode(responseData));
        return responseData.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch medicine orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching medicine orders: $e');
      rethrow;
    }
  }
}
