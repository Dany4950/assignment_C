import 'package:flutter/foundation.dart';

import 'dispose_bag.dart';

/// Base class of every controller in the app.
///
/// OWNERSHIP RULE: a controller is created by a `ChangeNotifierProvider(create:)`
/// that sits INSIDE its route. When the route leaves the tree (back button,
/// swipe-back, pushReplacement, popUntil, process death...) Flutter calls
/// [dispose] - no manual cleanup, no global registry, no `permanent`.
///
/// What this base class adds:
///  * [bag]       - single place that releases subscriptions / timers / tokens.
///  * [isDisposed]/[safeNotify] - async work that finishes after disposal is ignored.
///  * debug registry - lets tests and the LeakGuardObserver prove that no
///    controller outlives its screen.
abstract class ScopedController extends ChangeNotifier {
  ScopedController() {
    assert(() {
      _live.add(this);
      return true;
    }());
  }

  static final Set<ScopedController> _live = <ScopedController>{};

  /// Number of controllers that are alive right now (debug/test builds only).
  static int get debugLiveCount => _live.length;

  static List<String> get debugLiveNames =>
      _live.map((controller) => controller.runtimeType.toString()).toList();

  final DisposeBag bag = DisposeBag();

  bool _disposed = false;

  bool get isDisposed => _disposed;

  /// `notifyListeners` that is a no-op after disposal.
  @protected
  void safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  @mustCallSuper
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    bag.dispose();
    assert(() {
      _live.remove(this);
      return true;
    }());
    super.dispose();
  }
}
