import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../core/enums.dart';

import '../../logic/document_camera_logic.dart';
import 'captured_image_preview.dart';
import 'frame_capture_animation.dart';

/// A layer that handles the camera preview and capture animations.
class DocumentCameraPreviewLayer extends StatelessWidget {
  /// The logic class instance.
  final DocumentCameraLogic logic;

  /// Border radius for the frame.
  final double borderRadius;

  /// Border radius for the inner corners of the frame.
  final double innerCornerBorderRadius;

  /// Duration for the capturing animation (optional).
  final Duration? capturingAnimationDuration;

  /// Color for the capturing animation (optional).
  final Color? capturingAnimationColor;

  /// Curve for the capturing animation (optional).
  final Curve? capturingAnimationCurve;

  /// Controls which UI elements are rendered.
  final DocumentCameraUIMode uiMode;

  const DocumentCameraPreviewLayer({
    super.key,
    required this.logic,
    required this.borderRadius,
    required this.innerCornerBorderRadius,
    this.capturingAnimationDuration,
    this.capturingAnimationColor,
    this.capturingAnimationCurve,
    required this.uiMode,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: logic.isInitializedNotifier,
      builder: (context, isInitialized, child) {
        if (!isInitialized) return const SizedBox.shrink();

        return Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview
            if (logic.controller.cameraController != null)
              CameraPreview(logic.controller.cameraController!),

            // Captured image preview
            CapturedImagePreview(
              capturedImageNotifier: logic.capturedImageNotifier,
              frameWidth: logic.updatedFrameWidth,
              frameHeight: logic.updatedFrameHeight,
              borderRadius: borderRadius,
              innerCornerBorderRadius: innerCornerBorderRadius,
              uiMode: uiMode,
            ),

            // Frame capture animation
            ValueListenableBuilder<bool>(
              valueListenable: logic.isLoadingNotifier,
              child: FrameCaptureAnimation(
                frameWidth: logic.updatedFrameWidth,
                frameHeight: logic.updatedFrameHeight,
                animationDuration: capturingAnimationDuration,
                animationColor: capturingAnimationColor,
                curve: capturingAnimationCurve,
                uiMode: uiMode,
              ),
              builder: (context, isLoading, child) {
                return isLoading ? child! : const SizedBox.shrink();
              },
            ),
          ],
        );
      },
    );
  }
}
