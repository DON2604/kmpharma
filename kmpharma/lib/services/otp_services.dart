import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kmpharma/constants.dart';

class OtpService {
  static Future<Map<String, dynamic>> signup(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$url/otp/signup'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
        }),
      );

      // Success
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      // Error (extract detail)
      final body = jsonDecode(response.body);

      return {
        'success': false,
        'message': body['detail'] ?? 'Failed to send OTP',
      };

    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> signin(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$url/otp/signin'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
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
        'message': body['detail'] ?? 'Failed to send OTP',
      };

    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(
    String phoneNumber,
    String otpCode,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$url/otp/verify'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
          'otp_code': otpCode,
        }),
      );

      // Success
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      // Error (extract detail)
      final body = jsonDecode(response.body);

      return {
        'success': false,
        'message': body['detail'] ?? 'Failed to verify OTP',
      };

    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}