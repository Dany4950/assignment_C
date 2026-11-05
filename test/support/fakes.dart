import 'dart:async';

import 'package:capassignment/core/di/app_dependencies.dart';
import 'package:capassignment/core/errors/app_exception.dart';
import 'package:capassignment/features/auth/auth_gateway.dart';
import 'package:capassignment/features/chat/domain/chat_message.dart';
import 'package:capassignment/features/chat/domain/chat_repository.dart';
import 'package:capassignment/features/identity/domain/identity.dart';
import 'package:capassignment/features/identity/domain/identity_repository.dart';
import 'package:capassignment/features/room/domain/room.dart';
import 'package:capassignment/features/room/domain/room_repository.dart';
import 'package:dio/dio.dart';


class FakeAuth implements AuthGateway {
  @override
  Future<void> ensureSignedIn() async {}
}

class FakeRoomRepository implements RoomRepository {
  final Map<String, Room> rooms = <String, Room>{};
  final StreamController<Room> updates = StreamController<Room>.broadcast();
  final List<String> joinedMemberIds = <String>[];

  @override
  Future<Room?> fetchRoom(String code) async => rooms[code];

  @override
  Future<Room> createRoom() async {
    const room = Room(code: '123456', memberCount: 0);
    rooms[room.code] = room;
    return room;
  }

  @override
  Future<void> joinRoom(String code, Identity identity) async => joinedMemberIds.add(identity.memberId);

  @override
  Stream<Room> watchRoom(String code) => updates.stream;

  Future<void> dispose() => updates.close();
}

class FakeChatRepository implements ChatRepository {
  final StreamController<MessageSnapshot> latest = StreamController<MessageSnapshot>.broadcast();
  final List<MessagePage> olderPages = <MessagePage>[];
  Completer<MessagePage>? olderGate;
  int fetchOlderCalls = 0;
  final List<String> sent = <String>[];
  bool failSend = false;

  @override
  Stream<MessageSnapshot> watchLatest(String roomCode, {required int limit}) => latest.stream;

  @override
  Future<MessagePage> fetchOlder(String roomCode,
      {required ChatMessage before, required int limit}) {
    fetchOlderCalls++;
    final gate = olderGate;
    if (gate != null) return gate.future;
    return Future<MessagePage>.value(olderPages.removeAt(0));
  }

  @override
  Future<void> send({
    required String roomCode,
    required String text,
    required Identity identity,
  }) async {
    if (failSend) throw const AppException(AppErrorKind.permission, 'nope');
    sent.add(text);
  }

  Future<void> dispose() => latest.close();
}

class FakeIdentityRepository implements IdentityRepository {
  final Map<String, Identity> store = <String, Identity>{};
  int created = 0;

  @override
  Identity? saved(String roomCode) => store[roomCode];

  @override
  Future<void> save(String roomCode, Identity identity) async => store[roomCode] = identity;

  @override
  Future<Identity> createNew({CancelToken? cancelToken}) async {
    created++;
    return Identity(memberId: 'member-$created', displayName: 'Brave Badger');
  }
}

class TestHarness {
  final FakeAuth auth = FakeAuth();
  final FakeRoomRepository rooms = FakeRoomRepository();
  final FakeChatRepository chat = FakeChatRepository();
  final FakeIdentityRepository identities = FakeIdentityRepository();

  AppDependencies build() => AppDependencies(
        auth: auth,
        rooms: rooms,
        chat: chat,
        identities: identities,
      );

  Future<void> dispose() async {
    await rooms.dispose();
    await chat.dispose();
  }
}

ChatMessage msg(
  String id,
  String text,
  DateTime at, {
  String sender = 'other',
  bool pending = false,
}) =>
    ChatMessage(
      id: id,
      text: text,
      senderId: sender,
      senderName: 'Pink Panther',
      createdAt: at,
      pending: pending,
    );
