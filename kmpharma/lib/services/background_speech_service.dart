import 'dart:async';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:kmpharma/services/trigger_phrase_service.dart';
import 'package:kmpharma/services/secure_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundSpeechService {
  static final BackgroundSpeechService _instance = BackgroundSpeechService._internal();
  factory BackgroundSpeechService() => _instance;
  BackgroundSpeechService._internal();

  stt.SpeechToText? _speech;
  Timer? _restartTimer;
  bool _isRunning = false;
  String? _triggerPhrase;
  List<String>? _emergencyContacts;

  Future<void> startListening() async {
    if (_isRunning) return;
    
    _speech = stt.SpeechToText();
    _triggerPhrase = await TriggerPhraseService.getTriggerPhrase();
    _emergencyContacts = await _loadEmergencyContacts();
    
    if (_triggerPhrase == null || _triggerPhrase!.isEmpty) {
      print("No trigger phrase set");
      return;
    }
    
    if (_emergencyContacts == null || _emergencyContacts!.isEmpty) {
      print("No emergency contacts set");
      return;
    }
    
    _isRunning = true;
    await _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speech!.initialize(
      onStatus: (status) async {
        print("Speech status: $status");
        if (status == "notListening" && _isRunning) {
          // Restart listening after a short delay
          _restartTimer?.cancel();
          _restartTimer = Timer(const Duration(seconds: 2), () {
            if (_isRunning) _startListeningSession();
          });
        }
      },
      onError: (error) {
        print("Speech error: ${error.errorMsg}");
      },
    );

    if (available) {
      await _startListeningSession();
    }
  }

  Future<void> _startListeningSession() async {
    if (!_isRunning || _speech == null) return;
    
    await _speech!.listen(
      onResult: (result) async {
        final spokenText = result.recognizedWords;
        print("Heard: $spokenText");
        
        if (TriggerPhraseService.matchesTriggerPhrase(spokenText, _triggerPhrase!)) {
          print("TRIGGER DETECTED: $spokenText");
          await _makeEmergencyCalls();
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: false,
      listenMode: stt.ListenMode.dictation,
    );
  }

  Future<void> _makeEmergencyCalls() async {
    if (_emergencyContacts == null || _emergencyContacts!.isEmpty) return;
    
    for (String contact in _emergencyContacts!) {
      try {
        // Remove any non-numeric characters
        final cleanNumber = contact.replaceAll(RegExp(r'[^0-9+]'), '');
        await FlutterPhoneDirectCaller.callNumber(cleanNumber);
        print("Calling emergency contact: $cleanNumber");
        
        // Wait before next call
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        print("Error calling $contact: $e");
      }
    }
  }

  Future<List<String>?> _loadEmergencyContacts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('emergency_contacts');
  }

  Future<void> stopListening() async {
    _isRunning = false;
    _restartTimer?.cancel();
    await _speech?.stop();
    _speech = null;
  }

  bool get isRunning => _isRunning;
}
