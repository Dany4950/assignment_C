import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/glow_button.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/widgets/room_header.dart';
import '../../chat/presentation/chat_screen.dart';
import '../../room/domain/room.dart';
import '../../room/domain/room_repository.dart';
import '../domain/identity.dart';
import '../domain/identity_repository.dart';
import 'reveal_controller.dart';

class RevealArgs {
  const RevealArgs({required this.room, required this.identity});
  final Room room;
  final Identity identity;
}

class RevealScreen extends StatelessWidget {
  const RevealScreen({super.key, required this.args});

  final RevealArgs args;

  static Route<void> route(RevealArgs args) => MaterialPageRoute<void>(
        settings: const RouteSettings(name: RouteNames.reveal),
        builder: (_) => RevealScreen(args: args),
      );

  @override
  Widget build(BuildContext context) {
    // The controller lives exactly as long as this route's widget subtree.
    return ChangeNotifierProvider<RevealController>(
      create: (ctx) => RevealController(
        rooms: ctx.read<RoomRepository>(),
        identities: ctx.read<IdentityRepository>(),
        room: args.room,
        identity: args.identity,
      ),
      child: const _RevealView(),
    );
  }
}

class _RevealView extends StatelessWidget {
  const _RevealView();

  Future<void> _acknowledge(BuildContext context) async {
    final controller = context.read<RevealController>();
    final navigator = Navigator.of(context);
    final ok = await controller.acknowledge();
    if (!ok || !context.mounted) return;
    // Replace (not push): this screen and its controller are disposed right after.
    unawaited(navigator.pushReplacement(ChatScreen.route(
      ChatArgs(roomCode: controller.room.code, identity: controller.identity),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RevealController>();
    return PopScope(
      canPop: !controller.joining, // no leaving mid-join: the write must finish
      child: Scaffold(
        backgroundColor: AppColors.chatBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
            child: Column(
              children: [
                RoomHeader(
                  title: controller.room.title,
                  subtitle: membersLabel(controller.membersAfterJoin),
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                const Spacer(),
                _IdentityCard(identity: controller.identity),
                SizedBox(
                  height: 34,
                  child: controller.error == null
                      ? null
                      : Align(
                          alignment: Alignment.center,
                          child: Text(controller.error!,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.error),
                        ),
                ),
                GlowButton(
                  label: 'Acknowledge and continue',
                  loading: controller.joining,
                  onPressed: () => _acknowledge(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.identity});

  final Identity identity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('For this room, you are', style: AppText.revealLabel),
          const SizedBox(height: 12),
          GradientText(identity.displayName.replaceAll(' ', '\n'), style: AppText.revealName),
          const SizedBox(height: 14),
          const Text(
            'This is your anonymous identifier, visible only to others in this room.',
            textAlign: TextAlign.center,
            style: AppText.revealBody,
          ),
        ],
      ),
    );
  }
}
