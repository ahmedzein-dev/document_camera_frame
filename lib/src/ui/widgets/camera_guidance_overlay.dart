import 'package:flutter/material.dart';

import '../../core/document_camera_style.dart';
import '../../core/enums.dart';

/// Top overlay that shows:
/// - a static instruction (front/back)
/// - an optional live detection status (e.g. "Move closer")
class CameraGuidanceOverlay extends StatelessWidget {
  final ValueNotifier<DocumentSide> currentSideNotifier;
  final ValueNotifier<String?> detectionStatusNotifier;
  final DocumentCameraInstructionStyle instructionStyle;

  /// Absolute `top` for the overlay `Positioned`.
  final double top;

  final bool showDetectionStatusText;

  const CameraGuidanceOverlay({
    super.key,
    required this.currentSideNotifier,
    required this.detectionStatusNotifier,
    required this.instructionStyle,
    required this.top,
    this.showDetectionStatusText = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool showInstruction = instructionStyle.showInstructionText;
    final bool showStatus = showDetectionStatusText;

    if (!showInstruction && !showStatus) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showInstruction)
            _InstructionBanner(
              currentSideNotifier: currentSideNotifier,
              instructionStyle: instructionStyle,
            ),
          if (showStatus)
            _DetectionStatusBanner(
              detectionStatusNotifier: detectionStatusNotifier,
              instructionStyle: instructionStyle,
            ),
        ],
      ),
    );
  }
}

class _InstructionBanner extends StatelessWidget {
  final ValueNotifier<DocumentSide> currentSideNotifier;
  final DocumentCameraInstructionStyle instructionStyle;

  const _InstructionBanner({
    required this.currentSideNotifier,
    required this.instructionStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DocumentSide>(
      valueListenable: currentSideNotifier,
      builder: (context, currentSide, child) {
        final instruction = currentSide == DocumentSide.front
            ? (instructionStyle.frontSideInstruction ??
                  'Position the front side of your document within the frame')
            : (instructionStyle.backSideInstruction ??
                  'Now position the back side of your document within the frame');

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha((0.6 * 255).toInt()),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            instruction,
            style:
                instructionStyle.instructionTextStyle ??
                const TextStyle(color: Colors.white, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}

class _DetectionStatusBanner extends StatelessWidget {
  final ValueNotifier<String?> detectionStatusNotifier;
  final DocumentCameraInstructionStyle instructionStyle;

  const _DetectionStatusBanner({
    required this.detectionStatusNotifier,
    required this.instructionStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: detectionStatusNotifier,
      builder: (context, status, child) {
        if (status == null || status.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Text(
            status,
            style:
                instructionStyle.instructionTextStyle ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
