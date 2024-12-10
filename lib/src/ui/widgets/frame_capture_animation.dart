import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FrameCaptureAnimation extends StatelessWidget {
  const FrameCaptureAnimation({
    super.key,
    required this.frameWidth,
    required this.frameHeight,
    this.animationDuration,
    this.animationColor,
  });

  final double frameWidth;
  final double frameHeight;
  final Duration? animationDuration;
  final Color? animationColor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: frameWidth,
        height: frameHeight,
        color: animationColor ?? Colors.black.withOpacity(0.5),
      )
          .animate(
              onPlay: (controller) =>
                  controller.repeat(period: animationDuration ?? const Duration(milliseconds: 1000)))
          .fade(duration: animationDuration ?? const Duration(milliseconds: 1000)),
    );
  }
}
