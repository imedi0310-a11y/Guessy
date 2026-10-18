import 'package:flutter/material.dart';

/// "Midnight Gold" palette.
class C {
  static const bg = Color(0xFF0D0B1E);
  static const bgTop = Color(0xFF1E1550);
  static const surface = Color(0xFF17132F);
  static const surface2 = Color(0xFF231C47);
  static const gold = Color(0xFFF5C451);
  static const goldLight = Color(0xFFFFE6A3);
  static const goldDeep = Color(0xFFD9972B);
  static const yellow = gold;
  static const pink = Color(0xFFFF6B9A);
  static const violet = Color(0xFF8B5CF6);
  static const green = Color(0xFF4BE3A6);
  static const muted = Color(0xFFA7A1C9);
  static const glass = Color(0x0FFFFFFF); // ~6% white
  static const glassBorder = Color(0x1FFFFFFF); // ~12% white
  static const ink = Color(0xFF14102B);

  static const goldGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, gold, goldDeep],
  );
  static const roseGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF8FB3), pink, Color(0xFFB04BF5)],
  );
  static const greenGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8BF5CB), green, Color(0xFF1FA77A)],
  );
}

const appFont = 'Tajawal';

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: C.gold,
    brightness: Brightness.dark,
    surface: C.surface,
    primary: C.gold,
    secondary: C.pink,
  );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: appFont);
  return base.copyWith(
    scaffoldBackgroundColor: C.bg,
    textTheme: base.textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white, fontFamily: appFont),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: C.surface2,
      contentTextStyle: const TextStyle(fontFamily: appFont, color: Colors.white, fontSize: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: C.glassBorder)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: C.surface2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: C.glassBorder)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: C.surface, showDragHandle: true),
  );
}
