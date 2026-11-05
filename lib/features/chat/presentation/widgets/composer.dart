import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';

/// "Type a message" pill + lime send button (Figma: 44dp tall, 8dp gap).
/// OWNS its TextEditingController and FocusNode and disposes them itself.
class Composer extends StatefulWidget {
  const Composer({super.key, required this.onSend, this.maxLength = 1000});

  final ValueChanged<String> onSend;
  final int maxLength;

  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> {
  final TextEditingController _text = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _text.text.trim();
    if (value.isEmpty) return;
    widget.onSend(value);
    _text.clear();
    _focus.requestFocus(); // keep the keyboard open for the next message
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  key: const Key('composer-field'),
                  controller: _text,
                  focusNode: _focus,
                  minLines: 1,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.send,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppText.composer,
                  cursorColor: AppColors.lime,
                  inputFormatters: [LengthLimitingTextInputFormatter(widget.maxLength)],
                  onSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    hintStyle: AppText.composerHint,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _text,
          builder: (context, value, _) => AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: value.text.trim().isEmpty ? 0.6 : 1,
            child: Semantics(
              button: true,
              label: 'Send message',
              child: Material(
                key: const Key('send-button'),
                color: AppColors.lime,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _submit,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Transform.rotate(
                      angle: -0.6,
                      child: const Icon(Icons.send_outlined, size: 22, color: AppColors.onLime),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
