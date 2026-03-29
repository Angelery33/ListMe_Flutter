import 'package:flutter/material.dart';

/// Centraliza la construcción de temas de widgets específicos (Cards, Botones, Inputs, Chips).
class WidgetThemes {
  WidgetThemes._();

  static AppBarTheme appBarTheme(ColorScheme scheme, bool isDark, bool isTitanium) {
    return AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: isTitanium ? (isDark ? Colors.white : Colors.black) : Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    );
  }

  static CardThemeData cardTheme(ColorScheme scheme, bool isDark) {
    return CardThemeData(
      elevation: isDark ? 6 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? scheme.surface : scheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      surfaceTintColor: isDark ? Colors.white10 : Colors.black12,
    );
  }

  static InputDecorationTheme inputDecorationTheme(ColorScheme scheme, bool isDark) {
    return InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
    );
  }

  static ElevatedButtonThemeData elevatedButtonTheme(ColorScheme scheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  static ChipThemeData chipTheme(ColorScheme scheme) {
    return ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      side: BorderSide.none,
      backgroundColor: scheme.surfaceContainerHighest,
    );
  }
}
