import 'dart:async';

import 'package:capassignment/core/lifecycle/dispose_bag.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  test('dispose cancels subscriptions and runs callbacks exactly once', () async {
    final source = StreamController<int>.broadcast();
    final bag = DisposeBag();
    var calls = 0;

    bag.addSubscription(source.stream.listen((_) {}));
    bag.onDispose(() => calls++);
    expect(source.hasListener, isTrue);

    bag.dispose();
    bag.dispose(); // idempotent
    await Future<void>.delayed(Duration.zero);

    expect(source.hasListener, isFalse);
    expect(calls, 1);
    await source.close();
  });

  test('registrations made after disposal are released immediately', () async {
    final source = StreamController<int>.broadcast();
    final bag = DisposeBag()..dispose();
    var ran = false;

    bag.addSubscription(source.stream.listen((_) {}));
    bag.onDispose(() => ran = true);
    await Future<void>.delayed(Duration.zero);

    expect(source.hasListener, isFalse);
    expect(ran, isTrue);
    await source.close();
  });
}
