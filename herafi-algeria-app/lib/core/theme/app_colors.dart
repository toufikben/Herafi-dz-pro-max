import 'package:flutter/material.dart';

/// نظام الألوان الموحد لتطبيق حرفي الجزائر
/// تصميم عصري متناسق مستوحى من الألوان الجزائرية مع لمسة احترافية
class AppColors {
  AppColors._();

  // Primary - Emerald Teal (احترافي + أخضر الجزائر)
  static const Color primary = Color(0xFF0D9488);       // Teal 600
  static const Color primaryLight = Color(0xFF14B8A6);  // Teal 500
  static const Color primaryDark = Color(0xFF0F766E);   // Teal 700
  static const Color primarySurface = Color(0xFFCCFBF1); // Teal 100

  // Secondary - Warm Amber
  static const Color secondary = Color(0xFFF59E0B);     // Amber 500
  static const Color secondaryLight = Color(0xFFFBBF24);
  static const Color secondaryDark = Color(0xFFD97706);

  // Accent
  static const Color accent = Color(0xFF6366F1);        // Indigo 500
  static const Color accentLight = Color(0xFF818CF8);

  // Neutral
  static const Color background = Color(0xFFF8FAFC);    // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate 100
  static const Color card = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);   // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textTertiary = Color(0xFF94A3B8);  // Slate 400
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF10B981);       // Emerald 500
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);         // Red 500
  static const Color info = Color(0xFF3B82F6);          // Blue 500

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);        // Slate 200
  static const Color divider = Color(0xFFF1F5F9);

  // Rating
  static const Color star = Color(0xFFFBBF24);
  static const Color starEmpty = Color(0xFFCBD5E1);

  // Dark Theme
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D9488), Color(0xFF134E4A)],
  );
}
