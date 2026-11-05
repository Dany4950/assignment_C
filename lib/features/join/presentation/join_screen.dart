import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../chat/presentation/chat_screen.dart';
import '../../identity/domain/identity_repository.dart';
import '../../identity/presentation/reveal_screen.dart';
import '../../room/domain/room_code.dart';
import '../../room/domain/room_repository.dart';
import 'join_controller.dart';
import 'widgets/code_input.dart';

class JoinScreen extends StatelessWidget {
  const JoinScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
    settings: const RouteSettings(name: RouteNames.join),
    builder: (_) => const JoinScreen(),
  );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<JoinController>(
      create: (ctx) => JoinController(
        rooms: ctx.read<RoomRepository>(),
        identities: ctx.read<IdentityRepository>(),
      ),
      child: const _JoinView(),
    );
  }

  static Route<void> fadeRoute() => PageRouteBuilder<void>(
    settings: const RouteSettings(name: RouteNames.join),
    transitionDuration: const Duration(milliseconds: 800),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => const JoinScreen(),
    transitionsBuilder: (_, animation, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
  );
}

class _JoinView extends StatefulWidget {
  const _JoinView();

  @override
  State<_JoinView> createState() => _JoinViewState();
}

class _JoinViewState extends State<_JoinView> {
  // Owned and disposed here.
  final TextEditingController _code = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _navigating = false;

  @override
  void dispose() {
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _run(
    Future<JoinOutcome> Function(JoinController c) action,
  ) async {
    if (_navigating) return;
    final controller = context.read<JoinController>();
    final outcome = await action(controller);
    if (!mounted) return;

    final navigator = Navigator.of(context);
    switch (outcome) {
      case OpenChat(:final roomCode, :final identity):
        _navigating = true;
        await navigator.push(
          ChatScreen.route(ChatArgs(roomCode: roomCode, identity: identity)),
        );
        _onReturned();
      case OpenReveal(:final room, :final identity):
        _navigating = true;
        await navigator.push(
          RevealScreen.route(RevealArgs(room: room, identity: identity)),
        );
        _onReturned();
      case JoinFailed():
      case JoinCancelled():
        break;
    }
  }

  void _onReturned() {
    if (!mounted) return;
    _navigating = false;
    _code.clear();
    context.read<JoinController>().reset();
  }

  void _onCodeChanged(String value) {
    context.read<JoinController>().onCodeChanged(value);
    if (value.length == RoomCode.length) {
      FocusScope.of(context).unfocus();
      _run((c) => c.join(value));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<JoinController>();
    final status = controller.status;
    final hasError =
        status == JoinStatus.notFound || status == JoinStatus.failed;

    return Scaffold(
      backgroundColor: AppColors.joinBackground,
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const _KeyBadge(),
                    const Spacer(flex: 5),
                    const Text('Join A Room', style: AppText.joinTitle),
                    const SizedBox(height: 12),
                    const Text(
                      'Enter the code to join the anon chat room',
                      textAlign: TextAlign.center,
                      style: AppText.joinSubtitle,
                    ),
                    const SizedBox(height: 37),
                    CodeInput(
                      controller: _code,
                      focusNode: _focus,
                      length: RoomCode.length,
                      enabled: !controller.isBusy,
                      hasError: hasError,
                      onChanged: _onCodeChanged,
                    ),
                    SizedBox(
                      height: 56,
                      child: Center(
                        child: controller.isBusy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: AppColors.lime,
                                ),
                              )
                            : (hasError && controller.message != null)
                            ? Text(
                                controller.message!,
                                textAlign: TextAlign.center,
                                style: AppText.error,
                              )
                            : null,
                      ),
                    ),
                    TextButton(
                      onPressed: controller.isBusy
                          ? null
                          : () => _run((c) => c.create()),
                      child: const Text(
                        'Create a new room',
                        style: AppText.link,
                      ),
                    ),
                    const Spacer(flex: 6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyBadge extends StatelessWidget {
  const _KeyBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.keyCircle,
        shape: BoxShape.circle,
      ),
      child: Image.asset(
        'assets/app_key.png',
        width: 48, // make it smaller
        height: 48,
        fit: BoxFit.contain,
      ),
    );
  }
}
