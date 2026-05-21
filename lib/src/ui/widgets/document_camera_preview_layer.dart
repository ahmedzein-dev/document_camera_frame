import 'dart:math' show max;

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
            // Camera preview — cover-fit so the sensor aspect is preserved
            // (no horizontal/vertical squeeze). One axis is scaled up to fill
            // the screen; overflow on the other axis is clipped.
            if (logic.controller.cameraController != null)
              _CoverFitCameraPreview(
                controller: logic.controller.cameraController!,
              ),

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

/// Workaround for the stretched/squeezed `CameraPreview` when the camera
/// sensor aspect ratio doesn't match the screen.
///
/// Known upstream issue (camera plugin): https://github.com/flutter/flutter/issues/180499
/// Solution adapted from: https://stackoverflow.com/questions/49946153/flutter-camera-appears-stretched
class _CoverFitCameraPreview extends StatelessWidget {
  final CameraController controller;

  const _CoverFitCameraPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final previewSize = controller.value.previewSize;
    if (previewSize == null) return const SizedBox.shrink();

    // CameraPreview applies the portrait aspect ratio (1/r) in portrait mode
    // and the landscape aspect ratio (r) in landscape mode internally.
    // Compute the natural layout size it takes under loose constraints, then
    // derive the cover scale: max(screenW / nativeW, screenH / nativeH).
    final bool isPortrait = size.width < size.height;
    final double cameraAspect = isPortrait
        ? previewSize.height / previewSize.width // portrait: nativeH/nativeW ≈ 0.75 for 4:3
        : previewSize.width / previewSize.height; // landscape: nativeW/nativeH ≈ 1.33 for 4:3

    // Natural size CameraPreview occupies when given loose constraints at screen size
    final double nativeW, nativeH;
    if (size.width <= size.height * cameraAspect) {
      nativeW = size.width;
      nativeH = size.width / cameraAspect;
    } else {
      nativeH = size.height;
      nativeW = size.height * cameraAspect;
    }

    final double scale = max(size.width / nativeW, size.height / nativeH);

    return ClipRect(
      child: Transform.scale(
        scale: scale,
        child: Center(child: CameraPreview(controller)),
      ),
    );
  }
}
