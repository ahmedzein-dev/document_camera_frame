import 'package:flutter/material.dart';

class CaptureButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double? captureOuterCircleRadius;
  final double? captureInnerCircleRadius;

  const CaptureButton({
    this.captureInnerCircleRadius,
    this.captureOuterCircleRadius,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: captureOuterCircleRadius ?? 70, // Outer circle size
        width: captureOuterCircleRadius ?? 70, // Outer circle size
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3, strokeAlign: BorderSide.strokeAlignInside),
        ),
        child: Center(
          child: Container(
            height: captureInnerCircleRadius ?? 59, // Inner circle size
            width: captureInnerCircleRadius ?? 59, // Inner circle size
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white, // Inner circle color
            ),
          ),
        ),
      ),
    );
  }
}
