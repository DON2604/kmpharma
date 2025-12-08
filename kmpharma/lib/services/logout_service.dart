import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kmpharma/Screens/LandingScreen.dart';

class LogoutService {
  static Future<void> logout(BuildContext context) async {
    const secureStorage = FlutterSecureStorage();
    
    // Delete session_id from secure storage
    await secureStorage.delete(key: 'session_id');
    
    print("SESSION CLEARED");
    
    // Navigate to LandingScreen and remove all previous routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => Landingscreen()),
      (route) => false,
    );
  }
}
