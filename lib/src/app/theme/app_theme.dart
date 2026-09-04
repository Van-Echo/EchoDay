import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color _lightCanvas = Color(0xFFF7F4EF);
  static const Color _lightSurface = Color(0xFFFFFEFA);
  static const Color _lightInk = Color(0xFF30342F);
  static const Color _lightPrimary = Color(0xFF788C77);

  static const Color _darkCanvas = Color(0xFF181B19);
  static const Color _darkSurface = Color(0xFF202420);
  static const Color _darkInk = Color(0xFFE8ECE7);
  static const Color _darkPrimary = Color(0xFF9FB19E);

  static ThemeData get light => lightWith(_lightPrimary);

  static ThemeData lightWith(Color primary) => _build(
    brightness: Brightness.light,
    canvas: _lightCanvas,
    surface: _lightSurface,
    ink: _lightInk,
    primary: primary,
  );

  static ThemeData get dark => darkWith(_darkPrimary);

  static ThemeData darkWith(Color primary) => _build(
    brightness: Brightness.dark,
    canvas: _darkCanvas,
    surface: _darkSurface,
    ink: _darkInk,
    primary: primary,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color canvas,
    required Color surface,
    required Color ink,
    required Color primary,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    ).copyWith(primary: primary, surface: surface, onSurface: ink);

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'EchoDaySans',
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: canvas,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.16),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.16),
      ),
      dividerColor: brightness == Brightness.light
          ? const Color(0xFFDEDCD5)
          : const Color(0xFF343934),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
