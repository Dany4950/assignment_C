// Lifecycle tests: whatever the user does, no controller outlives its screen.
import 'package:capassignment/app.dart';
import 'package:capassignment/core/lifecycle/scoped_controller.dart';
import 'package:capassignment/features/chat/presentation/chat_screen.dart';
import 'package:capassignment/features/identity/domain/identity.dart';
import 'package:capassignment/features/room/domain/room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


import 'support/fakes.dart';

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('rejoin: chat opens with the saved identity and its controller dies on back',
      (tester) async {
    final h = TestHarness();
    h.identities.store['123456'] = const Identity(memberId: 'me', displayName: 'Brave Badger');

    await tester.pumpWidget(RumourApp(createDependencies: h.build, enableLeakGuard: false));
    await tester.pump();
    expect(ScopedController.debugLiveCount, 1); // JoinController

    await tester.enterText(find.byType(TextField), '123456');
    await _settle(tester);
    expect(find.byType(ChatScreen), findsOneWidget);
    expect(ScopedController.debugLiveCount, 2); // Join + Chat
    expect(h.chat.latest.hasListener, isTrue);
    expect(h.identities.created, 0, reason: 'a rejoin must reuse the saved identity');

    await tester.tap(find.byKey(const Key('room-back-button')));
    await _settle(tester);
    expect(find.byType(ChatScreen), findsNothing);
    expect(ScopedController.debugLiveCount, 1); // only Join remains
    expect(h.chat.latest.hasListener, isFalse);
    expect(h.rooms.updates.hasListener, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(ScopedController.debugLiveCount, 0);
    await h.dispose();
  });

  testWidgets('first join: reveal is replaced by the chat and its controller is disposed',
      (tester) async {
    final h = TestHarness();
    h.rooms.rooms['654321'] = const Room(code: '654321', memberCount: 3);

    await tester.pumpWidget(RumourApp(createDependencies: h.build, enableLeakGuard: false));
    await tester.pump();

    await tester.enterText(find.byType(TextField), '654321');
    await _settle(tester);
    expect(find.text('Acknowledge and continue'), findsOneWidget);
    expect(ScopedController.debugLiveCount, 2); // Join + Reveal

    await tester.tap(find.text('Acknowledge and continue'));
    await _settle(tester);
    expect(find.byType(ChatScreen), findsOneWidget);
    expect(ScopedController.debugLiveCount, 2); // Join + Chat (Reveal is gone)
    expect(h.rooms.joinedMemberIds, ['member-1']);
    expect(h.identities.store['654321']?.displayName, 'Brave Badger');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(ScopedController.debugLiveCount, 0);
    await h.dispose();
  });

  testWidgets('unknown room shows an error and starts no navigation', (tester) async {
    final h = TestHarness();
    await tester.pumpWidget(RumourApp(createDependencies: h.build, enableLeakGuard: false));
    await tester.pump();

    await tester.enterText(find.byType(TextField), '999999');
    await _settle(tester);
    expect(find.textContaining('Room not found'), findsOneWidget);
    expect(ScopedController.debugLiveCount, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(ScopedController.debugLiveCount, 0);
    await h.dispose();
  });
}
