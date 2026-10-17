import 'package:flutter/material.dart';

class C {
  static const bg = Color(0xFF15112B);
  static const surface = Color(0xFF221C44);
  static const surface2 = Color(0xFF2E2658);
  static const yellow = Color(0xFFFFC93C);
  static const pink = Color(0xFFFF5D8F);
  static const green = Color(0xFF3DDC97);
  static const muted = Color(0xFFA9A3CC);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: C.yellow,
    brightness: Brightness.dark,
    surface: C.surface,
    primary: C.yellow,
    secondary: C.pink,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: C.bg,
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
