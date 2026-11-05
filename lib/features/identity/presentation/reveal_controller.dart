import '../../../core/errors/app_exception.dart';
import '../../../core/lifecycle/scoped_controller.dart';
import '../../room/domain/room.dart';
import '../../room/domain/room_repository.dart';
import '../domain/identity.dart';
import '../domain/identity_repository.dart';

class RevealController extends ScopedController {
  RevealController({
    required RoomRepository rooms,
    required IdentityRepository identities,
    required this.room,
    required this.identity,
  })  : _rooms = rooms,
        _identities = identities;

  final RoomRepository _rooms;
  final IdentityRepository _identities;
  final Room room;
  final Identity identity;

  bool _joining = false;
  String? _error;

  bool get joining => _joining;
  String? get error => _error;

  /// Members shown on the card, counting the user who is about to join.
  int get membersAfterJoin => room.memberCount + 1;

  /// "Acknowledge and continue": register as a member, then remember the identity
  /// for this room. Returns true when the user may enter the chat.
  Future<bool> acknowledge() async {
    if (_joining || isDisposed) return false;
    _joining = true;
    _error = null;
    safeNotify();
    try {
      await _rooms.joinRoom(room.code, identity);
      // Saved even if the screen vanished meanwhile: the join already happened on
      // the server, and rejoining must reuse this identity.
      await _identities.save(room.code, identity);
      return true;
    } on AppException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Could not join the room. Please try again.';
      return false;
    } finally {
      _joining = false;
      safeNotify();
    }
  }
}
