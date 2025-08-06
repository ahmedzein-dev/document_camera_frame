import 'package:flutter/material.dart';
import '../../../document_camera_frame.dart';
import 'camera_switcher.dart';
import 'capture_button.dart';

class TwoSidedActionButtons extends StatelessWidget {
  final double? captureOuterCircleRadius;
  final double? captureInnerCircleRadius;
  final Alignment? captureButtonAlignment;
  final EdgeInsets? captureButtonPadding;
  final EdgeInsets? actionButtonPadding;

  // Button text properties
  final String? captureButtonText;
  final String? captureFrontButtonText;
  final String? captureBackButtonText;
  final String? saveButtonText;
  final String? nextButtonText;
  final String? previousButtonText;
  final String? retakeButtonText;

  // Button styling
  final TextStyle? captureButtonTextStyle;
  final TextStyle? actionButtonTextStyle;
  final TextStyle? retakeButtonTextStyle;
  final ButtonStyle? captureButtonStyle;
  final ButtonStyle? actionButtonStyle;
  final ButtonStyle? retakeButtonStyle;

  // Button dimensions
  final double? actionButtonWidth;
  final double? actionButtonHeight;
  final double? captureButtonWidth;
  final double? captureButtonHeight;

  // State notifiers
  final ValueNotifier<String> capturedImageNotifier;
  final ValueNotifier<bool> isLoadingNotifier;
  final ValueNotifier<DocumentSide> currentSideNotifier;
  final ValueNotifier<DocumentCaptureData> documentDataNotifier;

  // Frame properties
  final double frameWidth;
  final double frameHeight;
  final double bottomFrameContainerHeight;

  // Controller
  final DocumentCameraController controller;

  // Callbacks
  final Future<void> Function(
    BuildContext context,
    double frameWidth,
    double frameHeight,
    int screenWidth,
    int screenHeight,
  )
  onManualCapture;
  final Function() onSave;
  final VoidCallback? onRetake;
  final Function() onNext;
  final Function() onPrevious;
  final Function() onCameraSwitched;

  // Configuration
  final bool requireBothSides;

  const TwoSidedActionButtons({
    super.key,
    this.captureOuterCircleRadius,
    this.captureInnerCircleRadius,
    this.captureButtonAlignment,
    this.captureButtonPadding,
    this.actionButtonPadding,
    this.captureButtonText,
    this.captureFrontButtonText,
    this.captureBackButtonText,
    this.saveButtonText,
    this.nextButtonText,
    this.previousButtonText,
    this.retakeButtonText,
    this.captureButtonTextStyle,
    this.actionButtonTextStyle,
    this.retakeButtonTextStyle,
    this.captureButtonStyle,
    this.actionButtonStyle,
    this.retakeButtonStyle,
    this.actionButtonWidth,
    this.actionButtonHeight,
    this.captureButtonWidth,
    this.captureButtonHeight,
    required this.capturedImageNotifier,
    required this.isLoadingNotifier,
    required this.currentSideNotifier,
    required this.documentDataNotifier,
    required this.frameWidth,
    required this.frameHeight,
    required this.bottomFrameContainerHeight,
    required this.controller,
    required this.onManualCapture,
    required this.onSave,
    this.onRetake,
    required this.onNext,
    required this.onPrevious,
    required this.onCameraSwitched,
    this.requireBothSides = true,
  });

  void _retakeImage() {
    onRetake?.call();
    controller.retakeImage();
    capturedImageNotifier.value = controller.imagePath;
  }

  bool _canSave() {
    final data = documentDataNotifier.value;
    if (!requireBothSides) {
      return data.frontImagePath?.isNotEmpty == true;
    }
    return data.isCompleteFor(requireBothSides: requireBothSides);
  }

  bool _showNextButton() {
    return requireBothSides &&
        currentSideNotifier.value == DocumentSide.front &&
        documentDataNotifier.value.frontImagePath?.isNotEmpty == true;
  }

  bool _showPreviousButton() {
    return requireBothSides && currentSideNotifier.value == DocumentSide.back;
  }

  // Helper method to count visible action buttons
  int _getVisibleButtonCount() {
    int count = 1; // Retake button is always shown
    if (_showNextButton()) count++;
    if (_showPreviousButton()) count++;
    if (_canSave()) count++;
    return count;
  }

  // Helper method to get dynamic button height based on button count
  double? _getDynamicButtonHeight() {
    final buttonCount = _getVisibleButtonCount();

    // Use smaller height when there are 3 or more buttons
    if (buttonCount >= 3) {
      return actionButtonHeight ?? 45.0; // Smaller height
    } else {
      return actionButtonHeight; // Original height
    }
  }

  // Helper method to get dynamic padding based on button count
  EdgeInsets _getDynamicPadding() {
    final buttonCount = _getVisibleButtonCount();

    // Use smaller padding when there are 3 or more buttons
    if (buttonCount >= 3) {
      return actionButtonPadding ?? const EdgeInsets.only(bottom: 12.0);
    } else {
      return actionButtonPadding ?? const EdgeInsets.only(bottom: 12.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: captureButtonAlignment ?? Alignment.center,
        child: ValueListenableBuilder<String>(
          valueListenable: capturedImageNotifier,
          builder: (context, imagePath, child) {
            return ValueListenableBuilder<DocumentSide>(
              valueListenable: currentSideNotifier,
              builder: (context, currentSide, child) {
                return ValueListenableBuilder<DocumentCaptureData>(
                  valueListenable: documentDataNotifier,
                  builder: (context, documentData, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (imagePath.isEmpty)
                          // Capture mode with camera switcher like original ActionButtons
                          Padding(
                            padding:
                                captureButtonPadding ??
                                const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 32.0,
                                ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(width: 45, height: 45),
                                ValueListenableBuilder<bool>(
                                  valueListenable: isLoadingNotifier,
                                  builder: (context, isLoading, child) {
                                    return CaptureButton(
                                      onPressed: () async {
                                        if (isLoading) return;
                                        await onManualCapture(
                                          context,
                                          frameWidth,
                                          frameHeight +
                                              bottomFrameContainerHeight,
                                          1.sw(context).toInt(),
                                          1.sh(context).toInt(),
                                        );
                                      },
                                      captureInnerCircleRadius:
                                          captureInnerCircleRadius,
                                      captureOuterCircleRadius:
                                          captureOuterCircleRadius,
                                    );
                                  },
                                ),

                                // Camera Switch Button - same as original ActionButtons
                                CameraSwitcher(onTap: onCameraSwitched),
                              ],
                            ),
                          )
                        else ...[
                          // Action buttons after capture
                          if (_showNextButton())
                            Padding(
                              padding: _getDynamicPadding(),
                              child: ActionButton(
                                text: nextButtonText ?? 'Next Side',
                                onPressed: onNext,
                                style: actionButtonStyle,
                                textStyle:
                                    actionButtonTextStyle ??
                                    const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                width: actionButtonWidth,
                                height: _getDynamicButtonHeight(),
                              ),
                            ),

                          if (_showPreviousButton())
                            Padding(
                              padding: _getDynamicPadding(),
                              child: ActionButton(
                                text: previousButtonText ?? 'Previous Side',
                                onPressed: onPrevious,
                                style:
                                    actionButtonStyle ??
                                    ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      side: const BorderSide(
                                        width: 1,
                                        color: Colors.white,
                                      ),
                                    ),
                                textStyle:
                                    actionButtonTextStyle ??
                                    const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                width: actionButtonWidth,
                                height: _getDynamicButtonHeight(),
                              ),
                            ),

                          if (_canSave())
                            Padding(
                              padding: _getDynamicPadding(),
                              child: ActionButton(
                                text: saveButtonText ?? 'Use this photo',
                                onPressed: onSave,
                                style: actionButtonStyle,
                                textStyle:
                                    actionButtonTextStyle ??
                                    const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                width: actionButtonWidth,
                                height: _getDynamicButtonHeight(),
                              ),
                            ),

                          Padding(
                            padding: _getDynamicPadding(),
                            child: ActionButton(
                              text: retakeButtonText ?? 'Retake photo',
                              onPressed: _retakeImage,
                              style:
                                  retakeButtonStyle ??
                                  ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    side: const BorderSide(
                                      width: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                              textStyle:
                                  retakeButtonTextStyle ??
                                  const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                              width: actionButtonWidth,
                              height: _getDynamicButtonHeight(),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
