import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppFonts {
  static const String poppins = 'Poppins'; // Join screen
  static const String urbanist = 'Urbanist'; // chat + identity screens
}

/// Every text style of the app, measured from the Figma frames.
abstract final class AppText {
  // ---- Join ----
  static const TextStyle joinTitle = TextStyle(
    fontFamily: AppFonts.poppins,
    fontSize: 30,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textPrimary,
  );
  static const TextStyle joinSubtitle = TextStyle(
    fontFamily: AppFonts.poppins,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.55,
    color: AppColors.joinSubtitle,
  );
  static const TextStyle joinDigit = TextStyle(
    fontFamily: AppFonts.poppins,
    fontSize: 30,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: AppColors.textPrimary,
  );
  static const TextStyle link = TextStyle(
    fontFamily: AppFonts.poppins,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.lime,
  );
  static const TextStyle error = TextStyle(
    fontFamily: AppFonts.poppins,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.error,
  );

  // ---- Header ----
  static const TextStyle roomTitle = TextStyle(
    fontFamily: AppFonts.urbanist,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );
  static const TextStyle roomSubtitle = TextStyle(
    fontFamily: AppFonts.urbanist,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textMuted,
  );

  // ---- Identity reveal ----
  static const TextStyle revealLabel = TextStyle(
    fontFamily: AppFonts.urbanist,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );
  static const TextStyle revealName = TextStyle(
    fontFamily: AppFonts.urbanist,
    fontSize: 56,
    fontWeight: FontWeight.w800,
    height: 1.07,
    color: Colors.white, // replaced by the gradient shader
  );
  static const TextStyle revealBody = TextStyle(
    fontFamily: AppFonts.urbanist,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: AppColors.revealBody,
  );
  static const TextStyle button = TextStyle(
    fontFamily: AppFonts.urbanist,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.onLime,
  );

  // ---- Chat ----
  static const TextStyle sender = TextStyle(
    fontFamily: AppFonts.urbanist,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.textPrimary,
  );
  static const TextStyle message = TextStyle(
    fontFamily: AppFonts.urbanist,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.33,
    color: Color(0xFFE8EAF0),
  );
  static const TextStyle time = TextStyle(
    fontFamily: AppFonts.urbanist,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.textMuted,
  );
  static const TextStyle dateChip = TextStyle(
    fontFamily: AppFonts.urbanist,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );
  static const TextStyle composer = TextStyle(
    fontFamily: AppFonts.urbanist,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  static const TextStyle composerHint = TextStyle(
    fontFamily: AppFonts.urbanist,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPlaceholder,
  );
}
