import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color background   = Color(0xFF0A0F1C);
  static const Color surface      = Color(0xFF141B27);
  static const Color surfaceCard  = Color(0xFF1A2234);
  static const Color surfaceInput = Color(0xFF1E2D3E);
  static const Color border       = Color(0xFF2A3A4E);

  static const Color primary      = Color(0xFF00BFA5);
  static const Color primaryDark  = Color(0xFF009688);

  static const Color textPrimary   = Color(0xFFEEF2F7);
  static const Color textSecondary = Color(0xFF8A9BB0);

  static const Color cyanLine = Color(0xFF00E5FF);
  static const Color redLine  = Color(0xFFFF4569);

  static const Color green = Color(0xFF4CAF50);
  static const Color amber = Color(0xFFFFC107);
  static const Color red   = Color(0xFFEF5350);
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.primary,
      error: AppColors.red,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    cardTheme: const CardThemeData(
      color: AppColors.surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border),
  );
}
