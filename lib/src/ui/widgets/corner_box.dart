import 'package:flutter/material.dart';

class CornerBox extends StatelessWidget {
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;
  final double flipProgress;
  final bool isDocumentAligned;
  final double innerCornerBorderRadius;

  const CornerBox({
    super.key,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
    required this.flipProgress,
    required this.isDocumentAligned,
    required this.innerCornerBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final Color baseColor = isDocumentAligned
        ? Colors.green.shade400
        : Colors.white;

    final double opacity = flipProgress == 0.0
        ? 1.0
        : (flipProgress <= 0.5
              ? 1.0 -
                    (flipProgress * 2) // fade out
              : (flipProgress - 0.5) * 2); // fade in

    final Color borderColor = baseColor.withValues(
      alpha: baseColor.a * opacity,
    );

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        border: Border(
          top: topLeft || topRight
              ? BorderSide(color: borderColor, width: 2)
              : BorderSide.none,
          left: topLeft || bottomLeft
              ? BorderSide(color: borderColor, width: 2)
              : BorderSide.none,
          right: topRight || bottomRight
              ? BorderSide(color: borderColor, width: 2)
              : BorderSide.none,
          bottom: bottomLeft || bottomRight
              ? BorderSide(color: borderColor, width: 2)
              : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: topLeft
              ? Radius.circular(innerCornerBorderRadius)
              : Radius.zero,
          topRight: topRight
              ? Radius.circular(innerCornerBorderRadius)
              : Radius.zero,
          bottomLeft: bottomLeft
              ? Radius.circular(innerCornerBorderRadius)
              : Radius.zero,
          bottomRight: bottomRight
              ? Radius.circular(innerCornerBorderRadius)
              : Radius.zero,
        ),
      ),
    );
  }
}
