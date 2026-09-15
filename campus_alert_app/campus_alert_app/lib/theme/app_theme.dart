import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colour + type tokens, kept in one place so they match the UI/UX mockups
/// exactly (see campus-alert-ui-ux.html for the visual reference).
class AppColors {
  static const ink = Color(0xFF10192E);
  static const inkSoft = Color(0xFF4B5768);
  static const paper = Color(0xFFF5F2EC);
  static const card = Color(0xFFFFFFFF);
  static const line = Color(0xFFE4DFD3);
  static const alert = Color(0xFFD8432B);
  static const alertDark = Color(0xFFB33420);
  static const safe = Color(0xFF2E7D5B);
  static const gold = Color(0xFFC7962B);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.alert,
        primary: AppColors.alert,
        secondary: AppColors.ink,
        surface: AppColors.card,
      ),
      textTheme: GoogleFonts.ibmPlexSansTextTheme().copyWith(
        displayLarge: GoogleFonts.fraunces(
          fontWeight: FontWeight.w600,
          fontSize: 26,
          color: AppColors.ink,
        ),
        displayMedium: GoogleFonts.fraunces(
          fontWeight: FontWeight.w600,
          fontSize: 19,
          color: AppColors.ink,
        ),
        bodyMedium: GoogleFonts.ibmPlexSans(
          fontSize: 13.5,
          color: AppColors.inkSoft,
        ),
        labelSmall: GoogleFonts.ibmPlexMono(
          fontSize: 10.5,
          letterSpacing: .08,
          color: AppColors.inkSoft,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.alert,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }
}
