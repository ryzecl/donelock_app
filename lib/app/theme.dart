import 'package:flutter/material.dart';

class BrutalistTheme {
  static ThemeData get light {
    const primaryColor = Color(0xFF0D0D0D);
    const bgColor = Color(0xFFF5F5F0);
    const surfaceColor = Color(0xFFFFFFFF);


    return ThemeData(
      fontFamily: 'monospace',
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        surface: bgColor, // Scaffold background
        onSurface: primaryColor,
        error: const Color(0xFFEF4444),
      ),
      scaffoldBackgroundColor: bgColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: primaryColor,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: surfaceColor,
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 3),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            letterSpacing: 2,
            fontSize: 16,
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            letterSpacing: 1,
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.zero,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.zero,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 3),
          borderRadius: BorderRadius.zero,
        ),
        labelStyle: TextStyle(
          fontFamily: 'monospace',
          color: primaryColor,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: const CardThemeData(
        color: surfaceColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.zero,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: primaryColor,
        thickness: 2,
        space: 0,
      ),
    );
  }
}
