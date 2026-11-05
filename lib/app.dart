import 'package:capassignment/features/splash/view/splash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/di/app_dependencies.dart';
import 'core/di/app_scope.dart';
import 'core/lifecycle/leak_guard_observer.dart';
import 'core/routing/app_router.dart';
import 'core/routing/route_names.dart';
import 'core/theme/app_theme.dart';

class RumourApp extends StatefulWidget {
  const RumourApp({
    super.key,
    required this.createDependencies,
    this.enableLeakGuard = kDebugMode,
  });

  final AppDependencies Function() createDependencies;
  final bool enableLeakGuard;

  @override
  State<RumourApp> createState() => _RumourAppState();
}

class _RumourAppState extends State<RumourApp> {
  late final LeakGuardObserver? _leakGuard = widget.enableLeakGuard
      ? LeakGuardObserver()
      : null;

  @override
  void dispose() {
    _leakGuard?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guard = _leakGuard;
    return AppScope(
      create: widget.createDependencies,
      child: MaterialApp(
        title: 'Rumour',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        initialRoute: RouteNames.splash,
        onGenerateRoute: (settings) => settings.name == RouteNames.splash
            ? SplashScreen.route()
            : AppRouter.onGenerateRoute(settings),
        navigatorObservers: <NavigatorObserver>[if (guard != null) guard],
        builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          ),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
