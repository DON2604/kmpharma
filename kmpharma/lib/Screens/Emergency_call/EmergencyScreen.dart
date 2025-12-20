import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kmpharma/Screens/Emergency_call/widgets/MicButton.dart';
import 'package:kmpharma/Screens/Emergency_call/widgets/WaveformBars.dart';
import 'package:kmpharma/Screens/Emergency_call/widgets/RecognizedSpeechBox.dart';
import 'package:kmpharma/Screens/Emergency_call/widgets/ContactManager.dart';
import 'package:kmpharma/services/secure_storage_service.dart';
import 'package:kmpharma/services/trigger_phrase_service.dart';
import 'package:kmpharma/services/background_speech_service.dart';
import 'package:kmpharma/constants.dart';

class Emergencyscreen extends StatefulWidget {
  final String? phoneNumber;

  const Emergencyscreen({super.key, this.phoneNumber});

  @override
  State<Emergencyscreen> createState() => _EmergencyscreenState();
}

class _EmergencyscreenState extends State<Emergencyscreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Timer _waveTimer;
  late stt.SpeechToText _speech;

  List<double> waveValues = List.filled(30, 0);
  String recognizedText = "Your words will appear here...";
  bool isListening = false;
  bool isBackgroundListening = false;

  // CONTACTS LIST
  final List<String> contacts = [];
  final TextEditingController contactController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _speech = stt.SpeechToText();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.9,
      upperBound: 1.15,
    )..repeat(reverse: true);

    _waveTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (isListening) {
        setState(() {
          waveValues = List.generate(30, (_) => Random().nextDouble() * 40 + 5);
        });
      }
    });

    // Store phone number in secure storage
    if (widget.phoneNumber != null) {
      SecureStorageService.savePhoneNumber(widget.phoneNumber!);
    }
    
    _loadContacts();
    _loadBackgroundListeningState();
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedContacts = prefs.getStringList('emergency_contacts') ?? [];
    setState(() {
      contacts.addAll(savedContacts);
    });
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('emergency_contacts', contacts);
  }

  Future<void> _loadBackgroundListeningState() async {
    final enabled = await TriggerPhraseService.isBackgroundListeningEnabled();
    setState(() {
      isBackgroundListening = enabled;
    });
    
    if (enabled) {
      await BackgroundSpeechService().startListening();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveTimer.cancel();
    super.dispose();
  }

  Future<void> toggleListening() async {
    var status = await Permission.microphone.request();

    if (status.isDenied) {
      setState(() {
        recognizedText = "Microphone permission denied.";
      });
      return;
    }

    if (status.isPermanentlyDenied) {
      setState(() {
        recognizedText = "Enable microphone permission from Settings.";
      });
      openAppSettings();
      return;
    }

    if (!isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == "notListening") {
            setState(() => isListening = false);
          }
        },
        onError: (e) {
          setState(() {
            isListening = false;
            recognizedText = "❗ Error: ${e.errorMsg}";
          });
        },
      );

      if (available) {
        setState(() {
          isListening = true;
          recognizedText = "";
        });

        _speech.listen(
          onResult: (result) {
            setState(() {
              recognizedText = result.recognizedWords;
            });
          },
          partialResults: true,
        );
      }
    } else {
      setState(() => isListening = false);
      _speech.stop();
    }
  }

  Future<void> _setTriggerPhrase() async {
    if (recognizedText.isEmpty || recognizedText == "Your words will appear here...") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Speak a trigger phrase first")),
      );
      return;
    }

    await TriggerPhraseService.saveTriggerPhrase(recognizedText);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Trigger phrase set: '$recognizedText'")),
    );
  }

  Future<void> _toggleBackgroundListening() async {
    if (contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add emergency contacts first")),
      );
      return;
    }

    final triggerPhrase = await TriggerPhraseService.getTriggerPhrase();
    if (triggerPhrase == null || triggerPhrase.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Set a trigger phrase first")),
      );
      return;
    }

    final newState = !isBackgroundListening;
    
    if (newState) {
      final phoneStatus = await Permission.phone.request();
      if (!phoneStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Phone permission required for emergency calls")),
        );
        return;
      }
      
      await BackgroundSpeechService().startListening();
    } else {
      await BackgroundSpeechService().stopListening();
    }

    await TriggerPhraseService.setBackgroundListening(newState);
    setState(() {
      isBackgroundListening = newState;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newState ? "Background listening activated" : "Background listening disabled"),
      ),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kBackgroundGradient),
        child: Scaffold(
          backgroundColor: Colors.transparent,

          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Emergency Voice",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),

          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Tap the microphone and speak clearly.",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),

                  const SizedBox(height: 40),

                  // MIC BUTTON
                  MicButton(
                    isListening: isListening,
                    pulseAnimation: _pulseController,
                    onTap: toggleListening,
                  ),

                  const SizedBox(height: 40),

                  // WAVEFORM
                  WaveformBars(values: waveValues, isListening: isListening),

                  const SizedBox(height: 30),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "You are saying:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  RecognizedSpeechBox(
                    text: recognizedText,
                    isListening: isListening,
                  ),

                  const SizedBox(height: 20),

                  // SET TRIGGER PHRASE BUTTON
                  ElevatedButton.icon(
                    onPressed: _setTriggerPhrase,
                    icon: const Icon(Icons.bookmark_add),
                    label: const Text("Set as Trigger Phrase"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // TOGGLE BACKGROUND LISTENING
                  SwitchListTile(
                    value: isBackgroundListening,
                    onChanged: (_) => _toggleBackgroundListening(),
                    title: const Text(
                      "Background Listening",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      isBackgroundListening 
                          ? "App will listen for trigger phrase in background" 
                          : "Enable to auto-call on trigger phrase",
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    activeThumbColor: Colors.green,
                    tileColor: Colors.white.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  const SizedBox(height: 30),

                  ContactManager(
                    controller: contactController,
                    contacts: contacts,
                    onAdd: (value) {
                      if (contacts.length < 2) {
                        setState(() {
                          contacts.add(value);
                        });
                        _saveContacts();
                      }
                    },

                    onRemove: (index) {
                      setState(() {
                        contacts.removeAt(index);
                      });
                      _saveContacts();
                    },
                  ),

                  const SizedBox(height: 20),

                  // CONTACTS LIST
                  if (contacts.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(
                            Icons.contact_phone,
                            color: Colors.red,
                          ),
                          title: Text(
                            contacts[index],
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                contacts.removeAt(index);
                              });
                              _saveContacts();
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
