import 'package:flutter/material.dart';

class AppStyles {
  static const Color cardColor = Color(0xFF1E1E1E);
  static const Color panelColor = Color(0xFF1E1E1E); // Alias
  static const Color tableColor = Color(0xFF1E1E1E);
  static const Color borderSoft = Color(0xFF3E3144);
  static const Color accentRose = Color(0xFFCE9799);
  static const Color mutedText = Color(0xFF9EA3AE);
  static const Color darkBackground = Color(0xFF141414);

  // Status Colors
  static const Color statusGreen = Color(0xFF35C86B);
  static const Color statusYellow = Colors.amber;
  static const Color statusRed = Color(0xFFE05C4D);
  static const Color copperBrush = Color(0xFFCE9799);

  // Decorations
  static BoxDecoration glassPanelDecoration = BoxDecoration(
    color: panelColor,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: borderSoft.withValues(alpha: 0.3)),
  );

  static LinearGradient copperGradient = LinearGradient(
    colors: [
      accentRose,
      accentRose.withValues(alpha: 0.8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration fidelityBackgroundDecoration() => BoxDecoration(
    color: darkBackground,
  );

  static BoxDecoration premiumCardDecoration({Color? color}) => BoxDecoration(
    color: color ?? cardColor,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: borderSoft.withValues(alpha: 0.1)),
  );
}
