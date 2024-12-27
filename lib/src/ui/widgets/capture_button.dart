import 'package:flutter/material.dart';

class CaptureButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double? width;
  final double? height;

  const CaptureButton({
    required this.onPressed,
    this.width,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: height, // Outer circle size
        width: width, // Outer circle size
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3, strokeAlign: BorderSide.strokeAlignInside),
        ),
        child: Center(
          child: Container(
            height: 59, // Inner circle size
            width: 59, // Inner circle size
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
