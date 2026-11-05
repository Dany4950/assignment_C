import '../../identity/domain/identity.dart';
import 'chat_message.dart';

/// One emission of the live "latest messages" query.
class MessageSnapshot {
  const MessageSnapshot({
    required this.upserts,
    required this.fromCache,
    required this.windowSize,
  });

  /// Messages added or modified since the previous emission.
  final List<ChatMessage> upserts;

  /// True while the data comes from the local (offline) cache.
  final bool fromCache;

  /// How many documents the live window currently holds.
  final int windowSize;
}

class MessagePage {
  const MessagePage({required this.messages, required this.hasMore});

  final List<ChatMessage> messages;
  final bool hasMore;
}

abstract interface class ChatRepository {
  /// Live window over the newest [limit] messages (works offline from cache).
  Stream<MessageSnapshot> watchLatest(String roomCode, {required int limit});

  /// One older page, strictly before [before].
  Future<MessagePage> fetchOlder(String roomCode, {required ChatMessage before, required int limit});

  /// Completes when the SERVER acknowledged the write (can take long offline;
  /// callers must not block the UI on it).
  Future<void> send({required String roomCode, required String text, required Identity identity});
}
