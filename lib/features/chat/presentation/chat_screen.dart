import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/room_header.dart';
import '../../identity/domain/identity.dart';
import '../../room/domain/room_repository.dart';
import '../domain/chat_items.dart';
import '../domain/chat_repository.dart';
import 'chat_controller.dart';
import 'widgets/composer.dart';
import 'widgets/date_chip.dart';
import 'widgets/message_bubble.dart';

class ChatArgs {
  const ChatArgs({required this.roomCode, required this.identity});
  final String roomCode;
  final Identity identity;
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.args});

  final ChatArgs args;

  static Route<void> route(ChatArgs args) => MaterialPageRoute<void>(
        settings: const RouteSettings(name: RouteNames.chat),
        builder: (_) => ChatScreen(args: args),
      );

  @override
  Widget build(BuildContext context) {
    // Created inside the route => disposed with the route, whatever way it is left
    // (back button, swipe-back, replaced, popUntil, app killed).
    return ChangeNotifierProvider<ChatController>(
      create: (ctx) => ChatController(
        chat: ctx.read<ChatRepository>(),
        rooms: ctx.read<RoomRepository>(),
        roomCode: args.roomCode,
        identity: args.identity,
      )..start(),
      child: _ChatView(args: args),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView({required this.args});

  final ChatArgs args;

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  // UI objects are owned (and disposed) by the State that uses them.
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _send(String text) {
    context.read<ChatController>().send(text);
    if (_scroll.hasClients) {
      _scroll.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: AppColors.chatBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
              child: Selector<ChatController, String?>(
                selector: (_, c) => c.membersText,
                builder: (context, members, _) => RoomHeader(
                  title: 'Room #${widget.args.roomCode}',
                  subtitle: members,
                  onBack: () => Navigator.of(context).maybePop(),
                  trailing: HeaderAvatar(url: widget.args.identity.avatarUrl),
                ),
              ),
            ),
            Expanded(child: _MessageList(scroll: _scroll)),
            Selector<ChatController, String?>(
              selector: (_, c) => c.sendError,
              builder: (context, error, _) => error == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                      child: Text(error, style: AppText.error),
                    ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset + 4),
              child: Composer(onSend: _send),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.scroll});

  final ScrollController scroll;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChatController>();
    final items = controller.items;

    if (!controller.loaded) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.lime),
        ),
      );
    }
    if (items.isEmpty) {
      return const Center(
        child: Text('No messages yet. Say hi!', style: AppText.roomSubtitle),
      );
    }

    final extra = controller.loadingOlder ? 1 : 0;
    return NotificationListener<ScrollNotification>(
      // No scroll listener to attach/detach: nothing to leak.
      onNotification: (n) {
        if (n.metrics.extentAfter < 400) controller.loadOlder();
        return false;
      },
      child: ListView.builder(
        controller: scroll,
        reverse: true, // newest at the bottom, history grows upwards
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        itemCount: items.length + extra,
        itemBuilder: (context, index) {
          if (index >= items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.lime),
                ),
              ),
            );
          }
          final item = items[index];
          return switch (item) {
            MessageItem m => MessageBubble(key: ValueKey(m.message.id), item: m),
            DateItem d => DateChip(key: ValueKey('day-${d.day.toIso8601String()}'), label: d.label),
          };
        },
      ),
    );
  }
}
