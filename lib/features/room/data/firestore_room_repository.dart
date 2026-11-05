import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/app_exception.dart';
import '../../auth/auth_gateway.dart';
import '../../identity/domain/identity.dart';
import '../domain/room.dart';
import '../domain/room_code.dart';
import '../domain/room_repository.dart';

const Duration _timeout = Duration(seconds: 12);
const int _maxCodeAttempts = 8;

class FirestoreRoomRepository implements RoomRepository {
  FirestoreRoomRepository(this._db, this._auth);

  final FirebaseFirestore _db;
  final AuthGateway _auth;

  DocumentReference<Map<String, dynamic>> _room(String code) => _db.collection('rooms').doc(code);

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<Room?> fetchRoom(String code) => _guard(() async {
        await _auth.ensureSignedIn();
        final snap =
            await _room(code).get(const GetOptions(source: Source.server)).timeout(_timeout);
        final data = snap.data();
        return snap.exists && data != null ? Room.fromMap(code, data) : null;
      });

  @override
  Future<Room> createRoom() => _guard(() async {
        await _auth.ensureSignedIn();
        for (var attempt = 0; attempt < _maxCodeAttempts; attempt++) {
          final code = RoomCode.generate();
          final ref = _room(code);
          final created = await _db.runTransaction<bool>((tx) async {
            final snap = await tx.get(ref);
            if (snap.exists) return false; // code taken, try another
            tx.set(ref, <String, dynamic>{
              'code': code,
              'createdAt': FieldValue.serverTimestamp(),
              'memberCount': 0,
            });
            return true;
          }).timeout(_timeout);
          if (created) return Room(code: code, memberCount: 0);
        }
        throw const AppException(
          AppErrorKind.unknown,
          'Could not find a free room code. Please try again.',
        );
      });

  @override
  Future<void> joinRoom(String code, Identity identity) => _guard(() async {
        await _auth.ensureSignedIn();
        final member = _room(code).collection('members').doc(identity.memberId);
        final batch = _db.batch()
          ..set(member, <String, dynamic>{
            'memberId': identity.memberId,
            'displayName': identity.displayName,
            if (identity.avatarUrl != null) 'avatarUrl': identity.avatarUrl,
            'joinedAt': FieldValue.serverTimestamp(),
          })
          ..update(_room(code), <String, dynamic>{'memberCount': FieldValue.increment(1)});
        try {
          await batch.commit().timeout(_timeout);
        } on FirebaseException catch (error) {
          // A retry after a lost acknowledgement: the member already exists
          // (the rules forbid overwriting it) - that means "already joined".
          if (error.code == 'permission-denied' && await _memberExists(member)) return;
          rethrow;
        }
      });

  Future<bool> _memberExists(DocumentReference<Map<String, dynamic>> member) async {
    final snap = await member.get(const GetOptions(source: Source.server)).timeout(_timeout);
    return snap.exists;
  }

  @override
  Stream<Room> watchRoom(String code) async* {
    await _auth.ensureSignedIn();
    yield* _room(code)
        .snapshots()
        .where((snap) => snap.exists && snap.data() != null)
        .map((snap) => Room.fromMap(code, snap.data()!));
  }
}
