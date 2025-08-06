import 'package:document_camera_frame/src/core/context_extensions.dart';
import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonStyle? style;
  final TextStyle? textStyle;
  final double? width;
  final double? height;

  const ActionButton({
    required this.text,
    required this.onPressed,
    this.style,
    this.textStyle,
    this.width,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? .8.sw(context),
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: Text(text, style: textStyle),
      ),
    );
  }
}
