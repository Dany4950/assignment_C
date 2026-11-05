import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/app_exception.dart';
import '../../auth/auth_gateway.dart';
import '../../identity/domain/identity.dart';
import '../domain/chat_message.dart';
import '../domain/chat_repository.dart';

class FirestoreChatRepository implements ChatRepository {
  FirestoreChatRepository(this._db, this._auth);

  final FirebaseFirestore _db;
  final AuthGateway _auth;

  CollectionReference<Map<String, dynamic>> _messages(String roomCode) =>
      _db.collection('rooms').doc(roomCode).collection('messages');

  @override
  Stream<MessageSnapshot> watchLatest(
    String roomCode, {
    required int limit,
  }) async* {
    await _auth.ensureSignedIn();
    final query = _messages(
      roomCode,
    ).orderBy('createdAt', descending: true).limit(limit);
    // includeMetadataChanges: also fires when a pending write is confirmed by the
    // server and when the data source flips between cache and server.
    yield* query
        .snapshots(includeMetadataChanges: true)
        .map(
          (snap) => MessageSnapshot(
            // Documents leaving the limit window arrive as "removed": we never
            // delete messages, so removals are ignored and history stays intact.
            upserts: <ChatMessage>[
              for (final change in snap.docChanges)
                if (change.type != DocumentChangeType.removed)
                  _fromDoc(change.doc),
            ],
            fromCache: snap.metadata.isFromCache,
            windowSize: snap.size,
          ),
        );
  }

  @override
  Future<MessagePage> fetchOlder(
    String roomCode, {
    required ChatMessage before,
    required int limit,
  }) async {
    try {
      await _auth.ensureSignedIn();
      final cursor = before.cursor;
      if (cursor is! DocumentSnapshot<Map<String, dynamic>>) {
        throw const AppException(
          AppErrorKind.unknown,
          'Missing paging cursor.',
        );
      }
      final snap = await _messages(roomCode)
          .orderBy('createdAt', descending: true)
          .startAfterDocument(cursor)
          .limit(limit)
          .get();
      final messages = <ChatMessage>[
        for (final doc in snap.docs) _fromDoc(doc),
      ];
      return MessagePage(messages: messages, hasMore: messages.length >= limit);
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<void> send({
    required String roomCode,
    required String text,
    required Identity identity,
  }) async {
    try {
      await _auth.ensureSignedIn();
      await _messages(roomCode).doc().set(<String, dynamic>{
        'text': text,
        'senderId': identity.memberId,
        'senderName': identity.displayName,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      throw mapError(error);
    }
  }

  ChatMessage _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final ts = data['createdAt'];
    return ChatMessage(
      id: doc.id,
      text: (data['text'] as String?) ?? '',
      senderId: (data['senderId'] as String?) ?? '',
      senderName: (data['senderName'] as String?) ?? 'Anonymous',
      // A just-sent message has no server timestamp yet: use "now" until it resolves.
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
      createdAtIsLocal: ts is! Timestamp,
      pending: doc.metadata.hasPendingWrites,
      cursor: doc,
    );
  }
}
