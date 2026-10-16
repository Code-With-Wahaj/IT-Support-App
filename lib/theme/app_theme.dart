import 'package:flutter/material.dart';

class AppTheme {
  // Modern Enterprise Slate & Indigo-Cyan Palette
  static const Color primaryColor = Color(0xFF0F172A);    // Slate 900
  static const Color primaryLight = Color(0xFF1E293B);    // Slate 800
  static const Color accentColor = Color(0xFF0EA5E9);     // Sky 500
  static const Color accentGlow = Color(0xFF38BDF8);      // Sky 400
  static const Color secondaryColor = Color(0xFF6366F1);  // Indigo 500

  // Semantic Status Colors
  static const Color successColor = Color(0xFF10B981);    // Emerald 500
  static const Color errorColor = Color(0xFFEF4444);      // Rose 500
  static const Color warningColor = Color(0xFFF59E0B);    // Amber 500
  static const Color infoColor = Color(0xFF3B82F6);       // Blue 500

  // Clean Surface Colors
  static const Color backgroundColor = Color(0xFFF1F5F9); // Slate 100
  static const Color cardColor = Colors.white;
  static const Color surfaceColor = Color(0xFFF8FAFC);    // Slate 50
  static const Color borderColor = Color(0xFFE2E8F0);     // Slate 200

  // Typography Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);

  static const Color statusPending = Color(0xFFEF4444);
  static const Color statusInProgress = Color(0xFFF59E0B);
  static const Color statusResolved = Color(0xFF10B981);
  static const Color statusWaiting = Color(0xFF14B8A6);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      tertiary: secondaryColor,
      error: errorColor,
      surface: cardColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      onError: Colors.white,
      surfaceContainerHighest: surfaceColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borderColor, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceColor,
      selectedColor: accentColor.withOpacity(0.15),
      secondarySelectedColor: accentColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textSecondary,
      ),
      secondaryLabelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: accentColor,
      ),
      side: const BorderSide(color: borderColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          letterSpacing: 0.3,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      labelStyle: const TextStyle(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
      hintStyle: const TextStyle(color: textTertiary, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryColor,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static Color getStatusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'resolved':
        return statusResolved;
      case 'in progress':
      case 'inprogress':
        return statusInProgress;
      case 'pending':
        return statusPending;
      case 'waiting approval':
        return statusWaiting;
      default:
        return textSecondary;
    }
  }
}
