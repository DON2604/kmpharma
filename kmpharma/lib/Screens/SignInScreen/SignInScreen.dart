import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kmpharma/constants.dart';
import 'package:kmpharma/services/otp_services.dart';
import 'package:kmpharma/Screens/ServicesScreen/ServicesScreen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final _secureStorage = const FlutterSecureStorage();

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _signin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final phoneNumber = '+91${_phoneController.text.trim()}';
    final pin = _pinController.text.trim();

    final response = await OtpService.signinWithPin(phoneNumber, pin);

    setState(() => _isLoading = false);

    if (response['status'] == 'success') {
      // Store phone number and session ID
      await _secureStorage.write(
        key: 'phone_number',
        value: phoneNumber,
      );
      await _secureStorage.write(
        key: 'session_id',
        value: response['session_id'],
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ServicesScreen(phoneNumber: phoneNumber),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Failed to sign in')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(gradient: kBackgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Custom AppBar
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Sign in to your account',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Progress Indicator
                const LinearProgressIndicator(
                  value: 1.0,
                  backgroundColor: Color(0xFFE0E0E0),
                  valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                  minHeight: 6,
                ),
                const SizedBox(height: 40),

                // Main Title
                const Text(
                  "Sign in with your credentials",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                const Text(
                  'Enter your phone number and 4-digit PIN',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Form
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Phone Number Input Field
                              TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixText: '+91 ',
                          prefixStyle: const TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.white54),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 80, 75, 231),
                              width: 2.0,
                            ),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (value.length != 10) {
                            return 'Phone number must be 10 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // PIN Input Field
                      TextFormField(
                        controller: _pinController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 4,
                        decoration: InputDecoration(
                          labelText: '4-Digit PIN',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.white54),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 80, 75, 231),
                              width: 2.0,
                            ),
                          ),
                          counterText: '',
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your PIN';
                          }
                          if (value.length != 4) {
                            return 'PIN must be 4 digits';
                          }
                          return null;
                        },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Sign In Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26.0,
                    vertical: 8,
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D5FEF),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Sign In'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
