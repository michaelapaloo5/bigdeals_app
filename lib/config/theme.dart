import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color gold = Color(0xFFD4A000);
  static const Color goldLight = Color(0xFFF5C842);
  static const Color goldPale = Color(0xFFFFF8E1);
  static const Color dark = Color(0xFF0D0D1A);
  static const Color surface = Color(0xFF121218);
  static const Color surfaceLight = Color(0xFF1A1A24);
  static const Color cardBg = Color(0xFF1E1E2A);
  static const Color textPrimary = Color(0xFFE4E4EC);
  static const Color textSecondary = Color(0xFF8A8A98);
  static const Color accent = Color(0xFF6366F1);
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFE03E3E);
  static const Color border = Color(0xFF2A2A36);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: dark,
      primaryColor: gold,
      colorScheme: const ColorScheme.dark(
        primary: gold,
        secondary: goldLight,
        surface: surface,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: dark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.clashDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      cardTheme: CardTheme(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: dark,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: gold, width: 2),
        ),
        hintStyle: const TextStyle(color: textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
