import 'package:capassignment/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// The Rumour logo (circle + key). Scales with whatever size it is given,
/// which lets it be used as a Hero between the splash and the join screen.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, required this.size});

  /// Shared Hero tag: splash logo -> join screen badge.
  static const String heroTag = 'app-logo';

  /// Export your key as a transparent PNG to this path (see pubspec).
  static const String assetPath = 'assets/images/logo_key.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: LayoutBuilder(
        // During a Hero flight the parent gives tight, changing constraints,
        // so size everything from the available space, not from [size].
        builder: (context, constraints) {
          final s = constraints.biggest.shortestSide;
          return DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.keyCircle,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                assetPath,
                width: s * 0.44,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.key_rounded, color: AppColors.lime, size: s * 0.44),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Wraps the logo in the shared Hero.
  static Widget hero({required double size}) => Hero(
        tag: heroTag,
        child: AppLogo(size: size),
      );
}