import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppColorSchemes {
  static final dark =
      ColorScheme.fromSeed(
        seedColor: AppColors.seed,
        brightness: Brightness.dark,
      ).copyWith(
        surface: const Color(0xFF13131A),
        surfaceContainerHighest: const Color(0xFF202028),
      );
}
