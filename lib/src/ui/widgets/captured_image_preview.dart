import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/app_constants.dart';

class CapturedImagePreview extends StatelessWidget {
  final ValueNotifier<String> capturedImageNotifier;
  final double frameWidth;
  final double frameHeight;

  final double borderRadius;
  const CapturedImagePreview({
    super.key,
    required this.capturedImageNotifier,
    required this.frameWidth,
    required this.frameHeight,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: capturedImageNotifier,
      builder: (context, imagePath, child) {
        if (imagePath.isEmpty) {
          return const SizedBox.shrink();
        }
        return Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: frameWidth,
            height: frameHeight + AppConstants.bottomFrameContainerHeight,
            child: Stack(
              children: [
                Positioned(
                  top: 3,
                  left: 3,
                  right: 3,
                  child: Container(
                    width: frameWidth,
                    height:
                        frameHeight + AppConstants.bottomFrameContainerHeight,
                    decoration: BoxDecoration(
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
