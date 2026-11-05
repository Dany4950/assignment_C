import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';

/// Six-slot room-code field (Figma: 293 x 66 box, six dashes).
/// The caller owns [controller] and [focusNode] and disposes them.
class CodeInput extends StatelessWidget {
  const CodeInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.length,
    required this.onChanged,
    this.enabled = true,
    this.hasError = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final bool hasError;

  static const double _height = 66;
  static const double _slotWidth = 38;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => focusNode.requestFocus(),
      child: Container(
        height: _height,
        decoration: BoxDecoration(
          color: AppColors.codeBox,
          borderRadius: BorderRadius.circular(20),
          border: hasError ? Border.all(color: AppColors.error, width: 1.5) : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Visual slots. ValueListenableBuilder adds/removes its own listener:
            // nothing for us to leak.
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final text = value.text;
                return ListenableBuilder(
                  listenable: focusNode,
                  builder: (context, _) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < length; i++)
                        _Slot(
                          char: i < text.length ? text[i] : null,
                          active: focusNode.hasFocus && i == text.length,
                          width: _slotWidth,
                        ),
                    ],
                  ),
                );
              },
            ),
            // Invisible field that receives the keyboard input.
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  enabled: enabled,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  enableSuggestions: false,
                  showCursor: false,
                  enableInteractiveSelection: false,
                  style: const TextStyle(color: Colors.transparent),
                  decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(length),
                  ],
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({required this.char, required this.active, required this.width});

  final String? char;
  final bool active;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: CodeInput._height,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: char != null
            ? Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(char!, style: AppText.joinDigit),
              )
            : Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: SizedBox(
                  width: 18,
                  height: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: active ? AppColors.lime : AppColors.codeDash,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
