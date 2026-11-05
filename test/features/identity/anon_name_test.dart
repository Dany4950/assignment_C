import 'package:capassignment/features/identity/domain/anon_name.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:capassignment/features/room/domain/room_code.dart';

void main() {
  test('randomuser usernames become two-word anonymous names', () {
    expect(AnonName.fromUsername('yellowpeacock117'), 'Yellow Peacock');
    expect(AnonName.fromUsername('lazybear442'), 'Lazy Bear');
    expect(AnonName.fromUsername('goldenswan9'), 'Golden Swan');
  });

  test('unsplittable usernames return null and the local generator still works', () {
    expect(AnonName.fromUsername('xyz123'), isNull);
    expect(AnonName.random().split(' '), hasLength(2));
  });

  test('room codes are six digits and never start with 0', () {
    for (var i = 0; i < 200; i++) {
      final code = RoomCode.generate();
      expect(RoomCode.isValid(code), isTrue);
      expect(code.startsWith('0'), isFalse);
    }
    expect(RoomCode.isValid('12345'), isFalse);
    expect(RoomCode.isValid('12345a'), isFalse);
  });
}
