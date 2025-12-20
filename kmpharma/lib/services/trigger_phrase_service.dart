import 'package:shared_preferences/shared_preferences.dart';

class TriggerPhraseService {
  static const String _triggerPhraseKey = 'emergency_trigger_phrase';
  static const String _isBackgroundListeningKey = 'is_background_listening';
  
  static Future<void> saveTriggerPhrase(String phrase) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_triggerPhraseKey, phrase.toLowerCase().trim());
  }
  
  static Future<String?> getTriggerPhrase() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_triggerPhraseKey);
  }
  
  static Future<void> setBackgroundListening(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isBackgroundListeningKey, enabled);
  }
  
  static Future<bool> isBackgroundListeningEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isBackgroundListeningKey) ?? false;
  }
  
  static bool matchesTriggerPhrase(String spokenText, String triggerPhrase) {
    final spoken = spokenText.toLowerCase().trim();
    final trigger = triggerPhrase.toLowerCase().trim();
    
    // Exact match or contains the trigger phrase
    return spoken == trigger || spoken.contains(trigger);
  }
}
