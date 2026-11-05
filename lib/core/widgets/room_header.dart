import 'package:flutter/material.dart';

import '../theme/app_text.dart';
import 'round_icon_button.dart';

/// Back button + "Room #code" / "N members" + trailing circle (Figma header).
class RoomHeader extends StatelessWidget {
  const RoomHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final Widget? trailing;

  static const double circle = 41;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RoundIconButton(
          key: const Key('room-back-button'),
          icon: Icons.chevron_left_rounded,
          semanticLabel: 'Back',
          onPressed: onBack,
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppText.roomTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(subtitle ?? ' ', style: AppText.roomSubtitle),
            ],
          ),
        ),
        SizedBox(
          width: circle,
          height: circle,
          child: trailing ?? const _BlackCircle(),
        ),
      ],
    );
  }
}

class _BlackCircle extends StatelessWidget {
  const _BlackCircle();

  @override
  Widget build(BuildContext context) =>
      const DecoratedBox(decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle));
}

/// Avatar in the header's right circle: network image, falls back to the plain
/// black circle from the design (also what you see offline).
class HeaderAvatar extends StatelessWidget {
  const HeaderAvatar({super.key, this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final u = url;
    if (u == null || u.isEmpty) return const _BlackCircle();
    return ClipOval(
      child: Image.network(
        u,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => const _BlackCircle(),
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : const _BlackCircle(),
      ),
    );
  }
}
