class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
    this.createdAtIsLocal = false,
    this.pending = false,
    this.cursor,
  });

  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime createdAt;

  /// True while the server timestamp has not been resolved yet (just sent).
  final bool createdAtIsLocal;

  /// True while the write is still queued (offline / in flight).
  final bool pending;

  /// Opaque paging cursor owned by the data layer (a Firestore DocumentSnapshot).
  final Object? cursor;

  ChatMessage copyWith({DateTime? createdAt, bool? createdAtIsLocal}) => ChatMessage(
        id: id,
        text: text,
        senderId: senderId,
        senderName: senderName,
        createdAt: createdAt ?? this.createdAt,
        createdAtIsLocal: createdAtIsLocal ?? this.createdAtIsLocal,
        pending: pending,
        cursor: cursor,
      );
}
