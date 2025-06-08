import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const chicaOrange = Color(0xFFFF5C22);
  static const spiceRed = Color(0xFF9B1C24); // Pantone 7625 C
  static const sunburstYellow = Color(0xFFFFCC72); // Pantone 123C
  static const pickleGreen = Color(0xFF9B9963); // Pantone 7495 C

  // Usage Guidelines
  // Chica Orange: Primary brand color, used for buttons and primary actions
  // Spice Red: Used sparingly for highlights, alerts and promotional badges
  // Sunburst Yellow: For backgrounds, overlays, and secondary accents
  // Pickle Green: For secondary calls-to-action and icon strokes

  // Text Colors
  static const textPrimary = Colors.black;
  static const textSecondary = Color(0xFF757575);
  static const textDisabled = Color(0xFFBDBDBD);

  // Background Colors
  static const background = Colors.white;
  static const surfaceLight = Color(0xFFF5F5F5);
  static const surfaceMedium = Color(0xFFEEEEEE);

  // Status Colors
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFC107);
  static const error = spiceRed;
}
