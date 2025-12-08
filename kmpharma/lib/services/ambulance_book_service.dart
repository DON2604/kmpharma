import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:kmpharma/constants.dart';

class AmbulanceBookService {
  
  static const secureStorage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> bookAmbulance({
    required String phoneNumber,
    required String sessionId,
    required String currentLocation,
    required String destination,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$url/ambulance/book'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
          'session_id': sessionId,
          'curr_loc': currentLocation,
          'destination': destination,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to book ambulance: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error booking ambulance: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getBookings({
    required String phoneNumber,
    required String sessionId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$url/ambulance/bookings/$phoneNumber/$sessionId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle both list and single object responses
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else {
          return [data as Map<String, dynamic>];
        }
      } else {
        throw Exception('Failed to fetch bookings: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  static Future<String?> getPhoneNumber() async {
    return await secureStorage.read(key: 'phone_number');
  }

  static Future<String?> getSessionId() async {
    return await secureStorage.read(key: 'session_id');
  }
}
