import 'dart:async';

import 'package:flutter/foundation.dart';

/// Collects everything a controller must release and releases it in ONE place.
///
/// Rule: every stream subscription, timer, cancel token or listener a controller
/// creates is registered here the moment it is created. Nothing is cancelled
/// by hand elsewhere, so nothing can be forgotten.
class DisposeBag {
  final List<StreamSubscription<Object?>> _subscriptions = <StreamSubscription<Object?>>[];
  final List<VoidCallback> _callbacks = <VoidCallback>[];
  bool _disposed = false;

  bool get isDisposed => _disposed;

  @visibleForTesting
  int get trackedCount => _subscriptions.length + _callbacks.length;

  /// Tracks [subscription]. If the bag is already disposed it is cancelled at once.
  StreamSubscription<T> addSubscription<T>(StreamSubscription<T> subscription) {
    if (_disposed) {
      unawaited(subscription.cancel());
      return subscription;
    }
    _subscriptions.add(subscription);
    return subscription;
  }

  /// Runs [callback] exactly once when the bag is disposed (timers, tokens, ...).
  /// If the bag is already disposed the callback runs immediately.
  void onDispose(VoidCallback callback) {
    if (_disposed) {
      callback();
      return;
    }
    _callbacks.add(callback);
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
    for (final callback in _callbacks.reversed) {
      try {
        callback();
      } catch (error, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'rumour dispose bag',
        ));
      }
    }
    _callbacks.clear();
  }
}
