import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:kmpharma/Screens/SignUpScreen/CreateAccountScreen.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double screenHeight = mediaQuery.size.height;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: screenHeight * 0.24,
                bottom: screenHeight * 0.3,
              ),
              child: Center(
                child: Image.asset("assets/company_logo.jpg", width: 300),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 26.0,
                vertical: 8,
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor("#033d8c"),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateAccountScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
                  foregroundColor: HexColor("#033d8c"),
                  backgroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12.0,
                    ), // Adjust the radius value here
                    side: BorderSide(color: HexColor("#033d8c")),
                  ),
                ),
                onPressed: () {
                  print('Sign Up button pressed!');
                },
                child: const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
