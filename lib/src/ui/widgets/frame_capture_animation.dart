import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app_constants.dart';

class FrameCaptureAnimation extends StatelessWidget {
  const FrameCaptureAnimation({
    super.key,
    required this.frameWidth,
    required this.frameHeight,
    this.animationDuration,
    this.animationColor,
    this.curve,
  });

  final double frameWidth;
  final double frameHeight;
  final Duration? animationDuration;
  final Color? animationColor;
  final Curve? curve;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child:
          Container(
                width: frameWidth,
                height: frameHeight + AppConstants.bottomFrameContainerHeight,
                color: animationColor ?? Colors.black.withAlpha(127),
              )
              .animate(
                onPlay: (controller) => controller.repeat(
                  period:
                      animationDuration ?? const Duration(milliseconds: 1000),
                ),
              )
              .fade(
                duration:
                    animationDuration ?? const Duration(milliseconds: 1000),
                curve: curve,
              ),
    );
  }
}
