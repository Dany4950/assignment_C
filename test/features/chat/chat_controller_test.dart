import 'dart:async';

import 'package:capassignment/features/chat/domain/chat_items.dart';
import 'package:capassignment/features/chat/domain/chat_repository.dart';
import 'package:capassignment/features/chat/presentation/chat_controller.dart';
import 'package:capassignment/features/identity/domain/identity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:capassignment/core/lifecycle/scoped_controller.dart';

import '../../support/fakes.dart';

void main() {
  late FakeChatRepository chat;
  late FakeRoomRepository rooms;
  const me = Identity(memberId: 'me', displayName: 'Brave Badger');
  DateTime at(int hour) => DateTime(2026, 11, 4, hour);

  ChatController make({int pageSize = 2}) => ChatController(
        chat: chat,
        rooms: rooms,
        roomCode: '123456',
        identity: me,
        clock: () => DateTime(2026, 11, 4, 12),
        pageSize: pageSize,
      );

  setUp(() {
    chat = FakeChatRepository();
    rooms = FakeRoomRepository();
  });

  tearDown(() async {
    // The leak check: every controller created by a test must be gone.
    expect(ScopedController.debugLiveCount, 0, reason: 'controller leaked');
    await chat.dispose();
    await rooms.dispose();
  });

  test('live messages merge newest first with a date chip', () async {
    final c = make()..start();
    chat.latest.add(MessageSnapshot(
      upserts: [msg('a', 'hi', at(10)), msg('b', 'yo', at(11))],
      fromCache: false,
      windowSize: 2,
    ));
    await pumpEventQueue();

    expect(c.loaded, isTrue);
    expect(c.messages.map((m) => m.id), ['b', 'a']);
    expect(c.items.whereType<DateItem>(), hasLength(1));
    c.dispose();
  });

  test('older pages are appended and paging stops at the end', () async {
    final c = make()..start();
    chat.latest.add(MessageSnapshot(
      upserts: [msg('c', '3', at(11)), msg('d', '4', at(12))],
      fromCache: false,
      windowSize: 2, // == pageSize: there may be more
    ));
    await pumpEventQueue();
    chat.olderPages.add(MessagePage(
      messages: [msg('b', '2', at(10)), msg('a', '1', at(9))],
      hasMore: false,
    ));

    await c.loadOlder();
    expect(c.messages.map((m) => m.id), ['d', 'c', 'b', 'a']);
    expect(c.hasMoreOlder, isFalse);

    await c.loadOlder(); // nothing more: must not hit the repository again
    expect(chat.fetchOlderCalls, 1);
    c.dispose();
  });

  test('a server snapshot smaller than the page means there is no history', () async {
    final c = make()..start();
    chat.latest.add(MessageSnapshot(upserts: [msg('a', '1', at(9))], fromCache: false, windowSize: 1));
    await pumpEventQueue();
    expect(c.hasMoreOlder, isFalse);
    c.dispose();
  });

  test('messages leaving the live window are kept (removals are ignored)', () async {
    final c = make()..start();
    chat.latest.add(MessageSnapshot(
      upserts: [msg('a', '1', at(9)), msg('b', '2', at(10))],
      fromCache: false,
      windowSize: 2,
    ));
    await pumpEventQueue();
    chat.latest.add(MessageSnapshot(upserts: [msg('c', '3', at(11))], fromCache: false, windowSize: 2));
    await pumpEventQueue();
    expect(c.messages.map((m) => m.id), ['c', 'b', 'a']);
    c.dispose();
  });

  test('send trims the text and surfaces failures, which clear themselves', () async {
    final c = make()..start();
    c.send('  hello  ');
    await pumpEventQueue();
    expect(chat.sent, ['hello']);

    chat.failSend = true;
    c.send('again');
    await pumpEventQueue();
    expect(c.sendError, isNotNull);
    c.dispose(); // also cancels the pending 4s error timer
  });

  test('dispose cancels every listener and late results are ignored', () async {
    final c = make()..start();
    chat.latest.add(MessageSnapshot(
      upserts: [msg('b', '2', at(11)), msg('a', '1', at(10))],
      fromCache: false,
      windowSize: 2,
    ));
    await pumpEventQueue();
    expect(chat.latest.hasListener, isTrue);
    expect(rooms.updates.hasListener, isTrue);

    // A page request is still in flight when the screen goes away.
    chat.olderGate = Completer<MessagePage>();
    final inFlight = c.loadOlder();
    c.dispose();
    chat.olderGate!.complete(MessagePage(messages: [msg('z', 'old', at(8))], hasMore: true));
    await inFlight; // must not throw "used after dispose"
    await pumpEventQueue();

    expect(c.isDisposed, isTrue);
    expect(chat.latest.hasListener, isFalse);
    expect(rooms.updates.hasListener, isFalse);
  });
}
