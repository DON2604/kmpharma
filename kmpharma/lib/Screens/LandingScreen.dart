import 'package:flutter/material.dart';
import 'package:kmpharma/Screens/SignInScreen/SignInScreen.dart';
import 'package:kmpharma/constants.dart';
import 'package:kmpharma/Screens/SignUpScreen/SignUpScreen.dart';

class Landingscreen extends StatefulWidget {
  const Landingscreen({super.key});

  @override
  State<Landingscreen> createState() => _LandingscreenState();
}

class _LandingscreenState extends State<Landingscreen> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double screenHeight = mediaQuery.size.height;
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: screenHeight,
          decoration: const BoxDecoration(gradient: kBackgroundGradient),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.24,
                    bottom: screenHeight * 0.3,
                  ),
                  child: Center(
                    child: Image.asset("assets/company_logo.png", width: 340),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26.0,
                    vertical: 8,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text('Sign Up'),
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26.0,
                    vertical: 8,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignInScreen(),
                        ),
                      );
                    },
                    child: const Text('Sign In'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
