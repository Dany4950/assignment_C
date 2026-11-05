import 'dart:async';

import '../../../core/errors/app_exception.dart';
import '../../../core/lifecycle/scoped_controller.dart';
import '../../identity/domain/identity.dart';
import '../../room/domain/room.dart';
import '../../room/domain/room_repository.dart';
import '../domain/chat_items.dart';
import '../domain/chat_message.dart';
import '../domain/chat_repository.dart';

/// Realtime + paginated chat for ONE room.
///
/// Data flow
///   live window (newest [pageSize], Firestore listener)  --upsert-->  _byId
///   older pages (get() + startAfter cursor, on scroll)   --merge---->  _byId
///   _byId --sort newest first--> messages --> chat items (date chips, sender runs)
///
/// Lifecycle: both listeners are registered in [bag] inside [start]; disposing the
/// controller (route removed) cancels them, the error timer and clears the cache.
class ChatController extends ScopedController {
  ChatController({
    required ChatRepository chat,
    required RoomRepository rooms,
    required this.roomCode,
    required this.identity,
    DateTime Function()? clock,
    this.pageSize = 25,
  })  : _chat = chat,
        _rooms = rooms,
        _clock = clock ?? DateTime.now {
    bag.onDispose(() {
      _errorTimer?.cancel();
      _byId.clear();
    });
  }

  static const int maxMessageLength = 1000;

  final ChatRepository _chat;
  final RoomRepository _rooms;
  final DateTime Function() _clock;
  final String roomCode;
  final Identity identity;
  final int pageSize;

  final Map<String, ChatMessage> _byId = <String, ChatMessage>{};
  List<ChatMessage> _messages = const <ChatMessage>[];
  List<ChatItem> _items = const <ChatItem>[];

  bool _started = false;
  bool _loaded = false;
  bool _hasMoreOlder = true;
  bool _loadingOlder = false;
  bool _fromCache = false;
  int? _members;
  String? _sendError;
  Timer? _errorTimer;

  String get title => 'Room #$roomCode';
  List<ChatItem> get items => _items;
  List<ChatMessage> get messages => _messages;
  bool get loaded => _loaded;
  bool get loadingOlder => _loadingOlder;
  bool get hasMoreOlder => _hasMoreOlder;
  bool get fromCache => _fromCache;
  String? get sendError => _sendError;
  String? get membersText => _members == null ? null : membersLabel(_members!);

  /// Starts the two live listeners (idempotent).
  void start() {
    if (_started || isDisposed) return;
    _started = true;
    bag.addSubscription(
      _chat.watchLatest(roomCode, limit: pageSize).listen(
            _onSnapshot,
            onError: (Object error) => _showSendError(_messageOf(error)),
          ),
    );
    bag.addSubscription(
      _rooms.watchRoom(roomCode).listen(
            _onRoom,
            onError: (Object _) {}, // header count is cosmetic; keep chatting
          ),
    );
  }

  void _onRoom(Room room) {
    if (isDisposed) return;
    _members = room.memberCount;
    safeNotify();
  }

  void _onSnapshot(MessageSnapshot snapshot) {
    if (isDisposed) return;
    for (final message in snapshot.upserts) {
      _upsert(message);
    }
    // Only a SERVER snapshot can say "there is nothing older".
    if (!snapshot.fromCache && snapshot.windowSize < pageSize) _hasMoreOlder = false;
    _fromCache = snapshot.fromCache;
    _loaded = true;
    _rebuild();
    safeNotify();
  }

  void _upsert(ChatMessage incoming) {
    final existing = _byId[incoming.id];
    // Keep the first local estimate stable until the server timestamp arrives.
    _byId[incoming.id] = (existing != null && incoming.createdAtIsLocal)
        ? incoming.copyWith(
            createdAt: existing.createdAt,
            createdAtIsLocal: existing.createdAtIsLocal,
          )
        : incoming;
  }

  void _rebuild() {
    _messages = _byId.values.toList()
      ..sort((a, b) {
        final byTime = b.createdAt.compareTo(a.createdAt);
        return byTime != 0 ? byTime : b.id.compareTo(a.id);
      });
    _items = buildChatItems(
      newestFirst: _messages,
      myMemberId: identity.memberId,
      now: _clock(),
    );
  }

  /// Loads the next older page (called when the user scrolls near the top).
  Future<void> loadOlder() async {
    if (isDisposed || _loadingOlder || !_hasMoreOlder || _messages.isEmpty) return;
    final oldest = _messages.last;
    if (oldest.pending) return; // a not-yet-confirmed message cannot be a paging cursor
    _loadingOlder = true;
    safeNotify();
    try {
      final page = await _chat.fetchOlder(roomCode, before: oldest, limit: pageSize);
      if (isDisposed) return;
      for (final message in page.messages) {
        _byId.putIfAbsent(message.id, () => message);
      }
      _hasMoreOlder = page.hasMore;
      _rebuild();
    } catch (error) {
      if (isDisposed) return;
      _showSendError(_messageOf(error));
    } finally {
      if (!isDisposed) {
        _loadingOlder = false;
        safeNotify();
      }
    }
  }

  /// Sends a message. The UI does not wait for the server: Firestore shows the
  /// message instantly from its local cache (pending), also when offline.
  void send(String raw) {
    final text = raw.trim();
    if (text.isEmpty || isDisposed) return;
    final clipped = text.length > maxMessageLength ? text.substring(0, maxMessageLength) : text;
    unawaited(
      _chat.send(roomCode: roomCode, text: clipped, identity: identity).then<void>(
        (_) {},
        onError: (Object error) => _showSendError(_messageOf(error)),
      ),
    );
  }

  void _showSendError(String message) {
    if (isDisposed) return;
    _sendError = message;
    safeNotify();
    _errorTimer?.cancel();
    _errorTimer = Timer(const Duration(seconds: 4), () {
      if (isDisposed) return;
      _sendError = null;
      safeNotify();
    });
  }

  String _messageOf(Object error) =>
      error is AppException ? error.message : 'Something went wrong. Please try again.';
}
