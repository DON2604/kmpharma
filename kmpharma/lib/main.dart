import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kmpharma/Screens/LandingScreen.dart';
import 'package:kmpharma/Screens/ServicesScreen/ServicesScreen.dart';
import 'package:kmpharma/services/session_service.dart';
import 'package:kmpharma/services/notification_service.dart';
import 'package:kmpharma/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await NotificationService().initialize();

 const secureStorage = FlutterSecureStorage();

  String? sessionId;

  try {
    sessionId = await secureStorage.read(key: 'session_id');

    // 🔹 TESTING FALLBACK SESSION ID
    if (sessionId == null || sessionId.isEmpty) {
      sessionId = '4f424c3c-8e34-4c97-b8fc-e081f9a85d9e';
      print("USING TEST SESSION ID");
    }
  } catch (e) {
    print("ERROR READING SESSION: $e");
    sessionId = '4f424c3c-8e34-4c97-b8fc-e081f9a85d9e';
  }

  print("SESSION ID USED: $sessionId");

  bool isSessionValid = false;
  String? phoneNumber;

  if (sessionId.isNotEmpty) {
    final response = await SessionService.checkUserSession(sessionId);
    if (response['status'] == 'success' &&
        response['verified'] == true &&
        response['message'] == 'User session found') {
      isSessionValid = true;
      phoneNumber = response['phone_number'];
      print("SESSION VALID: $phoneNumber");
    }
  }

  runApp(MyApp(isSessionValid: isSessionValid, phoneNumber: phoneNumber));
}

class MyApp extends StatelessWidget {
  final bool isSessionValid;
  final String? phoneNumber;

  const MyApp({
    super.key,
    required this.isSessionValid,
    this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    print("Session Valid inside MyApp: $isSessionValid");

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: isSessionValid 
          ? ServicesScreen(phoneNumber: phoneNumber)
          : Landingscreen(),
    );
  }
}
