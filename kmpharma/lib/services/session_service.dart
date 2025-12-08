import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kmpharma/constants.dart';

class SessionService {
  static Future<Map<String, dynamic>> checkUserSession(String sessionId) async {
    try {
      final response = await http.post(
        Uri.parse('$url/check-user'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'session_id': sessionId,
        }),
      );
      print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      final body = jsonDecode(response.body);
      return {
        'status': 'error',
        'message': body['detail'] ?? 'Session check failed',
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error: $e',
      };
    }
  }
}
