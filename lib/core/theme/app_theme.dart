import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: AppFonts.urbanist,
        scaffoldBackgroundColor: AppColors.chatBackground,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.lime,
          onPrimary: AppColors.onLime,
          surface: AppColors.chatBackground,
          onSurface: AppColors.textPrimary,
          error: AppColors.error,
        ),
        splashFactory: InkRipple.splashFactory,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.lime,
          selectionColor: Color(0x55B3E55B),
          selectionHandleColor: AppColors.lime,
        ),
      );
}
