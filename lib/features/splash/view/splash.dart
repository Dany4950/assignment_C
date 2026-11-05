import 'dart:async';

import 'package:capassignment/features/join/presentation/join_screen.dart';
import 'package:capassignment/features/splash/widgets/app_logo_splash.dart';
import 'package:flutter/material.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';


/// Cold-start splash. Shows for [displayDuration], then the logo flies
/// (Hero) up into the key badge on the Join screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const Duration displayDuration = Duration(seconds: 3);
  static const double logoSize = 112;

  static Route<void> route() => PageRouteBuilder<void>(
        settings: RouteSettings(name: RouteNames.splash),
        transitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => const SplashScreen(),
      );

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  late final Animation<double> _scale = Tween<double>(begin: 0.55, end: 1).animate(
    CurvedAnimation(parent: _intro, curve: Curves.easeOutBack),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0, 0.5, curve: Curves.easeOut),
  );

  Timer? _timer;
  bool _precached = false;

  @override
  void initState() {
    super.initState();
    _intro.forward();
    _intro.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) _pulse.repeat(reverse: true);
    });
    _timer = Timer(SplashScreen.displayDuration, _goNext);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precached) {
      _precached = true;
      // Avoid the logo popping in late.
      precacheImage(const AssetImage(AppLogo.assetPath), context).catchError((_) {});
    }
  }

  void _goNext() {
    if (!mounted) return;
    _pulse.stop();
    Navigator.of(context).pushReplacement(JoinScreen.fadeRoute());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _intro.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Same colour as the Join screen so the handoff is seamless.
      backgroundColor: AppColors.joinBackground,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[_intro, _pulse]),
          builder: (context, _) {
            final glowSize = SplashScreen.logoSize * (1.9 + 0.25 * _pulse.value);
            final glowAlpha = (_fade.value * (0.10 + 0.10 * _pulse.value) * 255).round();
            return Stack(
              alignment: Alignment.center,
              children: [
                // Soft pulsing glow behind the logo.
                Container(
                  width: glowSize,
                  height: glowSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.lime.withAlpha(glowAlpha),
                        AppColors.lime.withAlpha(0),
                      ],
                    ),
                  ),
                ),
                Opacity(
                  opacity: _fade.value,
                  child: Transform.scale(
                    scale: _scale.value,
                    child: AppLogo.hero(size: SplashScreen.logoSize),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}