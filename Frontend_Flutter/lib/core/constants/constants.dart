import 'package:flutter/material.dart';

class AppColors {
  // Gradient Colors
  static const Color gradientStart = Color(0xFFF9D181); // Top Right (Yellowish)
  static const Color gradientMiddle = Color(0xFF478F9A); // Middle (Teal)
  static const Color gradientEnd = Color(0xFF00225A); // Bottom Left (Dark Blue)

  // Text Colors
  static const Color textPrimary = Color(0xFF00225A);
  static const Color textSecondary = Color(0xFF8B9EAF);
  static const Color textYellow = Color(0xFFE2AE25); // "ISHARA" logo text color
  static const Color textWhite = Colors.white;

  // Background Colors
  static const Color cardBackground = Color(0xFFFCF6EA); // Cream/Beige
  static const Color buttonPrimary = Color(0xFF3B567D);
  static const Color buttonSecondary = Color(0xFFBDD2CE); // Light Teal
}

class AppConstants {
  static const double borderRadius = 40.0;
  static const double fieldBorderRadius = 32.0;
  static const double buttonBorderRadius = 24.0;
  static const EdgeInsets defaultPadding = EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0);
}
