import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../domain/anon_name.dart';
import '../domain/identity.dart';
import '../domain/identity_repository.dart';
import 'identity_store.dart';
import 'random_user_remote.dart';

class DefaultIdentityRepository implements IdentityRepository {
  DefaultIdentityRepository({required RandomUserRemote remote, required IdentityStore store})
      : _remote = remote,
        _store = store;

  final RandomUserRemote _remote;
  final IdentityStore _store;
  static const Uuid _uuid = Uuid();

  @override
  Identity? saved(String roomCode) => _store.read(roomCode);

  @override
  Future<void> save(String roomCode, Identity identity) => _store.write(roomCode, identity);

  @override
  Future<Identity> createNew({CancelToken? cancelToken}) async {
    try {
      final user = await _remote.fetch(cancelToken: cancelToken);
      final fullName = '${_cap(user.first)} ${_cap(user.last)}'.trim();
      final name = AnonName.fromUsername(user.username) ??
          (fullName.isEmpty ? AnonName.random() : fullName);
      return Identity(
        memberId: _uuid.v4(),
        displayName: name,
        avatarUrl: user.picture,
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow; // controller was disposed: stop quietly
      return _local();
    } catch (_) {
      return _local();
    }
  }

  /// randomuser.me unreachable (offline, rate limit...): still let the user in.
  Identity _local() => Identity(
        memberId: _uuid.v4(),
        displayName: AnonName.random(),
        source: IdentitySource.local,
      );

  static String _cap(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}';
}
