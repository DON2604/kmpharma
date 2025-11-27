import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFF1B1865);

const LinearGradient kBackgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF3533CD), // Dark Blue at the top
    Colors.black, // Black at the bottom
  ],
  stops: [0.0, 1.0],
);
