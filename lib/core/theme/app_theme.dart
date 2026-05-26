import 'package:flutter/material.dart';

import 'app_color_schemes.dart';

abstract final class AppTheme {
  static ThemeData get darkTheme {
    final colorScheme = AppColorSchemes.dark;

    return ThemeData(
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      useMaterial3: true,
      visualDensity: VisualDensity.compact,
      scaffoldBackgroundColor: Colors.transparent,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.surface,
        contentTextStyle: TextStyle(color: colorScheme.onSurface),
      ),
      chipTheme: ChipThemeData.fromDefaults(
        brightness: Brightness.dark,
        secondaryColor: colorScheme.primary,
        labelStyle: TextStyle(color: colorScheme.onSurface),
      ),
    );
  }
}
