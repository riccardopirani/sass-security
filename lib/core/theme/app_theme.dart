import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _surface = Color(0xFF111827);
  static const _surfaceSoft = Color(0xFF1F2937);
  static const _border = Color(0xFF374151);
  static const _accent = Color(0xFF14B8A6);
  static const _accent2 = Color(0xFF0EA5E9);

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.spaceGroteskTextTheme(
      base.textTheme,
    ).apply(bodyColor: Colors.white, displayColor: Colors.white);

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF030712),
      colorScheme: const ColorScheme.dark(
        primary: _accent,
        secondary: _accent2,
        surface: _surface,
        onSurface: Colors.white,
        error: Color(0xFFF43F5E),
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _accent),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      chipTheme: base.chipTheme.copyWith(
        side: const BorderSide(color: _border),
        backgroundColor: _surfaceSoft,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
