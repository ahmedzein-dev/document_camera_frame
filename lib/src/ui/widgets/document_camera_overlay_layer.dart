import 'package:flutter/material.dart';
import 'package:document_camera_frame/document_camera_frame.dart';
import 'package:document_camera_frame/src/core/context_extensions.dart';

import '../../core/app_constants.dart';
import '../../logic/document_camera_logic.dart';
import 'camera_guidance_overlay.dart';
import 'corner_box.dart';

/// A layer that handles all overlays, instructions, and action buttons.
///
/// Visibility table for each [DocumentCameraUIMode]:
///
/// | Feature                    | default | minimal | overlay | kiosk | textExtract |
/// |----------------------------|---------|---------|---------|-------|-------------|
/// | Dark cutout overlay        | ✅      | ❌      | ❌      | ✅    | ✅           |
/// | Frame border + corners     | ✅      | ❌      | ✅      | ✅    | ✅           |
/// | Bottom frame container     | ✅      | ❌      | ✅      | ✅    | ✅           |
/// | Progress bar               | ✅      | ❌      | ❌      | ✅    | ✅           |
/// | Guidance / instruction     | ✅      | ❌      | ❌      | ✅    | ✅           |
/// | Screen title               | ✅      | ❌      | ✅      | ✅    | ✅           |
/// | Side indicator (dots)      | ✅      | ❌      | ❌      | ✅    | ✅           |
/// | Capture button (circle)    | ✅      | ✅      | ✅      | ❌    | ✅           |
/// | Auto-capture trigger       | ✅      | ❌      | ✅      | ✅    | ✅           |
/// | On-device OCR (default)    | ❌      | ❌      | ❌      | ❌    | ✅           |

class DocumentCameraOverlayLayer extends StatelessWidget {
  final DocumentCameraLogic logic;
  final DocumentCameraFrameStyle frameStyle;
  final DocumentCameraAnimationStyle animationStyle;
  final String? bottomHintText;
  final Widget? sideInfoOverlay;
  final Widget? bottomFrameContainerChild;
  final DocumentCameraSideIndicatorStyle sideIndicatorStyle;
  final DocumentCameraProgressStyle progressStyle;
  final Animation<double>? progressAnimation;
  final bool showDetectionStatusText;

  /// Whether the side indicator (and progress bar) should be shown.
  /// Resolved by the package based on [uiMode]; false for `minimal` and `overlay`.
  final bool showSideIndicator;

  /// Whether the static instruction text should be shown.
  /// Resolved by the package based on [uiMode]; false for `minimal` and `overlay`.
  final bool showInstruction;

  /// Whether the screen title should be shown.
  /// Resolved by the package from [DocumentCameraTitleStyle.showScreenTitle]
  /// and [uiMode]; always false for `minimal` and `camScanner`.
  final bool showScreenTitle;

  final DocumentCameraInstructionStyle instructionStyle;
  final DocumentCameraTitleStyle titleStyle;
  final bool showCloseButton;
  final DocumentCameraButtonStyle buttonStyle;

  /// Controls which UI elements are rendered.
  final DocumentCameraUIMode uiMode;

  const DocumentCameraOverlayLayer({
    super.key,
    required this.logic,
    required this.frameStyle,
    required this.animationStyle,
    required this.bottomHintText,
    required this.sideInfoOverlay,
    this.bottomFrameContainerChild,
    required this.sideIndicatorStyle,
    required this.progressStyle,
    required this.progressAnimation,
    required this.showDetectionStatusText,
    this.showSideIndicator = false,
    this.showInstruction = true,
    this.showScreenTitle = true,
    required this.instructionStyle,
    required this.titleStyle,
    required this.showCloseButton,
    required this.buttonStyle,
    this.uiMode = DocumentCameraUIMode.defaultMode,
  });

  // ── Convenience helpers ────────────────────────────────────────────────────

  bool get _isMinimal => uiMode == DocumentCameraUIMode.minimal;

  /// `true` for all modes that render the standard frame + overlays group.
  bool get _isFullUi => !_isMinimal;

  /// Whether the dark cutout overlay should be painted.
  bool get _showDarkOverlay => uiMode != DocumentCameraUIMode.overlay;

  /// Whether only the capture button (circle + switcher) should be hidden.
  /// Navigation, retake, and save buttons remain visible.
  bool get _hideCaptureButton => uiMode == DocumentCameraUIMode.kiosk;

  // ── Sub-builders ───────────────────────────────────────────────────────────

  Widget _buildProgressIndicator(BuildContext context) {
    if (progressAnimation == null) return const SizedBox.shrink();
    return Container(
      height: progressStyle.progressIndicatorHeight,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: progressAnimation!,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: progressAnimation!.value,
            backgroundColor: Colors.white.withAlpha((0.3 * 255).toInt()),
            valueColor: AlwaysStoppedAnimation<Color>(
              progressStyle.progressIndicatorColor ??
                  Theme.of(context).primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentTitle() {
    return ValueListenableBuilder<DocumentSide>(
      valueListenable: logic.currentSideNotifier,
      builder: (context, currentSide, child) {
        // title overrides per-side titles when set
        if (titleStyle.title != null) {
          return titleStyle.title!;
        }
        return currentSide == DocumentSide.front
            ? titleStyle.frontSideTitle
            : titleStyle.backSideTitle;
      },
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Full-UI elements (all modes except minimal) ────────────────────
        if (_isFullUi)
          ValueListenableBuilder<bool>(
            valueListenable: logic.isDocumentAlignedNotifier,
            builder: (context, isAligned, child) {
              return TwoSidedAnimatedFrame(
                frameHeight: logic.updatedFrameHeight,
                frameWidth: logic.updatedFrameWidth,
                outerFrameBorderRadius: frameStyle.outerFrameBorderRadius,
                innerCornerBorderRadius: frameStyle.innerCornerBorderRadius,
                frameFlipDuration: animationStyle.frameFlipDuration,
                frameFlipCurve: animationStyle.frameFlipCurve,
                border: frameStyle.frameBorder,
                currentSideNotifier: logic.currentSideNotifier,
                isDocumentAligned: isAligned,
                showDarkOverlay: _showDarkOverlay,
              );
            },
          ),

        if (_isFullUi)
          TwoSidedBottomFrameContainer(
            width: logic.updatedFrameWidth,
            height: logic.updatedFrameHeight,
            borderRadius: frameStyle.outerFrameBorderRadius,
            currentSideNotifier: logic.currentSideNotifier,
            documentDataNotifier: logic.documentDataNotifier,
            bottomFrameContainerChild: bottomFrameContainerChild,
            bottomHintText: bottomHintText,
            sideInfoOverlay: sideInfoOverlay,
          ),

        if (_isFullUi && logic.requireBothSides && showSideIndicator)
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 0,
            right: 0,
            child: _buildProgressIndicator(context),
          ),

        if (_isFullUi)
          CameraGuidanceOverlay(
            showDetectionStatusText: showDetectionStatusText,
            currentSideNotifier: logic.currentSideNotifier,
            detectionStatusNotifier: logic.detectionStatusNotifier,
            instructionStyle: instructionStyle.copyWith(
              showInstructionText:
                  showInstruction && instructionStyle.showInstructionText,
            ),
            top: logic.requireBothSides && showSideIndicator
                ? MediaQuery.of(context).padding.top + 120
                : MediaQuery.of(context).padding.top + 60,
            frameHeight: logic.updatedFrameHeight,
          ),

        // Screen title — only rendered when showScreenTitle is true
        if (_isFullUi && showScreenTitle)
          ScreenTitle(
            title: _buildCurrentTitle(),
            showCloseButton: showCloseButton,
            screenTitleAlignment: titleStyle.screenTitleAlignment,
            screenTitlePadding: titleStyle.screenTitlePadding,
          ),

        if (_isFullUi && logic.requireBothSides && showSideIndicator)
          SideIndicator(
            currentSideNotifier: logic.currentSideNotifier,
            documentDataNotifier: logic.documentDataNotifier,
            rightPosition: sideIndicatorStyle.rightPosition,
            topPosition: sideIndicatorStyle.topPosition,
            backgroundColor:
                sideIndicatorStyle.sideIndicatorBackgroundColor ??
                Colors.black.withAlpha((0.8 * 255).toInt()),
            borderColor: sideIndicatorStyle.sideIndicatorBorderColor,
            activeColor:
                sideIndicatorStyle.sideIndicatorActiveColor ?? Colors.blue,
            inactiveColor:
                sideIndicatorStyle.sideIndicatorInactiveColor ?? Colors.grey,
            completedColor:
                sideIndicatorStyle.sideIndicatorCompletedColor ?? Colors.green,
            textStyle: sideIndicatorStyle.sideIndicatorTextStyle,
          ),

        // ── Minimal-only elements ──────────────────────────────────────────
        if (_isMinimal)
          ValueListenableBuilder<bool>(
            valueListenable: logic.isDocumentAlignedNotifier,
            builder: (context, isAligned, child) {
              final top = (1.sh(context) - logic.updatedFrameHeight) / 2;
              final bottom = top + logic.updatedFrameHeight;
              final left = (1.sw(context) - logic.updatedFrameWidth) / 2;
              final right = left + logic.updatedFrameWidth;

              return Stack(
                children: [
                  Positioned(
                    top: top,
                    left: left,
                    child: CornerBox(
                      topLeft: true,
                      flipProgress: 0.0,
                      isDocumentAligned: isAligned,
                      innerCornerBorderRadius:
                          frameStyle.innerCornerBorderRadius,
                    ),
                  ),
                  Positioned(
                    top: top,
                    right: (1.sw(context) - right),
                    child: CornerBox(
                      topRight: true,
                      flipProgress: 0.0,
                      isDocumentAligned: isAligned,
                      innerCornerBorderRadius:
                          frameStyle.innerCornerBorderRadius,
                    ),
                  ),
                  Positioned(
                    top: bottom - 16,
                    left: left,
                    child: CornerBox(
                      bottomLeft: true,
                      flipProgress: 0.0,
                      isDocumentAligned: isAligned,
                      innerCornerBorderRadius:
                          frameStyle.innerCornerBorderRadius,
                    ),
                  ),
                  Positioned(
                    top: bottom - 16,
                    right: (1.sw(context) - right),
                    child: CornerBox(
                      bottomRight: true,
                      flipProgress: 0.0,
                      isDocumentAligned: isAligned,
                      innerCornerBorderRadius:
                          frameStyle.innerCornerBorderRadius,
                    ),
                  ),
                ],
              );
            },
          ),

        // ── Always visible — capture button hidden in kiosk mode ─────────
        TwoSidedActionButtons(
          captureOuterCircleRadius: buttonStyle.captureOuterCircleRadius,
          captureInnerCircleRadius: buttonStyle.captureInnerCircleRadius,
          captureButtonAlignment: buttonStyle.captureButtonAlignment,
          captureButtonPadding: buttonStyle.captureButtonPadding,
          captureButtonText: buttonStyle.captureButtonText,
          captureFrontButtonText: buttonStyle.captureFrontButtonText,
          captureBackButtonText: buttonStyle.captureBackButtonText,
          saveButtonText: buttonStyle.saveButtonText,
          nextButtonText: buttonStyle.nextButtonText,
          previousButtonText: buttonStyle.previousButtonText,
          retakeButtonText: buttonStyle.retakeButtonText,
          captureButtonTextStyle: buttonStyle.captureButtonTextStyle,
          actionButtonTextStyle: buttonStyle.actionButtonTextStyle,
          retakeButtonTextStyle: buttonStyle.retakeButtonTextStyle,
          captureButtonStyle: buttonStyle.captureButtonStyle,
          actionButtonStyle: buttonStyle.actionButtonStyle,
          retakeButtonStyle: buttonStyle.retakeButtonStyle,
          actionButtonPadding: buttonStyle.actionButtonPadding,
          actionButtonWidth: buttonStyle.actionButtonWidth,
          actionButtonHeight: buttonStyle.actionButtonHeight,
          captureButtonWidth: buttonStyle.captureButtonWidth,
          captureButtonHeight: buttonStyle.captureButtonHeight,
          capturedImageNotifier: logic.capturedImageNotifier,
          isLoadingNotifier: logic.isLoadingNotifier,
          currentSideNotifier: logic.currentSideNotifier,
          documentDataNotifier: logic.documentDataNotifier,
          frameWidth: logic.updatedFrameWidth,
          frameHeight: logic.updatedFrameHeight,
          bottomFrameContainerHeight: AppConstants.bottomFrameContainerHeight,
          controller: logic.controller,
          onManualCapture: logic.captureAndHandleImageUnified,
          onSave: logic.handleSave,
          onRetake: logic.handleRetake,
          onNext: logic.switchToBackSide,
          onPrevious: logic.switchToFrontSide,
          onCameraSwitched: logic.switchCamera,
          requireBothSides: logic.requireBothSides,
          hideCaptureButton: _hideCaptureButton,
        ),
      ],
    );
  }
}
