import 'package:capassignment/core/utils/day_label.dart';
import 'package:capassignment/features/chat/domain/chat_items.dart';
import 'package:flutter_test/flutter_test.dart';


import '../../support/fakes.dart';

void main() {
  final now = DateTime(2026, 11, 4, 12);

  test('date chips sit above the first message of each day', () {
    final items = buildChatItems(
      newestFirst: [
        msg('3', 'c', DateTime(2026, 11, 4, 11), sender: 'me'),
        msg('2', 'b', DateTime(2026, 11, 4, 10)),
        msg('1', 'a', DateTime(2026, 11, 3, 9)),
      ],
      myMemberId: 'me',
      now: now,
    );

    expect(items.map((i) => i.runtimeType.toString()), [
      'MessageItem', // 3 (me, today)
      'MessageItem', // 2 (today)
      'DateItem', //    Today
      'MessageItem', // 1 (yesterday)
      'DateItem', //    Yesterday
    ]);
    expect((items[2] as DateItem).label, 'Today');
    expect((items[4] as DateItem).label, 'Yesterday');
    expect((items[0] as MessageItem).isMine, isTrue);
  });

  test('sender name is shown once per consecutive run', () {
    final items = buildChatItems(
      newestFirst: [
        msg('2', 'b', DateTime(2026, 11, 4, 11)),
        msg('1', 'a', DateTime(2026, 11, 4, 10)),
      ],
      myMemberId: 'me',
      now: now,
    );
    expect((items[0] as MessageItem).showSender, isFalse);
    expect((items[1] as MessageItem).showSender, isTrue);
  });

  test('day labels', () {
    expect(dayLabel(DateTime(2026, 11, 4, 1), now), 'Today');
    expect(dayLabel(DateTime(2026, 11, 3, 23), now), 'Yesterday');
    expect(dayLabel(DateTime(2026, 10, 31), now), '31 Oct 2026');
  });
}
