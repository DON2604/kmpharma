import 'package:flutter/material.dart';
import 'package:kmpharma/Screens/SignUpScreen/SignUpScreen.dart';
import 'package:kmpharma/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: Signupscreen(),
    );
  }
}
