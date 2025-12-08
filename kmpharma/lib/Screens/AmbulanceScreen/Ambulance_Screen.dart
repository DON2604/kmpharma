import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
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
  final TextEditingController destinationController = TextEditingController();
  bool isBooking = false;
  Map<String, dynamic>? bookedAmbulance;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _micPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.9,
      upperBound: 1.15,
    )..repeat(reverse: true);

    _speech = stt.SpeechToText();
    getCurrentLocation(); // 🔥 auto fetch on page open
  }

  @override
  void dispose() {
    _dotController.dispose();
    _micPulseController.dispose();
    destinationController.dispose();
    super.dispose();
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check GPS enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        currentAddress = "Enable location services";
        isLoadingLocation = false;
      });
      return;
    }

    // Permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          currentAddress = "Location denied";
          isLoadingLocation = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        currentAddress = "Enable location in settings";
        isLoadingLocation = false;
      });
      return;
    }

    // Get coordinates
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Convert coords → address
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    Placemark place = placemarks.first;

    setState(() {
      currentAddress =
          "${place.street}, ${place.locality}, ${place.administrativeArea}";
      isLoadingLocation = false;
    });
  }

  Future<void> toggleListening() async {
    var status = await Permission.microphone.request();

    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Microphone permission denied.")),
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
          setState(() {
            isListening = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${e.errorMsg}")),
          );
        },
      );

      if (available) {
        setState(() => isListening = true);

        _speech.listen(
          onResult: (result) {
            setState(() {
              destinationController.text = result.recognizedWords;
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

  Future<void> _bookAmbulance() async {
    if (currentAddress == "Fetching location" || isLoadingLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please wait for location to load")),
      );
      return;
    }

    setState(() => isBooking = true);

    try {
      final phoneNumber = await AmbulanceBookService.getPhoneNumber();
      final sessionId = await AmbulanceBookService.getSessionId();

      if (phoneNumber == null || sessionId == null) {
        throw Exception("Phone number or session ID not found in storage");
      }

      final destination = destinationController.text.isEmpty
          ? "Not specified"
          : destinationController.text;

      await AmbulanceBookService.bookAmbulance(
        phoneNumber: phoneNumber,
        sessionId: sessionId,
        currentLocation: currentAddress,
        destination: destination,
      );

      // Fetch booked ambulance details
      final bookings = await AmbulanceBookService.getBookings(
        phoneNumber: phoneNumber,
        sessionId: sessionId,
      );

      setState(() {
        // Get the first booking from the list
        bookedAmbulance = bookings.isNotEmpty ? bookings.first : null;
        isBooking = false;
      });

      _showBookingConfirmation();
    } catch (e) {
      setState(() => isBooking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void _showBookingConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Ambulance Booked!",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
        content: const Text(
          "Your ambulance has been booked successfully. The driver will arrive shortly.",
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Done"),
          ),
        ],
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
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Request an Ambulance",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.history, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AmbulanceHistoryScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  LocationDisplay(
                    currentAddress: currentAddress,
                    isLoadingLocation: isLoadingLocation,
                    dotController: _dotController,
                  ),

                  const SizedBox(height: 25),

                  DestinationInput(
                    destinationController: destinationController,
                  ),

                  const SizedBox(height: 40),

                  MicrophoneButton(
                    isListening: isListening,
                    micPulseController: _micPulseController,
                    onTap: toggleListening,
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height - 540),

                  BookingButton(
                    isBooking: isBooking,
                    onPressed: _bookAmbulance,
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
