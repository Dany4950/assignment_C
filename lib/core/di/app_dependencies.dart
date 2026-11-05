import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/auth_gateway.dart';
import '../../features/chat/data/firestore_chat_repository.dart';
import '../../features/chat/domain/chat_repository.dart';
import '../../features/identity/data/default_identity_repository.dart';
import '../../features/identity/data/identity_store.dart';
import '../../features/identity/data/random_user_remote.dart';
import '../../features/identity/domain/identity_repository.dart';
import '../../features/room/data/firestore_room_repository.dart';
import '../../features/room/domain/room_repository.dart';

/// App-lifetime, stateless-ish services. They hold NO per-screen state:
/// controllers (which do) are created per route and never live here.
class AppDependencies {
  AppDependencies({
    required this.auth,
    required this.rooms,
    required this.chat,
    required this.identities,
    this.onDispose,
  });

  final AuthGateway auth;
  final RoomRepository rooms;
  final ChatRepository chat;
  final IdentityRepository identities;
  final VoidCallback? onDispose;

  factory AppDependencies.live(SharedPreferences prefs) {
    final auth = FirebaseAuthGateway(FirebaseAuth.instance);
    final dio = Dio(BaseOptions(
      baseUrl: 'https://randomuser.me',
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ));
    return AppDependencies(
      auth: auth,
      rooms: FirestoreRoomRepository(FirebaseFirestore.instance, auth),
      chat: FirestoreChatRepository(FirebaseFirestore.instance, auth),
      identities: DefaultIdentityRepository(
        remote: RandomUserRemote(dio),
        store: IdentityStore(prefs),
      ),
      onDispose: () => dio.close(force: true),
    );
  }

  void dispose() => onDispose?.call();
}
