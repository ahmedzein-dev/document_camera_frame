import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FrameCaptureAnimation extends StatelessWidget {
  const FrameCaptureAnimation({super.key, required this.frameWidth, required this.frameHeight});

  final double frameWidth;
  final double frameHeight;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(width: frameWidth, height: frameHeight, color: Colors.black.withOpacity(0.5))
          .animate(onPlay: (controller) => controller.repeat(period: const Duration(milliseconds: 1000)))
          .fade(duration: const Duration(milliseconds: 1000)),
    );
  }
}
