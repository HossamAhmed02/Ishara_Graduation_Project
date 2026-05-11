import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ishara/core/constants/constants.dart';

class AppTheme {
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent, // Gradient background on Scaffold
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.gradientEnd),
      textTheme: GoogleFonts.montserratTextTheme().copyWith(
        headlineLarge: GoogleFonts.merriweather(
          color: AppColors.textYellow,
          fontSize: 40,
          fontWeight: FontWeight.w900,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 5,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  static BoxDecoration get gradientBackground {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
           AppColors.gradientStart,
           AppColors.gradientMiddle,
           AppColors.gradientEnd,
        ],
        stops: [0.0, 0.4, 1.0],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
    );
  }

  static BoxDecoration gradientWithRadius({double radius = 30}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          AppColors.gradientStart,
          AppColors.gradientMiddle,
          AppColors.gradientEnd,
        ],
        stops: [0.0, 0.4, 1.0],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(radius),
      ),
    );
  }
}
