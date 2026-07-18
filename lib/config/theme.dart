import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color seed = Color(0xFF2E7D32);
  static const Color bajo = Color(0xFF2E7D32);
  static const Color medio = Color(0xFFF9A825);
  static const Color alto = Color(0xFFC62828);
  static const Color surfaceTint = Color(0xFFE8F5E9);

  static Color riesgo(String nivel) {
    switch (nivel) {
      case 'Alto':
        return alto;
      case 'Medio':
        return medio;
      default:
        return bajo;
    }
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF7FAF7),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: scheme.primaryContainer,
      ),
    );
  }
}
