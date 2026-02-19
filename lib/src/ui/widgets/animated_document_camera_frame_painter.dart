import 'package:flutter/material.dart';

class AnimatedDocumentCameraFramePainter extends CustomPainter {
  final double frameWidth;
  final double frameMaxHeight;
  final double animatedFrameHeight;
  final double bottomPosition;
  final double borderRadius;
  final BuildContext context;
  final bool isFlipping;

  AnimatedDocumentCameraFramePainter({
    required this.isFlipping,
    required this.frameWidth,
    required this.frameMaxHeight,
    required this.animatedFrameHeight,
    required this.bottomPosition,
    required this.borderRadius,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    if (animatedFrameHeight > 0) {
      final double top =
          bottomPosition + (frameMaxHeight - animatedFrameHeight);

      final clearRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          (size.width - frameWidth) / 2,
          top,
          frameWidth,
          animatedFrameHeight,
        ),
        Radius.circular(borderRadius),
      );

      final path = Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addRRect(clearRect)
        ..fillType = PathFillType.evenOdd;

      canvas.drawPath(path, paint);
    } else {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is AnimatedDocumentCameraFramePainter) {
      return oldDelegate.frameWidth != frameWidth ||
          oldDelegate.bottomPosition != bottomPosition ||
          oldDelegate.animatedFrameHeight != animatedFrameHeight ||
          oldDelegate.frameMaxHeight != frameMaxHeight ||
          oldDelegate.borderRadius != borderRadius;
    }
    return true;
  }
}
