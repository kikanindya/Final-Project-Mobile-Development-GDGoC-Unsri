import 'package:flutter/material.dart';

class AppTheme {
  static const yellow = Color(0xFFFFD447);
  static const gold = Color(0xFFECC236);
  static const amber = Color(0xFF735C00);
  static const brown = Color(0xFF2C1600);
  static const darkBrown = Color(0xFF1E1C12);
  static const muted = Color(0xFF7F7662);

  static const cream50 = Color(0xFFFFFDFA);
  static const cream100 = Color(0xFFFFF9EC);
  static const cream200 = Color(0xFFFAF3E2);
  static const cream300 = Color(0xFFF4EDDD);

  static const nightBg = Color(0xFF12151E);
  static const nightCard = Color(0xFF1A1F2C);
  static const nightElevated = Color(0xFF242B3D);
  static const nightBorder = Color(0xFF2F374E);
  static const nightText = Color(0xFFF2F4F8);
  static const nightMuted = Color(0xFF9BA4B5);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: cream100,
        colorScheme: ColorScheme.fromSeed(
          seedColor: yellow,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: cream100,
          foregroundColor: brown,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cream100,
          border: _border(cream300),
          enabledBorder: _border(cream300),
          focusedBorder: _border(yellow, width: 2),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: nightBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: yellow,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: nightBg,
          foregroundColor: nightText,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: nightBg,
          border: _border(nightBorder),
          enabledBorder: _border(nightBorder),
          focusedBorder: _border(yellow, width: 2),
        ),
      );

  static OutlineInputBorder _border(
    Color color, {
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}