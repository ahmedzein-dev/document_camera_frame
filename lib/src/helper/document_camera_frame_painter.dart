import 'package:flutter/material.dart';

class DocumentCameraFramePainter extends CustomPainter {
  final double frameWidth;
  final double frameHeight;

  DocumentCameraFramePainter(
      {required this.frameWidth, required this.frameHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withAlpha(127)
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
