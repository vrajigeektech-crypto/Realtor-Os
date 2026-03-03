import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─────────────────────────────────────────────────
/// AppTheme — Single source of truth for colours,
/// typography, and shared decorations.
/// ─────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  // ── Colours ──────────────────────────────────────
  static const Color bgDeep       = Color(0xFF080808);
  static const Color bgCard       = Color(0xFF111111);
  static const Color bgCardHover  = Color(0xFF181818);
  static const Color bgSidebar    = Color(0xFF0C0C0C);
  static const Color borderColor  = Color(0xFF242424);
  static const Color borderAccent = Color(0xFF2A241E);

  static const Color accent       = Color(0xFFCA8A5A);   // warm orange/gold
  static const Color accentDim    = Color(0xFF7A5636);
  static const Color accentGlow   = Color(0x33CA8A5A);

  static const Color textPrimary   = Color(0xFFEEEEEE);
  static const Color textSecondary = Color(0xFF909090);
  static const Color textMuted     = Color(0xFF555555);

  // ── ThemeData ─────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDeep,
    cardColor: bgCard,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      secondary: accentDim,
      surface: bgCard,
      onPrimary: Colors.white,
      onSurface: textPrimary,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    dividerColor: borderColor,
  );

  // ── Shared decorations ────────────────────────────
  static BoxDecoration cardDecoration({double radius = 16}) => BoxDecoration(
    color: bgCard,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: borderAccent, width: 1),
    boxShadow: const [
      BoxShadow(color: Color(0x55000000), blurRadius: 18, offset: Offset(0, 4)),
    ],
  );

  static BoxDecoration glassDecoration({double radius = 16}) => BoxDecoration(
    color: Color(0x18FFFFFF),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Color(0x22FFFFFF), width: 1),
    boxShadow: const [
      BoxShadow(color: Color(0x44000000), blurRadius: 24, offset: Offset(0, 6)),
    ],
  );

  static LinearGradient get accentGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentDim],
  );
}
