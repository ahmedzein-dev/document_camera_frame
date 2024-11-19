import 'package:flutter/material.dart';

class CameraFramePainter extends CustomPainter {
  final double frameWidth;
  final double frameHeight;

  CameraFramePainter({required this.frameWidth, required this.frameHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final clearRect = Rect.fromLTWH(
      (size.width - frameWidth) / 2,
      (size.height - frameHeight) / 2,
      frameWidth,
      frameHeight,
    );

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(clearRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
