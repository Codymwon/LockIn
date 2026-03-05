import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Core palette from Framework
  static const background = Color(0xFF0F0A1A);
  static const surface = Color(0xFF1A0F2E);
  static const surfaceLight = Color(0xFF241845);
  static const primary = Color(0xFF7C4DFF);
  static const accent = Color(0xFFBB86FC);
  static const textPrimary = Color(0xFFEDE7F6);
  static const textSecondary = Color(0xFFB0A3C7);
  static const warning = Color(0xFFFF5370);
  static const success = Color(0xFF69F0AE);
  static const cardBorder = Color(0x337C4DFF);
  static const glowPurple = Color(0x557C4DFF);
  static const gradientMid = Color(0xFF12082A);
}

/// Premium AMOLED pure-black palette — same accents, black backgrounds.
class AppColorsAmoled {
  static const background = Color(0xFF000000);
  static const surface = Color(0xFF0A0A0F);
  static const surfaceLight = Color(0xFF121218);
  static const primary = Color(0xFF7C4DFF);
  static const accent = Color(0xFFBB86FC);
  static const textPrimary = Color(0xFFEDE7F6);
  static const textSecondary = Color(0xFF9E93B8);
  static const warning = Color(0xFFFF5370);
  static const success = Color(0xFF69F0AE);
  static const cardBorder = Color(0x227C4DFF);
  static const glowPurple = Color(0x337C4DFF);
  static const gradientMid = Color(0xFF000000);
}

/// Helper to get the right color set based on AMOLED mode.
class AppColorScheme {
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color primary;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color warning;
  final Color success;
  final Color cardBorder;
  final Color glowPurple;
  final Color gradientMid;

  const AppColorScheme._({
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.primary,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.warning,
    required this.success,
    required this.cardBorder,
    required this.glowPurple,
    required this.gradientMid,
  });

  static const standard = AppColorScheme._(
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceLight: AppColors.surfaceLight,
    primary: AppColors.primary,
    accent: AppColors.accent,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    warning: AppColors.warning,
    success: AppColors.success,
    cardBorder: AppColors.cardBorder,
    glowPurple: AppColors.glowPurple,
    gradientMid: AppColors.gradientMid,
  );

  static const amoled = AppColorScheme._(
    background: AppColorsAmoled.background,
    surface: AppColorsAmoled.surface,
    surfaceLight: AppColorsAmoled.surfaceLight,
    primary: AppColorsAmoled.primary,
    accent: AppColorsAmoled.accent,
    textPrimary: AppColorsAmoled.textPrimary,
    textSecondary: AppColorsAmoled.textSecondary,
    warning: AppColorsAmoled.warning,
    success: AppColorsAmoled.success,
    cardBorder: AppColorsAmoled.cardBorder,
    glowPurple: AppColorsAmoled.glowPurple,
    gradientMid: AppColorsAmoled.gradientMid,
  );

  static AppColorScheme of(bool isAmoled) => isAmoled ? amoled : standard;
}

class AppTheme {
  static ThemeData get darkTheme => _buildTheme(AppColorScheme.standard);
  static ThemeData get amoledTheme => _buildTheme(AppColorScheme.amoled);

  static ThemeData _buildTheme(AppColorScheme c) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: c.background,
      colorScheme: ColorScheme.dark(
        primary: c.primary,
        secondary: c.accent,
        surface: c.surface,
        error: c.warning,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: c.textPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          displayLarge: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w800,
            color: c.textPrimary,
            letterSpacing: -1.5,
          ),
          displayMedium: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
            letterSpacing: -1,
          ),
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: c.textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: c.textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: c.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: c.textSecondary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: c.textSecondary,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: c.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.surface,
        selectedItemColor: c.primary,
        unselectedItemColor: c.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: c.cardBorder, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
