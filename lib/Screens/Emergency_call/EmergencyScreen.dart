import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class Emergencyscreen extends StatefulWidget {
  const Emergencyscreen({super.key});

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

  @override
  void initState() {
    super.initState();

    _speech = stt.SpeechToText();

    // Pulse mic animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.9,
      upperBound: 1.15,
    )..repeat(reverse: true);

    // Wave animation
    _waveTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (isListening) {
        setState(() {
          waveValues = List.generate(30, (_) => Random().nextDouble() * 40 + 5);
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveTimer.cancel();
    super.dispose();
  }

  Future<void> toggleListening() async {
    // Request microphone permission first
    var status = await Permission.microphone.request();

    if (status.isDenied) {
      // User pressed "Deny"
      setState(() {
        recognizedText = "Microphone permission denied.";
      });
      return;
    }

    if (status.isPermanentlyDenied) {
      // User pressed "Don't ask again"
      setState(() {
        recognizedText = "Enable microphone permission from Settings.";
      });
      openAppSettings();
      return;
    }

    // Now start speech to text
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
      // stop listening
      setState(() => isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Emergency Voice",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Tap the microphone and speak clearly.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 40),

            // MIC BUTTON WITH PULSE
            GestureDetector(
              onTap: toggleListening,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isListening ? _pulseController.value : 1,
                    child: child,
                  );
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: isListening ? Colors.red.shade700 : Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.mic, color: Colors.white, size: 55),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // WAVEFORM
            SizedBox(
              height: 60,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: waveValues.map((v) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      width: 4,
                      height: isListening ? v : 6,
                      decoration: BoxDecoration(
                        color: isListening ? Colors.red : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 30),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "You are saying:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                recognizedText.isEmpty ? "Listening..." : recognizedText,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
