import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/day_label.dart';
import '../../domain/chat_items.dart';

/// Sender label + bubble. Mine: lime, right aligned, label "You".
/// Others: navy, left aligned, label "@BraveBadger".
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.item});

  final MessageItem item;

  static const double _maxWidth = 316;
  // Figma: incoming bubbles start 16dp from the edge, outgoing end 29dp from it.
  static const double _mineExtraRightInset = 13;

  @override
  Widget build(BuildContext context) {
    final message = item.message;
    final mine = item.isMine;
    final label = mine ? 'You' : '@${message.senderName.replaceAll(' ', '')}';

    final bubble = DecoratedBox(
      decoration: BoxDecoration(
        color: mine ? AppColors.lime : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                message.text,
                style: AppText.message.copyWith(color: mine ? AppColors.onLime : null),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Opacity(
                  opacity: message.pending ? 0.5 : 1,
                  child: Text(
                    timeLabel(message.createdAt),
                    style: AppText.time.copyWith(
                      color: mine ? AppColors.onLime.withAlpha(150) : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(
        top: item.showSender ? 12 : 4,
        right: mine ? _mineExtraRightInset : 0,
      ),
      child: Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: Column(
            crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.showSender) ...[
                Text(label, style: AppText.sender),
                const SizedBox(height: 3),
              ],
              bubble,
            ],
          ),
        ),
      ),
    );
  }
}
