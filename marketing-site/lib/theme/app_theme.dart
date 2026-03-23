import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF111827);
  static const Color text = Color(0xFFF1F5F9);
  static const Color accent = Color(0xFF00FFC2);
  static const Color mutedText = Color(0xFF9CA3AF);
  static const Color border = Color(0x33F1F5F9);
}

class AppTheme {
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.dmSansTextTheme(
      ThemeData.dark(useMaterial3: true).textTheme,
    );

    final heading = GoogleFonts.ibmPlexMono(
      color: AppColors.text,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
    );

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.accent,
        onPrimary: AppColors.background,
        onSurface: AppColors.text,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: heading.copyWith(fontSize: 64, height: 1.05),
        displayMedium: heading.copyWith(fontSize: 52, height: 1.08),
        displaySmall: heading.copyWith(fontSize: 42, height: 1.08),
        headlineLarge: heading.copyWith(fontSize: 34, height: 1.2),
        headlineMedium: heading.copyWith(fontSize: 28, height: 1.22),
        headlineSmall: heading.copyWith(fontSize: 22, height: 1.25),
        titleLarge: heading.copyWith(fontSize: 18, height: 1.3),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.text,
          height: 1.55,
          fontSize: 16,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.text,
          height: 1.5,
          fontSize: 14,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.mutedText,
          height: 1.4,
          fontSize: 12,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      dividerColor: AppColors.border,
      cardColor: Colors.white.withValues(alpha: 0.04),
    );
  }
}
