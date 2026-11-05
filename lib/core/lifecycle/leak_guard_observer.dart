import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../routing/route_names.dart';
import 'scoped_controller.dart';

/// DEBUG-ONLY watchdog. After every navigation change it waits for the exit
/// animation to finish and compares:
///   controllers alive  vs  controller-owning routes still on the stack.
/// If a controller outlived its route it reports a loud error with the names.
class LeakGuardObserver extends NavigatorObserver {
  LeakGuardObserver({this.settleDelay = const Duration(milliseconds: 900)});

  final Duration settleDelay;
  final List<Route<dynamic>> _stack = <Route<dynamic>>[];
  Timer? _timer;

  static const Set<String> _owners = <String>{
    RouteNames.join,
    RouteNames.reveal,
    RouteNames.chat,
  };

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.add(route);
    _schedule();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.remove(route);
    _schedule();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.remove(route);
    _schedule();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) _stack.remove(oldRoute);
    if (newRoute != null) _stack.add(newRoute);
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer(settleDelay, _check);
  }

  void _check() {
    final expected = _stack.where((r) => _owners.contains(r.settings.name)).length;
    final live = ScopedController.debugLiveCount;
    if (live > expected) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: StateError(
          'Controller leak: $live controllers alive but only $expected controller routes '
          'on the stack. Alive: ${ScopedController.debugLiveNames}',
        ),
        library: 'rumour leak guard',
      ));
    } else {
      debugPrint('LeakGuard OK: $live controller(s) alive, $expected route(s) on the stack.');
    }
  }

  /// Cancels the pending check. Call from the owning State.dispose().
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
