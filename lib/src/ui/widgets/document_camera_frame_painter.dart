import 'package:flutter/material.dart';

class DocumentCameraFramePainter extends CustomPainter {
  final double frameWidth;
  final double frameHeight;

  final double borderRadius;

  DocumentCameraFramePainter({required this.frameWidth, required this.frameHeight, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final clearRect = RRect.fromRectAndRadius(
      Rect.fromLTWH((size.width - frameWidth) / 2, (size.height - frameHeight) / 2, frameWidth, frameHeight),
      Radius.circular(borderRadius),
    );

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(clearRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
