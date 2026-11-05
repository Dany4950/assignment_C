import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/identity.dart';

/// Local, per-room identity storage (one JSON entry per room code).
/// Not a secret, so SharedPreferences is the right tool.
class IdentityStore {
  IdentityStore(this._prefs);

  final SharedPreferences _prefs;

  static String _key(String roomCode) => 'identity.$roomCode';

  Identity? read(String roomCode) {
    final raw = _prefs.getString(_key(roomCode));
    if (raw == null) return null;
    try {
      return Identity.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String roomCode, Identity identity) =>
      _prefs.setString(_key(roomCode), jsonEncode(identity.toJson()));
}
