import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kmpharma/constants.dart';

class OtpService {
  static Future<Map<String, dynamic>> signinWithPin(
    String phoneNumber,
    String pin,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$url/auth/signin'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
          'pin': pin,
        }),
      );

      // Success
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      // Error (extract detail)
      final body = jsonDecode(response.body);

      return {
        'status': 'error',
        'message': body['detail'] ?? 'Failed to sign in',
      };

    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> signupWithPin(
    String phoneNumber,
    String pin,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$url/auth/signup'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
          'pin': pin,
        }),
      );

      // Success
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      // Error (extract detail)
      final body = jsonDecode(response.body);

      return {
        'status': false,
        'message': body['detail'] ?? 'Failed to sign up',
      };

    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
      };
    }
  }
}