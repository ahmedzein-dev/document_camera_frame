import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/app_constants.dart';
import '../../core/enums.dart';

class CapturedImagePreview extends StatelessWidget {
  final ValueNotifier<String> capturedImageNotifier;
  final double frameWidth;
  final double frameHeight;
  final DocumentCameraUIMode uiMode;

  final double borderRadius;
  final double innerCornerBorderRadius;
  const CapturedImagePreview({
    super.key,
    required this.capturedImageNotifier,
    required this.frameWidth,
    required this.frameHeight,
    required this.borderRadius,
    required this.innerCornerBorderRadius,
    required this.uiMode,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: capturedImageNotifier,
      builder: (context, imagePath, child) {
        if (imagePath.isEmpty) {
          return const SizedBox.shrink();
        }
        final double height = uiMode == DocumentCameraUIMode.minimal
            ? frameHeight
            : frameHeight + AppConstants.bottomFrameContainerHeight;

        final double cornerBorderRadius = uiMode == DocumentCameraUIMode.minimal
            ? innerCornerBorderRadius
            : 0;

        return Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: frameWidth,
            height: height,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: frameWidth,
                    height: height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(cornerBorderRadius),
                      image: DecorationImage(
                        image: FileImage(File(imagePath)),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
