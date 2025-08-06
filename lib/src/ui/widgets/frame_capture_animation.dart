import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app_constants.dart';

class FrameCaptureAnimation extends StatelessWidget {
  const FrameCaptureAnimation({
    super.key,
    required this.frameWidth,
    required this.frameHeight,
    this.animationColor,
    this.animationDuration = const Duration(milliseconds: 600),
    this.curve = Curves.easeInOut,
  });

  final double frameWidth;
  final double frameHeight;
  final Duration? animationDuration;
  final Color? animationColor;
  final Curve? curve;

  static final Color _defaultAnimationColor = Colors.black.withAlpha(127);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child:
          Container(
                width: frameWidth,
                height: frameHeight + AppConstants.bottomFrameContainerHeight,
                color: animationColor ?? _defaultAnimationColor,
              )
              .animate(
                onPlay: (controller) =>
                    controller.repeat(period: animationDuration),
              )
              .fade(duration: animationDuration, curve: curve),
    );
  }
}
