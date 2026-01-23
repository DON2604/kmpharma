import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kmpharma/Screens/LandingScreen.dart';
import 'package:kmpharma/Screens/ServicesScreen/ServicesScreen.dart';
import 'package:kmpharma/services/session_service.dart';
import 'package:kmpharma/services/notification_service.dart';
import 'package:kmpharma/services/background_speech_service.dart';
import 'package:kmpharma/services/trigger_phrase_service.dart';
import 'package:kmpharma/services/location_service.dart';
import 'package:kmpharma/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await NotificationService().initialize();

  // Fetch and store current location
  await LocationService.fetchAndStoreLocation();

  // Initialize background speech service if enabled
  final isBackgroundEnabled =
      await TriggerPhraseService.isBackgroundListeningEnabled();
  if (isBackgroundEnabled) {
    await BackgroundSpeechService().startListening();
  }

  const secureStorage = FlutterSecureStorage();
  String? sessionId;

  try {
    sessionId = await secureStorage.read(key: 'session_id');
  } catch (e) {
    print("ERROR READING SESSION: $e");
    sessionId = null;
  }

  print("SESSION ID FROM STORAGE: $sessionId");

  bool isSessionValid = false;
  String? phoneNumber;

  if (sessionId != null && sessionId.isNotEmpty) {
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
