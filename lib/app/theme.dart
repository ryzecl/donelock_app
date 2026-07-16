import 'package:flutter/material.dart';

class NeoBrutalistTheme {
  static ThemeData get light {
    const primaryColor = Color(0xFF000000);
    const bgColor = Color(0xFFF4F4F0);
    const surfaceColor = Color(0xFFFFFFFF);
    const accentColor = Color(0xFFFFD073); // Neo Yellow

    return ThemeData(
      fontFamily: 'monospace',
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: bgColor, // Scaffold background
        onSurface: primaryColor,
        error: Color(0xFFEF4444),
      ),
      scaffoldBackgroundColor: bgColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: primaryColor,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: primaryColor, width: 3),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            letterSpacing: 1,
            fontSize: 16,
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            letterSpacing: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryColor, width: 3),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryColor, width: 3),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryColor, width: 4),
          borderRadius: BorderRadius.circular(12),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'monospace',
          color: primaryColor,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: primaryColor, width: 3),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: primaryColor,
        thickness: 3,
        space: 0,
      ),
    );
  }
}
