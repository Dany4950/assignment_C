import 'package:flutter/material.dart';

import '../../features/chat/presentation/chat_screen.dart';
import '../../features/identity/presentation/reveal_screen.dart';
import '../../features/join/presentation/join_screen.dart';
import 'route_names.dart';

abstract final class AppRouter {
  /// Screens are normally pushed with their typed `Screen.route(args)`; this
  /// handles the initial route (and any named navigation).
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.reveal:
        return RevealScreen.route(settings.arguments! as RevealArgs);
      case RouteNames.chat:
        return ChatScreen.route(settings.arguments! as ChatArgs);
      case RouteNames.join:
      default:
        return JoinScreen.route();
    }
  }
}
