import 'package:flutter/material.dart';
import 'package:document_camera_frame/document_camera_frame.dart';

/// A widget that displays the current side indicator for two-sided document capture
class SideIndicator extends StatelessWidget {
  final ValueNotifier<DocumentSide> currentSideNotifier;
  final ValueNotifier<DocumentCaptureData> documentDataNotifier;
  final double? topPosition;
  final double? rightPosition;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? completedColor;
  final TextStyle? textStyle;

  const SideIndicator({
    super.key,
    required this.currentSideNotifier,
    required this.documentDataNotifier,
    this.topPosition,
    this.rightPosition,
    this.backgroundColor,
    this.borderColor,
    this.activeColor,
    this.inactiveColor,
    this.completedColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DocumentSide>(
      valueListenable: currentSideNotifier,
      builder: (context, currentSide, child) {
        return ValueListenableBuilder<DocumentCaptureData>(
          valueListenable: documentDataNotifier,
          builder: (context, documentData, child) {
            return Positioned(
              top: topPosition ?? (MediaQuery.of(context).padding.top + 80),
              right: rightPosition ?? 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      backgroundColor ??
                      Colors.black.withAlpha((0.7 * 255).toInt()),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        borderColor ??
                        Colors.white.withAlpha((0.3 * 255).toInt()),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Front side indicator
                    _buildSideDot(
                      isActive: currentSide == DocumentSide.front,
                      isCompleted:
                          documentData.frontImagePath != null &&
                          documentData.frontImagePath!.isNotEmpty,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Front',
                      style:
                          textStyle?.copyWith(
                            color: currentSide == DocumentSide.front
                                ? (activeColor ?? Colors.white)
                                : (inactiveColor ?? Colors.grey),
                          ) ??
                          TextStyle(
                            color: currentSide == DocumentSide.front
                                ? (activeColor ?? Colors.white)
                                : (inactiveColor ?? Colors.grey),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(width: 12),
                    // Back side indicator
                    _buildSideDot(
                      isActive: currentSide == DocumentSide.back,
                      isCompleted:
                          documentData.backImagePath != null &&
                          documentData.backImagePath!.isNotEmpty,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Back',
                      style:
                          textStyle?.copyWith(
                            color: currentSide == DocumentSide.back
                                ? (activeColor ?? Colors.white)
                                : (inactiveColor ?? Colors.grey),
                          ) ??
                          TextStyle(
                            color: currentSide == DocumentSide.back
                                ? (activeColor ?? Colors.white)
                                : (inactiveColor ?? Colors.grey),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Builds a colored dot to indicate the state of each side
  Widget _buildSideDot({required bool isActive, required bool isCompleted}) {
    Color dotColor;
    if (isCompleted) {
      dotColor = completedColor ?? Colors.green;
    } else if (isActive) {
      dotColor = activeColor ?? Colors.white;
    } else {
      dotColor = inactiveColor ?? Colors.grey;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
    );
  }
}
