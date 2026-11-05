import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../features/auth/auth_gateway.dart';
import '../../features/chat/domain/chat_repository.dart';
import '../../features/identity/domain/identity_repository.dart';
import '../../features/room/domain/room_repository.dart';
import 'app_dependencies.dart';

/// Owns [AppDependencies] (creates in initState, releases in dispose) and
/// exposes the repositories to the tree.
class AppScope extends StatefulWidget {
  const AppScope({super.key, required this.create, required this.child});

  final AppDependencies Function() create;
  final Widget child;

  @override
  State<AppScope> createState() => _AppScopeState();
}

class _AppScopeState extends State<AppScope> {
  late final AppDependencies _deps = widget.create();

  @override
  void dispose() {
    _deps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthGateway>.value(value: _deps.auth),
        Provider<RoomRepository>.value(value: _deps.rooms),
        Provider<ChatRepository>.value(value: _deps.chat),
        Provider<IdentityRepository>.value(value: _deps.identities),
      ],
      child: widget.child,
    );
  }
}
