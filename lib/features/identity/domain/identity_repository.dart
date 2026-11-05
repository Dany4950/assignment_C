import 'package:dio/dio.dart';

import 'identity.dart';

abstract interface class IdentityRepository {
  /// Identity this device already uses in [roomCode] (null on first join). Synchronous: works offline.
  Identity? saved(String roomCode);

  Future<void> save(String roomCode, Identity identity);

  /// Fetches a fresh random identity (randomuser.me). The request is cancelled
  /// through [cancelToken] when the owning controller is disposed.
  Future<Identity> createNew({CancelToken? cancelToken});
}
