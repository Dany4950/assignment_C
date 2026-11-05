import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Vertical yellow -> lime gradient over a (multi-line) text block.
class GradientText extends StatelessWidget {
  const GradientText(this.text, {super.key, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.gradientTop, AppColors.gradientBottom],
      ).createShader(bounds),
      child: Text(text, textAlign: TextAlign.center, style: style),
    );
  }
}
