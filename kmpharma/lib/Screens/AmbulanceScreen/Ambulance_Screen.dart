import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';

import 'package:kmpharma/constants.dart';
import 'package:kmpharma/services/ambulance_book_service.dart';
import 'package:kmpharma/Screens/AmbulanceScreen/widgets/LocationDisplay.dart';
import 'package:kmpharma/Screens/AmbulanceScreen/widgets/DestinationInput.dart';
import 'package:kmpharma/Screens/AmbulanceScreen/widgets/MicrophoneButton.dart';
import 'package:kmpharma/Screens/AmbulanceScreen/widgets/BookingButton.dart';
import 'package:kmpharma/Screens/AmbulanceScreen/Ambulance_history.dart';

class AmbulanceScreen extends StatefulWidget {
  const AmbulanceScreen({super.key});

  @override
  State<AmbulanceScreen> createState() => _AmbulanceScreenState();
}

class _AmbulanceScreenState extends State<AmbulanceScreen>
    with TickerProviderStateMixin {
  String currentAddress = "Fetching location";
  bool isLoadingLocation = true;

  late AnimationController _dotController;
  late AnimationController _micPulseController;
  late stt.SpeechToText _speech;

  bool isListening = false;
  bool isBooking = false;

  final TextEditingController destinationController = TextEditingController();
  Map<String, dynamic>? bookedAmbulance;
  Position? currentPosition;

  @override
  void initState() {
    super.initState();

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _micPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.9,
      upperBound: 1.15,
    )..repeat(reverse: true);

    _speech = stt.SpeechToText();
    getCurrentLocation();
  }

  @override
  void dispose() {
    _dotController.dispose();
    _micPulseController.dispose();
    destinationController.dispose();
    super.dispose();
  }

  // ================= LOCATION =================

  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        currentAddress = "Enable location services";
        isLoadingLocation = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          currentAddress = "Location permission denied";
          isLoadingLocation = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        currentAddress = "Enable location permission in settings";
        isLoadingLocation = false;
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    Placemark place = placemarks.first;

    setState(() {
      currentPosition = position;
      currentAddress =
          "${place.street}, ${place.locality}, ${place.administrativeArea}";
      isLoadingLocation = false;
    });
  }

  // ================= SPEECH =================

  Future<void> toggleListening() async {
    var status = await Permission.microphone.request();

    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Microphone permission denied")),
      );
      return;
    }

    if (status.isPermanentlyDenied) {
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
          setState(() => isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.errorMsg)),
          );
        },
      );

      if (available) {
        setState(() => isListening = true);
        _speech.listen(
          partialResults: true,
          onResult: (result) {
            setState(() {
              destinationController.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      _speech.stop();
      setState(() => isListening = false);
    }
  }

  // ================= GOOGLE MAPS =================

  Future<void> _openGoogleMaps() async {
    if (currentPosition == null || isLoadingLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please wait for location to load")),
      );
      return;
    }

    if (destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a destination")),
      );
      return;
    }

    // Android intent (most reliable)
    final Uri mapsIntent = Uri.parse(
      "google.navigation:q=${Uri.encodeComponent(destinationController.text)}&mode=d",
    );

    try {
      await launchUrl(
        mapsIntent,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      // Browser fallback
      final Uri fallback = Uri.parse(
        "https://www.google.com/maps/dir/?api=1"
        "&origin=${currentPosition!.latitude},${currentPosition!.longitude}"
        "&destination=${Uri.encodeComponent(destinationController.text)}",
      );

      await launchUrl(
        fallback,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  // ================= BOOKING =================

  Future<void> _bookAmbulance() async {
    if (isLoadingLocation) return;

    setState(() => isBooking = true);

    try {
      final phoneNumber = await AmbulanceBookService.getPhoneNumber();
      final sessionId = await AmbulanceBookService.getSessionId();

      if (phoneNumber == null || sessionId == null) {
        throw Exception("Session not found");
      }

      await AmbulanceBookService.bookAmbulance(
        phoneNumber: phoneNumber,
        sessionId: sessionId,
        currentLocation: currentAddress,
        destination: destinationController.text.isEmpty
            ? "Not specified"
            : destinationController.text,
      );

      setState(() => isBooking = false);
      _showBookingConfirmation();
    } catch (e) {
      setState(() => isBooking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _showBookingConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Ambulance Booked"),
        content: const Text("Driver will arrive shortly."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Done"),
          )
        ],
      ),
    );
  }

  // ================= UI =================

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
              "Request an Ambulance",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.history, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AmbulanceHistoryScreen(),
                    ),
                  );
                },
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                LocationDisplay(
                  currentAddress: currentAddress,
                  isLoadingLocation: isLoadingLocation,
                  dotController: _dotController,
                ),
                const SizedBox(height: 20),
                DestinationInput(
                  destinationController: destinationController,
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _openGoogleMaps,
                    icon: const Icon(Icons.map, color: Colors.white),
                    label: const Text(
                      "Open in Google Maps",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                MicrophoneButton(
                  isListening: isListening,
                  micPulseController: _micPulseController,
                  onTap: toggleListening,
                ),
                SizedBox(height: MediaQuery.of(context).size.height - 590),
                BookingButton(
                  isBooking: isBooking,
                  onPressed: _bookAmbulance,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
