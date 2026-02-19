import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_constants.dart';
import '../../core/enums.dart';

class FrameCaptureAnimation extends StatelessWidget {
  const FrameCaptureAnimation({
    super.key,
    required this.frameWidth,
    required this.frameHeight,
    this.animationColor,
    this.animationDuration = const Duration(milliseconds: 600),
    this.curve = Curves.easeInOut,
    required this.uiMode,
  });

  final double frameWidth;
  final double frameHeight;
  final Duration? animationDuration;
  final Color? animationColor;
  final Curve? curve;
  final DocumentCameraUIMode uiMode;

  static final Color _defaultAnimationColor = Colors.black.withAlpha(127);

  @override
  Widget build(BuildContext context) {
    final double height = uiMode == DocumentCameraUIMode.minimal
        ? frameHeight
        : frameHeight + AppConstants.bottomFrameContainerHeight;

    return Align(
      alignment: Alignment.center,
      child:
          Container(
                width: frameWidth,
                height: height,
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
