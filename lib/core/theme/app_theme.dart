import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  // ══════════════════════════════════════════════════════════════════════════
  // ── 1. DARK THEME (Approved, Preserved) ──────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════
  static ThemeData get darkTheme {
    final baseFont = GoogleFonts.inter();

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: baseFont.fontFamily,
      fontFamilyFallback: [
        'Segoe UI',
        'Roboto',
        'system-ui',
        'sans-serif',
      ],
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.darkPrimary,
      canvasColor: AppColors.darkSurface,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        onPrimary: Color(0xFF041E17),
        secondary: AppColors.darkCyan,
        onSecondary: Color(0xFF021B24),
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.darkError,
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(
        baseFont,
        AppColors.darkTextPrimary,
        AppColors.darkTextSecondary,
        AppColors.darkTextMuted,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSidebarBg,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.darkCardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkCardBorder,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkInputBg,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.darkInputBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.darkInputBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.darkPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.darkError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.darkError, width: 1.5),
        ),
        hintStyle: TextStyle(
          color: AppColors.darkTextDim,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceElevated,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.darkCardBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        textStyle: TextStyle(color: AppColors.darkTextPrimary, fontSize: 12),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── 2. LIGHT THEME (Clean Enterprise DevOps SaaS) ───────────────────────
  // ══════════════════════════════════════════════════════════════════════════
  static ThemeData get lightTheme {
    final baseFont = GoogleFonts.inter();

    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      fontFamily: baseFont.fontFamily,
      fontFamilyFallback: [
        'Segoe UI',
        'Roboto',
        'system-ui',
        'sans-serif',
      ],
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.lightPrimary,
      canvasColor: AppColors.lightSurface,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimary,
        onPrimary: Colors.white,
        secondary: AppColors.lightCyan,
        onSecondary: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.lightError,
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(
        baseFont,
        AppColors.lightTextPrimary,
        AppColors.lightTextSecondary,
        AppColors.lightTextMuted,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSidebarBg,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.lightCardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightCardBorder,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightInputBg,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.lightInputBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.lightInputBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.lightPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.lightError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.lightError, width: 1.5),
        ),
        hintStyle: TextStyle(
          color: AppColors.lightTextDim,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.lightTextPrimary,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        textStyle: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  static TextTheme _buildTextTheme(
    TextStyle baseFont,
    Color textPrimary,
    Color textSecondary,
    Color textMuted,
  ) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: baseFont.fontFamily,
        color: textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
      headlineMedium: TextStyle(
        fontFamily: baseFont.fontFamily,
        color: textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      headlineSmall: TextStyle(
        fontFamily: baseFont.fontFamily,
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      titleLarge: TextStyle(
        fontFamily: baseFont.fontFamily,
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(
        fontFamily: baseFont.fontFamily,
        color: textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      titleSmall: TextStyle(
        fontFamily: baseFont.fontFamily,
        color: textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        fontFamily: baseFont.fontFamily,
        color: textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        fontFamily: baseFont.fontFamily,
        color: textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        fontFamily: baseFont.fontFamily,
        color: textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        fontFamily: baseFont.fontFamily,
        color: textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelSmall: TextStyle(
        fontFamily: baseFont.fontFamily,
        color: textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      ),
    );
  }
}
