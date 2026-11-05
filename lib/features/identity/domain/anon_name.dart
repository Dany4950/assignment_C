import 'dart:math';

/// Turns randomuser.me data into an anonymous two-word name like "Brave Badger".
abstract final class AnonName {
  /// randomuser.me usernames look like "yellowpeacock117" / "lazybear442":
  /// <adjective or colour><animal><digits>. Split on a known prefix.
  static const List<String> _prefixes = <String>[
    'angry', 'beautiful', 'big', 'black', 'blue', 'bright', 'brown', 'crazy',
    'gold', 'golden', 'green', 'happy', 'heavy', 'lazy', 'little', 'lonely',
    'orange', 'organic', 'purple', 'red', 'sad', 'silver', 'small', 'smooth',
    'ticklish', 'tiny', 'white', 'yellow',
  ];

  static const List<String> _fallbackAdjectives = <String>[
    'Brave', 'Clever', 'Swift', 'Quiet', 'Bold', 'Calm', 'Witty', 'Lucky',
    'Sunny', 'Mellow', 'Fierce', 'Gentle', 'Jolly', 'Nimble', 'Rapid',
  ];

  static const List<String> _fallbackAnimals = <String>[
    'Badger', 'Panther', 'Otter', 'Falcon', 'Koala', 'Lynx', 'Heron', 'Fox',
    'Wolf', 'Owl', 'Tiger', 'Panda', 'Raven', 'Gecko', 'Moose', 'Bison',
    'Crane', 'Eagle', 'Hawk', 'Seal',
  ];

  /// "yellowpeacock117" -> "Yellow Peacock". Returns null when it cannot be split.
  static String? fromUsername(String username) {
    final base = username.toLowerCase().replaceAll(RegExp(r'\d+$'), '');
    final prefixes = List<String>.of(_prefixes)..sort((a, b) => b.length.compareTo(a.length));
    for (final prefix in prefixes) {
      if (base.startsWith(prefix) && base.length >= prefix.length + 3) {
        return '${_cap(prefix)} ${_cap(base.substring(prefix.length))}';
      }
    }
    return null;
  }

  /// Used only when randomuser.me cannot be reached.
  static String random([Random? random]) {
    final rnd = random ?? Random.secure();
    final adjective = _fallbackAdjectives[rnd.nextInt(_fallbackAdjectives.length)];
    final animal = _fallbackAnimals[rnd.nextInt(_fallbackAnimals.length)];
    return '$adjective $animal';
  }

  static String _cap(String word) =>
      word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
}
