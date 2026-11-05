import 'dart:math';

/// Room codes are 6 digits (the Join screen has 6 slots). The first digit is never 0.
abstract final class RoomCode {
  static const int length = 6;
  static final RegExp _pattern = RegExp(r'^\d{6}$');

  static bool isValid(String code) => _pattern.hasMatch(code);

  static String generate([Random? random]) {
    final rnd = random ?? Random.secure();
    final digits = List<int>.generate(length, (i) => i == 0 ? 1 + rnd.nextInt(9) : rnd.nextInt(10));
    return digits.join();
  }
}
