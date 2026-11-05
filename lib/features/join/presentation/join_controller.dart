import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/lifecycle/scoped_controller.dart';
import '../../identity/domain/identity.dart';
import '../../identity/domain/identity_repository.dart';
import '../../room/domain/room.dart';
import '../../room/domain/room_code.dart';
import '../../room/domain/room_repository.dart';

enum JoinStatus { idle, checking, creating, notFound, failed }

/// What the screen should do after an action. The controller never touches
/// Navigator/BuildContext: the screen (which owns the context) navigates.
sealed class JoinOutcome {
  const JoinOutcome();
}

/// Same device joined this room before: reuse the saved identity, go to the chat.
final class OpenChat extends JoinOutcome {
  const OpenChat({required this.roomCode, required this.identity});
  final String roomCode;
  final Identity identity;
}

/// First time in this room: show the identity reveal.
final class OpenReveal extends JoinOutcome {
  const OpenReveal({required this.room, required this.identity});
  final Room room;
  final Identity identity;
}

/// An error was recorded in the controller state.
final class JoinFailed extends JoinOutcome {
  const JoinFailed();
}

/// Nothing to do (busy, or the screen was closed while working).
final class JoinCancelled extends JoinOutcome {
  const JoinCancelled();
}

class JoinController extends ScopedController {
  JoinController({required RoomRepository rooms, required IdentityRepository identities})
      : _rooms = rooms,
        _identities = identities;

  final RoomRepository _rooms;
  final IdentityRepository _identities;

  JoinStatus _status = JoinStatus.idle;
  String? _message;
  bool _busy = false;

  JoinStatus get status => _status;
  String? get message => _message;
  bool get isBusy => _status == JoinStatus.checking || _status == JoinStatus.creating;

  /// Typing again clears a previous error.
  void onCodeChanged(String value) {
    if (_status == JoinStatus.notFound || _status == JoinStatus.failed) {
      _status = JoinStatus.idle;
      _message = null;
      safeNotify();
    }
  }

  /// Called when the user comes back to this screen.
  void reset() {
    _status = JoinStatus.idle;
    _message = null;
    safeNotify();
  }

  Future<JoinOutcome> join(String code) => _run(JoinStatus.checking, () async {
        if (!RoomCode.isValid(code)) {
          return _fail(JoinStatus.failed, 'Enter the ${RoomCode.length}-digit room code.');
        }
        // Rejoin: the saved identity is read locally, so this works offline too.
        final saved = _identities.saved(code);
        if (saved != null) return OpenChat(roomCode: code, identity: saved);

        final room = await _rooms.fetchRoom(code);
        if (isDisposed) return const JoinCancelled();
        if (room == null) {
          return _fail(JoinStatus.notFound, 'Room not found. Check the code or create a new room.');
        }
        final identity = await _identities.createNew(cancelToken: _newCancelToken());
        if (isDisposed) return const JoinCancelled();
        return OpenReveal(room: room, identity: identity);
      });

  Future<JoinOutcome> create() => _run(JoinStatus.creating, () async {
        final room = await _rooms.createRoom();
        if (isDisposed) return const JoinCancelled();
        final identity = await _identities.createNew(cancelToken: _newCancelToken());
        if (isDisposed) return const JoinCancelled();
        return OpenReveal(room: room, identity: identity);
      });

  /// Single entry point for async work: double-tap guard, uniform error mapping,
  /// and "ignore the result if the screen is already gone".
  Future<JoinOutcome> _run(JoinStatus working, Future<JoinOutcome> Function() body) async {
    if (_busy || isDisposed) return const JoinCancelled();
    _busy = true;
    _status = working;
    _message = null;
    safeNotify();
    try {
      final outcome = await body();
      if (!isDisposed && outcome is! JoinFailed) _status = JoinStatus.idle;
      return outcome;
    } on AppException catch (error) {
      return _fail(JoinStatus.failed, error.message);
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return const JoinCancelled();
      return _fail(JoinStatus.failed, 'Network error. Check your connection and try again.');
    } catch (_) {
      return _fail(JoinStatus.failed, 'Something went wrong. Please try again.');
    } finally {
      _busy = false;
      safeNotify();
    }
  }

  JoinOutcome _fail(JoinStatus status, String message) {
    if (!isDisposed) {
      _status = status;
      _message = message;
    }
    return const JoinFailed();
  }

  /// A request token that is cancelled automatically when this controller is disposed.
  CancelToken _newCancelToken() {
    final token = CancelToken();
    bag.onDispose(() => token.cancel('controller disposed'));
    return token;
  }
}
