import 'package:flutter/material.dart';

class AppTheme {
  static const Color forest = Color(0xFF14594A);
  static const Color paper = Color(0xFFF7F5EF);
  static const Color ink = Color(0xFF20241F);
  static const Color gold = Color(0xFFD99A2B);
  static const Color line = Color(0xFFE3DFD3);
  static const Color darkCard = Color(0xFF2B2B28);

  static ThemeData get lightTheme => _bangun(Brightness.light);
  static ThemeData get darkTheme => _bangun(Brightness.dark);

  static ThemeData _bangun(Brightness brightness) {
    final gelap = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: forest,
      brightness: brightness,
    ).copyWith(
      primary: gelap ? const Color(0xFF8FD3BC) : forest,
      onPrimary: gelap ? const Color(0xFF06231C) : Colors.white,
      secondary: gelap ? const Color(0xFFE8C275) : gold,
      onSecondary: gelap ? const Color(0xFF2B1F05) : ink,
      surface: gelap ? const Color(0xFF141713) : paper,
      onSurface: gelap ? const Color(0xFFEDEDE6) : ink,
      outlineVariant: gelap ? const Color(0xFF3A3F38) : line,
    );

    final kartu = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: BorderSide(color: scheme.outlineVariant),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: gelap ? darkCard : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: kartu,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: scheme.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: gelap ? const Color(0xFF1E211D) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: gelap ? darkCard : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: gelap ? const Color(0xFFEDEDE6) : ink,
        contentTextStyle: TextStyle(
          color: gelap ? ink : Colors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
      ),
    );
  }
}
