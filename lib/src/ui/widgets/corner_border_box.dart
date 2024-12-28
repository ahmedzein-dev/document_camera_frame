import 'package:flutter/material.dart';

class CornerBorderBox extends StatelessWidget {
  final double width;
  final double height;
  final double cornerSize; // Unified size for corner borders
  final Color borderColor;
  final double cornerRadius;
  final double top;
  final double bottom;

  const CornerBorderBox({
    super.key,
    required this.width,
    required this.height,
    required this.top,
    required this.bottom,
    this.cornerSize = 12.0,
    this.borderColor = Colors.white,
    this.cornerRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // Top-left corner
          Positioned(
            top: top,
            left: 0,
            child: Container(
              width: cornerSize,
              height: cornerSize,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white, width: 2),
                  left: BorderSide(color: Colors.white, width: 2),
                  right: BorderSide.none,
                  bottom: BorderSide.none,
                ),
                borderRadius:
                    BorderRadius.only(topLeft: Radius.circular(cornerRadius)),
              ),
            ),
          ),

          // Top-right corner
          Positioned(
            top: top,
            right: 0,
            child: Container(
              width: cornerSize,
              height: cornerSize,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white, width: 2),
                  right: BorderSide(color: Colors.white, width: 2),
                  left: BorderSide.none,
                  bottom: BorderSide.none,
                ),
                borderRadius:
                    BorderRadius.only(topRight: Radius.circular(cornerRadius)),
              ),
            ),
          ),

          // Bottom-left corner
          Positioned(
            bottom: bottom,
            left: 0,
            child: Container(
              width: cornerSize,
              height: cornerSize,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide.none,
                  right: BorderSide.none,
                  left: BorderSide(color: Colors.white, width: 2),
                  bottom: BorderSide(color: Colors.white, width: 2),
                ),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(cornerRadius)),
              ),
            ),
          ),

          // Bottom-right corner
          Positioned(
            bottom: bottom,
            right: 0,
            child: Container(
              width: cornerSize,
              height: cornerSize,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide.none,
                  left: BorderSide.none,
                  right: BorderSide(color: Colors.white, width: 2),
                  bottom: BorderSide(color: Colors.white, width: 2),
                ),
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(cornerRadius)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
