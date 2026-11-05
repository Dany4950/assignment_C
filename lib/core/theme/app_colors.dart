import 'package:flutter/material.dart';

/// Colours sampled from the Figma frames. Eyedrop them in Dev Mode to confirm;
/// they live in this one file so a correction is a one-line change.
abstract final class AppColors {
  static const Color joinBackground = Color(0xFF09090B);
  static const Color chatBackground = Color(0xFF0A0A0C);

  static const Color lime = Color(0xFFB3E55B);
  static const Color limeGlow = Color(0x59B3E55B);
  static const Color gradientTop = Color(0xFFF2E55C);
  static const Color gradientBottom = Color(0xFFB3E55B);
  static const Color onLime = Color(0xFF10140A);

  static const Color surface = Color(0xFF111827); // reveal card, incoming bubble, composer
  static const Color circleButton = Color(0xFF1F2937); // back button, date chip

  static const Color keyCircle = Color(0xFF232325);
  static const Color codeBox = Color(0xFF29292B);
  static const Color codeDash = Color(0xFFAFAFB4);
  static const Color joinSubtitle = Color(0xFFA0A0A8);

  static const Color textPrimary = Colors.white;
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textPlaceholder = Color(0xFF6B7280);
  static const Color revealBody = Color(0xFFD5D8E0);

  static const Color error = Color(0xFFF87171);
}
