import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static const String arabicFont = 'Noto Naskh Arabic';
  static const String latinFont = 'Poppins';

  static TextTheme get textTheme => const TextTheme(
        displayLarge: TextStyle(
          fontFamily: arabicFont,
          fontSize: 32,
          height: 40 / 32,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: TextStyle(
          fontFamily: arabicFont,
          fontSize: 24,
          height: 32 / 24,
          fontWeight: FontWeight.w600,
        ),
        displaySmall: TextStyle(
          fontFamily: arabicFont,
          fontSize: 20,
          height: 28 / 20,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: TextStyle(
          fontFamily: arabicFont,
          fontSize: 18,
          height: 26 / 18,
          fontWeight: FontWeight.w400,
        ),
        headlineMedium: TextStyle(
          fontFamily: arabicFont,
          fontSize: 16,
          height: 24 / 16,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: TextStyle(
          fontFamily: arabicFont,
          fontSize: 14,
          height: 20 / 14,
          fontWeight: FontWeight.w400,
        ),
        titleMedium: TextStyle(
          fontFamily: arabicFont,
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w400,
        ),
        bodyLarge: TextStyle(
          fontFamily: arabicFont,
          fontSize: 18,
          height: 26 / 18,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          fontFamily: arabicFont,
          fontSize: 16,
          height: 24 / 16,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: TextStyle(
          fontFamily: latinFont,
          fontSize: 20,
          height: 24 / 20,
          fontWeight: FontWeight.w600,
        ),
      );
}
