import '../../../core/utils/day_label.dart';
import 'chat_message.dart';

sealed class ChatItem {
  const ChatItem();
}

final class MessageItem extends ChatItem {
  const MessageItem({required this.message, required this.isMine, required this.showSender});

  final ChatMessage message;
  final bool isMine;

  /// Sender name is printed above the first message of a consecutive run.
  final bool showSender;
}

final class DateItem extends ChatItem {
  const DateItem({required this.day, required this.label});

  final DateTime day;
  final String label;
}

/// [newestFirst] -> list items for a `reverse: true` ListView (index 0 = bottom).
/// A date chip is emitted AFTER the oldest message of each day, which puts it
/// visually above that day's first message.
List<ChatItem> buildChatItems({
  required List<ChatMessage> newestFirst,
  required String myMemberId,
  required DateTime now,
}) {
  final items = <ChatItem>[];
  for (var i = 0; i < newestFirst.length; i++) {
    final message = newestFirst[i];
    final older = i + 1 < newestFirst.length ? newestFirst[i + 1] : null;
    final startsNewDay = older == null || !isSameDay(older.createdAt, message.createdAt);
    final startsNewRun =
        older == null || !isSameDay(older.createdAt, message.createdAt) || older.senderId != message.senderId;

    items.add(MessageItem(
      message: message,
      isMine: message.senderId == myMemberId,
      showSender: startsNewRun,
    ));
    if (startsNewDay) {
      items.add(DateItem(day: message.createdAt, label: dayLabel(message.createdAt, now)));
    }
  }
  return items;
}
