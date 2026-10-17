import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GestaltTheme {
  // Official Pinterest Brand Colors
  static const Color pinterestRed = Color(0xFFE60023);
  static const Color darkRed = Color(0xFFB6001B);
  static const Color softGrey = Color(0xFFEFEFEF);
  static const Color hoverGrey = Color(0xFFE2E2E2);
  static const Color textDark = Color(0xFF111111);
  static const Color textMuted = Color(0xFF767676);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);

  // Border Radii
  static const double cardRadius = 16.0;
  static const double pillRadius = 24.0;
  static const double buttonRadius = 20.0;

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: pinterestRed,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: pinterestRed,
        secondary: textDark,
        surface: backgroundLight,
        onSurface: textDark,
        surfaceContainerHighest: softGrey,
      ),
      textTheme: GoogleFonts.interTightTextTheme().copyWith(
        displayLarge: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: textDark, letterSpacing: -0.5),
        headlineMedium: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textDark),
        titleLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textDark),
        titleMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textDark),
        bodyLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textDark),
        bodyMedium: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: textDark),
        bodySmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textMuted),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textDark),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundLight,
        selectedItemColor: textDark,
        unselectedItemColor: textMuted,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: pinterestRed,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: pinterestRed,
        secondary: Colors.white,
        surface: backgroundDark,
        onSurface: Colors.white,
        surfaceContainerHighest: cardDark,
      ),
      textTheme: GoogleFonts.interTightTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
    );
  }
}
