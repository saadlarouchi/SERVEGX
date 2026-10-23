import 'package:flutter/material.dart';

/// SERVEGX Design System Palette
/// Supports both:
/// 1. Dark Mode: Deep obsidian surfaces, crisp 1px borders, and vibrant mint/teal accents.
/// 2. Light Mode: Clean white cards, neutral slate backgrounds (#F7F9FC), refined borders (#E2E8F0),
///    high-contrast slate typography (#0F172A / #64748B), and controlled mint/teal (#00C7A5).
class AppColors {
  /// Global theme toggle flag, kept in sync with ThemeProvider
  static bool isLight = false;

  // ══════════════════════════════════════════════════════════════════════════
  // ── 1. DARK PALETTE (Approved & Untouched) ───────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════
  static const Color darkBackground = Color(0xFF090D16);
  static const Color darkSidebarBg = Color(0xFF0C101B);
  static const Color darkSurface = Color(0xFF0F1523);
  static const Color darkSurfaceElevated = Color(0xFF141C2E);
  static const Color darkSurfaceLight = Color(0xFF172236);
  static const Color darkCardBg = Color(0xFF0F1523);
  static const Color darkCardBorder = Color(0xFF1C263A);
  static const Color darkCardBorderSubtle = Color(0xFF151D2D);
  static const Color darkCardBorderHighlight = Color(0x3300D4AA);
  static const Color darkInputBg = Color(0xFF0A0F1A);
  static const Color darkInputBorder = Color(0xFF1E2B40);
  static const Color darkPillBg = Color(0xFF141D2C);

  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);
  static const Color darkTextDim = Color(0xFF475569);

  static const Color darkPrimary = Color(0xFF00D4AA);
  static const Color darkPrimaryHover = Color(0xFF00E5B8);
  static const Color darkCyan = Color(0xFF00C2FF);
  static const Color darkMint = Color(0xFF00E5B8);
  static const Color darkPurple = Color(0xFF8B5CF6);
  static const Color darkBlue = Color(0xFF38BDF8);
  static const Color darkSuccess = Color(0xFF10B981);
  static const Color darkWarning = Color(0xFFF59E0B);
  static const Color darkError = Color(0xFFF43F5E);
  static const Color darkInfo = Color(0xFF38BDF8);

  // ══════════════════════════════════════════════════════════════════════════
  // ── 2. LIGHT PALETTE (Enterprise DevOps SaaS) ───────────────────────────
  // ══════════════════════════════════════════════════════════════════════════
  static const Color lightBackground = Color(0xFFF7F9FC); // Very light neutral background
  static const Color lightSidebarBg = Color(0xFFFFFFFF);  // Clean white sidebar
  static const Color lightSurface = Color(0xFFFFFFFF);    // Primary card/panel surface
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightSurfaceLight = Color(0xFFF1F5F9); // Secondary surface
  static const Color lightCardBg = Color(0xFFFFFFFF);     // White card surface
  static const Color lightCardBorder = Color(0xFFE2E8F0); // Subtle 1px border
  static const Color lightCardBorderSubtle = Color(0xFFEEF2F6);
  static const Color lightCardBorderHighlight = Color(0x3300C7A5);
  static const Color lightInputBg = Color(0xFFF8FAFC);
  static const Color lightInputBorder = Color(0xFFCBD5E1);
  static const Color lightPillBg = Color(0xFFF1F5F9);

  static const Color lightTextPrimary = Color(0xFF0F172A);   // Deep Slate 900
  static const Color lightTextSecondary = Color(0xFF475569); // Slate 600
  static const Color lightTextMuted = Color(0xFF64748B);     // Slate 500
  static const Color lightTextDim = Color(0xFF94A3B8);       // Slate 400

  static const Color lightPrimary = Color(0xFF00C7A5);       // Refined enterprise Mint/Teal
  static const Color lightPrimaryHover = Color(0xFF00B395);
  static const Color lightCyan = Color(0xFF0284C7);          // High-contrast Sky/Cyan 600
  static const Color lightMint = Color(0xFF00C7A5);
  static const Color lightPurple = Color(0xFF7C3AED);        // Violet 600
  static const Color lightBlue = Color(0xFF2563EB);          // Blue 600
  static const Color lightSuccess = Color(0xFF059669);       // Emerald 600
  static const Color lightWarning = Color(0xFFD97706);       // Amber 600
  static const Color lightError = Color(0xFFDC2626);         // Red 600
  static const Color lightInfo = Color(0xFF2563EB);          // Royal Blue 600

  // ══════════════════════════════════════════════════════════════════════════
  // ── 3. DYNAMIC THEME-AWARE GETTERS ───────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════
  // Brand & Accent
  static Color get primary => isLight ? lightPrimary : darkPrimary;
  static Color get primaryHover => isLight ? lightPrimaryHover : darkPrimaryHover;
  static Color get accent => primary;
  static Color get cyan => isLight ? lightCyan : darkCyan;
  static Color get mint => isLight ? lightMint : darkMint;
  static Color get teal => primary;
  static Color get secondary => isLight ? lightPurple : darkPurple;
  static Color get purple => isLight ? lightPurple : darkPurple;
  static Color get blue => isLight ? lightBlue : darkBlue;
  static Color get info => isLight ? lightInfo : darkInfo;

  // Semantic Status
  static Color get success => isLight ? lightSuccess : darkSuccess;
  static Color get green => success;
  static Color get warning => isLight ? lightWarning : darkWarning;
  static Color get orange => warning;
  static Color get error => isLight ? lightError : darkError;
  static Color get red => error;
  static Color get pink => error;

  // Surfaces & Backgrounds
  static Color get background => isLight ? lightBackground : darkBackground;
  static Color get sidebarBg => isLight ? lightSidebarBg : darkSidebarBg;
  static Color get surface => isLight ? lightSurface : darkSurface;
  static Color get surfaceElevated => isLight ? lightSurfaceElevated : darkSurfaceElevated;
  static Color get surfaceLight => isLight ? lightSurfaceLight : darkSurfaceLight;
  static Color get cardBg => isLight ? lightCardBg : darkCardBg;
  static Color get cardBorder => isLight ? lightCardBorder : darkCardBorder;
  static Color get cardBorderSubtle => isLight ? lightCardBorderSubtle : darkCardBorderSubtle;
  static Color get cardBorderHighlight => isLight ? lightCardBorderHighlight : darkCardBorderHighlight;
  static Color get inputBg => isLight ? lightInputBg : darkInputBg;
  static Color get inputBorder => isLight ? lightInputBorder : darkInputBorder;
  static Color get pillBg => isLight ? lightPillBg : darkPillBg;

  // Text Hierarchy
  static Color get textPrimary => isLight ? lightTextPrimary : darkTextPrimary;
  static Color get textSecondary => isLight ? lightTextSecondary : darkTextSecondary;
  static Color get textMuted => isLight ? lightTextMuted : darkTextMuted;
  static Color get textDim => isLight ? lightTextDim : darkTextDim;

  // Specialized Surfaces
  static Color get codeBg => isLight ? const Color(0xFFF1F5F9) : const Color(0xFF070B13);
  static Color get codeBorder => isLight ? const Color(0xFFE2E8F0) : const Color(0xFF162133);
  static Color get activeItemBg => isLight ? const Color(0xFFE6F9F5) : const Color(0xFF142426);
  static Color get tableRowHover => isLight ? const Color(0xFFF8FAFC) : const Color(0xFF121A2A);
  static Color get cardShadow => isLight ? const Color(0x0A0F172A) : Colors.transparent;

  // ── Gradients ──────────────────────────────────────────────────────────
  static LinearGradient get primaryGradient => LinearGradient(
    colors: isLight
        ? [Color(0xFF00C7A5), Color(0xFF0284C7)]
        : [Color(0xFF00E5B8), Color(0xFF00C2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get accentPillGradient => LinearGradient(
    colors: isLight
        ? [Color(0x1F00C7A5), Color(0x0F0284C7)]
        : [Color(0x1F00D4AA), Color(0x0F00C2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get heroGradient => LinearGradient(
    colors: isLight
        ? [Color(0xFFF8FAFC), Color(0xFFF1F5F9), Color(0xFFE2E8F0)]
        : [Color(0xFF090D16), Color(0xFF0D1422), Color(0xFF0A101C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get cardGradient => LinearGradient(
    colors: isLight
        ? [Color(0xFFFFFFFF), Color(0xFFFAFAFA)]
        : [Color(0xFF0F1523), Color(0xFF121A2A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
