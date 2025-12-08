import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _phoneNumberKey = 'phone_number';
  static const _sessionid = 'session_id';

  /// Save phone number to secure storage
  static Future<void> savePhoneNumber(String phoneNumber) async {
    await _storage.write(
      key: _phoneNumberKey,
      value: phoneNumber,
    );
  }

  /// Retrieve phone number from secure storage
  static Future<String?> getPhoneNumber() async {
    return await _storage.read(key: _phoneNumberKey);
  }

  static Future<String?> getSessionId() async {
    return await _storage.read(key: _sessionid);
  }

  /// Delete phone number from secure storage
  static Future<void> deletePhoneNumber() async {
    await _storage.delete(key: _phoneNumberKey);
  }

  /// Clear all data from secure storage
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
